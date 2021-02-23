SELECT
    o.N,
    CASE
        WHEN o.P IS NULL THEN 'Root'
        WHEN NOT EXISTS (SELECT * FROM BST AS i WHERE i.P=o.N) THEN 'Leaf'
        ELSE 'Inner'
    END AS type
FROM BST AS o
ORDER BY N;
