#!/bin/bash

echo "Start running ecommerce data warehouse SQL scripts..."

mysql -u root < sql/01_create_database.sql
mysql -u root < sql/02_ods_user_behavior.sql
mysql -u root < sql/03_dwd_user_behavior_detail.sql
mysql -u root < sql/04_dws_user_behavior_daily.sql
mysql -u root < sql/05_ads_metrics.sql

echo "All SQL scripts executed successfully."

echo "Query ADS results:"
mysql -u root -e "USE ecommerce_dw; SELECT * FROM ads_daily_overview; SELECT * FROM ads_top_items_daily;"
