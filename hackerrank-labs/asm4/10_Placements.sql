SELECT S.Name
FROM Friends F
INNER JOIN Students S ON F.ID = S.ID
INNER JOIN Packages SelfP ON F.ID = SelfP.ID
INNER JOIN Packages FriendP ON F.Friend_ID = FriendP.ID
WHERE SelfP.Salary < FriendP.Salary
ORDER BY FriendP.Salary ASC;
