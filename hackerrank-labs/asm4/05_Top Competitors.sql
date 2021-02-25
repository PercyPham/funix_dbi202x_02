WITH submit_with_full_score AS
(
    SELECT DISTINCT S.hacker_id, S.challenge_id
    FROM Submissions S
    INNER JOIN Challenges C ON S.challenge_id = C.challenge_id
    INNER JOIN Difficulty D ON C.difficulty_level = D.difficulty_level
    WHERE S.score = D.score
), hacker_full_score_count AS 
(
    SELECT hacker_id, COUNT(challenge_id) as count
    FROM submit_with_full_score
    GROUP BY hacker_id
)

SELECT C.hacker_id, H.name
FROM hacker_full_score_count C
INNER JOIN Hackers H ON C.hacker_id = H.hacker_id
WHERE C.count > 1
ORDER BY C.count DESC, C.hacker_id ASC;
