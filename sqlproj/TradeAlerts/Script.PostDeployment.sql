-- This file contains SQL statements that will be executed after the build script.
IF NOT EXISTS (select * from sys.database_principals where name = 'nonprivileged')
BEGIN
    CREATE USER nonprivileged WITHOUT LOGIN
    GRANT SELECT ON Users TO nonprivileged
END
GO

IF NOT EXISTS (
    SELECT * FROM [dbo].[Users] WHERE [Email] = 'griehmmj@gmail.com'
)
INSERT INTO [dbo].[Users] (Email)
VALUES ('griehmmj@gmail.com')
GO

DECLARE @UserId BIGINT;
SELECT @UserId = [Id] FROM [dbo].[Users] WHERE [Email] = 'griehmmj@gmail.com';

IF NOT EXISTS (
    SELECT * FROM [dbo].[CryptoAlerts] WHERE [UserId] = @UserId AND [Symbol] = 'MATIC'
)
INSERT INTO [dbo].[CryptoAlerts] ([UserId],[Symbol],[Name],[High],[Low],[PurchasedPrice])
VALUES (@UserId,'MATIC','Polygon',2.00,1.30,1.90)
GO