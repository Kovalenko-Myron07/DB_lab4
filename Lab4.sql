-----АГРЕГАЦІЯ-----


// Загальна вартість всього майна

SELECT SUM(Price) AS Total_Asset_Value
FROM Asset;

//Кількість одиниць майна в кожній категорії

SELECT CategoryID, COUNT(*) AS Asset_Count
FROM Asset
GROUP BY CategoryID;

//статистика цін по всьому майну

SELECT 
    MIN(Price) AS Min_Price, 
    MAX(Price) AS Max_Price, 
    ROUND(AVG(Price), 2) AS Avg_Price
FROM Asset;


//Категорії, середня вартість майна в яких перевищує 10000 грн

SELECT CategoryID, ROUND(AVG(Price), 2) AS Average_Category_Price
FROM Asset
GROUP BY CategoryID
HAVING AVG(Price) > 10000;

//кількість майна виданого кожному співробітнику

SELECT Employee.FullName, COUNT(Asset_Allocation.AssetID) AS Items_Allocated
FROM Employee
JOIN Asset_Allocation ON Employee.EmployeeID = Asset_Allocation.EmployeeID
GROUP BY Employee.FullName;


//вартість та кількість майна в кабінетах

SELECT 
    Room.RoomNumber AS "Номер кабінету", 
    COUNT(Asset.AssetID) AS "Кількість речей",
    SUM(Asset.Price) AS "Загальна вартість (грн)"
FROM Room
LEFT JOIN Asset_Allocation ON Room.RoomID = Asset_Allocation.RoomID
LEFT JOIN Asset ON Asset_Allocation.AssetID = Asset.AssetID
GROUP BY Room.RoomNumber;




----- Використання JOIN -----


//Перелік майна разом з назвами категорій (якщо задані)

SELECT Asset.InventoryNumber, Asset.AssetName, Asset.Price, Category.CategoryName
FROM Asset
INNER JOIN Category ON Asset.CategoryID = Category.CategoryID;


//співробітники та їхнє майно

SELECT Employee.FullName, Asset.AssetName, Asset_Allocation.IssueDate
FROM Employee
LEFT JOIN Asset_Allocation ON Employee.EmployeeID = Asset_Allocation.EmployeeID
LEFT JOIN Asset ON Asset_Allocation.AssetID = Asset.AssetID
ORDER BY Employee.FullName;


//кабінети та майно в них

SELECT Room.RoomNumber, Asset.AssetName
FROM Asset_Allocation
JOIN Asset ON Asset_Allocation.AssetID = Asset.AssetID
RIGHT JOIN Room ON Asset_Allocation.RoomID = Room.RoomID
ORDER BY Room.RoomNumber;


//всі можливих комбінації "Співробітник - Кабінет"

SELECT Employee.FullName, Room.RoomNumber
FROM Employee
CROSS JOIN Room;



----- ПІДЗАПИТИ -----

//найдорожче майно

SELECT Asset.AssetName, Asset.Price
FROM Asset
WHERE Asset.Price = (SELECT MAX(Asset.Price) FROM Asset);


//порівняння ціни з середнім значенням цін

SELECT 
    Asset.AssetName, 
    Asset.Price,
    ROUND(Asset.Price - (SELECT AVG(Asset.Price) FROM Asset), 2) AS Difference_From_Avg
FROM Asset;


//Категорії де сер.  ціна яких вища за загальну сер. ціну

SELECT 
    Category.CategoryName, 
    ROUND(AVG(Asset.Price), 2) AS "Середня ціна в категорії"
FROM Asset
JOIN Category ON Asset.CategoryID = Category.CategoryID
GROUP BY Category.CategoryName
HAVING AVG(Asset.Price) > (SELECT AVG(Asset.Price) FROM Asset);