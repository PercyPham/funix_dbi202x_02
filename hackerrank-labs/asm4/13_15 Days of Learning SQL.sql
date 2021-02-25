SELECT DISTINCT submission_date, hacker_id
INTO #daily_unique_submissions
FROM Submissions
ORDER BY submission_date ASC

DECLARE @cursor CURSOR;
SET @cursor = CURSOR FOR SELECT DISTINCT submission_date FROM Submissions ORDER BY submission_date;

CREATE TABLE #everyday_unique_submissions (
    submission_date DATE,
    unique_submissions INT
);

DECLARE @start_date DATE;
DECLARE @date DATE;

OPEN @cursor FETCH NEXT FROM @cursor INTO @date;
SET @start_date = @date;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @day_num INT = DATEDIFF(day, @start_date, @date) + 1;
    DECLARE @unique_submissions INT = 0;

    SELECT @unique_submissions = COUNT(DISTINCT(DUS.hacker_id))
    FROM #daily_unique_submissions DUS
    WHERE DUS.submission_date <= @date
    AND (
        SELECT COUNT(*) FROM #daily_unique_submissions WHERE hacker_id = DUS.hacker_id AND submission_date <= @date
    ) = @day_num

    INSERT INTO #everyday_unique_submissions
    VALUES (@date, @unique_submissions);

    FETCH NEXT FROM @cursor INTO @date    
END;

WITH tbl_submission_count AS
(
    SELECT
        submission_date,
        hacker_id,
        COUNT(submission_id) AS count
    FROM Submissions
    GROUP BY submission_date, hacker_id
),
tbl_submission_max_count AS
(
    SELECT
        SC.submission_date,
        SC.hacker_id,
        H.name,
        SC.count
    FROM tbl_submission_count SC
    INNER JOIN Hackers H ON SC.hacker_id = H.hacker_id
    WHERE count = (
        SELECT MAX(count)
        FROM tbl_submission_count
        WHERE submission_date = SC.submission_date
        GROUP BY submission_date
    )
)

SELECT 
    S.submission_date,
    S.unique_submissions,
    (SELECT TOP(1) hacker_id FROM tbl_submission_max_count WHERE submission_date = S.submission_date ORDER BY hacker_id) AS max_submit_hacker_id,
    (SELECT TOP(1) name FROM tbl_submission_max_count WHERE submission_date = S.submission_date ORDER BY hacker_id) AS max_submit_hacker_name
FROM #everyday_unique_submissions S
ORDER BY S.submission_date ASC;
