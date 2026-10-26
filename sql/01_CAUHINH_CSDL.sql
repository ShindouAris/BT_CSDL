
USE master;
GO

-- Cho phép chạy lại nhiều lần
IF DB_ID(N'QL_CAFE_NHAHANG') IS NOT NULL
BEGIN
    ALTER DATABASE QL_CAFE_NHAHANG
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE QL_CAFE_NHAHANG;
END;
GO

DECLARE @DataPath NVARCHAR(4000) =
    CONVERT(NVARCHAR(4000),
        SERVERPROPERTY('InstanceDefaultDataPath'));

DECLARE @LogPath NVARCHAR(4000) =
    CONVERT(NVARCHAR(4000),
        SERVERPROPERTY('InstanceDefaultLogPath'));

-- Fallback nếu instance chưa cấu hình đường dẫn mặc định
IF @DataPath IS NULL
    SET @DataPath = CONVERT(NVARCHAR(4000),
        SERVERPROPERTY('InstanceDefaultDataPath'));

IF @LogPath IS NULL
    SET @LogPath = @DataPath;

-- Chuẩn hóa dấu phân cách cuối đường dẫn
IF RIGHT(@DataPath, 1) NOT IN (N'\', N'/')
    SET @DataPath += N'\';

IF RIGHT(@LogPath, 1) NOT IN (N'\', N'/')
    SET @LogPath += N'\';

DECLARE @SQL NVARCHAR(MAX) = N'
CREATE DATABASE QL_CAFE_NHAHANG
COLLATE Vietnamese_CI_AS
ON PRIMARY
(
    NAME = N''QL_CAFE_Data'',
    FILENAME = N''' +
        REPLACE(@DataPath + N'QL_CAFE_NHAHANG.mdf', N'''', N'''''') + N''',
    SIZE = 50MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 10MB
)
LOG ON
(
    NAME = N''QL_CAFE_Log'',
    FILENAME = N''' +
        REPLACE(@LogPath + N'QL_CAFE_NHAHANG_log.ldf', N'''', N'''''') + N''',
    SIZE = 20MB,
    MAXSIZE = 200MB,
    FILEGROWTH = 10MB
);';

EXEC sys.sp_executesql @SQL;
GO

-- Kiểm tra cấu hình file vừa tạo
SELECT
    name,
    physical_name,
    size * 8.0 / 1024 AS SizeMB,
    growth * 8.0 / 1024 AS GrowthMB
FROM QL_CAFE_NHAHANG.sys.database_files;
GO