SELECT hacker_id, challenge_id, MAX(score) AS score
INTO #submission_max_scores
FROM Submissions
GROUP BY hacker_id,challenge_id;

SELECT hacker_id, SUM(score) AS total
INTO #hacker_totals
FROM #submission_max_scores
GROUP BY hacker_id;

SELECT HT.hacker_id, H.name, HT.total
FROM #hacker_totals HT
INNER JOIN Hackers H ON HT.hacker_id = H.hacker_id
WHERE HT.total <> 0
ORDER BY HT.total DESC, HT.hacker_id;
