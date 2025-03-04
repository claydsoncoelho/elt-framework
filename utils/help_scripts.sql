-- Delete all data of the ControlDB tables:

TRUNCATE TABLE [ELT].[ColumnMapping];
TRUNCATE TABLE [ELT].[IngestInstance];
TRUNCATE TABLE [ELT].[L2TransformInstance];
TRUNCATE TABLE [ELT].[L2TransformDefinition];
TRUNCATE TABLE [ELT].[L1TransformInstance];
TRUNCATE TABLE [ELT].[L1TransformDefinition];
TRUNCATE TABLE [ELT].[IngestDefinition];

-- Select all data of the ControlDB tables:
SELECT * FROM  [ELT].[ColumnMapping];
SELECT * FROM  [ELT].[IngestInstance];
SELECT * FROM  [ELT].[L2TransformInstance];
SELECT * FROM  [ELT].[L2TransformDefinition];
SELECT * FROM  [ELT].[L1TransformInstance];
SELECT * FROM  [ELT].[L1TransformDefinition];
SELECT * FROM  [ELT].[IngestDefinition];
