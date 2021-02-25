DECLARE @minLat DECIMAL(15,5);
DECLARE @minLong DECIMAL(15,5);

DECLARE @maxLat DECIMAL(15,5);
DECLARE @maxLong DECIMAL(15,5);

SELECT
    @minLat = MIN(LAT_N),
    @minLong = MIN(LONG_W),
    @maxLat = MAX(LAT_N),
    @maxLong = MAX(LONG_W)
FROM STATION;

SELECT CONVERT(DECIMAL(15, 4),ROUND(ABS(@maxLat - @minLat) + ABS(@maxLong - @minLong),4));
