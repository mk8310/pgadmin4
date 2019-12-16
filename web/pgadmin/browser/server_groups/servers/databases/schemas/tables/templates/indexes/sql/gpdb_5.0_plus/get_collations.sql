SELECT 'sys_catalog.' || quote_ident(collate_setting.value) AS copy_collation
FROM (
       SELECT setting AS value
       FROM sys_settings
       WHERE name='lc_collate'
     ) collate_setting
