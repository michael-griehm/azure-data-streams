IF OBJECT_ID('dbo.CryptoAlerts', 'U') IS NOT NULL
DELETE FROM [dbo].[CryptoAlerts]
GO

IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL
DELETE FROM [dbo].[Users]
GO