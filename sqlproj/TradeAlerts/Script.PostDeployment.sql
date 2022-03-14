-- This file contains SQL statements that will be executed after the build script.
IF NOT EXISTS (select * from sys.database_principals where name = 'nonprivileged')
BEGIN
    CREATE USER nonprivileged WITHOUT LOGIN
    GRANT SELECT ON Users TO nonprivileged
END
GO

IF NOT EXISTS (
    SELECT * FROM [dbo].[Users] WHERE Email = 'griehmmj@gmail.com'
)
INSERT INTO [dbo].[Users] (Email)
VALUES ('griehmmj@gmail.com')
GO

