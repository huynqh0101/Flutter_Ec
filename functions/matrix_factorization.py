import torch
import torch.nn as nn
import torch.optim as optim
import pytorch_lightning as pl

class MFLightning(pl.LightningModule):
    def __init__(
        self,
        n_users: int,
        n_items: int,
        n_factors: int = 100,
        reg: float = 1.0,
        lr: float = 0.01,
        min_rating: float = 0,
        max_rating: float = 5,
        init_mean: float = 0,
        init_std: float = 0.01,
        p = 0.5
    ):
        """
        PyTorch Lightning implementation of Kernel Matrix Factorization

        Args:
            n_users (int): Total number of users
            n_items (int): Total number of items
            n_factors (int): Number of latent factors
            reg (float): Regularization strength
            lr (float): Learning rate
            min_rating (float): Minimum possible rating
            max_rating (float): Maximum possible rating
            init_mean (float): Mean for parameter initialization
            init_std (float): Standard deviation for parameter initialization
        """
        super().__init__()
        self.save_hyperparameters()

        # Hyperparameters
        self.n_users = n_users
        self.n_items = n_items
        self.n_factors = n_factors
        self.reg = reg
        self.lr = lr
        self.min_rating = min_rating
        self.max_rating = max_rating
        self.p = p

        # User and item embeddings with biases
        self.user_embeddings = nn.Embedding(n_users, n_factors)
        self.item_embeddings = nn.Embedding(n_items, n_factors)

        self.user_biases = nn.Embedding(n_users, 1)
        self.item_biases = nn.Embedding(n_items, 1)

        self.score_net = torch.nn.Sequential(
            nn.BatchNorm1d(num_features=2*n_factors),
            nn.Linear(in_features=2*n_factors, out_features=128),  #
            nn.ReLU(),
            nn.BatchNorm1d(num_features=128),
            nn.Linear(in_features=128, out_features=64),
            nn.ReLU(),
            nn.Dropout(p=self.p),
            nn.Linear(in_features=64, out_features=1)
        )

        nn.init.normal_(self.user_embeddings.weight, mean=init_mean, std=0.1)
        nn.init.normal_(self.item_embeddings.weight, mean=init_mean, std=0.1)
        nn.init.zeros_(self.user_biases.weight)
        nn.init.zeros_(self.item_biases.weight)


    def forward(self, user_ids, item_ids):
        """
        Forward pass to get rating predictions

        Args:
            user_ids (torch.LongTensor): User indices
            item_ids (torch.LongTensor): Item indices

        Returns:
            torch.Tensor: Predicted ratings
        """

        user_features = self.user_embeddings(user_ids)
        item_features = self.item_embeddings(item_ids)

        user_bias = self.user_biases(user_ids).squeeze()
        item_bias = self.item_biases(item_ids).squeeze()

        x = torch.cat([user_features, item_features], dim=1)
        out = self.score_net(x).squeeze()

        return out + user_bias + item_bias

    def training_step(self, batch, batch_idx):
        """
        Training step for PyTorch Lightning

        Args:
            batch (tuple): Contains user_ids, item_ids, and ratings
            batch_idx (int): Batch index

        Returns:
            torch.Tensor: Loss value
        """
        user_ids, item_ids, ratings = batch['user'], batch['item'], batch['rating']
        predictions = self(user_ids, item_ids)

        # MSE Loss with L2 regularization
        mse_loss = nn.functional.mse_loss(predictions, ratings)
        rmse_loss = torch.sqrt(mse_loss)

        # L2 regularization
        l2_loss = (
            torch.norm(self.user_embeddings.weight) +
            torch.norm(self.item_embeddings.weight) +
            torch.norm(self.user_biases.weight) +
            torch.norm(self.item_biases.weight) +
            sum(torch.norm(param) for param in self.score_net.parameters())
        ) * self.reg

        total_loss = rmse_loss + l2_loss

        self.log('train_loss', total_loss, on_epoch=True, prog_bar=True, logger=True)
        return total_loss

    def validation_step(self, batch, batch_idx):
        """
        Validation step for PyTorch Lightning

        Args:
            batch (tuple): Contains user_ids, item_ids, and ratings
            batch_idx (int): Batch index

        Returns:
            dict: Validation loss and optional other metrics
        """
        user_ids, item_ids, ratings = batch['user'], batch['item'], batch['rating']
        predictions = self(user_ids, item_ids)

        # MSE Loss with L2 regularization
        mse_loss = nn.functional.mse_loss(predictions, ratings)
        rmse_loss = torch.sqrt(mse_loss)

        # L2 regularization
        l2_loss = (
            torch.norm(self.user_embeddings.weight) +
            torch.norm(self.item_embeddings.weight) +
            torch.norm(self.user_biases.weight) +
            torch.norm(self.item_biases.weight) +
            sum(torch.norm(param) for param in self.score_net.parameters())
        ) * self.reg

        total_loss = rmse_loss + l2_loss

        # Log validation loss
        self.log('val_loss', total_loss, on_epoch=True, prog_bar=True, logger=True)

        return {'val_loss': total_loss}

    def configure_optimizers(self):
        """
        Configure optimizer for PyTorch Lightning

        Returns:
            torch.optim.Optimizer: Adam optimizer
        """
        return optim.Adam(self.parameters(), lr=self.lr)