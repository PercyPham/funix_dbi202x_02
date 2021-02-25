WITH power_age_mincoin AS (
    SELECT WP.age, W.power, MIN(W.coins_needed) as mincoin
    FROM Wands_Property WP
    INNER JOIN Wands W ON WP.code = W.code
    GROUP BY WP.age, W.power
), result AS (
    SELECT W.id, WP.age, W.coins_needed, W.power
    FROM Wands W
    INNER JOIN Wands_Property WP ON W.code = WP.code AND WP.is_evil = 0
    INNER JOIN power_age_mincoin MC ON WP.age = MC.age AND W.power = MC.power AND W.coins_needed = MC.mincoin
)

SELECT *
FROM result
ORDER BY power DESC, age DESC;
