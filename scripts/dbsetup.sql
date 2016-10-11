connect / as sysdba
set pages 1000 line 150
spool /tmp/dbsetup.log
alter system set db_recovery_file_dest='+RECO' scope=both;
ALTER DATABASE FORCE LOGGING;
ALTER DATABASE ADD LOGFILE MEMBER   '+RECO' TO GROUP 1;
ALTER DATABASE ADD LOGFILE MEMBER   '+RECO' TO GROUP 2;
ALTER DATABASE ADD LOGFILE MEMBER   '+RECO' TO GROUP 3;
alter system set db_recovery_file_dest='+RECO' scope = both;
ALTER SYSTEM SET LOG_ARCHIVE_FORMAT='QS_PRIMARY_NAME_%t_%s_%r.arc' SCOPE=SPFILE;
alter system set LOG_ARCHIVE_DEST_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=QS_PRIMARY_NAME';
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ALTER SYSTEM SET LOCAL_LISTENER='(ADDRESS=(PROTOCOL=TCP)(HOST=QS_PRIMARY_IP)(PORT=QS_DATABASE_PORT))' scope=both;
ALTER DATABASE ADD STANDBY LOGFILE ('+RECO') SIZE 50M;
ALTER DATABASE ADD STANDBY LOGFILE ('+RECO') SIZE 50M;
ALTER DATABASE ADD STANDBY LOGFILE ('+RECO') SIZE 50M;
ALTER DATABASE ADD STANDBY LOGFILE ('+RECO') SIZE 50M;
ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(QS_PRIMARY_NAME,QS_STANDBY_NAME)';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=QS_STANDBY_NAME NOAFFIRM ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=QS_STANDBY_NAME';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=ENABLE;
ALTER DATABASE CREATE STANDBY CONTROLFILE AS '/tmp/stby.ctl';
CREATE PFILE='/tmp/stby.ora' FROM SPFILE;
set echo off
set head off
spool /tmp/status.log
select 'QS_PRIMARY_DATABASE_SETUP|SUCCESS' status from v$database d where d.LOG_MODE='ARCHIVELOG' and 'OPEN' = (select status from v$instance);
spool off
exit
