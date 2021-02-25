SELECT
    CT.contest_id,
    CT.hacker_id,
    CT.name,
    ISNULL(SUM(SST.sum_total_submissions), 0) as total_submissions,
    ISNULL(SUM(SST.sum_total_accepted_submissions), 0) as total_accepted_submissions,
    ISNULL(SUM(SVT.sum_total_views), 0) as total_views,
    ISNULL(SUM(SVT.sum_total_unique_views), 0) as total_unique_views
FROM Contests CT
INNER JOIN Colleges C ON CT.contest_id = C.contest_id
INNER JOIN Challenges CL ON C.college_id = CL.college_id
LEFT JOIN (
    SELECT
        challenge_id,
        SUM(total_views) AS sum_total_views,
        SUM(total_unique_views) AS sum_total_unique_views
    FROM View_Stats
    GROUP BY challenge_id
) AS SVT ON CL.challenge_id = SVT.challenge_id
LEFT JOIN (
    SELECT
        challenge_id,
        SUM(total_submissions) AS sum_total_submissions,
        SUM(total_accepted_submissions) AS sum_total_accepted_submissions
    FROM Submission_Stats
    GROUP BY challenge_id
) AS SST ON CL.challenge_id = SST.challenge_id
GROUP BY CT.contest_id, CT.hacker_id, CT.name
HAVING NOT (
    ISNULL(SUM(SST.sum_total_submissions), 0) = 0 AND
    ISNULL(SUM(SST.sum_total_accepted_submissions), 0) = 0 AND 
    ISNULL(SUM(SVT.sum_total_views), 0) = 0 AND
    ISNULL(SUM(SVT.sum_total_unique_views), 0) = 0
)
ORDER BY CT.contest_id;
