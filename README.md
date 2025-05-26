# Online-Shop_ZJSU

## 项目介绍

这是一个基于Java和Microsoft SQL Server开发的在线商城系统，为浙江工商大学数据库应用课程的实践项目。该系统实现了用户注册登录、商品管理、购物车、订单处理、支付管理等功能，支持商家和普通用户两种角色。

## 技术栈

### 前端
- UI框架：Java Swing
- 界面设计：基于AWT和Swing组件的桌面应用界面

### 后端
- 编程语言：Java
- 数据库：Microsoft SQL Server
- 构建工具：Maven
- 数据库连接：JDBC (mssql-jdbc驱动)

## 系统功能

### 用户模块
- 用户注册与登录
- 个人信息管理
- 查看商品分类与商品
- 购物车管理
- 订单创建与查看
- 退货申请

### 商家模块
- 商品分类管理
- 商品上架与管理
- 订单处理
- 退货处理

## 数据库设计

系统包含以下主要数据表：
- Users：用户信息表
- Categories：商品分类表
- Products：商品表
- Cart：购物车表
- Orders：订单表
- OrderItems：订单项表
- Promotions：优惠活动表
- OrderPromotions：订单优惠记录表
- Payments：支付记录表
- Returns：退货记录表
- Deliveries：配送记录表
- StockChanges：库存变更记录表

## 项目结构

```
├── shop/                      # 主项目目录
│   ├── src/                   # 源代码
│   │   ├── main/java/         # Java源文件
│   │   │   ├── AddCategoryFrame.java       # 添加分类界面
│   │   │   ├── AddProductFrame.java        # 添加商品界面
│   │   │   ├── CreateOrderFrame.java       # 创建订单界面
│   │   │   ├── DatabaseConnection.java     # 数据库连接
│   │   │   ├── LoginFrame.java             # 登录界面
│   │   │   ├── ProcessOrderFrame.java      # 处理订单界面
│   │   │   ├── ProcessReturnFrame.java     # 处理退货界面
│   │   │   ├── RegisterFrame.java          # 注册界面
│   │   │   ├── SellerMainFrame.java        # 商家主界面
│   │   │   ├── UserMainFrame.java          # 用户主界面
│   │   │   ├── ViewCartFrame.java          # 查看购物车界面
│   │   │   ├── ViewCategoriesFrame.java    # 查看分类界面
│   │   │   ├── ViewOrdersFrame.java        # 查看订单界面
│   │   │   ├── ViewProductsFrame.java      # 查看商品界面
│   │   │   └── ViewUserOrdersFrame.java    # 查看用户订单界面
│   │   └── resources/         # 资源文件
│   ├── pom.xml                # Maven配置文件
│   └── target/                # 编译输出目录
├── TABLE_CREAT.sql            # 数据库表创建脚本
├── PROCEDURE_CREAT.sql        # 数据库存储过程创建脚本
└── 数据库应用.mp4              # 项目演示视频
```

## 安装与运行

### 前提条件
- JDK 11或更高版本
- Microsoft SQL Server
- Maven

### 数据库设置
1. 在SQL Server中创建一个新的数据库
2. 运行`TABLE_CREAT.sql`脚本创建表结构
3. 运行`PROCEDURE_CREAT.sql`脚本创建存储过程

### 应用配置
1. 修改`DatabaseConnection.java`中的数据库连接信息，包括服务器地址、数据库名称、用户名和密码

### 编译与运行
```bash
# 进入项目目录
cd shop

# 使用Maven编译项目
mvn clean package

# 运行应用
java -jar target/Shop-1.0-SNAPSHOT.jar
```

## 使用说明

1. 启动应用后，首先会显示登录界面
2. 新用户可以点击注册按钮创建账户
3. 登录后，根据用户类型（商家/普通用户）会进入不同的主界面
4. 普通用户可以浏览商品、添加到购物车、创建订单等
5. 商家可以管理商品、处理订单、处理退货等

## 开发者

浙江工商大学数据库应用课程学生
