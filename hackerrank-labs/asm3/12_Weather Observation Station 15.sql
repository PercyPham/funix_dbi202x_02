SELECT CONVERT(DECIMAL(10,4), LONG_W)
FROM STATION
WHERE LAT_N = (
    SELECT MAX(LAT_N) FROM STATION WHERE LAT_N < 137.2345
);
