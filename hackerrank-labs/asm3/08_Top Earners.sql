DECLARE @max_earn INT;
SELECT @max_earn = MAX(months * salary)
FROM Employee;

DECLARE @count INT;
SELECT @count = COUNT(employee_id)
FROM Employee
WHERE months * salary = @max_earn;

PRINT CONVERT(VARCHAR(10), @max_earn) + '  ' + CONVERT(VARCHAR(10), @count);
