"""
Data Validation Utilities
Ecommerce Analytics Project

This script provides reusable functions for validating
datasets before analysis.
"""

from pathlib import Path
from typing import Dict, List

import pandas as pd


def load_dataset(file_path: str | Path) -> pd.DataFrame:
    """
    Load a CSV file into a Pandas DataFrame.

    Parameters
    ----------
    file_path : str or Path
        Path to the CSV file.

    Returns
    -------
    pd.DataFrame
        Loaded dataset.
    """

    file_path = Path(file_path)

    if not file_path.exists():
        raise FileNotFoundError(
            f"CSV file not found: {file_path}"
        )

    try:
        return pd.read_csv(file_path)
    except Exception as exc:
        raise RuntimeError(
            f"Could not load CSV file: {file_path}"
        ) from exc


def check_missing_values(df: pd.DataFrame) -> pd.DataFrame:
    """
    Calculate missing-value counts for every column.
    """

    result = pd.DataFrame({
        "Column": df.columns,
        "MissingValues": df.isna().sum().values,
        "MissingPercentage": (
            df.isna().mean().values * 100
        ).round(2)
    })

    return result


def check_duplicates(df: pd.DataFrame) -> int:
    """
    Return the number of completely duplicated rows.
    """

    return int(df.duplicated().sum())


def check_numeric_columns(
    df: pd.DataFrame,
    columns: List[str]
) -> pd.DataFrame:
    """
    Validate numeric columns.

    Returns missing, negative, zero, minimum,
    maximum, and average values.
    """

    report = []

    for column in columns:

        if column not in df.columns:
            raise KeyError(
                f"Column '{column}' does not exist."
            )

        series = pd.to_numeric(
            df[column],
            errors="coerce"
        )

        report.append({
            "Column": column,
            "MissingValues": int(series.isna().sum()),
            "NegativeValues": int((series < 0).sum()),
            "ZeroValues": int((series == 0).sum()),
            "Minimum": series.min(),
            "Maximum": series.max(),
            "Average": series.mean()
        })

    return pd.DataFrame(report)


def check_categorical_columns(
    df: pd.DataFrame,
    columns: List[str]
) -> pd.DataFrame:
    """
    Validate categorical/text columns.
    """

    report = []

    for column in columns:

        if column not in df.columns:
            raise KeyError(
                f"Column '{column}' does not exist."
            )

        series = (
            df[column]
            .astype("string")
            .str.strip()
        )

        report.append({
            "Column": column,
            "MissingValues": int(series.isna().sum()),
            "UniqueValues": int(
                series.nunique(dropna=True)
            ),
            "BlankValues": int(
                series.eq("").sum()
            ),
            "DuplicateValues": int(
                series.duplicated().sum()
            )
        })

    return pd.DataFrame(report)


def create_dataset_summary(
    datasets: Dict[str, pd.DataFrame]
) -> pd.DataFrame:
    """
    Create a high-level validation summary
    for multiple datasets.
    """

    report = []

    for dataset_name, df in datasets.items():

        report.append({
            "Dataset": dataset_name,
            "Rows": df.shape[0],
            "Columns": df.shape[1],
            "MissingValues": int(
                df.isna().sum().sum()
            ),
            "DuplicateRows": int(
                df.duplicated().sum()
            )
        })

    return pd.DataFrame(report)


if __name__ == "__main__":

    # Project root:
    # EcommerceAnalytics/
    #
    # This script is in:
    # EcommerceAnalytics/python/scripts/
    #
    # Therefore we move:
    # scripts -> python -> project root

    PROJECT_ROOT = (
        Path(__file__).resolve().parents[2]
    )

    RAW_DATA = PROJECT_ROOT / "data" / "raw"

    # Load datasets
    orders = load_dataset(
        RAW_DATA / "olist_orders_dataset.csv"
    )

    customers = load_dataset(
        RAW_DATA / "olist_customers_dataset.csv"
    )

    order_items = load_dataset(
        RAW_DATA / "olist_order_items_dataset.csv"
    )

    # -----------------------------------------------------
    # Dataset summary
    # -----------------------------------------------------

    datasets = {
        "Orders": orders,
        "Customers": customers,
        "Order Items": order_items
    }

    print("\n==============================")
    print("DATASET VALIDATION SUMMARY")
    print("==============================")

    summary = create_dataset_summary(
        datasets
    )

    print(summary.to_string(index=False))

    # -----------------------------------------------------
    # Missing values
    # -----------------------------------------------------

    print("\n==============================")
    print("ORDERS MISSING VALUES")
    print("==============================")

    print(
        check_missing_values(orders)
        .to_string(index=False)
    )

    # -----------------------------------------------------
    # Duplicate rows
    # -----------------------------------------------------

    print("\n==============================")
    print("DUPLICATE ROWS")
    print("==============================")

    print(
        "Orders:",
        check_duplicates(orders)
    )

    print(
        "Customers:",
        check_duplicates(customers)
    )

    print(
        "Order Items:",
        check_duplicates(order_items)
    )

    # -----------------------------------------------------
    # Numeric validation
    # -----------------------------------------------------

    print("\n==============================")
    print("NUMERIC VALIDATION")
    print("==============================")

    numeric_report = check_numeric_columns(
        order_items,
        [
            "price",
            "freight_value"
        ]
    )

    print(
        numeric_report.to_string(
            index=False
        )
    )

    # -----------------------------------------------------
    # Categorical validation
    # -----------------------------------------------------

    print("\n==============================")
    print("CATEGORICAL VALIDATION")
    print("==============================")

    categorical_report = check_categorical_columns(
        orders,
        ["order_status"]
    )

    print(
        categorical_report.to_string(
            index=False
        )
    )

    print("\nValidation completed successfully.")