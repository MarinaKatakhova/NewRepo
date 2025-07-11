USE [CosmeticsShop]
GO
/****** Object:  User [admin_user]    Script Date: 14/05/2025 3:57:22 PM ******/
CREATE USER [admin_user] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [cosmetics_admin]    Script Date: 14/05/2025 3:57:22 PM ******/
CREATE USER [cosmetics_admin] FOR LOGIN [cosmetics_admin] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [cosmetics_employee]    Script Date: 14/05/2025 3:57:22 PM ******/
CREATE USER [cosmetics_employee] FOR LOGIN [cosmetics_employee] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [employee_user]    Script Date: 14/05/2025 3:57:22 PM ******/
CREATE USER [employee_user] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [Admin]    Script Date: 14/05/2025 3:57:22 PM ******/
CREATE ROLE [Admin]
GO
/****** Object:  DatabaseRole [Employee]    Script Date: 14/05/2025 3:57:22 PM ******/
CREATE ROLE [Employee]
GO
ALTER ROLE [Admin] ADD MEMBER [admin_user]
GO
ALTER ROLE [Admin] ADD MEMBER [cosmetics_admin]
GO
ALTER ROLE [Employee] ADD MEMBER [cosmetics_employee]
GO
ALTER ROLE [Employee] ADD MEMBER [employee_user]
GO
/****** Object:  Table [dbo].[Discounts]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Discounts](
	[DiscountID] [int] IDENTITY(1,1) NOT NULL,
	[DiscountName] [varchar](255) NOT NULL,
	[DiscountPercentage] [decimal](5, 2) NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
 CONSTRAINT [PK__Discount__E43F6DF6A7E3D5A5] PRIMARY KEY CLUSTERED 
(
	[DiscountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Products]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [varchar](255) NOT NULL,
	[Brand] [varchar](255) NOT NULL,
	[Category] [varchar](255) NOT NULL,
	[Price] [decimal](10, 2) NOT NULL,
	[Stock] [int] NOT NULL,
	[DiscountID] [int] NULL,
 CONSTRAINT [PK__Products__B40CC6ED9844E535] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderDetails]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetails](
	[OrderDetailID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Price] [decimal](10, 2) NOT NULL,
	[EmployeesID] [int] NULL,
 CONSTRAINT [PK__OrderDet__D3B9D30C67FB5179] PRIMARY KEY CLUSTERED 
(
	[OrderDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_AdminDashboard]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 6. Создание представлений для отчетов

-- Представление для администраторов (вся информация)
CREATE   VIEW [dbo].[vw_AdminDashboard]
AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.Brand,
    p.Category,
    p.Price,
    p.Stock,
    d.DiscountName,
    d.DiscountPercentage,
    d.StartDate AS DiscountStart,
    d.EndDate AS DiscountEnd,
    (SELECT COUNT(*) FROM [dbo].[OrderDetails] od WHERE od.ProductID = p.ProductID) AS TimesOrdered
FROM 
    [dbo].[Products] p
    LEFT JOIN [dbo].[Discounts] d ON p.DiscountID = d.DiscountID
GO
/****** Object:  View [dbo].[vw_EmployeeProducts]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Представление для сотрудников (ограниченная информация)
CREATE   VIEW [dbo].[vw_EmployeeProducts]
AS
SELECT 
    ProductID,
    ProductName,
    Brand,
    Category,
    Price,
    Stock,
    CASE 
        WHEN EXISTS (SELECT 1 FROM [dbo].[Discounts] d 
                   WHERE d.DiscountID = p.DiscountID AND GETDATE() BETWEEN d.StartDate AND d.EndDate)
        THEN 'Да'
        ELSE 'Нет'
    END AS HasDiscount
FROM 
    [dbo].[Products] p
WHERE 
    Stock > 0
GO
/****** Object:  Table [dbo].[Shipments]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Shipments](
	[ShipmentID] [int] IDENTITY(1,1) NOT NULL,
	[SupplierID] [int] NOT NULL,
	[ShipmentDate] [date] NOT NULL,
 CONSTRAINT [PK__Shipment__5CAD378D06D4A49D] PRIMARY KEY CLUSTERED 
(
	[ShipmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ShipmentDetails]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShipmentDetails](
	[ShipmentDetailID] [int] IDENTITY(1,1) NOT NULL,
	[ShipmentID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK__Shipment__047142C02527D218] PRIMARY KEY CLUSTERED 
(
	[ShipmentDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_CosmeticsReceiptReport]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_CosmeticsReceiptReport] AS
SELECT 
    p.ProductName AS [название товара],
    s.ShipmentDate AS [дата поступления],
    sd.Quantity AS [количество],
    'Стандартные условия хранения' AS [условия] -- Здесь можно добавить реальные условия из таблицы, если они есть
FROM 
    [dbo].[Shipments] s
    JOIN [dbo].[ShipmentDetails] sd ON s.ShipmentID = sd.ShipmentID
    JOIN [dbo].[Products] p ON sd.ProductID = p.ProductID
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](255) NULL,
	[LastName] [varchar](255) NOT NULL,
	[Email] [varchar](255) NOT NULL,
	[PhoneNumber] [varchar](20) NULL,
	[login] [nvarchar](max) NULL,
	[password] [nvarchar](max) NULL,
 CONSTRAINT [PK__Customer__A4AE64B8D6309C28] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employees]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employees](
	[EmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](255) NOT NULL,
	[LastName] [varchar](255) NOT NULL,
	[Position] [varchar](255) NOT NULL,
	[HireDate] [date] NOT NULL,
	[Salary] [decimal](10, 2) NOT NULL,
 CONSTRAINT [PK__Employee__7AD04FF19719F9D8] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[OrderDate] [date] NOT NULL,
	[TotalAmount] [decimal](10, 2) NOT NULL,
 CONSTRAINT [PK__Orders__C3905BAF4955C91D] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductRatings]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductRatings](
	[RatingID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[Rating] [int] NOT NULL,
	[Review] [text] NULL,
 CONSTRAINT [PK__ProductR__FCCDF85C8EB80B94] PRIMARY KEY CLUSTERED 
(
	[RatingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Suppliers]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Suppliers](
	[SupplierID] [int] IDENTITY(1,1) NOT NULL,
	[SupplierName] [varchar](255) NOT NULL,
	[ContactPerson] [varchar](255) NOT NULL,
	[PhoneNumber] [varchar](20) NULL,
	[Email] [varchar](255) NULL,
 CONSTRAINT [PK__Supplier__4BE66694A789A07B] PRIMARY KEY CLUSTERED 
(
	[SupplierID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK__OrderDeta__Order__5070F446] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK__OrderDeta__Order__5070F446]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK__OrderDeta__Produ__5165187F] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK__OrderDeta__Produ__5165187F]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Employees] FOREIGN KEY([EmployeesID])
REFERENCES [dbo].[Employees] ([EmployeeID])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_Employees]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK__Orders__Customer__4D94879B] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK__Orders__Customer__4D94879B]
GO
ALTER TABLE [dbo].[ProductRatings]  WITH CHECK ADD  CONSTRAINT [FK__ProductRa__Custo__619B8048] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[ProductRatings] CHECK CONSTRAINT [FK__ProductRa__Custo__619B8048]
GO
ALTER TABLE [dbo].[ProductRatings]  WITH CHECK ADD  CONSTRAINT [FK__ProductRa__Produ__60A75C0F] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[ProductRatings] CHECK CONSTRAINT [FK__ProductRa__Produ__60A75C0F]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Discounts] FOREIGN KEY([DiscountID])
REFERENCES [dbo].[Discounts] ([DiscountID])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Discounts]
GO
ALTER TABLE [dbo].[ShipmentDetails]  WITH CHECK ADD  CONSTRAINT [FK__ShipmentD__Produ__5BE2A6F2] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[ShipmentDetails] CHECK CONSTRAINT [FK__ShipmentD__Produ__5BE2A6F2]
GO
ALTER TABLE [dbo].[ShipmentDetails]  WITH CHECK ADD  CONSTRAINT [FK__ShipmentD__Shipm__5AEE82B9] FOREIGN KEY([ShipmentID])
REFERENCES [dbo].[Shipments] ([ShipmentID])
GO
ALTER TABLE [dbo].[ShipmentDetails] CHECK CONSTRAINT [FK__ShipmentD__Shipm__5AEE82B9]
GO
ALTER TABLE [dbo].[Shipments]  WITH CHECK ADD  CONSTRAINT [FK__Shipments__Suppl__5812160E] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Suppliers] ([SupplierID])
GO
ALTER TABLE [dbo].[Shipments] CHECK CONSTRAINT [FK__Shipments__Suppl__5812160E]
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateOrder]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Процедура для сотрудников (создание заказа)
CREATE   PROCEDURE [dbo].[sp_CreateOrder]
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT,
    @EmployeeID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Проверка наличия товара
        DECLARE @Stock INT
        SELECT @Stock = Stock FROM [dbo].[Products] WHERE ProductID = @ProductID
        
        IF @Stock < @Quantity
        BEGIN
            RAISERROR('Недостаточно товара на складе', 16, 1)
            RETURN
        END
        
        -- Получаем цену с учетом скидки
        DECLARE @Price DECIMAL(10,2)
        DECLARE @Discount DECIMAL(5,2) = 0
        
        SELECT @Discount = ISNULL(d.DiscountPercentage, 0)
        FROM [dbo].[Products] p
        LEFT JOIN [dbo].[Discounts] d ON p.DiscountID = d.DiscountID
        WHERE p.ProductID = @ProductID
            AND GETDATE() BETWEEN d.StartDate AND d.EndDate
        
        SELECT @Price = Price * (1 - @Discount/100) 
        FROM [dbo].[Products] 
        WHERE ProductID = @ProductID
        
        -- Создаем заказ
        DECLARE @OrderID INT
        
        INSERT INTO [dbo].[Orders] (CustomerID, OrderDate, TotalAmount)
        VALUES (@CustomerID, GETDATE(), @Price * @Quantity)
        
        SET @OrderID = SCOPE_IDENTITY()
        
        -- Добавляем детали заказа
        INSERT INTO [dbo].[OrderDetails] (OrderID, ProductID, Quantity, Price, EmployeesID)
        VALUES (@OrderID, @ProductID, @Quantity, @Price, @EmployeeID)
        
        -- Обновляем количество товара
        UPDATE [dbo].[Products]
        SET Stock = Stock - @Quantity
        WHERE ProductID = @ProductID
        
        COMMIT TRANSACTION
        
        SELECT @OrderID AS NewOrderID
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        
        THROW
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetProducts]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- ФУНКЦИОНАЛЬНАЯ НАГРУЗКА ДЛЯ СОТРУДНИКА
-- =============================================

-- Создание процедуры для просмотра продуктов (доступно всем)
CREATE   PROCEDURE [dbo].[sp_GetProducts]
    @CategoryID INT = NULL,
    @BrandID INT = NULL
AS
BEGIN
    SELECT 
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        b.BrandName,
        p.Price,
        p.StockQuantity
    FROM 
        Products p
        JOIN Categories c ON p.CategoryID = c.CategoryID
        JOIN Brands b ON p.BrandID = b.BrandID
    WHERE 
        p.IsActive = 1
        AND (@CategoryID IS NULL OR p.CategoryID = @CategoryID)
        AND (@BrandID IS NULL OR p.BrandID = @BrandID)
    ORDER BY 
        p.ProductName;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ManageDiscounts]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 4. Создание хранимых процедур для разделения функционала

-- Процедура только для администраторов (управление скидками)
CREATE   PROCEDURE [dbo].[sp_ManageDiscounts]
    @Action VARCHAR(10), -- 'ADD', 'UPDATE', 'DELETE'
    @DiscountID INT = NULL,
    @DiscountName VARCHAR(255) = NULL,
    @DiscountPercentage DECIMAL(5,2) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    IF IS_ROLEMEMBER('Admin') = 0
    BEGIN
        RAISERROR('Только администраторы могут управлять скидками', 16, 1)
        RETURN
    END
    
    IF @Action = 'ADD'
    BEGIN
        INSERT INTO [dbo].[Discounts] (DiscountName, DiscountPercentage, StartDate, EndDate)
        VALUES (@DiscountName, @DiscountPercentage, @StartDate, @EndDate)
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE [dbo].[Discounts]
        SET DiscountName = @DiscountName,
            DiscountPercentage = @DiscountPercentage,
            StartDate = @StartDate,
            EndDate = @EndDate
        WHERE DiscountID = @DiscountID
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM [dbo].[Discounts] WHERE DiscountID = @DiscountID
    END
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ManageUsers]    Script Date: 14/05/2025 3:57:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- ФУНКЦИОНАЛЬНАЯ НАГРУЗКА ДЛЯ АДМИНИСТРАТОРА
-- =============================================

-- Создание процедуры для управления пользователями (только для админа)
CREATE   PROCEDURE [dbo].[sp_ManageUsers]
    @Action NVARCHAR(10), -- 'CREATE', 'DELETE', 'ROLE'
    @Username NVARCHAR(50),
    @Password NVARCHAR(50) = NULL,
    @Role NVARCHAR(50) = NULL
AS
BEGIN
    IF IS_ROLEMEMBER('Admin', SYSTEM_USER) = 0
    BEGIN
        RAISERROR('Доступ запрещен: только администраторы могут управлять пользователями', 16, 1)
        RETURN
    END
    
    IF @Action = 'CREATE'
    BEGIN
        DECLARE @SQL NVARCHAR(500)
        SET @SQL = 'CREATE LOGIN ' + QUOTENAME(@Username) + ' WITH PASSWORD = ''' + @Password + ''''
        EXEC sp_executesql @SQL
        
        SET @SQL = 'CREATE USER ' + QUOTENAME(@Username) + ' FOR LOGIN ' + QUOTENAME(@Username)
        EXEC sp_executesql @SQL
        
        PRINT 'Пользователь ' + @Username + ' успешно создан'
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Username)
        BEGIN
            EXEC sp_dropuser @Username
            PRINT 'Пользователь ' + @Username + ' удален из базы данных'
        END
        
        IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @Username)
        BEGIN
            EXEC sp_droplogin @Username
            PRINT 'Логин ' + @Username + ' удален с сервера'
        END
    END
    ELSE IF @Action = 'ROLE' AND @Role IS NOT NULL
    BEGIN
        DECLARE @RoleExists BIT = 0
        IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Role AND type = 'R')
            SET @RoleExists = 1
        
        IF @RoleExists = 1
        BEGIN
            EXEC sp_addrolemember @Role, @Username
            PRINT 'Пользователь ' + @Username + ' добавлен в роль ' + @Role
        END
        ELSE
            PRINT 'Роль ' + @Role + ' не существует'
    END
END;
GO
