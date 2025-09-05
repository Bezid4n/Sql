--سؤال 1 – مجموع فروش هر مشتری
--برای هر مشتری مجموع مبلغ خریدش را محاسبه کنید .
--)مبلغ = UnitPrice * Qty * (1 - Discount)

SELECT CustomerID,
	   ROUND(SUM(UnitPrice*Quantity*(1-Discount)),2) totalSale
FROM Orders O
INNER JOIN [Order Details] OD ON O.OrderID=OD.OrderID
GROUP BY CustomerID
----------------------------------------------

--سؤال 2 – پرفروشترین محصول هر دستهبندی
--با استفاده از Window Function مشخص کنید در هر دستهبندی ) CategoryID ( کدام محصول بیشترین فروش را
--داشته است.

;WITH ProductCte AS
(
	SELECT P.ProductID,
		   P.ProductName,
		   P.CategoryID,
		   SUM(OD.Quantity) SumQnt,
		   ROW_NUMBER()OVER(PARTITION BY P.CategoryID ORDER BY SUM(OD.Quantity) DESC) RN
	FROM [Order Details] OD
	INNER JOIN Products P ON P.ProductID=OD.ProductID
	GROUP BY P.ProductID,
			 P.ProductName,
			 P.CategoryID	
)
SELECT CategoryID,
	   ProductName,
	   SumQnt
FROM ProductCte 
WHERE RN=1
----------------------------------------------
--سؤال 3 – مشتریان طلایی
--مشتریانی را پیدا کنید که مجموع خریدشان در بین ۵٪ بالایی کل مشتریان قرار دارد.

;WITH GoldenCustomer AS
(
	SELECT CustomerID,
		   SUM(Quantity) TotalQnt,
		   PERCENT_RANK()OVER(ORDER BY SUM(Quantity) DESC) PR
	FROM Orders O
	INNER JOIN [Order Details] OD ON O.OrderID=OD.OrderID
	GROUP BY CustomerID
)
SELECT CustomerID,
	   TotalQnt
FROM GoldenCustomer
WHERE PR>=0.95
ORDER BY TotalQnt
-------------------------------------------------------
--سؤال 4 – سابقه کار کارمندان
--کارمندان را به ترتیب بیشتری ن سابقه کار تا کمتری ن نمای ش دهید و رتبه بدهید. )سابقه = DATEDIFF(YEAR, HireDate, GETDATE())

SELECT EmployeeID,
	   CONCAT(TitleOfCourtesy,' ',FirstName,' ',LastName) EmployeeName,
	   DATEDIFF(YEAR,HireDate,GETDATE()) WorkHistoryYear,
	   DENSE_RANK()OVER(ORDER BY DATEDIFF(YEAR,HireDate,GETDATE()) DESC)
FROM Employees
----------------------------------------------------
--سؤال 5 – روند فروش ماهانه
--حجم فروش کل شرکت را به تفکیک ماه و سال نشان دهید و همچنین میانگین ۳ ماهه متحرک فروش را با Window Function محاسبه کنید.

;WITH MovingAvg AS
(
	SELECT YEAR(O.OrderDate) YearOrder,
		   MONTH(O.OrderDate) MonthOrder,
		   SUM(OD.Quantity) SumQnt
	FROM Orders O
	INNER JOIN [Order Details] OD ON O.OrderID=OD.OrderID
	GROUP BY YEAR(O.OrderDate),
		     MONTH(O.OrderDate)
)
SELECT *,
	   AVG(SumQnt)OVER(ORDER BY YearOrder,MonthOrder ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) MovingAvg3Months
FROM MovingAvg

