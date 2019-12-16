SELECT conname as name,
    NOT convalidated as convalidated
FROM sys_constraint ct
WHERE contype = 'c'
AND  ct.oid = {{cid}}::oid
