DECLARE @max INT = 0;

DECLARE @doctorCount INT;
DECLARE @professorCount INT;
DECLARE @singerCount INT;
DECLARE @actorCount INT;

SELECT @doctorCount = COUNT(*) FROM OCCUPATIONS WHERE Occupation = 'Doctor';
IF @max < @doctorCount SET @max = @doctorCount;

SELECT @professorCount = COUNT(*) FROM OCCUPATIONS WHERE Occupation = 'Professor';
IF @max < @professorCount SET @max = @professorCount;

SELECT @singerCount = COUNT(*) FROM OCCUPATIONS WHERE Occupation = 'Singer';
IF @max < @singerCount SET @max = @singerCount;

SELECT @actorCount = COUNT(*) FROM OCCUPATIONS WHERE Occupation = 'Actor';
IF @max < @actorCount SET @max = @actorCount;

CREATE TABLE #temp (
    doctor VARCHAR(30),
    professor VARCHAR(30),
    singer VARCHAR(30),
    actor VARCHAR(30)
);

DECLARE @i INT = 0;

WHILE @i < @max
BEGIN
    INSERT INTO #temp
    VALUES (
        (SELECT Name FROM OCCUPATIONS WHERE Occupation = 'Doctor' ORDER BY Name OFFSET @i ROWS FETCH NEXT 1 ROWS ONLY),
        (SELECT Name FROM OCCUPATIONS WHERE Occupation = 'Professor' ORDER BY Name OFFSET @i ROWS FETCH NEXT 1 ROWS ONLY),
        (SELECT Name FROM OCCUPATIONS WHERE Occupation = 'Singer' ORDER BY Name OFFSET @i ROWS FETCH NEXT 1 ROWS ONLY),
        (SELECT Name FROM OCCUPATIONS WHERE Occupation = 'Actor' ORDER BY Name OFFSET @i ROWS FETCH NEXT 1 ROWS ONLY)
    );

    SET @i += 1
END

SELECT * FROM #temp;
