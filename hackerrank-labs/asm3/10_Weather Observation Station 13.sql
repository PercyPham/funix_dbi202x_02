SELECT
    CONVERT(DECIMAL(10,4), SUM(LAT_N))
FROM STATION
WHERE LAT_N > 38.788 AND LAT_N < 137.2345;
