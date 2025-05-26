go
--2.1 用户注册
CREATE PROCEDURE RegisterUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20),
    @Address NVARCHAR(200),
    @UserType NVARCHAR(20)
AS
BEGIN
    IF @UserType NOT IN ('商家', '普通用户')
    BEGIN
        PRINT '错误：用户类型不合法！';
        RETURN;
    END

    INSERT INTO Users (Username, Password, Email, Phone, Address, UserType)
    VALUES (@Username, @Password, @Email, @Phone, @Address, @UserType);
    PRINT '用户注册成功！';
END;
go
ALTER  PROCEDURE RegisterUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20),
    @Address NVARCHAR(200),
    @UserType NVARCHAR(20),
    @Result INT OUTPUT
AS
BEGIN
    IF @UserType NOT IN ('普通用户', '商家')
    BEGIN
        SET @Result = -1;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username)
    BEGIN
        SET @Result = -2;
        RETURN;
    END

    INSERT INTO Users (Username, Password, Email, Phone, Address, UserType)
    VALUES (@Username, @Password, @Email, @Phone, @Address, @UserType);
    SET @Result = 0;
END;

go
--2.2 用户登录
-- 修改后的用户登录存储过程
CREATE PROCEDURE LoginUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(100)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username AND Password = @Password)
        SELECT UserType FROM Users WHERE Username = @Username;
    ELSE
        SELECT NULL AS UserType;
END;


go

-- 2.3.1添加商品（仅商家用户）
CREATE PROCEDURE InsertProduct
    @ProductName NVARCHAR(100),
    @Description NVARCHAR(MAX),
    @CategoryID INT,              -- 必须是 INT 类型
    @Price DECIMAL(10, 2),
    @StockQuantity INT,
    @Status NVARCHAR(20),
    @SellerID INT                 -- 添加 SellerID 参数
AS
BEGIN
    -- 验证商家身份
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @SellerID AND UserType = '商家')
    BEGIN
        PRINT '错误：只有商家用户可以添加商品！';
        RETURN;
    END

    -- 验证分类是否存在
    IF NOT EXISTS (SELECT 1 FROM Categories WHERE CategoryID = @CategoryID)
    BEGIN
        PRINT '错误：分类不存在！';
        RETURN;
    END

    -- 验证状态是否合法
    IF @Status NOT IN ('上架', '下架')
    BEGIN
        PRINT '错误：状态值不合法！';
        RETURN;
    END

    -- 插入商品
    INSERT INTO Products (ProductName, Description, CategoryID, Price, StockQuantity, Status, SellerID)
    VALUES (@ProductName, @Description, @CategoryID, @Price, @StockQuantity, @Status, @SellerID);

    PRINT '商品添加成功！';
END;

go
--2.3.2添加商品品类
CREATE PROCEDURE AddCategory
    @CategoryName NVARCHAR(100)
AS
BEGIN
    -- 检查品类名称是否已存在
    IF EXISTS (SELECT 1 FROM Categories WHERE CategoryName = @CategoryName)
    BEGIN
        PRINT '错误：品类名称已存在！';
        RETURN;
    END

    -- 插入品类
    INSERT INTO Categories (CategoryName)
    VALUES (@CategoryName);

    PRINT '品类添加成功！';
END;

--2.3.3查看商品品类
go
CREATE PROCEDURE GetCategories
AS
BEGIN
    SELECT CategoryID, CategoryName
    FROM Categories;
END;
go
CREATE PROCEDURE GetCategoryIdByName
    @CategoryName NVARCHAR(100)
AS
BEGIN
    SELECT CategoryID
    FROM Categories
    WHERE CategoryName = @CategoryName;
END;
go
alter PROCEDURE GetCategoryIdByName
    @CategoryName NVARCHAR(100)
AS
BEGIN
    SELECT CategoryID
    FROM Categories
    WHERE CategoryName = @CategoryName;
END;

go
--2.4.1 添加商品到购物车
CREATE PROCEDURE AddToCart
    @UserID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    -- 检查商品是否存在
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
    BEGIN
        PRINT '错误：商品不存在！';
        RETURN;
    END

    -- 检查库存是否充足
    DECLARE @StockQuantity INT;
    SELECT @StockQuantity = StockQuantity
    FROM Products
    WHERE ProductID = @ProductID;

    IF @StockQuantity < @Quantity
    BEGIN
        PRINT '错误：库存不足！';
        RETURN;
    END

    -- 添加商品到购物车
    INSERT INTO Cart (UserID, ProductID, Quantity)
    VALUES (@UserID, @ProductID, @Quantity);

    PRINT '商品已添加到购物车！';
END;
--2.4.2 查看购物车
go
CREATE PROCEDURE GetCartItems
    @UserID INT
AS
BEGIN
    SELECT c.CartID, c.ProductID, p.ProductName, p.Price, c.Quantity
    FROM Cart c
    JOIN Products p ON c.ProductID = p.ProductID
    WHERE c.UserID = @UserID; -- 根据用户ID获取购物车中的商品
END;

go
--2.4.3 从购物车中移除商品
CREATE PROCEDURE RemoveCartItem
    @CartID INT
AS
BEGIN
    -- 检查购物车项是否存在
    IF NOT EXISTS (SELECT 1 FROM Cart WHERE CartID = @CartID)
    BEGIN
        PRINT '错误：购物车项不存在！';
        RETURN;
    END

    -- 删除购物车项
    DELETE FROM Cart
    WHERE CartID = @CartID;

    PRINT '商品已从购物车中移除！';
END;

go
--2.5 创建订单并应用优惠
CREATE PROCEDURE CreateOrderWithPromotion
    @UserID INT,
    @DeliveryAddress NVARCHAR(200)
AS
BEGIN
    DECLARE @TotalAmount DECIMAL(10, 2);
    DECLARE @OrderID INT;

    -- 计算购物车总金额
    SELECT @TotalAmount = SUM(p.Price * c.Quantity)
    FROM Cart c
    JOIN Products p ON c.ProductID = p.ProductID
    WHERE c.UserID = @UserID;

    -- 创建订单
    INSERT INTO Orders (UserID, TotalAmount, Status, DeliveryAddress)
    VALUES (@UserID, @TotalAmount, '待支付', @DeliveryAddress);

    SET @OrderID = SCOPE_IDENTITY();

    -- 添加订单项
    INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
    SELECT @OrderID, c.ProductID, c.Quantity, p.Price
    FROM Cart c
    JOIN Products p ON c.ProductID = p.ProductID
    WHERE c.UserID = @UserID;

    -- 清空购物车
    DELETE FROM Cart WHERE UserID = @UserID;

    -- 应用优惠活动
    DECLARE @PromotionID INT, @PromotionType NVARCHAR(20), @DiscountAmount DECIMAL(10, 2), @Condition DECIMAL(10, 2);

    DECLARE PromotionCursor CURSOR FOR
    SELECT PromotionID, PromotionType, DiscountAmount, Condition
    FROM Promotions
    WHERE StartTime <= GETDATE() AND EndTime >= GETDATE();

    OPEN PromotionCursor;
    FETCH NEXT FROM PromotionCursor INTO @PromotionID, @PromotionType, @DiscountAmount, @Condition;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @PromotionType = '满减' AND @TotalAmount >= @Condition
        BEGIN
            INSERT INTO OrderPromotions (OrderID, PromotionID, DiscountAmount)
            VALUES (@OrderID, @PromotionID, @DiscountAmount);
            SET @TotalAmount = @TotalAmount - @DiscountAmount;
        END
        ELSE IF @PromotionType = '折扣' AND @TotalAmount >= @Condition
        BEGIN
            DECLARE @Discount DECIMAL(10, 2) = @TotalAmount * (@DiscountAmount / 100);
            INSERT INTO OrderPromotions (OrderID, PromotionID, DiscountAmount)
            VALUES (@OrderID, @PromotionID, @Discount);
            SET @TotalAmount = @TotalAmount - @Discount;
        END

        FETCH NEXT FROM PromotionCursor INTO @PromotionID, @PromotionType, @DiscountAmount, @Condition;
    END

    CLOSE PromotionCursor;
    DEALLOCATE PromotionCursor;

    -- 更新订单总金额
    UPDATE Orders
    SET TotalAmount = @TotalAmount
    WHERE OrderID = @OrderID;

    PRINT '订单创建成功，优惠已应用！';
END;



--2.6支付管理
--2.6.1创建支付记录
go
CREATE PROCEDURE CreatePayment
    @OrderID INT,
    @PaymentMethod NVARCHAR(50)
AS
BEGIN
    -- 检查订单是否存在
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
    BEGIN
        PRINT '错误：订单不存在！';
        RETURN;
    END

    -- 检查订单状态是否为待支付
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID AND Status = '待支付')
    BEGIN
        PRINT '错误：订单状态不是待支付！';
        RETURN;
    END

    -- 获取订单的待支付金额
    DECLARE @Amount DECIMAL(10, 2);
    SELECT @Amount = TotalAmount
    FROM Orders
    WHERE OrderID = @OrderID;

    -- 插入支付记录
    INSERT INTO Payments (OrderID, PaymentMethod, Amount, Status)
    VALUES (@OrderID, @PaymentMethod, @Amount, '待支付');

    PRINT '支付记录创建成功！';
END;


--2.6.2更新支付状态
go
CREATE PROCEDURE UpdatePaymentStatus
    @PaymentID INT,
    @Status NVARCHAR(20)
AS
BEGIN
    UPDATE Payments
    SET Status = @Status,
        PayTime = CASE WHEN @Status = '已支付' THEN GETDATE() ELSE PayTime END
    WHERE PaymentID = @PaymentID;
    PRINT '支付状态更新成功！';
END;

--2.7退货管理
--2.7.1申请退货
go
CREATE PROCEDURE ApplyReturn
    @UserID INT,
    @OrderID INT,
    @Reason NVARCHAR(MAX)
AS
BEGIN
    -- 检查用户身份是否为普通用户
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND UserType = '普通用户')
    BEGIN
        PRINT '错误：仅普通用户可以申请退货！';
        RETURN;
    END

    -- 插入退货记录
    INSERT INTO Returns (OrderID, Reason, Status)
    VALUES (@OrderID, @Reason, '待处理');
    PRINT '退货申请已提交！';
END;
go
alter PROCEDURE ApplyReturn
    @UserID INT,
    @OrderID INT,
    @Reason NVARCHAR(MAX)
AS
BEGIN
    -- 检查用户身份是否为普通用户
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND UserType = '普通用户')
    BEGIN
        PRINT '错误：仅普通用户可以申请退货！';
        RETURN;
    END

    -- 插入退货记录
    INSERT INTO Returns (OrderID, Reason, Status)
    VALUES (@OrderID, @Reason, '待处理');
    PRINT '退货申请已提交！';
END;

--2.7.2处理退货
go
CREATE PROCEDURE ProcessReturn
    @SellerID INT,
    @ReturnID INT,
    @Status NVARCHAR(20)
AS
BEGIN
    -- 验证商家是否有权处理退货
    IF NOT EXISTS (
        SELECT 1 
        FROM Returns r
        JOIN Orders o ON r.OrderID = o.OrderID
        JOIN OrderItems oi ON o.OrderID = oi.OrderID
        JOIN Products p ON oi.ProductID = p.ProductID
        WHERE r.ReturnID = @ReturnID AND p.SellerID = @SellerID
    )
    BEGIN
        PRINT '错误：您无权处理此退货！';
        RETURN;
    END

    -- 更新退货状态
    UPDATE Returns
    SET Status = @Status,
        ProcessTime = CASE WHEN @Status = '已处理' THEN GETDATE() ELSE ProcessTime END
    WHERE ReturnID = @ReturnID;
    PRINT '退货处理完成！';
END;

--2.8订单配送管理
--2.8.1创建配送记录
go
-- 修改2.8.1创建配送记录
CREATE PROCEDURE CreateDelivery
    @SellerID INT,
    @OrderID INT,
    @LogisticsCompany NVARCHAR(100),
    @TrackingNumber NVARCHAR(100)
AS
BEGIN
    -- 验证商家是否有权操作订单
    IF NOT EXISTS (
        SELECT 1 
        FROM Orders o
        JOIN OrderItems oi ON o.OrderID = oi.OrderID
        JOIN Products p ON oi.ProductID = p.ProductID
        WHERE o.OrderID = @OrderID AND p.SellerID = @SellerID
    )
    BEGIN
        PRINT '错误：您无权创建此订单的配送记录！';
        RETURN;
    END

    -- 创建配送记录
    INSERT INTO Deliveries (OrderID, LogisticsCompany, TrackingNumber, Status)
    VALUES (@OrderID, @LogisticsCompany, @TrackingNumber, '待发货');
    PRINT '配送记录创建成功！';
END;

-- 修改2.8.2更新配送状态
GO
CREATE PROCEDURE UpdateDelivery
    @SellerID INT,
    @OrderID INT,
    @Status NVARCHAR(20)
AS
BEGIN
    -- 验证商家是否有权操作订单
    IF NOT EXISTS (
        SELECT 1 
        FROM Orders o
        JOIN OrderItems oi ON o.OrderID = oi.OrderID
        JOIN Products p ON oi.ProductID = p.ProductID
        WHERE o.OrderID = @OrderID AND p.SellerID = @SellerID
    )
    BEGIN
        PRINT '错误：您无权更新此订单的配送状态！';
        RETURN;
    END

    -- 更新配送状态
    UPDATE Deliveries
    SET Status = @Status
    WHERE OrderID = @OrderID;

    PRINT '配送状态已更新！';
END;


--2.8.2更新配送状态
go
CREATE PROCEDURE UpdateDelivery
    @SellerID INT,
    @OrderID INT,
    @LogisticsCompany NVARCHAR(100),
    @TrackingNumber NVARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Products p
        JOIN OrderItems oi ON p.ProductID = oi.ProductID
        WHERE p.SellerID = @SellerID AND oi.OrderID = @OrderID
    )
    BEGIN
        PRINT '错误：订单不属于该商家！';
        RETURN;
    END

    INSERT INTO Deliveries (OrderID, LogisticsCompany, TrackingNumber, Status)
    VALUES (@OrderID, @LogisticsCompany, @TrackingNumber, '已发货');

    PRINT '物流信息已更新！';
END;


--2.9商品管理
--2.9.1插入品类
go
CREATE PROCEDURE InsertCategory
    @CategoryName NVARCHAR(100),
    @ParentCategoryID INT
AS
BEGIN
    -- 检查 ParentCategoryID 是否存在（如果提供）
    IF @ParentCategoryID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Categories WHERE CategoryID = @ParentCategoryID)
    BEGIN
        PRINT '错误：ParentCategoryID 不存在，请先添加父品类！';
        RETURN; -- 终止存储过程
    END

    -- 插入品类数据
    INSERT INTO Categories (CategoryName, ParentCategoryID)
    VALUES (@CategoryName, @ParentCategoryID);

    PRINT '品类插入成功！';
END;



--2.10库存管理
--2.10.1增加库存
go
-- 修改2.10.1增加库存
CREATE PROCEDURE IncreaseStock
    @SellerID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    -- 验证商家是否拥有该商品
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID AND SellerID = @SellerID)
    BEGIN
        PRINT '错误：您无权操作该商品的库存！';
        RETURN;
    END

    -- 如果商品不存在，则初始化库存为0
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
    BEGIN
        INSERT INTO Products (ProductID, StockQuantity)
        VALUES (@ProductID, 0);
    END

    -- 增加库存
    UPDATE Products
    SET StockQuantity = StockQuantity + @Quantity
    WHERE ProductID = @ProductID;

    -- 记录库存变更历史
    INSERT INTO StockChanges (ProductID, ChangeType, ChangeQuantity)
    VALUES (@ProductID, '入库', @Quantity);

    PRINT '库存增加成功！';
END;


--2.10.2减少库存
go
CREATE PROCEDURE DecreaseStock
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    -- 检查商品是否存在
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
    BEGIN
        PRINT '错误：商品不存在！';
        RETURN; -- 终止存储过程
    END

    -- 检查库存是否充足
    DECLARE @CurrentStock INT;
    SELECT @CurrentStock = StockQuantity
    FROM Products
    WHERE ProductID = @ProductID;

    IF @CurrentStock < @Quantity
    BEGIN
        PRINT '错误：库存不足！';
        RETURN; -- 终止存储过程
    END

    -- 减少库存
    UPDATE Products
    SET StockQuantity = StockQuantity - @Quantity
    WHERE ProductID = @ProductID;

    -- 记录库存变更历史
    INSERT INTO StockChanges (ProductID, ChangeType, ChangeQuantity)
    VALUES (@ProductID, '出库', @Quantity);

    PRINT '库存减少成功！';
END;

--2.10.3查询库存
go
CREATE PROCEDURE GetStock
    @ProductID INT
AS
BEGIN
    -- 检查商品是否存在
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
    BEGIN
        PRINT '错误：商品不存在！';
        RETURN; -- 终止存储过程
    END

    -- 查询库存
    SELECT ProductID, ProductName, StockQuantity
    FROM Products
    WHERE ProductID = @ProductID;
END;
go
--2.11获取商品列表
CREATE PROCEDURE GetProducts
    @SellerID INT = NULL -- 可选参数，默认为 NULL
AS
BEGIN
    -- 如果 @SellerID 为 NULL，获取所有上架商品
    -- 如果 @SellerID 不为 NULL，获取指定商家的商品
    SELECT ProductID, ProductName, Price, StockQuantity
    FROM Products
    WHERE Status = '上架' -- 只获取上架的商品
      AND (@SellerID IS NULL OR SellerID = @SellerID); -- 根据 @SellerID 过滤
END;

--2.12获取订单列表
go
CREATE PROCEDURE GetSellerOrders
    @SellerID INT
AS
BEGIN
    SELECT o.OrderID, o.UserID, o.TotalAmount, o.Status, o.DeliveryAddress
    FROM Orders o
    JOIN OrderItems oi ON o.OrderID = oi.OrderID
    JOIN Products p ON oi.ProductID = p.ProductID
    WHERE p.SellerID = @SellerID;
END;

go
CREATE PROCEDURE GetUserOrders
    @UserID INT
AS
BEGIN
    SELECT OrderID, TotalAmount, Status, DeliveryAddress
    FROM Orders
    WHERE UserID = @UserID;
END;

go

CREATE PROCEDURE UpdateOrderStatus
    @OrderID INT
AS
BEGIN
    UPDATE Orders
    SET Status = '已支付'
    WHERE OrderID = @OrderID;

    PRINT '订单状态已更新为已支付！';
END;