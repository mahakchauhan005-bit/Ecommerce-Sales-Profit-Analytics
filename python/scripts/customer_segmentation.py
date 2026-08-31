"""
Customer Segmentation Utilities
Ecommerce Analytics Project

This script calculates:
- Customer RFM metrics
- Customer segments
- Segment-level business summaries
"""

from pathlib import Path

import numpy as np
import pandas as pd


# =========================================================
# C9: Calculate RFM
# =========================================================

def calculate_rfm(
    customers: pd.DataFrame,
    orders: pd.DataFrame,
    order_items: pd.DataFrame
) -> pd.DataFrame:
    """
    Calculate customer-level RFM metrics.

    RFM:
    R = Recency
    F = Frequency
    M = Monetary Value
    """

    # -----------------------------------------------------
    # Connect customers to orders
    # -----------------------------------------------------

    customer_orders = customers[
        [
            "customer_id",
            "customer_unique_id"
        ]
    ].merge(
        orders[
            [
                "order_id",
                "customer_id",
                "order_purchase_timestamp"
            ]
        ],
        on="customer_id",
        how="inner"
    )

    # -----------------------------------------------------
    # Convert purchase date
    # -----------------------------------------------------

    customer_orders["order_purchase_timestamp"] = (
        pd.to_datetime(
            customer_orders["order_purchase_timestamp"],
            errors="coerce"
        )
    )

    # -----------------------------------------------------
    # Connect orders to order items
    # -----------------------------------------------------

    customer_data = customer_orders.merge(
        order_items[
            [
                "order_id",
                "order_item_id",
                "price"
            ]
        ],
        on="order_id",
        how="inner"
    )

    # -----------------------------------------------------
    # Dataset reference date
    # -----------------------------------------------------

    dataset_max_date = (
        customer_data["order_purchase_timestamp"].max()
    )

    # -----------------------------------------------------
    # Customer-level RFM
    # -----------------------------------------------------

    rfm = (
        customer_data
        .groupby("customer_unique_id")
        .agg(
            LastPurchaseDate=(
                "order_purchase_timestamp",
                "max"
            ),
            Frequency=(
                "order_id",
                "nunique"
            ),
            MonetaryValue=(
                "price",
                "sum"
            )
        )
        .reset_index()
    )

    # -----------------------------------------------------
    # Recency
    # -----------------------------------------------------

    rfm["RecencyDays"] = (
        dataset_max_date
        - rfm["LastPurchaseDate"]
    ).dt.days

    # -----------------------------------------------------
    # Round revenue
    # -----------------------------------------------------

    rfm["MonetaryValue"] = (
        rfm["MonetaryValue"].round(2)
    )

    # -----------------------------------------------------
    # Arrange columns
    # -----------------------------------------------------

    rfm = rfm[
        [
            "customer_unique_id",
            "LastPurchaseDate",
            "RecencyDays",
            "Frequency",
            "MonetaryValue"
        ]
    ]

    return rfm


# =========================================================
# C10: Assign Customer Segments
# =========================================================

def assign_customer_segments(
    rfm: pd.DataFrame
) -> pd.DataFrame:
    """
    Assign customer segments using RFM business rules.
    """

    segmented = rfm.copy()

    segmented["CustomerSegment"] = np.select(
        [
            (
                (segmented["RecencyDays"] <= 90)
                &
                (segmented["Frequency"] >= 3)
                &
                (segmented["MonetaryValue"] >= 500)
            ),

            (
                (segmented["RecencyDays"] > 180)
                &
                (segmented["Frequency"] == 1)
            )
        ],
        [
            "Champions",
            "At Risk"
        ],
        default="Regular Customers"
    )

    return segmented


# =========================================================
# C11: Summarize Customer Segments
# =========================================================

def summarize_segments(
    segmented_data: pd.DataFrame
) -> pd.DataFrame:
    """
    Create a segment-level summary containing
    customer count, order count, revenue,
    and average customer metrics.
    """

    segment_summary = (
        segmented_data
        .groupby("CustomerSegment")
        .agg(
            TotalCustomers=(
                "customer_unique_id",
                "nunique"
            ),
            TotalOrders=(
                "Frequency",
                "sum"
            ),
            TotalRevenue=(
                "MonetaryValue",
                "sum"
            )
        )
        .reset_index()
    )

    # -----------------------------------------------------
    # Average revenue per customer
    # -----------------------------------------------------

    segment_summary[
        "AverageRevenuePerCustomer"
    ] = (
        segment_summary["TotalRevenue"]
        / segment_summary["TotalCustomers"]
    )

    # -----------------------------------------------------
    # Average orders per customer
    # -----------------------------------------------------

    segment_summary[
        "AverageOrdersPerCustomer"
    ] = (
        segment_summary["TotalOrders"]
        / segment_summary["TotalCustomers"]
    )

    # -----------------------------------------------------
    # Round values
    # -----------------------------------------------------

    segment_summary[
        "TotalRevenue"
    ] = (
        segment_summary["TotalRevenue"]
        .round(2)
    )

    segment_summary[
        "AverageRevenuePerCustomer"
    ] = (
        segment_summary[
            "AverageRevenuePerCustomer"
        ]
        .round(2)
    )

    segment_summary[
        "AverageOrdersPerCustomer"
    ] = (
        segment_summary[
            "AverageOrdersPerCustomer"
        ]
        .round(2)
    )

    return segment_summary


# =========================================================
# Main Test
# =========================================================

if __name__ == "__main__":

    # -----------------------------------------------------
    # Project paths
    # -----------------------------------------------------

    PROJECT_ROOT = Path(__file__).resolve().parents[2]

    RAW_DATA = PROJECT_ROOT / "data" / "raw"

    # -----------------------------------------------------
    # Load datasets
    # -----------------------------------------------------

    customers = pd.read_csv(
        RAW_DATA / "olist_customers_dataset.csv"
    )

    orders = pd.read_csv(
        RAW_DATA / "olist_orders_dataset.csv"
    )

    order_items = pd.read_csv(
        RAW_DATA / "olist_order_items_dataset.csv"
    )

    # -----------------------------------------------------
    # C9: Calculate RFM
    # -----------------------------------------------------

    customer_rfm = calculate_rfm(
        customers,
        orders,
        order_items
    )

    print("\n==============================")
    print("CUSTOMER RFM ANALYSIS")
    print("==============================")

    print(
        "Number of Customers:",
        len(customer_rfm)
    )

    print(
        customer_rfm.head(10).to_string(
            index=False
        )
    )

    # -----------------------------------------------------
    # C10: Assign segments
    # -----------------------------------------------------

    customer_segments = assign_customer_segments(
        customer_rfm
    )

    print("\n==============================")
    print("CUSTOMER SEGMENTATION")
    print("==============================")

    print(
        customer_segments[
            "CustomerSegment"
        ]
        .value_counts()
        .to_string()
    )

    # -----------------------------------------------------
    # C11: Segment summary
    # -----------------------------------------------------

    segment_summary = summarize_segments(
        customer_segments
    )

    print("\n==============================")
    print("SEGMENT SUMMARY")
    print("==============================")

    print(
        segment_summary.to_string(
            index=False
        )
    )

    print(
        "\nCustomer segmentation pipeline "
        "completed successfully."
    )

# =========================================================
#  Revenue Contribution by Customer Segment
# =========================================================

# Total revenue across all customer segments
total_revenue = segment_summary["TotalRevenue"].sum()

# Calculate each segment's revenue contribution
segment_summary["RevenueSharePercent"] = (
    segment_summary["TotalRevenue"] * 100
    / total_revenue
)

# Round percentage
segment_summary["RevenueSharePercent"] = (
    segment_summary["RevenueSharePercent"]
    .round(2)
)

# Sort by highest revenue contribution
segment_summary = segment_summary.sort_values(
    "RevenueSharePercent",
    ascending=False
).reset_index(drop=True)

# ---------------------------------------------------------
# Final output
# ---------------------------------------------------------

print("\n==============================")
print("FINAL CUSTOMER SEGMENT SUMMARY")
print("==============================")

print(
    segment_summary.to_string(
        index=False
    )
)

# ---------------------------------------------------------
# Validation checks
# ---------------------------------------------------------

print("\n==============================")
print("FINAL VALIDATION")
print("==============================")

print(
    "Total Revenue:",
    round(total_revenue, 2)
)

print(
    "Total Customers:",
    customer_segments["customer_unique_id"].nunique()
)

print(
    "Revenue Share Total:",
    segment_summary["RevenueSharePercent"].sum(),
    "%"
)

print(
    "\nCustomer segmentation pipeline "
    "completed successfully."
)