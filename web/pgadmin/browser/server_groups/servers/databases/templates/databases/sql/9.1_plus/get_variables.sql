  SELECT rl.*, r.rolname AS user_name, db.datname as db_name
FROM sys_db_role_setting AS rl
 LEFT JOIN sys_roles AS r ON rl.setrole = r.oid
 LEFT JOIN sys_database AS db ON rl.setdatabase = db.oid
WHERE setdatabase = {{did}}
