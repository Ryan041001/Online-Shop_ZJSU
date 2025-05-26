go
--1.1 �û���Users��
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(200),
    UserType NVARCHAR(20) CHECK (UserType IN ('�̼�', '��ͨ�û�')) NOT NULL -- �û�����
);


go
--1.2 ��ƷƷ���Categories��
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL,
    ParentCategoryID INT,
    FOREIGN KEY (ParentCategoryID) REFERENCES Categories(CategoryID)
);


go
--1.3 ��Ʒ��Products��
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    CategoryID INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL,
    Status NVARCHAR(20) CHECK (Status IN ('�ϼ�', '�¼�')) DEFAULT '�ϼ�',
    SellerID INT NOT NULL, -- �̼��û�ID
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (SellerID) REFERENCES Users(UserID)
);


go
--1.4 ���ﳵ��Cart��
CREATE TABLE Cart (
    CartID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);


go
--1.5 ������Orders��
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1), -- ��������
    UserID INT NOT NULL, -- �û�ID
    TotalAmount DECIMAL(10, 2) NOT NULL, -- �����ܽ��
    Status NVARCHAR(20) CHECK (Status IN ('��֧��', '��֧��', '��ȡ��', '�����')) DEFAULT '��֧��', -- ����״̬
    CreateTime DATETIME DEFAULT GETDATE(), -- ����ʱ��
    PayTime DATETIME, -- ֧��ʱ��
    DeliveryAddress NVARCHAR(200), -- ���͵�ַ
	ProductID INT NOT NULL
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);


go
--1.6 �������OrderItems��
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY IDENTITY(1,1), -- ��������
    OrderID INT NOT NULL, -- ����ID
    ProductID INT NOT NULL, -- ��ƷID
    Quantity INT NOT NULL CHECK (Quantity > 0), -- ��Ʒ����
    UnitPrice DECIMAL(10, 2) NOT NULL, -- ��Ʒ����
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);


go
--1.7 �Żݻ��Promotions��
CREATE TABLE Promotions (
    PromotionID INT PRIMARY KEY IDENTITY(1,1), -- ��������
    PromotionName NVARCHAR(100) NOT NULL, -- �����
    PromotionType NVARCHAR(20) CHECK (PromotionType IN ('����', '�ۿ�')), -- �����
    DiscountAmount DECIMAL(10, 2), -- �Żݽ����ۿ۱���
    Condition DECIMAL(10, 2), -- ��������
    StartTime DATETIME, -- ��ʼʱ��
    EndTime DATETIME, -- ����ʱ��
    CHECK ((PromotionType = '����' AND DiscountAmount > 0) OR (PromotionType = '�ۿ�' AND DiscountAmount BETWEEN 0 AND 100))
);


go
--1.8 �����Żݼ�¼��OrderPromotions��
CREATE TABLE OrderPromotions (
    OrderPromotionID INT PRIMARY KEY IDENTITY(1,1), -- ��������
    OrderID INT NOT NULL, -- ����ID
    PromotionID INT NOT NULL, -- �ŻݻID
    DiscountAmount DECIMAL(10, 2) NOT NULL, -- ʵ���Żݽ��
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (PromotionID) REFERENCES Promotions(PromotionID)
);


go
--1.9֧����¼��Payments��
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1), -- ��������
    OrderID INT NOT NULL, -- ����ID
    PaymentMethod NVARCHAR(50) NOT NULL, -- ֧����ʽ����֧������΢�š����п���
    Amount DECIMAL(10, 2) NOT NULL, -- ֧�����
    Status NVARCHAR(20) CHECK (Status IN ('��֧��', '��֧��', '֧��ʧ��')) DEFAULT '��֧��', -- ֧��״̬
    PayTime DATETIME, -- ֧��ʱ��
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


go
--1.10 �˻���¼��Returns��
CREATE TABLE Returns (
    ReturnID INT PRIMARY KEY IDENTITY(1,1), -- ��������
    OrderID INT NOT NULL, -- ����ID
    Reason NVARCHAR(MAX), -- �˻�ԭ��
    Status NVARCHAR(20) CHECK (Status IN ('������', '�Ѵ���')) DEFAULT '������', -- �˻�״̬
    ApplyTime DATETIME DEFAULT GETDATE(), -- ����ʱ��
    ProcessTime DATETIME, -- ����ʱ��
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


go
--1.11 ���ͼ�¼��Deliveries��
CREATE TABLE Deliveries (
    DeliveryID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    LogisticsCompany NVARCHAR(100),
    TrackingNumber NVARCHAR(100),
    Status NVARCHAR(20) CHECK (Status IN ('������', '�ѷ���', '��ǩ��')) DEFAULT '������',
    DeliveryTime DATETIME,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

--1.12 �������¼��StockChanges��
CREATE TABLE StockChanges (
    ChangeID INT PRIMARY KEY IDENTITY(1,1), -- ��������
    ProductID INT NOT NULL, -- ��ƷID
    ChangeType NVARCHAR(20) CHECK (ChangeType IN ('���', '����')), -- �������
    ChangeQuantity INT NOT NULL CHECK (ChangeQuantity > 0), -- �������
    ChangeTime DATETIME DEFAULT GETDATE(), -- ���ʱ��
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);