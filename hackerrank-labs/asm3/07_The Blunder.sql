DECLARE @realAvg DECIMAL(7,2);
SELECT @realAvg = AVG(Salary) FROM EMPLOYEES;

DECLARE @mistakeAvg DECIMAL(7,2);
SELECT @mistakeAvg = AVG(
    CONVERT(
        INT,
        CASE 
            WHEN REPLACE(CONVERT(VARCHAR(6), Salary), '0', '') <> '' 
                THEN REPLACE(CONVERT(VARCHAR(6), Salary), '0', '')
            ELSE '0'
        END
    )
) FROM EMPLOYEES

SELECT CEILING(@realAvg - @mistakeAvg) + 1;
