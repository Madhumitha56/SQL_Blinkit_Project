-- Clean inconsistent values in Item_Fat_Content
UPDATE blinkit_data
SET Item_Fat_Content = CASE
    WHEN Item_Fat_Content IN ('Low Fat', 'LF', 'low fat') THEN 'Low Fat'
    WHEN Item_Fat_Content IN ('Regular', 'reg') THEN 'Regular'
    ELSE Item_Fat_Content
END;

-- KPI 1: Total Sales
SELECT SUM(Total_Sales) AS Total_Sales FROM blinkit_data;

-- KPI 2: Average Sales
SELECT AVG(Total_Sales) AS Average_Sales FROM blinkit_data;

-- KPI 3: Number of Items Sold
SELECT COUNT(Item_Identifier) AS No_Of_Items FROM blinkit_data;

-- KPI 4: Average Rating
SELECT ROUND(AVG(Rating), 2) AS Avg_Rating FROM blinkit_data;

-- Total Sales by Item Fat Content
SELECT Item_Fat_Content, SUM(Total_Sales) AS Total_Sales
FROM blinkit_data
GROUP BY Item_Fat_Content;

-- Total Sales by Outlet Size
SELECT Outlet_Size, SUM(Total_Sales) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Size;

-- Total Sales by Establishment Year
SELECT Outlet_Establishment_Year, SUM(Total_Sales) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Establishment_Year;

-- Total Sales by Outlet Type
SELECT Outlet_Type, SUM(Total_Sales) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Type;

-- Total Sales by Item Type
SELECT Item_Type, SUM(Total_Sales) AS Total_Sales
FROM blinkit_data
GROUP BY Item_Type;

-- Sales Percentage by Outlet Location
SELECT 
    Outlet_Location_Type,
    CAST(SUM(Total_Sales) * 100.0 / (SELECT SUM(Total_Sales) FROM blinkit_data) AS DECIMAL(5,2)) AS Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Location_Type;

-- Pivot-style Summary: Fat Content vs Outlet Location
SELECT 
    Item_Fat_Content,
    SUM(CASE WHEN Outlet_Location_Type = 'Tier 1' THEN Total_Sales ELSE 0 END) AS Tier1_Sales,
    SUM(CASE WHEN Outlet_Location_Type = 'Tier 2' THEN Total_Sales ELSE 0 END) AS Tier2_Sales,
    SUM(CASE WHEN Outlet_Location_Type = 'Tier 3' THEN Total_Sales ELSE 0 END) AS Tier3_Sales
FROM blinkit_data
GROUP BY Item_Fat_Content;

-- Average Sales by Fat Content and Outlet Type
SELECT 
    Item_Fat_Content, 
    Outlet_Type, 
    ROUND(AVG(Total_Sales), 2) AS Avg_Sales
FROM blinkit_data
GROUP BY Item_Fat_Content, Outlet_Type
ORDER BY Avg_Sales DESC;

-- Top 5 Outlets with Highest Average Rating
SELECT 
    Outlet_Identifier, 
    ROUND(AVG(Rating), 2) AS Avg_Rating
FROM blinkit_data
GROUP BY Outlet_Identifier
ORDER BY Avg_Rating DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-- Items with Visibility Above 0.20 and Sales Over 5000
SELECT 
    Item_Identifier, 
    Item_Type, 
    Item_Visibility, 
    Total_Sales
FROM blinkit_data
WHERE Item_Visibility > 0.20 AND Total_Sales > 5000
ORDER BY Total_Sales DESC;

-- Window Function: Sales Contribution by Outlet
SELECT 
    Outlet_Identifier,
    SUM(Total_Sales) AS Outlet_Sales,
    ROUND(
        SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER(), 2
    ) AS Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Identifier
ORDER BY Sales_Percentage DESC;

-- Outlet Count by Size and Location Type
SELECT 
    Outlet_Size, 
    Outlet_Location_Type, 
    COUNT(DISTINCT Outlet_Identifier) AS Outlet_Count
FROM blinkit_data
GROUP BY Outlet_Size, Outlet_Location_Type
ORDER BY Outlet_Count DESC;

-- Identify Unrated Items
SELECT 
    Item_Identifier, 
    Item_Type, 
    Outlet_Identifier
FROM blinkit_data
WHERE Rating IS NULL OR Rating = 0;

-- Total Sales Per Year and Outlet
SELECT 
    Outlet_Establishment_Year, 
    Outlet_Identifier, 
    SUM(Total_Sales) AS Sales
FROM blinkit_data
GROUP BY Outlet_Establishment_Year, Outlet_Identifier
ORDER BY Outlet_Establishment_Year, Sales DESC;
