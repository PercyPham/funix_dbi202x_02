SELECT DISTINCT A.X, A.Y
FROM Functions A
INNER JOIN Functions B ON A.X = B.Y AND A.Y = B.X
WHERE A.X < A.Y 
    OR (
        A.X = A.Y
        AND
        (SELECT COUNT(*) FROM Functions WHERE X = Y AND X = A.X) > 1
    )
ORDER BY A.X ASC;
