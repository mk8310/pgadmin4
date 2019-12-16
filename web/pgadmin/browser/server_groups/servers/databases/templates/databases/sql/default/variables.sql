SELECT name, vartype, min_val, max_val, enumvals
FROM sys_settings WHERE context in ('user', 'superuser')
