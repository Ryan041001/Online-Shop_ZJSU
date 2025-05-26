go
--2.1 �û�ע��
CREATE PROCEDURE RegisterUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20),
    @Address NVARCHAR(200),
    @UserType NVARCHAR(20)
AS
BEGIN
    IF @UserType NOT IN ('�̼�', '��ͨ�û�')
    BEGIN
        PRINT '�����û����Ͳ��Ϸ���';
        RETURN;
    END

    INSERT INTO Users (Username, Password, Email, Phone, Address, UserType)
    VALUES (@Username, @Password, @Email, @Phone, @Address, @UserType);
    PRINT '�û�ע��ɹ���';
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
    IF @UserType NOT IN ('��ͨ�û�', '�̼�')
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
--2.2 �û���¼
-- �޸ĺ���û���¼�洢����
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

-- 2.3.1�����Ʒ�����̼��û���
CREATE PROCEDURE InsertProduct
    @ProductName NVARCHAR(100),
    @Description NVARCHAR(MAX),
    @CategoryID INT,              -- ������ INT ����
    @Price DECIMAL(10, 2),
    @StockQuantity INT,
    @Status NVARCHAR(20),
    @SellerID INT                 -- ��� SellerID ����
AS
BEGIN
    -- ��֤�̼����
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @SellerID AND UserType = '�̼�')
    BEGIN
        PRINT '����ֻ���̼��û����������Ʒ��';
        RETURN;
    END

    -- ��֤�����Ƿ����
    IF NOT EXISTS (SELECT 1 FROM Categories WHERE CategoryID = @CategoryID)
    BEGIN
        PRINT '���󣺷��಻���ڣ�';
        RETURN;
    END

    -- ��֤״̬�Ƿ�Ϸ�
    IF @Status NOT IN ('�ϼ�', '�¼�')
    BEGIN
        PRINT '����״ֵ̬���Ϸ���';
        RETURN;
    END

    -- ������Ʒ
    INSERT INTO Products (ProductName, Description, CategoryID, Price, StockQuantity, Status, SellerID)
    VALUES (@ProductName, @Description, @CategoryID, @Price, @StockQuantity, @Status, @SellerID);

    PRINT '��Ʒ��ӳɹ���';
END;

go
--2.3.2�����ƷƷ��
CREATE PROCEDURE AddCategory
    @CategoryName NVARCHAR(100)
AS
BEGIN
    -- ���Ʒ�������Ƿ��Ѵ���
    IF EXISTS (SELECT 1 FROM Categories WHERE CategoryName = @CategoryName)
    BEGIN
        PRINT '����Ʒ�������Ѵ��ڣ�';
        RETURN;
    END

    -- ����Ʒ��
    INSERT INTO Categories (CategoryName)
    VALUES (@CategoryName);

    PRINT 'Ʒ����ӳɹ���';
END;

--2.3.3�鿴��ƷƷ��
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
--2.4.1 �����Ʒ�����ﳵ
CREATE PROCEDURE AddToCart
    @UserID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    -- �����Ʒ�Ƿ����
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
    BEGIN
        PRINT '������Ʒ�����ڣ�';
        RETURN;
    END

    -- ������Ƿ����
    DECLARE @StockQuantity INT;
    SELECT @StockQuantity = StockQuantity
    FROM Products
    WHERE ProductID = @ProductID;

    IF @StockQuantity < @Quantity
    BEGIN
        PRINT '���󣺿�治�㣡';
        RETURN;
    END

    -- �����Ʒ�����ﳵ
    INSERT INTO Cart (UserID, ProductID, Quantity)
    VALUES (@UserID, @ProductID, @Quantity);

    PRINT '��Ʒ����ӵ����ﳵ��';
END;
--2.4.2 �鿴���ﳵ
go
CREATE PROCEDURE GetCartItems
    @UserID INT
AS
BEGIN
    SELECT c.CartID, c.ProductID, p.ProductName, p.Price, c.Quantity
    FROM Cart c
    JOIN Products p ON c.ProductID = p.ProductID
    WHERE c.UserID = @UserID; -- �����û�ID��ȡ���ﳵ�е���Ʒ
END;

go
--2.4.3 �ӹ��ﳵ���Ƴ���Ʒ
CREATE PROCEDURE RemoveCartItem
    @CartID INT
AS
BEGIN
    -- ��鹺�ﳵ���Ƿ����
    IF NOT EXISTS (SELECT 1 FROM Cart WHERE CartID = @CartID)
    BEGIN
        PRINT '���󣺹��ﳵ����ڣ�';
        RETURN;
    END

    -- ɾ�����ﳵ��
    DELETE FROM Cart
    WHERE CartID = @CartID;

    PRINT '��Ʒ�Ѵӹ��ﳵ���Ƴ���';
END;

go
--2.5 ����������Ӧ���Ż�
CREATE PROCEDURE CreateOrderWithPromotion
    @UserID INT,
    @DeliveryAddress NVARCHAR(200)
AS
BEGIN
    DECLARE @TotalAmount DECIMAL(10, 2);
    DECLARE @OrderID INT;

    -- ���㹺�ﳵ�ܽ��
    SELECT @TotalAmount = SUM(p.Price * c.Quantity)
    FROM Cart c
    JOIN Products p ON c.ProductID = p.ProductID
    WHERE c.UserID = @UserID;

    -- ��������
    INSERT INTO Orders (UserID, TotalAmount, Status, DeliveryAddress)
    VALUES (@UserID, @TotalAmount, '��֧��', @DeliveryAddress);

    SET @OrderID = SCOPE_IDENTITY();

    -- ��Ӷ�����
    INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
    SELECT @OrderID, c.ProductID, c.Quantity, p.Price
    FROM Cart c
    JOIN Products p ON c.ProductID = p.ProductID
    WHERE c.UserID = @UserID;

    -- ��չ��ﳵ
    DELETE FROM Cart WHERE UserID = @UserID;

    -- Ӧ���Żݻ
    DECLARE @PromotionID INT, @PromotionType NVARCHAR(20), @DiscountAmount DECIMAL(10, 2), @Condition DECIMAL(10, 2);

    DECLARE PromotionCursor CURSOR FOR
    SELECT PromotionID, PromotionType, DiscountAmount, Condition
    FROM Promotions
    WHERE StartTime <= GETDATE() AND EndTime >= GETDATE();

    OPEN PromotionCursor;
    FETCH NEXT FROM PromotionCursor INTO @PromotionID, @PromotionType, @DiscountAmount, @Condition;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @PromotionType = '����' AND @TotalAmount >= @Condition
        BEGIN
            INSERT INTO OrderPromotions (OrderID, PromotionID, DiscountAmount)
            VALUES (@OrderID, @PromotionID, @DiscountAmount);
            SET @TotalAmount = @TotalAmount - @DiscountAmount;
        END
        ELSE IF @PromotionType = '�ۿ�' AND @TotalAmount >= @Condition
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

    -- ���¶����ܽ��
    UPDATE Orders
    SET TotalAmount = @TotalAmount
    WHERE OrderID = @OrderID;

    PRINT '���������ɹ����Ż���Ӧ�ã�';
END;



--2.6֧������
--2.6.1����֧����¼
go
CREATE PROCEDURE CreatePayment
    @OrderID INT,
    @PaymentMethod NVARCHAR(50)
AS
BEGIN
    -- ��鶩���Ƿ����
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
    BEGIN
        PRINT '���󣺶��������ڣ�';
        RETURN;
    END

    -- ��鶩��״̬�Ƿ�Ϊ��֧��
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID AND Status = '��֧��')
    BEGIN
        PRINT '���󣺶���״̬���Ǵ�֧����';
        RETURN;
    END

    -- ��ȡ�����Ĵ�֧�����
    DECLARE @Amount DECIMAL(10, 2);
    SELECT @Amount = TotalAmount
    FROM Orders
    WHERE OrderID = @OrderID;

    -- ����֧����¼
    INSERT INTO Payments (OrderID, PaymentMethod, Amount, Status)
    VALUES (@OrderID, @PaymentMethod, @Amount, '��֧��');

    PRINT '֧����¼�����ɹ���';
END;


--2.6.2����֧��״̬
go
CREATE PROCEDURE UpdatePaymentStatus
    @PaymentID INT,
    @Status NVARCHAR(20)
AS
BEGIN
    UPDATE Payments
    SET Status = @Status,
        PayTime = CASE WHEN @Status = '��֧��' THEN GETDATE() ELSE PayTime END
    WHERE PaymentID = @PaymentID;
    PRINT '֧��״̬���³ɹ���';
END;

--2.7�˻�����
--2.7.1�����˻�
go
CREATE PROCEDURE ApplyReturn
    @UserID INT,
    @OrderID INT,
    @Reason NVARCHAR(MAX)
AS
BEGIN
    -- ����û�����Ƿ�Ϊ��ͨ�û�
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND UserType = '��ͨ�û�')
    BEGIN
        PRINT '���󣺽���ͨ�û����������˻���';
        RETURN;
    END

    -- �����˻���¼
    INSERT INTO Returns (OrderID, Reason, Status)
    VALUES (@OrderID, @Reason, '������');
    PRINT '�˻��������ύ��';
END;
go
alter PROCEDURE ApplyReturn
    @UserID INT,
    @OrderID INT,
    @Reason NVARCHAR(MAX)
AS
BEGIN
    -- ����û�����Ƿ�Ϊ��ͨ�û�
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND UserType = '��ͨ�û�')
    BEGIN
        PRINT '���󣺽���ͨ�û����������˻���';
        RETURN;
    END

    -- �����˻���¼
    INSERT INTO Returns (OrderID, Reason, Status)
    VALUES (@OrderID, @Reason, '������');
    PRINT '�˻��������ύ��';
END;

--2.7.2�����˻�
go
CREATE PROCEDURE ProcessReturn
    @SellerID INT,
    @ReturnID INT,
    @Status NVARCHAR(20)
AS
BEGIN
    -- ��֤�̼��Ƿ���Ȩ�����˻�
    IF NOT EXISTS (
        SELECT 1 
        FROM Returns r
        JOIN Orders o ON r.OrderID = o.OrderID
        JOIN OrderItems oi ON o.OrderID = oi.OrderID
        JOIN Products p ON oi.ProductID = p.ProductID
        WHERE r.ReturnID = @ReturnID AND p.SellerID = @SellerID
    )
    BEGIN
        PRINT '��������Ȩ������˻���';
        RETURN;
    END

    -- �����˻�״̬
    UPDATE Returns
    SET Status = @Status,
        ProcessTime = CASE WHEN @Status = '�Ѵ���' THEN GETDATE() ELSE ProcessTime END
    WHERE ReturnID = @ReturnID;
    PRINT '�˻�������ɣ�';
END;

--2.8�������͹���
--2.8.1�������ͼ�¼
go
-- �޸�2.8.1�������ͼ�¼
CREATE PROCEDURE CreateDelivery
    @SellerID INT,
    @OrderID INT,
    @LogisticsCompany NVARCHAR(100),
    @TrackingNumber NVARCHAR(100)
AS
BEGIN
    -- ��֤�̼��Ƿ���Ȩ��������
    IF NOT EXISTS (
        SELECT 1 
        FROM Orders o
        JOIN OrderItems oi ON o.OrderID = oi.OrderID
        JOIN Products p ON oi.ProductID = p.ProductID
        WHERE o.OrderID = @OrderID AND p.SellerID = @SellerID
    )
    BEGIN
        PRINT '��������Ȩ�����˶��������ͼ�¼��';
        RETURN;
    END

    -- �������ͼ�¼
    INSERT INTO Deliveries (OrderID, LogisticsCompany, TrackingNumber, Status)
    VALUES (@OrderID, @LogisticsCompany, @TrackingNumber, '������');
    PRINT '���ͼ�¼�����ɹ���';
END;

-- �޸�2.8.2��������״̬
GO
CREATE PROCEDURE UpdateDelivery
    @SellerID INT,
    @OrderID INT,
    @Status NVARCHAR(20)
AS
BEGIN
    -- ��֤�̼��Ƿ���Ȩ��������
    IF NOT EXISTS (
        SELECT 1 
        FROM Orders o
        JOIN OrderItems oi ON o.OrderID = oi.OrderID
        JOIN Products p ON oi.ProductID = p.ProductID
        WHERE o.OrderID = @OrderID AND p.SellerID = @SellerID
    )
    BEGIN
        PRINT '��������Ȩ���´˶���������״̬��';
        RETURN;
    END

    -- ��������״̬
    UPDATE Deliveries
    SET Status = @Status
    WHERE OrderID = @OrderID;

    PRINT '����״̬�Ѹ��£�';
END;


--2.8.2��������״̬
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
        PRINT '���󣺶��������ڸ��̼ң�';
        RETURN;
    END

    INSERT INTO Deliveries (OrderID, LogisticsCompany, TrackingNumber, Status)
    VALUES (@OrderID, @LogisticsCompany, @TrackingNumber, '�ѷ���');

    PRINT '������Ϣ�Ѹ��£�';
END;


--2.9��Ʒ����
--2.9.1����Ʒ��
go
CREATE PROCEDURE InsertCategory
    @CategoryName NVARCHAR(100),
    @ParentCategoryID INT
AS
BEGIN
    -- ��� ParentCategoryID �Ƿ���ڣ�����ṩ��
    IF @ParentCategoryID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Categories WHERE CategoryID = @ParentCategoryID)
    BEGIN
        PRINT '����ParentCategoryID �����ڣ�������Ӹ�Ʒ�࣡';
        RETURN; -- ��ֹ�洢����
    END

    -- ����Ʒ������
    INSERT INTO Categories (CategoryName, ParentCategoryID)
    VALUES (@CategoryName, @ParentCategoryID);

    PRINT 'Ʒ�����ɹ���';
END;



--2.10������
--2.10.1���ӿ��
go
-- �޸�2.10.1���ӿ��
CREATE PROCEDURE IncreaseStock
    @SellerID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    -- ��֤�̼��Ƿ�ӵ�и���Ʒ
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID AND SellerID = @SellerID)
    BEGIN
        PRINT '��������Ȩ��������Ʒ�Ŀ�棡';
        RETURN;
    END

    -- �����Ʒ�����ڣ����ʼ�����Ϊ0
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
    BEGIN
        INSERT INTO Products (ProductID, StockQuantity)
        VALUES (@ProductID, 0);
    END

    -- ���ӿ��
    UPDATE Products
    SET StockQuantity = StockQuantity + @Quantity
    WHERE ProductID = @ProductID;

    -- ��¼�������ʷ
    INSERT INTO StockChanges (ProductID, ChangeType, ChangeQuantity)
    VALUES (@ProductID, '���', @Quantity);

    PRINT '������ӳɹ���';
END;


--2.10.2���ٿ��
go
CREATE PROCEDURE DecreaseStock
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    -- �����Ʒ�Ƿ����
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
    BEGIN
        PRINT '������Ʒ�����ڣ�';
        RETURN; -- ��ֹ�洢����
    END

    -- ������Ƿ����
    DECLARE @CurrentStock INT;
    SELECT @CurrentStock = StockQuantity
    FROM Products
    WHERE ProductID = @ProductID;

    IF @CurrentStock < @Quantity
    BEGIN
        PRINT '���󣺿�治�㣡';
        RETURN; -- ��ֹ�洢����
    END

    -- ���ٿ��
    UPDATE Products
    SET StockQuantity = StockQuantity - @Quantity
    WHERE ProductID = @ProductID;

    -- ��¼�������ʷ
    INSERT INTO StockChanges (ProductID, ChangeType, ChangeQuantity)
    VALUES (@ProductID, '����', @Quantity);

    PRINT '�����ٳɹ���';
END;

--2.10.3��ѯ���
go
CREATE PROCEDURE GetStock
    @ProductID INT
AS
BEGIN
    -- �����Ʒ�Ƿ����
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
    BEGIN
        PRINT '������Ʒ�����ڣ�';
        RETURN; -- ��ֹ�洢����
    END

    -- ��ѯ���
    SELECT ProductID, ProductName, StockQuantity
    FROM Products
    WHERE ProductID = @ProductID;
END;
go
--2.11��ȡ��Ʒ�б�
CREATE PROCEDURE GetProducts
    @SellerID INT = NULL -- ��ѡ������Ĭ��Ϊ NULL
AS
BEGIN
    -- ��� @SellerID Ϊ NULL����ȡ�����ϼ���Ʒ
    -- ��� @SellerID ��Ϊ NULL����ȡָ���̼ҵ���Ʒ
    SELECT ProductID, ProductName, Price, StockQuantity
    FROM Products
    WHERE Status = '�ϼ�' -- ֻ��ȡ�ϼܵ���Ʒ
      AND (@SellerID IS NULL OR SellerID = @SellerID); -- ���� @SellerID ����
END;

--2.12��ȡ�����б�
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
    SET Status = '��֧��'
    WHERE OrderID = @OrderID;

    PRINT '����״̬�Ѹ���Ϊ��֧����';
END;