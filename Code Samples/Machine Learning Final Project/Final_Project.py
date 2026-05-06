import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.svm import SVC
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.impute import SimpleImputer
from xgboost import XGBClassifier
from lightgbm import LGBMClassifier
import shap


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
    """Load an Excel file and split into features/target."""
    df = pd.read_excel(path)
    X = df.iloc[:, :-1]
    y = df.iloc[:, -1]
    return X, y


def create_models():
    """Create SVM, RF, LogReg, XGBoost, and LightGBM models."""
    
    imputer = SimpleImputer(strategy="median")

    svm_pipeline = Pipeline([
        ("imputer", imputer),
        ("scaler", StandardScaler()),
        ("svm", SVC(kernel='rbf',C=10,gamma=0.001)),
    ])
    
    logreg_pipeline = Pipeline([
        ("imputer", imputer),
        ("scaler", StandardScaler()),
        ("logreg", LogisticRegression(max_iter=10000,C=1,penalty='l2'))
    ])
    
    rf_model = Pipeline([
        ("imputer", imputer),
        ("rf", RandomForestClassifier(
            max_depth=5,
            min_samples_split=10,
            n_estimators=400,
            random_state=42
        ))
    ])

    xgb_model = Pipeline([
        ("imputer", imputer),
        ("xgb", XGBClassifier(
            n_estimators=200,
            learning_rate=0.01,
            max_depth=3,
            subsample=0.8,
            colsample_bytree=0.8,
            eval_metric="logloss",
            random_state=42
        ))
    ])

    lgbm_model = Pipeline([
        ("imputer", imputer),
        ("lgbm", LGBMClassifier(
            n_estimators=300,
            learning_rate=0.01,
            max_depth=-1,
            subsample=0.9,
            colsample_bytree=0.9,
            random_state=42,
            verbose=-1
        ))
    ])
    
    return [
        BaseModel("Support Vector Machine (SVM)", svm_pipeline),
        BaseModel("Random Forest", rf_model),
        BaseModel("Logistic Regression", logreg_pipeline),
        BaseModel("XGBoost", xgb_model),
        BaseModel("LightGBM", lgbm_model)
    ]


def run_shap_analysis(model, X_train, feature_names):
    """Runs SHAP on tree-based models (RF, XGBoost, LightGBM)."""
    print("Running SHAP analysis... this may take a moment.")

    # Extract underlying estimator if pipeline was used
    if hasattr(model, "named_steps"):
        for name, step in model.named_steps.items():
            if hasattr(step, "predict"):
                model = step  # replace with tree model

    # TreeExplainer works with RF, XGB, LGBM
    explainer = shap.TreeExplainer(model)
    shap_values = explainer.shap_values(X_train)

    shap.summary_plot(shap_values, X_train, feature_names=feature_names)


def run_all_models(X, y):
    """Split data, train all models, print metrics, and run SHAP for tree models."""
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.20, random_state=42, stratify=y
    )
    
    models = create_models()
    
    for model in models:
        train_acc = model.train(X_train, y_train)
        test_acc = model.evaluate(X_test, y_test)
        model.report(train_acc, test_acc)

        # SHAP only for tree models
        if model.model_name in ["Random Forest", "XGBoost", "LightGBM"]:
            run_shap_analysis(model.model, X_train, X.columns)


def main():
    excel_path = "main_data.xlsx"
    X, y = load_dataset(excel_path)
    run_all_models(X, y)


if __name__ == "__main__":
    main()
