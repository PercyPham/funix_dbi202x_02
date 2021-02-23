SELECT
    C.company_code,
    C.founder,
    (
        SELECT COUNT(DISTINCT LM.lead_manager_code)
        FROM Lead_Manager AS LM
        WHERE C.company_code = LM.company_code
    ) as leadManagerCount,
    (
        SELECT COUNT(DISTINCT SM.senior_manager_code)
        FROM Senior_Manager AS SM
        WHERE C.company_code = SM.company_code
    ) as seniorManagerCount,
    (
        SELECT COUNT(DISTINCT M.manager_code)
        FROM Manager AS M
        WHERE C.company_code = M.company_code
    ) as managerCount,
    (
        SELECT COUNT(DISTINCT E.employee_code)
        FROM Employee AS E
        WHERE C.company_code = E.company_code
    ) as employeeCount
FROM Company AS C
ORDER BY C.company_code ASC;
