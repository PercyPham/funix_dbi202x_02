DECLARE @row_count INT;
SELECT @row_count = COUNT(*) FROM STATION;

DECLARE @is_not_even BIT = CASE WHEN @row_count % 2 <> 0 THEN 1 ELSE 0 END;

DECLARE @median DECIMAL(15,4);

IF @is_not_even = 1
    BEGIN
        DECLARE @median_row_idx INT = CEILING(@row_count / 2);

        SELECT @median = LAT_N
        FROM STATION
        ORDER BY LAT_N
        OFFSET @median_row_idx ROWS FETCH NEXT 1 ROWS ONLY;
    END
ELSE
    BEGIN
        DECLARE @first_median_row_idx INT =  FLOOR(@row_count / 2);
        DECLARE @second_median_row_idx INT =  CEILING(@row_count / 2);
            
        DECLARE @first_num DECIMAL(15,4);
        DECLARE @second_num DECIMAL(15,4);

        SELECT @first_num = LAT_N FROM STATION ORDER BY LAT_N OFFSET @first_median_row_idx ROWS FETCH NEXT 1 ROWS ONLY;
        SELECT @second_num = LAT_N FROM STATION ORDER BY LAT_N OFFSET @second_median_row_idx ROWS FETCH NEXT 1 ROWS ONLY;

        SET @median = (@first_num + @second_num) / 2;
    END

SELECT @median;
