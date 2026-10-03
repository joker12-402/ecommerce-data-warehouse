#!/bin/bash

echo "Start running ecommerce data warehouse SQL scripts..."

echo "Step 1: Create database"
mysql -u root < sql/01_create_database.sql

echo "Step 2: Load ODS data"
mysql -u root < sql/02_ods_user_behavior.sql

echo "Step 3: Build DWD detail table"
mysql -u root < sql/03_dwd_user_behavior_detail.sql

echo "Step 4: Build DWS daily summary table"
mysql -u root < sql/04_dws_user_behavior_daily.sql

echo "Step 5: Build ADS metrics tables"
mysql -u root < sql/05_ads_metrics.sql

echo "Step 6: Run data quality checks"
mysql -u root < sql/06_data_quality_check.sql

echo "All SQL scripts executed successfully."

echo "Query ADS results:"
mysql -u root -e "USE ecommerce_dw; SELECT * FROM ads_daily_overview; SELECT * FROM ads_top_items_daily;"
