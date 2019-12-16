/*pga4dash*/
SELECT
    name,
    category,
    setting,
    unit,
    short_desc
FROM
    sys_settings
ORDER BY
    category
