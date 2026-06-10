SELECT *
FROM Sales.SalesOrderDetail;

-- Total orders placed
select count(*) as total_orders from sales.SalesOrderDetail;

select * from Sales.SalesOrderHeader;

-- Total revenue of the company 
select sum(TotalDue) as Total_revenue
from Sales.SalesOrderHeader;

-- Avg order value
 select avg(TotalDue) as avg_order
 from Sales.SalesOrderHeader;

-- Find high-value order (above 5000)
select SalesOrderID , TotalDue 
from Sales.SalesOrderHeader 
where TotalDue > 5000;

-- Show all orders placed in 2013 along with the total number of orders in that year
SELECT 
    SalesOrderID,
    OrderDate,
    TotalDue,
    count(*) over() AS total_count
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013; 

--Total sales per customer
select CustomerID, sum(TotalDue) as total_spent
from Sales.SalesOrderHeader 
group by CustomerID;

-- Customers spending more than 10000
select CustomerID, sum(TotalDue) as total_spent
from Sales.SalesOrderHeader
group by CustomerID
having sum(TotalDue) > 10000;

-- How many orders were placed in each year?
select YEAR(OrderDate) as order_year,
count(*) as total_order 
from Sales.SalesOrderHeader
group by YEAR(OrderDate)
order by order_year;

-- Show first 10 customers by spending
select CustomerID , sum(TotalDue) as total_spent
from Sales.SalesOrderHeader
group by CustomerID
order by total_spent 
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- Which products are being sold?
select * from Production.Product;

select soh.SalesOrderID,
p.name as ProductName,
sod.LineTotal
from Sales.SalesOrderHeader soh
inner join Sales.SalesOrderDetail sod
on soh.SalesOrderID = sod.SalesOrderID
inner join Production.product p 
on sod.ProductID = p.ProductID;

-- Which product categories generate most revenue?

select pc.Name as category,
sum(sod.LineTotal) as revenue
from Sales.SalesOrderDetail sod
inner join Production.Product p on 
sod.ProductID = p.ProductID 
inner join Production.ProductSubcategory ps on 
p.ProductSubcategoryID = ps.ProductSubcategoryID
inner join Production.ProductCategory pc on 
ps.ProductCategoryID = pc.ProductCategoryID 
group by pc.Name
order by revenue desc;

-- Which customers have never placed an order?
select c.CustomerID , 
soh.SalesOrderID
from Sales.Customer c 
left join Sales.SalesOrderHeader soh 
on c.CustomerID = soh.CustomerID 
where soh.SalesOrderID is null ;

-- Show all sold products, even if product master data is missing
select p.Name,
sod.SalesOrderID 
from Production.Product p 
right join Sales.SalesOrderDetail sod 
on p.ProductID = sod.ProductID;

-- Identify the Top 5 highest-spending customers in each sales territory

select * from Sales.SalesTerritory;

select * from (
select 
    st.Name as Territory,
    soh.CustomerID,
    sum(soh.TotalDue) as total_spent,
    rank() over(
        partition by st.Name
        order by sum(soh.TotalDue) desc
    ) as customer_rank 
    from Sales.SalesOrderHeader soh 
    join Sales.SalesTerritory st
    on soh.TerritoryID = st.TerritoryID
    group by st.Name , soh.CustomerID
) ranked_customers
where customer_rank <=5;

-- Classify orders into Low, Medium, High

select SalesOrderID,
TotalDue,
case 
    when TotalDue < 1000 then 'Low'
    when TotalDue between 1000 and 5000 then 'Medium'
    else 'High'
end as oreder_type
from Sales.SalesOrderHeader;

-- Free Shipping / Paid Shipping

select SalesOrderID,
Freight,
case 
    when Freight = 0 Then 'Free Shipping'
    else 'Paid Shipping'
end as shipping_type 
from Sales.SalesOrderHeader; 


