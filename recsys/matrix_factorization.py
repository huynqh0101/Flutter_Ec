import torch
import torch.nn as nn
import torch.optim as optim
import pytorch_lightning as pl
from torch.utils.data import Dataset
from typing import Dict
import pandas as pd
import json

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


class RecsysDataset(Dataset):
    """
    A custom PyTorch Dataset for recommendation systems,
    supporting flexible column naming and mapping of IDs to indices.
    """
    def __init__(
            self,
            json_path: str,
            user_col: str = 'user_amazon_id',
            item_col: str = 'item_amazon_id',
            rating_col: str = 'rating'
    ):
        """
        Initialize the dataset by loading data and creating ID mappings.

        Args:
            json_path (str): Path to the JSON file containing rating data
            user_col (str, optional): Column name for user IDs
            item_col (str, optional): Column name for item IDs
            rating_col (str, optional): Column name for ratings
        """
        # Convert to DataFrame and select required columns
        self.df = self.getDF(json_path)

        # Validate required columns exist
        required_cols = [user_col, item_col, rating_col]
        missing_cols = [col for col in required_cols if col not in self.df.columns]
        if missing_cols:
            raise ValueError(f"Missing columns: {missing_cols}")

        self.df = self.df[[user_col, item_col, rating_col]]

        print(self.df.shape)

        # Create mappings for users and items
        self.user_mapping = self._create_mapping(self.df[user_col])
        self.item_mapping = self._create_mapping(self.df[item_col])

        # Store column names
        self.user_col = user_col
        self.item_col = item_col
        self.rating_col = rating_col

    def parse(self, path):
        """Parse a JSON file and yield each line as a Python dict."""
        with open(path, 'r', encoding='utf-8') as f:  # Mở tệp JSON thông thường
            for line in f:
                yield json.loads(line)  # Sử dụng json.loads() để chuyển chuỗi JSON thành đối tượng Python

    def getDF(self, path):
        """Convert JSON file to a pandas DataFrame."""
        data = []
        for d in self.parse(path):
            data.append(d)  # Thêm mỗi dict vào danh sách

        # Chuyển đổi danh sách các dict thành DataFrame
        return pd.DataFrame(data)

    def _create_mapping(self, series: pd.Series) -> Dict[str, int]:
        """
        Create a mapping from unique IDs to consecutive indices.

        Args:
            series (pd.Series): Column containing original IDs

        Returns:
            Dict[str, int]: Mapping from original ID to index
        """
        unique_ids = series.unique()
        return {id: idx for idx, id in enumerate(unique_ids)}

    def __len__(self) -> int:
        """
        Get the total number of samples in the dataset.

        Returns:
            int: Number of samples
        """
        return len(self.df)

    def __getitem__(self, idx: int) -> Dict[str, torch.Tensor]:
        """
        Retrieve a single sample and convert IDs to indices.

        Args:
            idx (int): Index of the sample

        Returns:
            Dict[str, torch.Tensor]: Dictionary with user index, item index, and rating
        """
        row = self.df.iloc[idx]

        return dict(
            user=torch.tensor(self.user_mapping[row[self.user_col]], dtype=torch.long),
            item=torch.tensor(self.item_mapping[row[self.item_col]], dtype=torch.long),
            rating=torch.tensor(row[self.rating_col], dtype=torch.float)
        )

    def get_user_count(self) -> int:
        """
        Get the number of unique users.

        Returns:
            int: Number of unique users
        """
        return len(self.user_mapping)

    def get_item_count(self) -> int:
        """
        Get the number of unique items.

        Returns:
            int: Number of unique items
        """
        return len(self.item_mapping)

    def get_id_mappings(self) -> Dict[str, Dict[str, int]]:
        """
        Retrieve the ID mappings for users and items.

        Returns:
            Dict[str, Dict[str, int]]: Mappings of users and items
        """
        return {
            'user_mapping': self.user_mapping,
            'item_mapping': self.item_mapping
        }