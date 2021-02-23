DECLARE @totalCount INT;
DECLARE @distinctCount INT;

SELECT @totalCount = COUNT(*) FROM STATION;
SELECT @distinctCount = COUNT(DISTINCT CITY) FROM STATION;

SELECT @totalCount - @distinctCount;
