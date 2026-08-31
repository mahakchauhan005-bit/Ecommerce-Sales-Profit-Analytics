"""
Data Cleaning Utilities
Ecommerce Analytics Project

This script provides reusable functions for clean the
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


#### CONVERT DATE COLUMNS
import pandas as pd
def convert_date_columns(
    df: pd.DataFrame,
    columns: list[str]
) -> pd.DataFrame:
    """
    Convert selected columns to datetime.
    """

    cleaned_df = df.copy()

    for column in columns:

        if column not in cleaned_df.columns:
            raise KeyError(
                f"Column '{column}' does not exist."
            )

        cleaned_df[column] = pd.to_datetime(
            cleaned_df[column],
            errors="coerce"
        )

    return cleaned_df

if __name__ == "__main__":

    PROJECT_ROOT = Path(__file__).resolve().parents[2]

    RAW_DATA = PROJECT_ROOT / "data" / "raw"

    orders = load_dataset(
        RAW_DATA / "olist_orders_dataset.csv"
    )

    date_columns = [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date"
    ]

    cleaned_orders = convert_date_columns(
        orders,
        date_columns
    )

    print(cleaned_orders[date_columns].dtypes)

def clean_numeric_columns(
    df: pd.DataFrame,
    columns: list[str]
) -> pd.DataFrame:

    """
    Convert selected columns to numeric.
    """

    cleaned_df = df.copy()

    for column in columns:

        if column not in cleaned_df.columns:
            raise KeyError(
                f"Column '{column}' does not exist."
            )

        cleaned_df[column] = pd.to_numeric(
            cleaned_df[column],
            errors="coerce"
        )

    return cleaned_df


if __name__ == "__main__":

    PROJECT_ROOT = Path(__file__).resolve().parents[2]

    RAW_DATA = PROJECT_ROOT / "data" / "raw"

    order_items = load_dataset(
        RAW_DATA / "olist_order_items_dataset.csv"
    )

    numeric_columns = [
        "price",
        "freight_value"
    ]

    cleaned_order_items = clean_numeric_columns(
        order_items,
        numeric_columns
    )

    print(
        cleaned_order_items[numeric_columns].dtypes
    )

def clean_text_columns(
    df: pd.DataFrame,
    columns: list[str]
) -> pd.DataFrame:

    """
    Clean selected text columns by converting
    values to strings and removing extra spaces.
    """

    cleaned_df = df.copy()

    for column in columns:

        if column not in cleaned_df.columns:
            raise KeyError(
                f"Column '{column}' does not exist."
            )

        cleaned_df[column] = (
            cleaned_df[column]
            .astype("string")
            .str.strip()
        )

    return cleaned_df
if __name__ == "__main__":

    PROJECT_ROOT = Path(__file__).resolve().parents[2]

    RAW_DATA = PROJECT_ROOT / "data" / "raw"

    orders = load_dataset(
        RAW_DATA / "olist_orders_dataset.csv"
    )

    customers = load_dataset(
        RAW_DATA / "olist_customers_dataset.csv"
    )

    # Clean order_status
    cleaned_orders = clean_text_columns(
        orders,
        ["order_status"]
    )

    # Clean customer city and state
    cleaned_customers = clean_text_columns(
        customers,
        [
            "customer_city",
            "customer_state"
        ]
    )

    print("Order status sample:")
    print(cleaned_orders["order_status"].head())

    print("\nCustomer city/state sample:")
    print(
        cleaned_customers[
            [
                "customer_city",
                "customer_state"
            ]
        ].head()
    )

def handle_missing_values(
    df: pd.DataFrame,
    replacements: dict[str, object]
) -> pd.DataFrame:

    """
    Replace missing values in selected columns.
    """

    cleaned_df = df.copy()

    for column, replacement in replacements.items():

        if column not in cleaned_df.columns:
            raise KeyError(
                f"Column '{column}' does not exist."
            )

        cleaned_df[column] = (
            cleaned_df[column]
            .fillna(replacement)
        )

    return cleaned_df
if __name__ == "__main__":

    PROJECT_ROOT = Path(__file__).resolve().parents[2]

    RAW_DATA = PROJECT_ROOT / "data" / "raw"

    orders = load_dataset(
        RAW_DATA / "olist_orders_dataset.csv"
    )

    replacements = {
        "order_status": "unknown"
    }

    cleaned_orders = handle_missing_values(
        orders,
        replacements
    )

    print("Missing values after cleaning:")

    print(
        cleaned_orders[
            ["order_status"]
        ].isna().sum()
    )

# =========================================================
# C5: Remove Duplicate Rows
# =========================================================

def remove_duplicate_rows(
    df: pd.DataFrame
) -> pd.DataFrame:
    """
    Remove completely duplicated rows.
    """

    cleaned_df = df.copy()

    cleaned_df = cleaned_df.drop_duplicates()

    return cleaned_df
if __name__ == "__main__":

    PROJECT_ROOT = Path(__file__).resolve().parents[2]

    RAW_DATA = PROJECT_ROOT / "data" / "raw"

    orders = load_dataset(
        RAW_DATA / "olist_orders_dataset.csv"
    )

    before_rows = len(orders)

    cleaned_orders = remove_duplicate_rows(
        orders
    )

    after_rows = len(cleaned_orders)

    print("C5: Duplicate Row Cleaning")
    print("---------------------------")
    print("Rows before:", before_rows)
    print("Rows after:", after_rows)
    print("Rows removed:", before_rows - after_rows)

# =========================================================
# C6: Standardize Column Names
# =========================================================

def standardize_column_names(
    df: pd.DataFrame
) -> pd.DataFrame:
    """
    Standardize DataFrame column names by:

    1. Removing leading/trailing spaces
    2. Converting to lowercase
    3. Replacing spaces with underscores
    """

    cleaned_df = df.copy()

    cleaned_df.columns = (
        cleaned_df.columns
        .str.strip()
        .str.lower()
        .str.replace(" ", "_", regex=False)
    )

    return cleaned_df
if __name__ == "__main__":

    PROJECT_ROOT = Path(__file__).resolve().parents[2]

    RAW_DATA = PROJECT_ROOT / "data" / "raw"

    orders = load_dataset(
        RAW_DATA / "olist_orders_dataset.csv"
    )

    print("C6: Column Name Standardization")
    print("--------------------------------")

    print("Original columns:")
    print(orders.columns.tolist())

    cleaned_orders = standardize_column_names(
        orders
    )

    print("\nCleaned columns:")
    print(cleaned_orders.columns.tolist())

# =========================================================
# C7: Reusable Data Cleaning Pipeline
# =========================================================

def clean_orders_data(df: pd.DataFrame) -> pd.DataFrame:
    """
    Apply the reusable cleaning functions to the orders dataset.
    """

    cleaned_df = df.copy()

    # 1. Standardize column names
    cleaned_df = standardize_column_names(
        cleaned_df
    )

    # 2. Convert date columns
    date_columns = [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date"
    ]

    cleaned_df = convert_date_columns(
        cleaned_df,
        date_columns
    )

    # 3. Clean text columns
    text_columns = [
        "order_status"
    ]

    cleaned_df = clean_text_columns(
        cleaned_df,
        text_columns
    )

    # 4. Handle missing categorical values
    replacements = {
        "order_status": "unknown"
    }

    cleaned_df = handle_missing_values(
        cleaned_df,
        replacements
    )

    # 5. Remove duplicate rows
    cleaned_df = remove_duplicate_rows(
        cleaned_df
    )

    return cleaned_df

if __name__ == "__main__":

    PROJECT_ROOT = Path(__file__).resolve().parents[2]

    RAW_DATA = PROJECT_ROOT / "data" / "raw"

    orders = load_dataset(
        RAW_DATA / "olist_orders_dataset.csv"
    )

    cleaned_orders = clean_orders_data(
        orders
    )

    print(
        "Original shape:",
        orders.shape
    )

    print(
        "Cleaned shape:",
        cleaned_orders.shape
    )

    print("\nCleaned column names:")
    print(
        cleaned_orders.columns.tolist()
    )

    print("\nDate column types:")
    print(
        cleaned_orders[
            [
                "order_purchase_timestamp",
                "order_approved_at",
                "order_delivered_carrier_date",
                "order_delivered_customer_date",
                "order_estimated_delivery_date"
            ]
        ].dtypes
    )

    print("\nMissing order status values:")
    print(
        cleaned_orders["order_status"].isna().sum()
    )

# =========================================================
# C8: Test the Full Cleaning Pipeline
# =========================================================

if __name__ == "__main__":

    # -----------------------------------------------------
    # 1. Project paths
    # -----------------------------------------------------

    PROJECT_ROOT = Path(__file__).resolve().parents[2]

    RAW_DATA = PROJECT_ROOT / "data" / "raw"

    # -----------------------------------------------------
    # 2. Load raw datasets
    # -----------------------------------------------------

    orders = load_dataset(
        RAW_DATA / "olist_orders_dataset.csv"
    )

    order_items = load_dataset(
        RAW_DATA / "olist_order_items_dataset.csv"
    )

    customers = load_dataset(
        RAW_DATA / "olist_customers_dataset.csv"
    )

    # -----------------------------------------------------
    # 3. Clean Orders
    # -----------------------------------------------------

    orders_before = orders.shape

    clean_orders = standardize_column_names(
        orders
    )

    clean_orders = convert_date_columns(
        clean_orders,
        [
            "order_purchase_timestamp",
            "order_approved_at",
            "order_delivered_carrier_date",
            "order_delivered_customer_date",
            "order_estimated_delivery_date"
        ]
    )

    clean_orders = clean_text_columns(
        clean_orders,
        ["order_status"]
    )

    clean_orders = handle_missing_values(
        clean_orders,
        {
            "order_status": "unknown"
        }
    )

    clean_orders = remove_duplicate_rows(
        clean_orders
    )

    # -----------------------------------------------------
    # 4. Clean Order Items
    # -----------------------------------------------------

    order_items_before = order_items.shape

    clean_order_items = standardize_column_names(
        order_items
    )

    clean_order_items = clean_numeric_columns(
        clean_order_items,
        [
            "price",
            "freight_value"
        ]
    )

    clean_order_items = remove_duplicate_rows(
        clean_order_items
    )

    # -----------------------------------------------------
    # 5. Clean Customers
    # -----------------------------------------------------

    customers_before = customers.shape

    clean_customers = standardize_column_names(
        customers
    )

    clean_customers = clean_text_columns(
        clean_customers,
        [
            "customer_city",
            "customer_state"
        ]
    )

    clean_customers = remove_duplicate_rows(
        clean_customers
    )

    # -----------------------------------------------------
    # 6. Print shape comparison
    # -----------------------------------------------------

    print("\n==============================")
    print("DATA CLEANING RESULTS")
    print("==============================")

    print("\nOrders")
    print("Before:", orders_before)
    print("After :", clean_orders.shape)

    print("\nOrder Items")
    print("Before:", order_items_before)
    print("After :", clean_order_items.shape)

    print("\nCustomers")
    print("Before:", customers_before)
    print("After :", clean_customers.shape)

    # -----------------------------------------------------
    # 7. Missing values after cleaning
    # -----------------------------------------------------

    print("\n==============================")
    print("MISSING VALUES AFTER CLEANING")
    print("==============================")

    print(
        "Orders:",
        clean_orders.isna().sum().sum()
    )

    print(
        "Order Items:",
        clean_order_items.isna().sum().sum()
    )

    print(
        "Customers:",
        clean_customers.isna().sum().sum()
    )

    # -----------------------------------------------------
    # 8. Duplicate rows after cleaning
    # -----------------------------------------------------

    print("\n==============================")
    print("DUPLICATES AFTER CLEANING")
    print("==============================")

    print(
        "Orders:",
        clean_orders.duplicated().sum()
    )

    print(
        "Order Items:",
        clean_order_items.duplicated().sum()
    )

    print(
        "Customers:",
        clean_customers.duplicated().sum()
    )

    # -----------------------------------------------------
    # 9. Check data types
    # -----------------------------------------------------

    print("\n==============================")
    print("ORDER DATE DATA TYPES")
    print("==============================")

    print(
        clean_orders[
            [
                "order_purchase_timestamp",
                "order_approved_at",
                "order_delivered_carrier_date",
                "order_delivered_customer_date",
                "order_estimated_delivery_date"
            ]
        ].dtypes
    )

    print("\n==============================")
    print("NUMERIC DATA TYPES")
    print("==============================")

    print(
        clean_order_items[
            [
                "price",
                "freight_value"
            ]
        ].dtypes
    )

    print("\nCleaning pipeline test completed successfully.")