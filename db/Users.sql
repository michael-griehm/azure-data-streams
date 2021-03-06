CREATE TABLE [dbo].[Users]
(
  [Id] BIGINT NOT NULL IDENTITY PRIMARY KEY,
  [Email] NVARCHAR(100) MASKED WITH (FUNCTION = 'email()') NOT NULL,
  [InsertedOn] DATETIME NOT NULL DEFAULT(GETUTCDATE()),
  [LastModifiedOn] DATETIME NULL
)