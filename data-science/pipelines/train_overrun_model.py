"""Model Training Pipeline: AwareScroll Usage Overrun Predictor
Predicts whether a proposed Instagram session will overrun its intended limit before the session starts.
Algorithms evaluated: Logistic Regression (baseline), Random Forest Classifier.
"""

import argparse
import os
import sys
import joblib
import pandas as pd
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import roc_auc_score, brier_score_loss, classification_report

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from pipelines.feature_engineering import generate_synthetic_behavioral_dataset


def train_overrun_model(data: pd.DataFrame, output_dir: str = "models"):
    feature_cols = [
        "intended_duration_minutes",
        "hour_of_day",
        "is_weekend",
        "time_of_day_bucket",
        "purpose_reels_flag",
        "purpose_social_flag",
        "user_prior_overrun_rate",
    ]
    target_col = "exceeded_limit"

    X = data[feature_cols]
    y = data[target_col]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.20, random_state=42, stratify=y
    )

    numeric_features = ["intended_duration_minutes", "hour_of_day", "user_prior_overrun_rate"]
    categorical_features = ["time_of_day_bucket"]
    binary_features = ["is_weekend", "purpose_reels_flag", "purpose_social_flag"]

    preprocessor = ColumnTransformer(
        transformers=[
            ("num", StandardScaler(), numeric_features),
            ("cat", OneHotEncoder(drop="first", handle_unknown="ignore"), categorical_features),
            ("bin", "passthrough", binary_features),
        ]
    )

    # 1. Logistic Regression Model
    lr_pipeline = Pipeline(steps=[
        ("preprocessor", preprocessor),
        ("classifier", LogisticRegression(random_state=42, max_iter=1000)),
    ])

    lr_pipeline.fit(X_train, y_train)
    lr_preds = lr_pipeline.predict(X_test)
    lr_probs = lr_pipeline.predict_proba(X_test)[:, 1]
    lr_auc = roc_auc_score(y_test, lr_probs)
    lr_brier = brier_score_loss(y_test, lr_probs)

    print("\n[Candidate 1: Logistic Regression]")
    print(f"ROC-AUC:     {lr_auc:.4f}")
    print(f"Brier Score: {lr_brier:.4f}")

    # 2. Random Forest Model
    rf_pipeline = Pipeline(steps=[
        ("preprocessor", preprocessor),
        ("classifier", RandomForestClassifier(n_estimators=100, max_depth=5, random_state=42)),
    ])

    rf_pipeline.fit(X_train, y_train)
    rf_preds = rf_pipeline.predict(X_test)
    rf_probs = rf_pipeline.predict_proba(X_test)[:, 1]
    rf_auc = roc_auc_score(y_test, rf_probs)
    rf_brier = brier_score_loss(y_test, rf_probs)

    print("\n[Candidate 2: Random Forest Classifier]")
    print(f"ROC-AUC:     {rf_auc:.4f}")
    print(f"Brier Score: {rf_brier:.4f}")

    # Select best model based on ROC-AUC
    best_pipeline = rf_pipeline if rf_auc >= lr_auc else lr_pipeline
    best_name = "RandomForest" if rf_auc >= lr_auc else "LogisticRegression"
    print(f"\nSelected Best Model: {best_name}")

    os.makedirs(output_dir, exist_ok=True)
    model_path = os.path.join(output_dir, "overrun_predictor.joblib")
    joblib.dump(best_pipeline, model_path)
    print(f"Saved serialized model pipeline to: {model_path}")

    return best_pipeline, max(lr_auc, rf_auc)


def main():
    parser = argparse.ArgumentParser(description="Train Overrun Prediction Model")
    parser.add_argument("--test-mode", action="store_true", help="Run quick verification")
    args = parser.parse_args()

    print("=" * 60)
    print("AwareScroll AI — Overrun Prediction Model Training")
    print("=" * 60)

    overrun_df, _ = generate_synthetic_behavioral_dataset(n_samples=600)
    model_dir = os.path.join(os.path.dirname(__file__), "..", "models")
    train_overrun_model(overrun_df, output_dir=model_dir)
    print("Training finished successfully.")


if __name__ == "__main__":
    main()
