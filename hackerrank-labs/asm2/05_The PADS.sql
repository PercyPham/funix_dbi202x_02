CREATE TABLE #temp1 (
    result VARCHAR(50),
    num INT DEFAULT 1
);
CREATE TABLE #temp2 (
    result VARCHAR(50),
    num INT DEFAULT 1
);

INSERT INTO #temp1(result)
SELECT Name + '(' + LEFT(Occupation, 1) + ')'
FROM OCCUPATIONS
ORDER BY Name ASC;

DECLARE @doctorCount INT;
DECLARE @singerCount INT;
DECLARE @actorCount INT;
DECLARE @professorCount INT;

SELECT @doctorCount = COUNT(*) FROM OCCUPATIONS WHERE Occupation = 'Doctor';
SELECT @singerCount = COUNT(*) FROM OCCUPATIONS WHERE Occupation = 'Singer';
SELECT @actorCount = COUNT(*) FROM OCCUPATIONS WHERE Occupation = 'Actor';
SELECT @professorCount = COUNT(*) FROM OCCUPATIONS WHERE Occupation = 'Professor';

INSERT INTO #temp2(result)
VALUES
    ('There are a total of ' + CONVERT(VARCHAR(20), @doctorCount) + ' doctors.'),
    ('There are a total of ' + CONVERT(VARCHAR(20), @singerCount) + ' singers.'),
    ('There are a total of ' + CONVERT(VARCHAR(20), @actorCount) + ' actors.'),
    ('There are a total of ' + CONVERT(VARCHAR(20), @professorCount) + ' professors.');


SELECT result from #temp1
Union
SELECT result from #temp2
