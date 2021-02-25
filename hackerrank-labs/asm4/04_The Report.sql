SELECT 
    CASE WHEN g.Grade >= 8 THEN std.Name ELSE NULL END as Name,
    g.Grade,
    std.Marks
FROM Students std
LEFT JOIN Grades g ON std.Marks >= g.Min_Mark AND std.Marks <= g.Max_Mark
ORDER BY g.Grade DESC, std.Name ASC, std.Marks ASC;
