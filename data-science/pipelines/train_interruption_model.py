"""Model Training Pipeline: FocusLock Interruption Predictor
Predicts whether a proposed focus session will be interrupted early.
Algorithms evaluated: Decision Tree, Random Forest Classifier.
"""

import argparse
import os
import sys
import joblib
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import roc_auc_score, f1_score, classification_report

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from pipelines.feature_engineering import generate_synthetic_behavioral_dataset


def train_interruption_model(data: pd.DataFrame, output_dir: str = "models"):
    feature_cols = [
        "task_category",
        "planned_duration_minutes",
        "hour_of_day",
        "is_weekend",
        "time_of_day_bucket",
        "user_prior_interruption_rate",
    ]
    target_col = "interrupted"

    X = data[feature_cols]
    y = data[target_col]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.20, random_state=42, stratify=y
    )

    numeric_features = ["planned_duration_minutes", "hour_of_day", "user_prior_interruption_rate"]
    categorical_features = ["task_category", "time_of_day_bucket"]
    binary_features = ["is_weekend"]

    preprocessor = ColumnTransformer(
        transformers=[
            ("num", StandardScaler(), numeric_features),
            ("cat", OneHotEncoder(drop="first", handle_unknown="ignore"), categorical_features),
            ("bin", "passthrough", binary_features),
        ]
    )

    # 1. Decision Tree Model
    dt_pipeline = Pipeline(steps=[
        ("preprocessor", preprocessor),
        ("classifier", DecisionTreeClassifier(max_depth=4, random_state=42)),
    ])
    dt_pipeline.fit(X_train, y_train)
    dt_probs = dt_pipeline.predict_proba(X_test)[:, 1]
    dt_auc = roc_auc_score(y_test, dt_probs)

    print("\n[Candidate 1: Decision Tree]")
    print(f"ROC-AUC:  {dt_auc:.4f}")

    # 2. Random Forest Model
    rf_pipeline = Pipeline(steps=[
        ("preprocessor", preprocessor),
        ("classifier", RandomForestClassifier(n_estimators=100, max_depth=5, random_state=42)),
    ])
    rf_pipeline.fit(X_train, y_train)
    rf_probs = rf_pipeline.predict_proba(X_test)[:, 1]
    rf_auc = roc_auc_score(y_test, rf_probs)

    print("\n[Candidate 2: Random Forest Classifier]")
    print(f"ROC-AUC:  {rf_auc:.4f}")

    best_pipeline = rf_pipeline if rf_auc >= dt_auc else dt_pipeline
    best_name = "RandomForest" if rf_auc >= dt_auc else "DecisionTree"
    print(f"\nSelected Best Model: {best_name} with ROC-AUC {max(rf_auc, dt_auc):.4f}")

    os.makedirs(output_dir, exist_ok=True)
    model_path = os.path.join(output_dir, "interruption_predictor.joblib")
    joblib.dump(best_pipeline, model_path)
    print(f"Saved serialized model pipeline to: {model_path}")

    return best_pipeline, max(dt_auc, rf_auc)


def main():
    parser = argparse.ArgumentParser(description="Train Interruption Prediction Model")
    parser.add_argument("--test-mode", action="store_true", help="Run quick verification")
    args = parser.parse_args()

    print("=" * 60)
    print("FocusLock — Interruption Prediction Model Training")
    print("=" * 60)

    _, focus_df = generate_synthetic_behavioral_dataset(n_samples=600)
    model_dir = os.path.join(os.path.dirname(__file__), "..", "models")
    train_interruption_model(focus_df, output_dir=model_dir)
    print("Interruption model training complete.")


if __name__ == "__main__":
    main()
