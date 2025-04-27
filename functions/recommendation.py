import torch
import copy
from torch import nn

def recommend_for_new_user(model, dataset, user_id, ratings, top_k=10):
    """
    Generate recommendations for a new user from Firebase.

    Args:
        model: Trained recommendation model
        dataset: Original recommendation dataset
        user_id: Unique user identifier
        ratings: List of (item_id, rating) tuples
        top_k: Number of recommendations

    Returns:
        List of recommended item IDs
    """
    # Deep copy to prevent model modification
    temp_model = copy.deepcopy(model)
    temp_dataset = copy.deepcopy(dataset)

    # Add new user to mapping
    new_user_idx = len(temp_dataset.user_mapping)
    temp_dataset.user_mapping[user_id] = new_user_idx

    # Initialize new user embedding
    with torch.no_grad():
        new_embedding = temp_model.user_embeddings.weight.mean(dim=0).unsqueeze(0)
        temp_model.user_embeddings.weight = nn.Parameter(
            torch.cat([temp_model.user_embeddings.weight, new_embedding])
        )
        temp_model.user_biases.weight = nn.Parameter(
            torch.cat([temp_model.user_biases.weight, torch.zeros(1, 1)])
        )

    # Validate and prepare ratings
    item_indices = []
    target_ratings = []
    for item_id, rating in ratings:
        if item_id not in temp_dataset.item_mapping:
            continue  # Skip unknown items
        item_indices.append(temp_dataset.item_mapping[item_id])
        target_ratings.append(rating)

    # Convert to tensors
    user_tensor = torch.tensor([new_user_idx], dtype=torch.long)
    item_tensor = torch.tensor(item_indices, dtype=torch.long)
    rating_tensor = torch.tensor(target_ratings, dtype=torch.float)

    # Fine-tune model
    optimizer = torch.optim.Adam(temp_model.parameters(), lr=0.001)
    for _ in range(10):
        optimizer.zero_grad()
        predictions = temp_model(user_tensor.expand_as(item_tensor), item_tensor)
        loss = torch.sqrt(nn.functional.mse_loss(predictions, rating_tensor))
        loss.backward()
        optimizer.step()

    # Generate recommendations
    all_items = torch.arange(len(temp_dataset.item_mapping), dtype=torch.long)
    with torch.no_grad():
        predictions = temp_model(user_tensor.expand_as(all_items), all_items)

    # Filter out rated items and get top recommendations
    rated_items = set(item_indices)
    candidate_items = [i for i in range(len(all_items)) if i not in rated_items]

    candidate_preds = predictions[candidate_items]
    top_indices = torch.topk(candidate_preds, top_k).indices
    recommended_item_ids = [list(temp_dataset.item_mapping.keys())[candidate_items[idx]] for idx in top_indices]

    return recommended_item_ids