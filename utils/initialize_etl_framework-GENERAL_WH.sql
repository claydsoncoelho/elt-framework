--------------------------------------- Create temp tables -------------------------------------------------

SELECT *
INTO ELT.Z_Source_Metadata
FROM (
    SELECT 'dbo' AS Schema_Name, 'Customers' AS Table_Name, 'CustomerID' as primary_key
    UNION
    SELECT 'dbo' AS Schema_Name, 'Orders' AS Table_Name, 'OrderID' as primary_key
    UNION
    SELECT 'dbo' AS Schema_Name, 'OrderLines' AS Table_Name, 'OrderLineID' as primary_key
) A;

SELECT *
INTO ELT.Z_Fabric_Metadata
FROM (SELECT '252a2b74-0b66-4bb9-ba94-9d88bd82d197' as L1NotebookID) B;



--------------------------------------- IngestDefinition -------------------------------------------------

INSERT INTO [ELT].[IngestDefinition] (
    [IngestID],
    [SourceSystemName],
    [StreamName],
    [SourceSystemDescription],
    [Backend],
    [DataFormat],
    [EntityName],
    [WatermarkColName],
    [DeltaFormat],
    [LastDeltaDate],
    [LastDeltaNumber],
    [LastDeltaString],
    [MaxIntervalMinutes],
    [MaxIntervalNumber],
    [DataMapping],
    [SourceFileDropFileSystem],
    [SourceFileDropFolder],
    [SourceFileDropFile],
    [SourceFileDelimiter],
    [SourceFileHeaderFlag],
    [SourceStructure],
    [DestinationRawFileSystem],
    [DestinationRawFolder],
    [DestinationRawFile],
    [RunSequence],
    [MaxRetries],
    [ActiveFlag],
    [L1TransformationReqdFlag],
    [L2TransformationReqdFlag],
    [DelayL1TransformationFlag],
    [DelayL2TransformationFlag],
    [CreatedBy],
    [CreatedTimestamp],
    [ModifiedBy],
    [ModifiedTimestamp]
)
SELECT
    ROW_NUMBER() OVER (ORDER BY Table_Name) as IngestID,
    'WWI' AS [SourceSystemName],
    Table_Name AS [StreamName],
    'Wide World Importers' AS [SourceSystemDescription],
    'Azure SQL' AS [Backend],
    NULL AS [DataFormat],  
    (Schema_Name + '.' + Table_Name) as [EntityName],   
    NULL AS [WatermarkColName], 
    NULL AS [DeltaFormat],  
    CAST('1900-01-01' AS datetime) AS [LastDeltaDate],
    NULL AS [LastDeltaNumber], 
    NULL AS [LastDeltaString], 
    NULL AS [MaxIntervalMinutes], 
    NULL AS [MaxIntervalNumber], 
    NULL AS [DataMapping],  
    NULL AS [SourceFileDropFileSystem], 
    NULL AS [SourceFileDropFolder], 
    NULL AS [SourceFileDropFile], 
    NULL AS [SourceFileDelimiter], 
    NULL AS [SourceFileHeaderFlag], 
    NULL AS [SourceStructure], 
    'Files' AS [DestinationRawFileSystem],
    'raw_bronze/wwi/'+ Schema_Name +'/'+  Table_Name +'/YYYY-MM' as [DestinationRawFolder], 
    Schema_Name +'_'+ Table_Name + '_'+ 'YYYY-MM-DD_HHMISS.parquet' as [DestinationRawFile], 
    100 AS [RunSequence], 
    3 AS [MaxRetries],
    CAST(1 AS bit) AS [ActiveFlag],
    CAST(1 AS bit) AS [L1TransformationReqdFlag],
    CAST(1 AS bit) AS [L2TransformationReqdFlag],
    CAST(0 AS bit) AS [DelayL1TransformationFlag],
    CAST(1 AS bit) AS [DelayL2TransformationFlag], 
    'initial_load' AS [CreatedBy],
    GETDATE() AS [CreatedTimestamp],
    'initial_load' AS [ModifiedBy], 
    GETDATE() AS [ModifiedTimestamp] 
from ELT.Z_Source_Metadata;


--------------------------------------- L1TransformDefinition -------------------------------------------------

INSERT INTO [ELT].[L1TransformDefinition] (
    [L1TransformID],
    [IngestID],
    [ComputePath],
    [ComputeName],
    [CustomParameters],
    [InputRawFileSystem],
    [InputRawFileFolder],
    [InputRawFile],
    [InputRawFileDelimiter],
    [InputFileHeaderFlag],
    [OutputL1CurateFileSystem],
    [OutputL1CuratedFolder],
    [OutputL1CuratedFile],
    [OutputL1CuratedFileDelimiter],
    [OutputL1CuratedFileFormat],
    [OutputL1CuratedFileWriteMode],
    [OutputDWStagingTable],
    [LookupColumns],
    [OutputDWTable],
    [OutputDWTableWriteMode],
    [MaxRetries],
    [WatermarkColName],
    [ActiveFlag],
    [CreatedBy],
    [CreatedTimestamp],
    [ModifiedBy],
    [ModifiedTimestamp]
)
SELECT ROW_NUMBER() OVER (ORDER BY IngestID) as L1TransformID,
IngestID, 
NULL AS [ComputePath],
t.L1NotebookID AS [ComputeName],
NULL AS [CustomParameters],
[DestinationRawFileSystem] as InputRawFileSystem,
[DestinationRawFolder] as InputRawFileFolder,
[DestinationRawFile] as InputRawFile,
NULL AS [InputRawFileDelimiter],
NULL AS [InputFileHeaderFlag],
'Not Applicable' AS [OutputL1CurateFileSystem],
'Not Applicable' as [OutputL1CuratedFolder],
'Not Applicable' as [OutputL1CuratedFile],
NULL AS [OutputL1CuratedFileDelimiter],
NULL AS [OutputL1CuratedFileFormat],
NULL AS [OutputL1CuratedFileWriteMode],
NULL AS [OutputDWStagingTable],
NULL AS [LookupColumns],
StreamName AS [OutputDWTable],
'append' AS [OutputDWTableWriteMode],
3 AS [MaxRetries],
NULL AS [WatermarkColName],
CAST(1 AS bit) AS [ActiveFlag],
'initial_load' AS [CreatedBy],
GETDATE() AS [CreatedTimestamp],
'initial_load' AS [ModifiedBy],
GETDATE() AS [ModifiedTimestamp]
FROM [ELT].[IngestDefinition]
INNER JOIN ELT.Z_Fabric_Metadata t ON 1=1;


UPDATE [ELT].[L1TransformDefinition]
SET LookupColumns = t.primary_key
FROM [ELT].[L1TransformDefinition] TargetTable
INNER JOIN [ELT].[IngestDefinition] SourceTable ON TargetTable.IngestID = SourceTable.IngestID
INNER JOIN ELT.Z_Source_Metadata t ON t.Table_Name = SourceTable.StreamName;


--------------------------- Drop temp tables--------------------------------------------------
DROP TABLE ELT.Z_Source_Metadata;
DROP TABLE ELT.Z_Fabric_Metadata;
