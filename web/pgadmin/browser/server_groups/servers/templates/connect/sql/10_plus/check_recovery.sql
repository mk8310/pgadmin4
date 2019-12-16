SELECT CASE WHEN usesuper
       THEN sys_is_in_recovery()
       ELSE FALSE
       END as inrecovery,
       CASE WHEN usesuper AND sys_is_in_recovery()
       THEN sys_is_wal_replay_paused()
       ELSE FALSE
       END as isreplaypaused
FROM sys_user WHERE usename=current_user
