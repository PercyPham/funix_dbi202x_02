SELECT 
    CONVERT(DECIMAL(10, 2), ROUND(SUM(LAT_N), 2)),
    CONVERT(DECIMAL(10, 2), ROUND(SUM(LONG_W), 2))
FROM STATION;
