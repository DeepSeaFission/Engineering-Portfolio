import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.svm import SVC
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.impute import SimpleImputer
from sklearn.model_selection import GridSearchCV
from xgboost import XGBClassifier
from lightgbm import LGBMClassifier
import warnings
warnings.filterwarnings("ignore", message=".*does not have valid feature names.*")


class BaseModel:
    """Base class to wrap training and evaluation."""
    
    def __init__(self, model_name, model):
        self.model_name = model_name
        self.model = model
        
    def train(self, X_train, y_train):
        self.model.fit(X_train, y_train)
        train_preds = self.model.predict(X_train)
        return accuracy_score(y_train, train_preds)
    
    def evaluate(self, X_test, y_test):
        test_preds = self.model.predict(X_test)
        return accuracy_score(y_test, test_preds)
    
    def report(self, train_acc, test_acc):
        print(f"=== {self.model_name} ===")
        print(f"Training Accuracy: {train_acc:.4f}")
        print(f"Test Accuracy:     {test_acc:.4f}\n")


def load_dataset(path):
    df = pd.read_excel(path)
    X = df.iloc[:, :-1]
    y = df.iloc[:, -1]
    return X, y


def create_models_with_grids():
    """Return models and their associated hyperparameter grids."""

    imputer = SimpleImputer(strategy="median")

    # -------------------------
    # SVM
    # -------------------------
    svm_pipeline = Pipeline([
        ("imputer", imputer),
        ("scaler", StandardScaler()),
        ("svm", SVC(kernel='rbf'))
    ])

    svm_grid = {
        "svm__C": [0.1, 1, 10],
        "svm__gamma": ["scale", 0.01, 0.001]
    }

    # -------------------------
    # Logistic Regression
    # -------------------------
    logreg_pipeline = Pipeline([
        ("imputer", imputer),
        ("scaler", StandardScaler()),
        ("logreg", LogisticRegression(max_iter=10000))
    ])

    logreg_grid = {
        "logreg__C": [0.01, 0.1, 1, 10],
        "logreg__penalty": ["l2"]
    }

    # -------------------------
    # Random Forest
    # -------------------------
    rf_model = Pipeline([
        ("imputer", imputer),
        ("rf", RandomForestClassifier(random_state=42))
    ])

    rf_grid = {
        "rf__n_estimators": [200, 400, 600],
        "rf__max_depth": [None, 5, 10],
        "rf__min_samples_split": [2, 5, 10]
    }

    # -------------------------
    # XGBoost
    # -------------------------
    xgb_model = Pipeline([
        ("imputer", imputer),
        ("xgb", XGBClassifier(eval_metric="logloss", random_state=42))
    ])

    xgb_grid = {
        "xgb__n_estimators": [200, 300, 400],
        "xgb__learning_rate": [0.01, 0.05, 0.1],
        "xgb__max_depth": [3, 4, 5],
        "xgb__subsample": [0.8, 0.9, 0.95],
        "xgb__colsample_bytree": [0.8, 0.9, 0.95]
    }

    # -------------------------
    # LightGBM
    # -------------------------
    lgbm_model = Pipeline([
        ("imputer", imputer),
        ("lgbm", LGBMClassifier(random_state=42,verbosity=-1))
    ])

    lgbm_grid = {
        "lgbm__n_estimators": [200, 300, 400],
        "lgbm__learning_rate": [0.01, 0.05, 0.1],
        "lgbm__subsample": [0.8, 0.9, 0.95],
        "lgbm__colsample_bytree": [0.8, 0.9, 0.95]
    }

    return [
        ("SVM", svm_pipeline, svm_grid),
        ("Logistic Regression", logreg_pipeline, logreg_grid),
        ("Random Forest", rf_model, rf_grid),
        ("XGBoost", xgb_model, xgb_grid),
        ("LightGBM", lgbm_model, lgbm_grid)
    ]

def run_hyperparameter_search(excel_path):
    
    X, y = load_dataset(excel_path)

    models = create_models_with_grids()

    for name, pipeline, grid in models:
        print(f"\n===== Hyperparameter Tuning: {name} =====")
        
        search = GridSearchCV(
            estimator=pipeline,
            param_grid=grid,
            scoring="accuracy",
            cv=5,
            n_jobs=-1,
            refit=True
        )

        search.fit(X, y)

        print("Best Params:", search.best_params_)
        print("Best CV Score:", search.best_score_)
        print("Best Estimator:", search.best_estimator_)


if __name__ == "__main__":
    run_hyperparameter_search("main_data.xlsx")
