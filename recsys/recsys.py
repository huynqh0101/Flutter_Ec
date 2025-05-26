import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
import logging
import torch
from torch import nn
import copy
from typing import Optional, List, Dict, Tuple
from matrix_factorization import MFLightning, RecsysDataset
import pickle

# Firebase Initialization
def initialize_firebase(cert_path: str):
    try:
        firebase_admin.get_app()
    except ValueError:
        cred = credentials.Certificate(cert_path)
        firebase_admin.initialize_app(cred)

# Firestore to DataFrame
def collection_to_dataframe(collection_name: str, selected_fields: Optional[List[str]] = None) -> pd.DataFrame:
    """
    Convert a Firestore collection to pandas DataFrame.

    Args:
        collection_name (str): Firestore collection name.
        selected_fields (List[str], optional): List of fields to include.

    Returns:
        pd.DataFrame: DataFrame containing the collection data.
    """
    db = firestore.client()
    docs = db.collection(collection_name).stream()

    data_list = [
        {k: v for k, v in doc.to_dict().items() if not selected_fields or k in selected_fields}
        for doc in docs
    ]

    df = pd.DataFrame(data_list)
    return df

# Recommendations for New User
def recommend_for_new_user(model, dataset: RecsysDataset, user_id: str, ratings: List[Tuple[str, float]], top_k: int = 50) -> List[str]:
    """
    Generate recommendations for a new user.

    Args:
        model: Trained recommendation model.
        dataset: Recommendation dataset.
        user_id: New user's ID.
        ratings: List of (item_id, rating) tuples.
        top_k: Number of recommendations.

    Returns:
        List of recommended item IDs.
    """
    temp_model = copy.deepcopy(model)
    temp_dataset = copy.deepcopy(dataset)

    # Add new user to dataset
    new_user_idx = len(temp_dataset.user_mapping)
    temp_dataset.user_mapping[user_id] = new_user_idx

    with torch.no_grad():
        mean_embedding = temp_model.user_embeddings.weight.mean(dim=0, keepdim=True)
        temp_model.user_embeddings.weight = nn.Parameter(torch.cat([temp_model.user_embeddings.weight, mean_embedding]))
        temp_model.user_biases.weight = nn.Parameter(torch.cat([temp_model.user_biases.weight, torch.zeros(1, 1)]))

    # Prepare user ratings
    item_indices = [temp_dataset.item_mapping[item_id] for item_id, _ in ratings if item_id in temp_dataset.item_mapping]
    target_ratings = [rating for item_id, rating in ratings if item_id in temp_dataset.item_mapping]

    user_tensor = torch.tensor([new_user_idx], dtype=torch.long)
    item_tensor = torch.tensor(item_indices, dtype=torch.long)
    rating_tensor = torch.tensor(target_ratings, dtype=torch.float)

    # Fine-tune model
    optimizer = torch.optim.Adam(temp_model.parameters(), lr=0.001)
    for _ in range(50):
        optimizer.zero_grad()
        predictions = temp_model(user_tensor.expand_as(item_tensor), item_tensor)
        loss = torch.sqrt(nn.functional.mse_loss(predictions, rating_tensor))
        loss.backward()
        optimizer.step()

    # Generate recommendations
    all_items = torch.arange(len(temp_dataset.item_mapping), dtype=torch.long)
    with torch.no_grad():
        predictions = temp_model(user_tensor.expand_as(all_items), all_items)

    rated_items = set(item_indices)
    candidate_items = [i for i in range(len(all_items)) if i not in rated_items]
    candidate_preds = predictions[candidate_items]
    top_indices = torch.topk(candidate_preds, top_k).indices

    return [list(temp_dataset.item_mapping.keys())[candidate_items[idx]] for idx in top_indices]

# Recommendations for All Users
def recommend_for_all_users(model, dataset: RecsysDataset, df: pd.DataFrame, top_k: int = 10) -> Dict[str, List[str]]:
    """
    Generate recommendations for all users in the DataFrame.

    Args:
        model: Trained recommendation model.
        dataset: Recommendation dataset.
        df: DataFrame containing user ratings.
        top_k: Number of recommendations per user.

    Returns:
        Dictionary of user_id to list of recommended item IDs.
    """
    recommendations = {}
    for user_id in df['user_id'].unique():
        user_ratings = df[df['user_id'] == user_id][['product_id', 'rating']].values.tolist()
        recommendations[user_id] = recommend_for_new_user(model, dataset, user_id, user_ratings, top_k)
    return recommendations

# Upload Recommendations to Firestore
def upload_recommendations_to_firebase(recommendations: Dict[str, List[str]]):
    """
    Upload recommendations to Firestore.

    Args:
        recommendations (dict): User recommendations.
    """
    db = firestore.client()
    for user_id, items in recommendations.items():
        try:
            db.collection('users').document(user_id).set({'recommended': items}, merge=True)
            logging.info(f"Successfully uploaded recommendations for user_id: {user_id}")
        except Exception as e:
            logging.error(f"Failed to upload recommendations for user_id: {user_id}. Error: {e}")

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    # Initialize Firebase
    initialize_firebase('globalcard-ff50f-firebase-adminsdk-av43o-5b3a1c6c76.json')

    # Load DataFrame
    selected_fields = ['user_id', 'product_id', 'rating']
    df_filtered = collection_to_dataframe('new_reviews', selected_fields=selected_fields)

    # Load Model and Dataset
    model = MFLightning.load_from_checkpoint('model.ckpt')
    with open('dataset.pkl', 'rb') as f:
        dataset = pickle.load(f)

    # Generate Recommendations
    recommendations = recommend_for_all_users(model, dataset, df_filtered, top_k=30)

    # Upload Recommendations
    upload_recommendations_to_firebase(recommendations)