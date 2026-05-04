# Лабораторна робота №4: Аналітичні SQL-запити (OLAP)

## Опис проекту
У цій роботі реалізовано аналітичні запити до бази даних системи обліку майна. Використано агрегатні функції, групування даних, різні типи з'єднань (JOIN) та вкладені підзапити для генерації звітів.

---

## 1. Запити з агрегацією

 Знаходження загальної вартості всього майна
```
SELECT SUM(Price) AS Total_Asset_Value
FROM Asset;
```
Кількість одиниць майна в кожній категорії (ROUP BY та COUNT для аналізу розподілу техніки)
```
SELECT CategoryID, COUNT(*) AS Asset_Count
FROM Asset
GROUP BY CategoryID;
```
Статистика цін по всьому майну (астосування MIN, MAX та AVG з округленням ROUND до 2 знаків після коми.)
```
SELECT 
    MIN(Price) AS Min_Price, 
    MAX(Price) AS Max_Price, 
    ROUND(AVG(Price), 2) AS Avg_Price
FROM Asset;
```
Категорії, середня вартість майна в яких перевищує 10000 грн (Фільтрація через HAVING)
```
SELECT CategoryID, ROUND(AVG(Price), 2) AS Average_Category_Price
FROM Asset
GROUP BY CategoryID
HAVING AVG(Price) > 10000;
```
Кількість майна виданого кожному співробітнику
```
SELECT Employee.FullName, COUNT(Asset_Allocation.AssetID) AS Items_Allocated
FROM Employee
JOIN Asset_Allocation ON Employee.EmployeeID = Asset_Allocation.EmployeeID
GROUP BY Employee.FullName;
```
Вартість та кількість майна в кабінетах (Багатотаблична агрегація - 3 таблиці)
```
SELECT 
    Room.RoomNumber AS "Номер кабінету", 
    COUNT(Asset.AssetID) AS "Кількість речей",
    SUM(Asset.Price) AS "Загальна вартість (грн)"
FROM Room
LEFT JOIN Asset_Allocation ON Room.RoomID = Asset_Allocation.RoomID
LEFT JOIN Asset ON Asset_Allocation.AssetID = Asset.AssetID
GROUP BY Room.RoomNumber;
```

## 2.  Використання Join

Перелік майна разом з назвами категорій (якщо задані)
```
SELECT Asset.InventoryNumber, Asset.AssetName, Asset.Price, Category.CategoryName
FROM Asset
INNER JOIN Category ON Asset.CategoryID = Category.CategoryID;
```
Повний список співробітників та їхнього майна (можна побачити навіть тих працівників, за якими нічого не закріплено).
```
SELECT Employee.FullName, Asset.AssetName, Asset_Allocation.IssueDate
FROM Employee
LEFT JOIN Asset_Allocation ON Employee.EmployeeID = Asset_Allocation.EmployeeID
LEFT JOIN Asset ON Asset_Allocation.AssetID = Asset.AssetID
ORDER BY Employee.FullName;
```
Кабінети та майно в них 
```
SELECT Room.RoomNumber, Asset.AssetName
FROM Asset_Allocation
JOIN Asset ON Asset_Allocation.AssetID = Asset.AssetID
RIGHT JOIN Room ON Asset_Allocation.RoomID = Room.RoomID
ORDER BY Room.RoomNumber;
```
Всі можливі комбінації "Співробітник - Кабінет" (декартів добуток через CROSS JOIN)
```
SELECT Employee.FullName, Room.RoomNumber
FROM Employee
CROSS JOIN Room;
```

## 3.  Підзапити

Знаходження найдрожчого майна
```
SELECT Asset.AssetName, Asset.Price
FROM Asset
WHERE Asset.Price = (SELECT MAX(Asset.Price) FROM Asset);
```
Порівняння вартості окремої речі з середньою вартістю чогось в усій компанії
```
SELECT 
    Asset.AssetName, 
    Asset.Price,
    ROUND(Asset.Price - (SELECT AVG(Asset.Price) FROM Asset), 2) AS Difference_From_Avg
FROM Asset;
```
Категорії середня ціна майна яких вища за загальну середню ціну майна
 ```
SELECT 
    Category.CategoryName, 
    ROUND(AVG(Asset.Price), 2) AS "Середня ціна в категорії"
FROM Asset
JOIN Category ON Asset.CategoryID = Category.CategoryID
GROUP BY Category.CategoryName
HAVING AVG(Asset.Price) > (SELECT AVG(Asset.Price) FROM Asset);
```

