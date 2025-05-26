go
--1.1 用户表（Users）
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(200),
    UserType NVARCHAR(20) CHECK (UserType IN ('商家', '普通用户')) NOT NULL -- 用户类型
);


go
--1.2 商品品类表（Categories）
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL,
    ParentCategoryID INT,
    FOREIGN KEY (ParentCategoryID) REFERENCES Categories(CategoryID)
);


go
--1.3 商品表（Products）
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    CategoryID INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL,
    Status NVARCHAR(20) CHECK (Status IN ('上架', '下架')) DEFAULT '上架',
    SellerID INT NOT NULL, -- 商家用户ID
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (SellerID) REFERENCES Users(UserID)
);


go
--1.4 购物车表（Cart）
CREATE TABLE Cart (
    CartID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);


go
--1.5 订单表（Orders）
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1), -- 自增主键
    UserID INT NOT NULL, -- 用户ID
    TotalAmount DECIMAL(10, 2) NOT NULL, -- 订单总金额
    Status NVARCHAR(20) CHECK (Status IN ('待支付', '已支付', '已取消', '已完成')) DEFAULT '待支付', -- 订单状态
    CreateTime DATETIME DEFAULT GETDATE(), -- 创建时间
    PayTime DATETIME, -- 支付时间
    DeliveryAddress NVARCHAR(200), -- 配送地址
	ProductID INT NOT NULL
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);


go
--1.6 订单项表（OrderItems）
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY IDENTITY(1,1), -- 自增主键
    OrderID INT NOT NULL, -- 订单ID
    ProductID INT NOT NULL, -- 商品ID
    Quantity INT NOT NULL CHECK (Quantity > 0), -- 商品数量
    UnitPrice DECIMAL(10, 2) NOT NULL, -- 商品单价
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);


go
--1.7 优惠活动表（Promotions）
CREATE TABLE Promotions (
    PromotionID INT PRIMARY KEY IDENTITY(1,1), -- 自增主键
    PromotionName NVARCHAR(100) NOT NULL, -- 活动名称
    PromotionType NVARCHAR(20) CHECK (PromotionType IN ('满减', '折扣')), -- 活动类型
    DiscountAmount DECIMAL(10, 2), -- 优惠金额或折扣比例
    Condition DECIMAL(10, 2), -- 满减条件
    StartTime DATETIME, -- 开始时间
    EndTime DATETIME, -- 结束时间
    CHECK ((PromotionType = '满减' AND DiscountAmount > 0) OR (PromotionType = '折扣' AND DiscountAmount BETWEEN 0 AND 100))
);


go
--1.8 订单优惠记录表（OrderPromotions）
CREATE TABLE OrderPromotions (
    OrderPromotionID INT PRIMARY KEY IDENTITY(1,1), -- 自增主键
    OrderID INT NOT NULL, -- 订单ID
    PromotionID INT NOT NULL, -- 优惠活动ID
    DiscountAmount DECIMAL(10, 2) NOT NULL, -- 实际优惠金额
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (PromotionID) REFERENCES Promotions(PromotionID)
);


go
--1.9支付记录表（Payments）
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1), -- 自增主键
    OrderID INT NOT NULL, -- 订单ID
    PaymentMethod NVARCHAR(50) NOT NULL, -- 支付方式（如支付宝、微信、银行卡）
    Amount DECIMAL(10, 2) NOT NULL, -- 支付金额
    Status NVARCHAR(20) CHECK (Status IN ('待支付', '已支付', '支付失败')) DEFAULT '待支付', -- 支付状态
    PayTime DATETIME, -- 支付时间
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


go
--1.10 退货记录表（Returns）
CREATE TABLE Returns (
    ReturnID INT PRIMARY KEY IDENTITY(1,1), -- 自增主键
    OrderID INT NOT NULL, -- 订单ID
    Reason NVARCHAR(MAX), -- 退货原因
    Status NVARCHAR(20) CHECK (Status IN ('待处理', '已处理')) DEFAULT '待处理', -- 退货状态
    ApplyTime DATETIME DEFAULT GETDATE(), -- 申请时间
    ProcessTime DATETIME, -- 处理时间
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


go
--1.11 配送记录表（Deliveries）
CREATE TABLE Deliveries (
    DeliveryID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    LogisticsCompany NVARCHAR(100),
    TrackingNumber NVARCHAR(100),
    Status NVARCHAR(20) CHECK (Status IN ('待发货', '已发货', '已签收')) DEFAULT '待发货',
    DeliveryTime DATETIME,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

--1.12 库存变更记录表（StockChanges）
CREATE TABLE StockChanges (
    ChangeID INT PRIMARY KEY IDENTITY(1,1), -- 自增主键
    ProductID INT NOT NULL, -- 商品ID
    ChangeType NVARCHAR(20) CHECK (ChangeType IN ('入库', '出库')), -- 变更类型
    ChangeQuantity INT NOT NULL CHECK (ChangeQuantity > 0), -- 变更数量
    ChangeTime DATETIME DEFAULT GETDATE(), -- 变更时间
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);