RESTORE DATABASE [demodb] FROM DISK = N'/opt/demo/rgr'
WITH FILE = 1, NOUNLOAD, REPLACE, STATS = 5, RECOVERY,
MOVE 'rgr_1' TO '/var/opt/mssql/data/rgr_2.mdf',
MOVE 'rgr_1_log' TO '/var/opt/mssql/data/rgr_2_log.ldf';
GO

SELECT   * FROM   SYSOBJECTS WHERE   xtype = 'U';
GO
