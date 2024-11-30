select * from [dbo].[DataCoSupplyChain]   -- to show all table data 

-- Delete useless Columns
ALTER TABLE [dbo].[DataCoSupplyChain]
DROP COLUMN [Customer_Password], -- Useless values 
[Customer_Email],                -- Useless values 
[Order_Item_Cardprod_Id],        --duplicated with Product card ID
[Product_Description],           -- Useless values 
[Order_Profit_Per_Order],         --duplicated with benifit per order
[Product_Image],                 -- Useless values 
[Product_Status],                -- Useless values 
[Order_Zipcode],                 -- Useless values 
[Order_Customer_Id],             --duplicated with customer ID
[Order_Item_Total],              --duplicated with Sales per Customer
[Order_Item_Product_Price],      --duplicated with Product Price
 [Category_Id]                   --duplicated with Product Category ID

  -- Checking missing data in some necessary columns shouldn't be null   
SELECT * FROM [dbo].[DataCoSupplyChain] WHERE
[Sales_per_customer] IS NULL OR
[Delivery_Status] IS NULL OR
[Late_delivery_risk] IS NULL OR
[Category_Id] IS NULL OR
[Category_Name] IS NULL OR
[Customer_Id] IS NULL OR
[Department_Id] IS NULL OR
[Department_Name] IS NULL OR
[Order_Id] IS NULL OR
[Order_Item_Discount] IS NULL OR
[Order_Item_Discount_Rate] IS NULL OR
[Order_Item_Id] IS NULL OR
[Sales] IS NULL OR
[Order_Item_Total] IS NULL OR
[Product_Category_Id] IS NULL OR
[Product_Name] IS NULL OR
[Product_Price] IS NULL


  -- Checking Dublication data
SELECT [Order_Id],[Order_Item_Id], COUNT(*) AS DuplicateCount
FROM [dbo].[DataCoSupplyChain]
GROUP BY [Order_Id],[Order_Item_Id]
HAVING COUNT(*) > 1;

-- Change Payment type 'payment' to Other
UPDATE [dbo].[DataCoSupplyChain]
SET [Type]= case 
when  [Type]='PAYMENT'then 'OTHER'
else  [Type]
end;

  -- Get Total Sales , total orders , Total Quanntaty , total profit
    -- total Discount , AVG Sales , total Customers 
SELECT CONCAT(ROUND((SUM([Sales])) / 1000000, 2), ' Million')
AS Total_Sales , 
COUNT(DISTINCT  [Order_Id]) AS Total_Orders ,
Sum([Order_Item_Quantity]) AS Total_quantity ,
CONCAT(ROUND((SUM([Benefit_per_order])) / 1000000, 2), ' Million')
AS Total_Prorfit ,
CONCAT(ROUND((SUM([Order_Item_Discount])) / 1000000, 2), ' Million')
AS Total_Discount ,
 ROUND ((SUM([Sales]) / count (DISTINCT [Customer_Id]) ), 2)
AS AVG_Sales_per_customer ,
COUNT(DISTINCT [Customer_Id]) AS Count_Of_Customers
FROM [dbo].[DataCoSupplyChain]

  --top 10 total sales , orders and customers per country  
SELECT top 10[Order_Country], 
CONCAT(ROUND((SUM([Sales])) / 1000, 2), ' K') AS Total_Sales , 
COUNT(DISTINCT  [Order_Id]) AS Total_Orders , COUNT( DISTINCT [Customer_Id]) AS Customer_num 
FROM [dbo].[DataCoSupplyChain]
GROUP BY [Order_Country]
ORDER BY ROUND((SUM([Sales])) / 1000, 2) DESC;

  --total sales , orders and customers per market  
SELECT [Market], 
CONCAT(ROUND((SUM([Sales])) / 1000, 2), ' K') AS Total_Sales , 
COUNT(DISTINCT  [Order_Id]) AS Total_Orders , COUNT( DISTINCT [Customer_Id]) AS Customer_num 
FROM [dbo].[DataCoSupplyChain]
GROUP BY [Market]
ORDER BY ROUND((SUM([Sales])) / 1000, 2) DESC;

 --total sales , orders and customers per Order Region  
 SELECT [Order_Region], 
CONCAT(ROUND((SUM([Sales])) / 1000, 2), ' K') AS Total_Sales , 
COUNT(DISTINCT  [Order_Id]) AS Total_Orders , COUNT(DISTINCT [Customer_Id]) AS Customer_num 
FROM [dbo].[DataCoSupplyChain]
GROUP BY [Order_Region]
ORDER BY ROUND((SUM([Sales])) / 1000, 2) DESC;

 --top 10 total sales and orders per CAT
 Select top 10 [Category_Name],
 CONCAT(ROUND((SUM([Sales])) / 1000, 0), ' K') AS Total_Sales ,
 COUNT(DISTINCT  [Order_Id]) AS Total_Orders 
FROM [dbo].[DataCoSupplyChain]
group by [Category_Name]
ORDER BY ROUND((SUM([Sales])) / 1000, 2) DESC;

--top 10 total sales and orders per Order Status
 Select [Order_Status],
 CONCAT(ROUND((SUM([Sales])) / 1000, 0), ' K') AS Total_Sales ,
 COUNT(DISTINCT  [Order_Id]) AS Total_Orders 
FROM [dbo].[DataCoSupplyChain]
group by [Order_Status]
ORDER BY ROUND((SUM([Sales])) / 1000, 2) DESC;


  --  most common payment method that Customers used to pay 
 SELECT [Type], count (*)
 as Number_of_using ,
CONCAT(CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5, 0)), ' %')
AS Percentage
 FROM [dbo].[DataCoSupplyChain]
 group by [Type]
 order by Number_of_using desc

   --  most common status of delivery 
SELECT [Delivery_Status],  COUNT(*)
AS Count_of_Status, 
CONCAT(CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5, 0)), ' %')
AS Percentage
FROM [dbo].[DataCoSupplyChain]
GROUP BY [Delivery_Status]
ORDER BY Count_of_Status DESC;


   --  most common Shipping Mode 
SELECT [Shipping_Mode],  COUNT(*) AS Count_of_mode, 
CONCAT(CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5, 0)), ' %')
AS Percentage
FROM [dbo].[DataCoSupplyChain]
GROUP BY [Shipping_Mode]
ORDER BY Count_of_mode DESC;


  --   add new column contain year from Shipping date column
   --   get Sales and total orders per Year
ALTER TABLE [dbo].[DataCoSupplyChain]
ADD year_column INT;

UPDATE [dbo].[DataCoSupplyChain]
SET [year_column] = YEAR ([shipping_date_DateOrders]) ;

SELECT [year_column],
CONCAT(ROUND((SUM([Sales])) / 1000000, 2), ' Milion')
AS Total_Sales_Per_year , COUNT(*) as Total_Orders_Per_year 
FROM [dbo].[DataCoSupplyChain]
GROUP BY [year_column]
ORDER BY ROUND((SUM([Sales])) / 1000, 2) DESC;
