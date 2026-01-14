# 图书管理系统 - SSM框架项目

## 项目简介
基于SSM（Spring + Spring MVC + MyBatis）框架开发的图书管理系统，实现了图书管理、借阅管理、用户管理等核心功能。

## 技术栈
- **后端**: Java 7, Spring 4.3, Spring MVC, MyBatis 3.5
- **前端**: Thymeleaf, Bootstrap, jQuery, ECharts
- **数据库**: MySQL 5.7
- **服务器**: Tomcat 8.0
- **构建工具**: Maven 3.x

## 功能模块
1. **用户管理**: 用户注册、登录、权限控制
2. **图书管理**: 图书CRUD、搜索、分类
3. **借阅管理**: 借书、还书、续借、逾期管理
4. **统计报表**: 图书分类统计、借阅趋势分析

## 快速开始

### 1. 环境准备
- JDK 1.7
- Tomcat 8.0
- MySQL 5.7
- Maven 3.x

### 2. 数据库配置
```bash
# 创建数据库
mysql -u root -p
CREATE DATABASE book_management;
USE book_management;

# 执行SQL脚本
source sql/book_management.sql