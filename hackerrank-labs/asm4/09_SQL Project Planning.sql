CREATE TABLE #result (
  start_date DATE,
  end_date DATE,
  prjLength INT
);

DECLARE @cursor CURSOR;

SET @cursor = CURSOR FOR
SELECT Start_Date, End_Date FROM Projects ORDER BY Start_Date ASC;

DECLARE @start_date DATE;
DECLARE @end_date DATE;
DECLARE @prjLength INT;

DECLARE @prevSD DATE, @prevED DATE;
DECLARE @currSD DATE, @currED DATE;

OPEN @cursor

FETCH NEXT FROM @cursor INTO @currSD, @currED;
SET @start_date = @currSD;
SET @end_date = @currED;
SET @prevSD = @currSD;
SET @prevED = @currED;
SET @prjLength = 1;

WHILE @@FETCH_STATUS = 0
BEGIN
  FETCH NEXT FROM @cursor INTO @currSD, @currED;
  IF @@FETCH_STATUS = 0
    BEGIN
      IF DATEDIFF(day, @prevED, @currED) = 1
        BEGIN
          SET @end_date = @currED;
          SET @prjLength += 1;

          SET @prevSD = @currSD;
          SET @prevED = @currED;
        END
      ELSE
        BEGIN
          INSERT INTO #result(start_date, end_date, prjLength)
          VALUES (@start_date, @end_date, @prjLength);

          SET @start_date = @currSD;
          SET @end_date = @currED;
          SET @prjLength = 1;

          SET @prevSD = @currSD;
          SET @prevED = @currED;
        END
    END
END

INSERT INTO #result(start_date, end_date, prjLength)
VALUES (@start_date, @end_date, @prjLength);

SELECT start_date, end_date
FROM #result
ORDER BY prjLength ASC, start_date ASC;
