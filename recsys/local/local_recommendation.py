import pandas as pd
import numpy as np
import json
import os
import pickle
from collections import Counter
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class LocalRecommendationSystem:
    def __init__(self):
        self.products = []
        self.users = {}
        self.ratings = []
        self.purchases = []
        self.recommendations = {}
        
    def load_products_from_json(self, filepath):
        """Tải dữ liệu sản phẩm từ file JSON"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                self.products = json.load(f)
            logger.info(f"Đã tải {len(self.products)} sản phẩm từ {filepath}")
            return True
        except Exception as e:
            logger.error(f"Lỗi khi tải sản phẩm: {e}")
            return False
    
    def save_recommendations_to_json(self, filepath):
        """Lưu đề xuất vào file JSON"""
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(self.recommendations, f, indent=2)
            logger.info(f"Đã lưu đề xuất cho {len(self.recommendations)} người dùng vào {filepath}")
            return True
        except Exception as e:
            logger.error(f"Lỗi khi lưu đề xuất: {e}")
            return False
    
    def create_sample_users_and_purchases(self, num_users=20, purchases_per_user=5):
        """Tạo dữ liệu mẫu về người dùng và lịch sử mua hàng"""
        if not self.products:
            logger.error("Không thể tạo mẫu: chưa có dữ liệu sản phẩm")
            return False
        
        # Tạo người dùng mẫu
        self.users = {}
        for i in range(1, num_users + 1):
            user_id = f"user_{i}"
            self.users[user_id] = {
                "id": user_id,
                "name": f"User {i}",
                "email": f"user{i}@example.com"
            }
        
        # Tạo lịch sử mua hàng mẫu
        self.purchases = []
        for user_id in self.users.keys():
            # Chọn ngẫu nhiên một số sản phẩm
            product_indices = np.random.choice(
                len(self.products), 
                min(purchases_per_user, len(self.products)),
                replace=False
            )
            
            for idx in product_indices:
                if idx < len(self.products) and isinstance(self.products[idx], dict):
                    product = self.products[idx]
                    product_id = product.get("product_id", f"product_{idx}")
                    
                    self.purchases.append({
                        "user_id": user_id,
                        "product_id": product_id,
                        "quantity": np.random.randint(1, 4),
                        "timestamp": pd.Timestamp.now() - pd.Timedelta(days=np.random.randint(1, 90))
                    })
        
        logger.info(f"Đã tạo {len(self.users)} người dùng và {len(self.purchases)} lịch sử mua hàng")
        return True
    
    def generate_recommendations_content_based(self):
        """Tạo đề xuất dựa trên nội dung sản phẩm"""
        if not self.products or not self.users:
            logger.error("Không thể tạo đề xuất: thiếu dữ liệu sản phẩm hoặc người dùng")
            return False
        
        # Chuyển sản phẩm thành dictionary để dễ truy cập
        product_dict = {}
        for p in self.products:
            if isinstance(p, dict) and "product_id" in p:
                product_dict[p["product_id"]] = p
        
        # Lấy danh mục của từng sản phẩm
        product_categories = {}
        for product_id, product in product_dict.items():
            category = product.get("category", "")
            
            # Xử lý trường hợp category là list
            if isinstance(category, list):
                # Nếu category là list, lấy phần tử đầu tiên hoặc dùng chuỗi rỗng
                if category:
                    category = category[0]
                else:
                    category = ""
            
            if category:
                if category not in product_categories:
                    product_categories[category] = []
                product_categories[category].append(product_id)
        
        # Tạo đề xuất cho từng người dùng
        self.recommendations = {}
        
        for user_id in self.users:
            # Lấy sản phẩm đã mua
            purchased_products = [p["product_id"] for p in self.purchases if p["user_id"] == user_id]
            
            # Nếu người dùng chưa mua sản phẩm nào, đề xuất sản phẩm phổ biến
            if not purchased_products:
                popular_products = sorted(
                    [p for p in self.products if isinstance(p, dict)],
                    key=lambda x: x.get("rating", 0) * np.log1p(x.get("rating_count", 0) + 1),
                    reverse=True
                )
                self.recommendations[user_id] = [
                    p.get("product_id", f"product_{i}") 
                    for i, p in enumerate(popular_products[:20])
                    if "product_id" in p
                ]
                continue
            
            # Tính danh mục ưa thích
            favorite_categories = []
            for product_id in purchased_products:
                if product_id in product_dict:
                    category = product_dict[product_id].get("category", "")
                    
                    # Xử lý trường hợp category là list
                    if isinstance(category, list):
                        if category:
                            category = category[0]
                        else:
                            category = ""
                    
                    if category:
                        favorite_categories.append(category)
            
            # Đếm và sắp xếp danh mục
            category_counts = Counter(favorite_categories)
            sorted_categories = [cat for cat, _ in category_counts.most_common()]
            
            # Tạo đề xuất từ danh mục ưa thích
            recommended_products = []
            already_recommended = set(purchased_products)
            
            # Thêm sản phẩm từ các danh mục ưa thích
            for category in sorted_categories:
                if category in product_categories:
                    for product_id in product_categories[category]:
                        if product_id not in already_recommended and product_id not in recommended_products:
                            recommended_products.append(product_id)
                            already_recommended.add(product_id)
                            
                        if len(recommended_products) >= 20:
                            break
            
            # Nếu chưa đủ, thêm sản phẩm phổ biến
            if len(recommended_products) < 20:
                popular_products = sorted(
                    [p for p in self.products if isinstance(p, dict)],
                    key=lambda x: x.get("rating", 0) * np.log1p(x.get("rating_count", 0) + 1),
                    reverse=True
                )
                
                for product in popular_products:
                    product_id = product.get("product_id")
                    if (product_id and product_id not in already_recommended 
                            and product_id not in recommended_products):
                        recommended_products.append(product_id)
                        
                    if len(recommended_products) >= 20:
                        break
            
            self.recommendations[user_id] = recommended_products[:20]
        
        logger.info(f"Đã tạo đề xuất cho {len(self.recommendations)} người dùng")
        return True
    
    def export_for_flutter(self, output_dir="recommendations"):
        """Xuất đề xuất để sử dụng trong Flutter"""
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        
        # Lưu đề xuất cho từng người dùng
        for user_id, recs in self.recommendations.items():
            filepath = os.path.join(output_dir, f"{user_id}_recommendations.json") 
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump({"recommended": recs}, f)
        
        # Lưu đề xuất mặc định
        default_recs = []
        if self.products:
            popular_products = sorted(
                [p for p in self.products if isinstance(p, dict)],
                key=lambda x: x.get("rating", 0) * np.log1p(x.get("rating_count", 0) + 1),
                reverse=True
            )
            default_recs = [p.get("product_id", f"product_{i}") 
                           for i, p in enumerate(popular_products[:20]) 
                           if "product_id" in p]
        
        with open(os.path.join(output_dir, "default_recommendations.json"), 'w', encoding='utf-8') as f:
            json.dump({"recommended": default_recs}, f)
        
        logger.info(f"Đã xuất đề xuất cho {len(self.recommendations)} người dùng vào thư mục {output_dir}")
        return output_dir

if __name__ == "__main__":
    recommender = LocalRecommendationSystem()
    
    # Tải sản phẩm từ file JSON
    if recommender.load_products_from_json("d:/Code/E_app/lib/assets/data .json"):
        # Tạo dữ liệu mẫu
        recommender.create_sample_users_and_purchases()
        
        # Tạo đề xuất
        recommender.generate_recommendations_content_based()
        
        # Xuất đề xuất
        output_dir = recommender.export_for_flutter("d:/Code/E_app/lib/assets/recommendations")
        
        print(f"Đã tạo đề xuất và lưu vào thư mục: {output_dir}")