-- 1. Convert TransactionDate to proper DATETIME format
UPDATE test_assessment.assessment_dataset
SET TransactionDate = STR_TO_DATE(TransactionDate, '%m/%d/%Y %H:%i');

ALTER TABLE test_assessment.assessment_dataset
MODIFY COLUMN TransactionDate DATETIME;

-- 2. Identify missing values in key columns
SELECT TransactionDate, COUNT(*) AS missing_count
FROM test_assessment.assessment_dataset
WHERE TransactionDate IS NULL
GROUP BY TransactionDate;


SELECT 
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN CustomerID IS NULL OR CustomerID = 0 THEN 1 ELSE 0 END) AS Missing_CustomerID,
    SUM(CASE WHEN TransactionDate IS NULL THEN 1 ELSE 0 END) AS Missing_TransactionDate
FROM test_assessment.assessment_dataset;


-- 3(a). Handling missing value in CustomerID
UPDATE test_assessment.assessment_dataset
SET CustomerID = -1
WHERE CustomerID IS NULL OR CustomerID = 0;

-- 3(b). Handle Missing TransactionDate Values
UPDATE test_assessment.assessment_dataset s
LEFT JOIN (
    SELECT CustomerID, MAX(TransactionDate) AS LastTransaction
    FROM test_assessment.assessment_dataset
    WHERE TransactionDate IS NOT NULL
    GROUP BY CustomerID
) t ON s.CustomerID = t.CustomerID
SET s.TransactionDate = t.LastTransaction
WHERE s.TransactionDate IS NULL;

UPDATE test_assessment.assessment_dataset
SET TransactionDate = '2000-01-01 00:00:00'
WHERE TransactionDate IS NULL;

-- 3(c). Fill missing PaymentMethod with 'Unknown'
UPDATE test_assessment.assessment_dataset
SET PaymentMethod = COALESCE(PaymentMethod, 'Unknown');

-- 3(c). Fill missing ProductName with 'Unknown'
UPDATE test_assessment.assessment_dataset
SET ProductName = COALESCE(ProductName, 'Unknown');

-- 3(d). Fill missing StoreType with 'Unknown'
UPDATE test_assessment.assessment_dataset
SET StoreType = COALESCE(StoreType, 'Unknown');

-- 4. Standardize text formats (lowercase, trim spaces)
UPDATE test_assessment.assessment_dataset
SET City = TRIM(LOWER(City)),
    PaymentMethod = TRIM(LOWER(PaymentMethod));

-- 5 Identify duplicate rows and Delete
WITH duplicates AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY TransactionID ORDER BY TransactionDate) AS row_num
    FROM test_assessment.assessment_dataset
)
DELETE FROM test_assessment.assessment_dataset
WHERE TransactionID IN (SELECT TransactionID FROM duplicates WHERE row_num > 1);