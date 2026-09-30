# MySQL 本地运行指南

## 1. 环境要求

本项目基于本地 MySQL 运行。

推荐环境：

| 工具 | 版本或说明 |
| --- | --- |
| 操作系统 | macOS |
| 数据库 | MySQL 8.x |
| 编辑器 | VS Code |
| 包管理工具 | Homebrew |
| 终端 | zsh |

---

## 2. 安装 MySQL

如果尚未安装 MySQL，可以通过 Homebrew 安装：

```bash
brew install mysql
```

启动 MySQL 服务：

```bash
brew services start mysql
```

查看 MySQL 服务状态：

```bash
brew services list
```

---

## 3. 登录 MySQL

无密码登录：

```bash
mysql -u root
```

如果 root 用户设置了密码：

```bash
mysql -u root -p
```

退出 MySQL：

```sql
exit;
```

---

## 4. 项目目录

进入项目目录：

```bash
cd ~/ecommerce-data-warehouse
```

查看目录结构：

```bash
find . -maxdepth 2 -type f | sort
```

---

## 5. 执行 SQL 脚本

按顺序执行：

```bash
mysql -u root < sql/01_create_database.sql
mysql -u root < sql/02_ods_user_behavior.sql
mysql -u root < sql/03_dwd_user_behavior_detail.sql
mysql -u root < sql/04_dws_user_behavior_daily.sql
mysql -u root < sql/05_ads_metrics.sql
```

如果 root 用户有密码，则使用：

```bash
mysql -u root -p < sql/01_create_database.sql
mysql -u root -p < sql/02_ods_user_behavior.sql
mysql -u root -p < sql/03_dwd_user_behavior_detail.sql
mysql -u root -p < sql/04_dws_user_behavior_daily.sql
mysql -u root -p < sql/05_ads_metrics.sql
```

---

## 6. 查询执行结果

执行：

```bash
mysql -u root -e "USE ecommerce_dw; SELECT * FROM ads_daily_overview; SELECT * FROM ads_top_items_daily;"
```

如果 root 用户有密码：

```bash
mysql -u root -p -e "USE ecommerce_dw; SELECT * FROM ads_daily_overview; SELECT * FROM ads_top_items_daily;"
```

---

## 7. 查看数据库和表

登录 MySQL：

```bash
mysql -u root
```

查看数据库：

```sql
SHOW DATABASES;
```

使用项目数据库：

```sql
USE ecommerce_dw;
```

查看表：

```sql
SHOW TABLES;
```

当前项目包含：

```text
ods_user_behavior
dwd_user_behavior_detail
dws_user_behavior_daily
ads_daily_overview
ads_top_items_daily
```

---

## 8. 常用验证 SQL

### 8.1 查看 ODS 层数据

```sql
SELECT * FROM ods_user_behavior;
```

### 8.2 查看 DWD 层数据

```sql
SELECT * FROM dwd_user_behavior_detail;
```

### 8.3 查看 DWS 层数据

```sql
SELECT * FROM dws_user_behavior_daily;
```

### 8.4 查看 ADS 每日概览

```sql
SELECT * FROM ads_daily_overview;
```

### 8.5 查看 ADS 热门商品

```sql
SELECT * FROM ads_top_items_daily;
```

---

## 9. 常见问题

### 9.1 Access denied for user root

如果出现：

```text
Access denied for user 'root'@'localhost'
```

说明 root 用户需要密码。

请改用：

```bash
mysql -u root -p
```

或者：

```bash
mysql -u root -p < sql/01_create_database.sql
```

---

### 9.2 command not found: mysql

如果出现：

```text
command not found: mysql
```

说明 MySQL 命令没有加入 PATH，或者 MySQL 未安装。

可以检查：

```bash
which mysql
```

或重新安装：

```bash
brew install mysql
```

---

### 9.3 表数据重复

本项目 SQL 中使用了：

```sql
DROP TABLE IF EXISTS table_name;
```

每次执行会先删除旧表再重新创建，因此可以重复运行，不会产生重复数据。

---

## 10. 一键复现流程

从项目根目录执行：

```bash
mysql -u root < sql/01_create_database.sql
mysql -u root < sql/02_ods_user_behavior.sql
mysql -u root < sql/03_dwd_user_behavior_detail.sql
mysql -u root < sql/04_dws_user_behavior_daily.sql
mysql -u root < sql/05_ads_metrics.sql

mysql -u root -e "USE ecommerce_dw; SELECT * FROM ads_daily_overview; SELECT * FROM ads_top_items_daily;"
```
