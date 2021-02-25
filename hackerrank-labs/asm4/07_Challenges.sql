SELECT hacker_id, COUNT(challenge_id) AS count
INTO #temp_count
FROM Challenges
GROUP BY hacker_id;

DECLARE @max INT;

SELECT @max = MAX(count)
FROM #temp_count;

SELECT count, COUNT(hacker_id) AS duplicates
INTO #temp_duplicate
FROM #temp_count
GROUP BY count
HAVING COUNT(hacker_id) > 1 AND count < @max;

SELECT TC.hacker_id, H.name, TC.count
FROM #temp_count TC
INNER JOIN Hackers H ON TC.hacker_id = H.hacker_id
WHERE NOT EXISTS (
  SELECT count FROM #temp_duplicate WHERE count = TC.count
)
ORDER BY TC.count DESC, TC.hacker_id
