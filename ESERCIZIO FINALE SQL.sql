CREATE DATABASE ToysGroup;
USE ToysGroup;

CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(100) NOT NULL
);

CREATE TABLE Region (
    RegionID INT PRIMARY KEY,
    State VARCHAR(100) NOT NULL,
    SalesRegion VARCHAR(100) NOT NULL
);

CREATE TABLE Sales (
    SalesID INT PRIMARY KEY,
    ProductID INT NOT NULL,
    RegionID INT NOT NULL,
    SalesDate DATE NOT NULL,
    Quantity INT NOT NULL,
    SalesAmount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);
INSERT INTO Product (ProductID, ProductName, Category) VALUES
(1, 'Bikes-100', 'Bikes'),
(2, 'Bikes-200', 'Bikes'),
(3, 'Helmet-100', 'Accessories'),
(4, 'Gloves-100', 'Accessories'),
(5, 'Ball-100', 'Sports');

INSERT INTO Region (RegionID, State, SalesRegion) VALUES
(1, 'France', 'WestEurope'),
(2, 'Germany', 'WestEurope'),
(3, 'Italy', 'SouthEurope'),
(4, 'Spain', 'SouthEurope');

INSERT INTO Sales (SalesID, ProductID, RegionID, SalesDate, Quantity, SalesAmount) VALUES
(1, 1, 1, '2023-03-15', 2, 2400.00),
(2, 2, 2, '2023-06-10', 1, 1500.00),
(3, 3, 3, '2023-09-20', 5, 500.00),
(4, 1, 4, '2024-02-12', 3, 3600.00),
(5, 4, 1, '2024-05-18', 4, 320.00),
(6, 2, 3, '2024-08-25', 2, 3000.00),
(7, 3, 2, '2025-01-14', 6, 600.00),
(8, 1, 3, '2025-04-22', 1, 1200.00),
(9, 4, 4, '2025-07-30', 8, 640.00),
(10, 2, 1, '2025-10-05', 3, 4500.00),
(11, 1, 2, '2026-02-16', 2, 2400.00),
(12, 3, 4, '2026-06-08', 7, 700.00);

SELECT * FROM Product;
SELECT * FROM Region;
SELECT * FROM Sales;
SELECT ProductID, COUNT(*) AS Conteggio
FROM Product
GROUP BY ProductID
HAVING COUNT(*) > 1;

SELECT RegionID, COUNT(*) AS Conteggio
FROM Region
GROUP BY RegionID
HAVING COUNT(*) > 1;

SELECT SalesID, COUNT(*) AS Conteggio
FROM Sales
GROUP BY SalesID
HAVING COUNT(*) > 1;

SELECT
    s.SalesID,
    p.ProductID,
    p.Category,
    r.State,
    r.SalesRegion,
    s.SalesDate,
    DATEDIFF(CURDATE(), s.SalesDate) > 180 AS Oltre180Giorni
FROM Sales s
INNER JOIN Product p
    ON s.ProductID = p.ProductID
INNER JOIN Region r
    ON s.RegionID = r.RegionID;

SELECT COUNT(*) AS TotaleSales
FROM Sales;

SELECT COUNT(*) AS TotaleJoin
FROM Sales s
INNER JOIN Product p
    ON s.ProductID = p.ProductID
INNER JOIN Region r
    ON s.RegionID = r.RegionID;
    SELECT
    ProductID,
    YEAR(SalesDate) AS Anno,
    SUM(SalesAmount) AS FatturatoTotale
FROM Sales
GROUP BY ProductID, YEAR(SalesDate)
ORDER BY Anno, ProductID;


SELECT
    r.State,
    YEAR(s.SalesDate) AS Anno,
    SUM(s.SalesAmount) AS FatturatoTotale
FROM Sales s
INNER JOIN Region r
    ON s.RegionID = r.RegionID
GROUP BY r.State, YEAR(s.SalesDate)
ORDER BY Anno, FatturatoTotale DESC;


SELECT
    p.Category,
    SUM(s.Quantity) AS QuantitaTotale
FROM Sales s
INNER JOIN Product p
    ON s.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY QuantitaTotale DESC
LIMIT 1;

SELECT ProductID, TotaleVenduto
FROM (
    SELECT
        ProductID,
        SUM(Quantity) AS TotaleVenduto
    FROM Sales
    WHERE YEAR(SalesDate) = (
        SELECT MAX(YEAR(SalesDate))
        FROM Sales
    )
    GROUP BY ProductID
) AS VenditeProdotto
WHERE TotaleVenduto > (
    SELECT AVG(TotaleVenduto)
    FROM (
        SELECT
            ProductID,
            SUM(Quantity) AS TotaleVenduto
        FROM Sales
        WHERE YEAR(SalesDate) = (
            SELECT MAX(YEAR(SalesDate))
            FROM Sales
        )
        GROUP BY ProductID
    ) AS MediaProdotti
);
WITH VenditeProdotto AS (
    SELECT
        ProductID,
        SUM(Quantity) AS TotaleVenduto
    FROM Sales
    WHERE YEAR(SalesDate) = (
        SELECT MAX(YEAR(SalesDate))
        FROM Sales
    )
    GROUP BY ProductID
),
MediaVendite AS (
    SELECT AVG(TotaleVenduto) AS Media
    FROM VenditeProdotto
)
SELECT
    ProductID,
    TotaleVenduto
FROM VenditeProdotto
WHERE TotaleVenduto > (
    SELECT Media
    FROM MediaVendite
);
WITH TotaliProdotto AS (
    SELECT
        p.ProductID,
        p.Category,
        SUM(s.SalesAmount) AS FatturatoTotale
    FROM Product p
    INNER JOIN Sales s
        ON p.ProductID = s.ProductID
    GROUP BY p.ProductID, p.Category
)
SELECT
    ProductID,
    Category,
    FatturatoTotale,
    RANK() OVER (
        PARTITION BY Category
        ORDER BY FatturatoTotale DESC
    ) AS Posizione
FROM TotaliProdotto;WITH TotaliProdotto AS (
    SELECT
        p.ProductID,
        p.Category,
        SUM(s.SalesAmount) AS FatturatoTotale
    FROM Product p
    INNER JOIN Sales s
        ON p.ProductID = s.ProductID
    GROUP BY p.ProductID, p.Category
)
SELECT
    ProductID,
    Category,
    FatturatoTotale,
    RANK() OVER (
        PARTITION BY Category
        ORDER BY FatturatoTotale DESC
    ) AS Posizione
FROM TotaliProdotto;
SELECT
    SalesID,
    RegionID,
    SalesDate,
    SalesAmount,
    SUM(SalesAmount) OVER (
        PARTITION BY RegionID
        ORDER BY SalesDate, SalesID
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS TotaleProgressivo
FROM Sales;
SELECT
    SalesID,
    RegionID,
    SalesDate,
    SalesAmount,
    LAG(SalesAmount) OVER (
        PARTITION BY RegionID
        ORDER BY SalesDate, SalesID
    ) AS VenditaPrecedente
FROM Sales;

SELECT
    p.ProductID,
    p.ProductName
FROM Product p
LEFT JOIN Sales s
    ON p.ProductID = s.ProductID
WHERE s.ProductID IS NULL;
SELECT
    ProductID,
    ProductName
FROM Product p
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales s
    WHERE s.ProductID = p.ProductID
);
CREATE VIEW vw_Prodotti AS
SELECT
    ProductID,
    ProductName,
    Category
FROM Product;
CREATE VIEW vw_Geografia AS
SELECT
    RegionID,
    State,
    SalesRegion
FROM Region;
SELECT * FROM vw_Prodotti;

SELECT * FROM vw_Geografia;

-- Caso 1
-- PurchaseCost è un dato commerciale riservato e non deve essere esposto
-- in una vista pubblica. Si applica il principio di minimizzazione dei dati.

CREATE VIEW vw_prodotti_rivenditori AS
SELECT
    ProductID,
    ProductName,
    Category
FROM Product;


-- Caso 2
-- Il numero di telefono del fornitore è un dato personale e non deve essere
-- condiviso con il reparto marketing se non è necessario per la sua attività.
-- L'accesso deve essere limitato ai soli utenti autorizzati.


-- Caso 3
-- PurchaseCost e Margin sono informazioni commerciali sensibili.
-- La vista commerciale deve mostrare solo i dati necessari.

CREATE VIEW vw_sales_commerciale AS
SELECT
    SalesID,
    SalesAmount
FROM Sales;


-- Caso 4
-- Un log non deve conservare dati senza una politica di retention.
-- QueryText può inoltre contenere informazioni sensibili.
-- È quindi necessario limitare i dati registrati e prevedere una scadenza.

CREATE TABLE ReportAccessLog (
    AccessID INT PRIMARY KEY,
    UserID INT NOT NULL,
    AccessDate DATETIME NOT NULL,
    RetentionUntil DATE NOT NULL
);