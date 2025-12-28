# Olist SQL Analytics Case Study

<p align="center">
  <img src="logo/logo.png" alt="Olist Dataset" width="700">
</p>

## Overview

This project presents an end-to-end SQL analytics workflow built on the **Brazilian E-Commerce Public Dataset (Olist)**. The objective was to validate raw transactional data, design an analytics-ready data model, and extract meaningful business insights using PostgreSQL.

Dataset source:
[Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## Data Quality Assessment

All raw datasets were ingested successfully with expected record volumes, confirming complete and accurate data loading. Referential integrity checks identified **no orphan records** across core relationships, including orders, customers, order items, products, payments, and reviews.

Data completeness analysis revealed limited and business-explainable gaps. Approximately **3% of orders lack delivery dates**, corresponding to canceled or in-progress orders, and **~2% of products lack category information**. No payment records are missing monetary values. Temporal validation confirmed **no invalid timestamps**, such as delivery dates preceding purchase dates. A small number of orders (**306**) exhibit unusually long delivery durations (>60 days), treated as operational outliers rather than data errors.

Observed behaviors such as multiple payments per order, multiple reviews per order, and multiple customer IDs per unique customer reflect real-world e-commerce operations. Overall, the dataset demonstrates **high data quality and realistic business behavior**, making it suitable for analytics and business intelligence use.

---

## Analytics Modeling

An analytics layer was created to separate raw data from business logic and simplify analysis. The model includes fact tables for orders, order items, payments, and reviews, along with dimension tables for customers, products, and sellers. Customer identity was resolved using `customer_unique_id`, product categories were standardized, and review duplication was handled by selecting the latest review per order.

---

## Business Case Study Findings

### Business Scale

* **Total orders analyzed:** 98,666
* **Total revenue (items + freight):** 15.84M

The platform operates at a mid-to-large e-commerce scale with substantial transaction volume.

### Revenue Trends

Revenue shows steady growth throughout 2017, with peak performance in late 2017 and early 2018. Minimal activity in late 2016 aligns with early-stage platform adoption.

### Product Category Performance

Revenue is concentrated in a small number of categories, led by **Health & Beauty**, **Watches & Gifts**, **Bed Bath & Table**, **Sports & Leisure**, and **Computers & Accessories**, indicating strong demand for lifestyle and consumer goods.

### Seller Performance

Seller revenue distribution is highly skewed, with a small group of sellers generating a disproportionate share of revenue. Top-performing sellers are predominantly located in **São Paulo (SP)**, suggesting regional advantages in demand or logistics.

### Delivery Performance and Customer Satisfaction

The average delivery time for delivered orders is approximately **12.5 days**. Orders with longer delivery durations are more likely to be canceled. Faster deliveries consistently correspond to higher review scores, while delayed deliveries are associated with lower customer satisfaction.

### Customer Behavior

Most customers place a single order; however, a smaller segment demonstrates strong repeat behavior, with some customers placing **5–17 orders**, highlighting opportunities for retention-focused strategies.

---

## Conclusion

This project demonstrates the complete SQL analytics lifecycle, from raw data validation to analytics modeling and insight generation. The findings highlight key revenue drivers, operational bottlenecks, and customer behavior patterns. The structured analytics approach enables reliable, scalable analysis and reflects real-world data engineering and analytics practices.

---

## Technologies Used

* PostgreSQL
* SQL (DDL, DML, analytical queries)
