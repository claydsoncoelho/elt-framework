select 
	'WWI' as [SourceSystemName]
	, t.name as [StreamName]
	,'Wide World Importers' as [SourceSystemDescription]
	,'Azure SQL' as [Backend]
	,(s.name + '.' + t.name) as [EntityName]
	, c.name as [DeltaName]
	, (CASE WHEN c.name is not null then cast('2013-01-01' as datetime)
		ELSE cast('1900-01-01' as datetime)
	 END) as [LastDeltaDate]
    , (CASE WHEN c.name is not null then 129600 --90days
		ELSE NULL
	 END)  as [MaxIntervalMinutes]
	,'Files' as [DestinationRawFileSystem]
    ,'raw_bronze/wwi/'+ s.name +'/'+  t.name +'/YYYY-MM' as [DestinationRawFolder]
    ,s.name +'_'+ t.name + '_'+ 'YYYY-MM-DD_HHMISS.parquet' as [DestinationRawFile]
    ,3 as [MaxRetries]
    ,cast(1 as bit) as [ActiveFlag]
    ,cast(1 as bit) as [L1TransformationReqdFlag]
    ,cast(1 as bit) as [L2TransformationReqdFlag]
    ,cast(0 as bit) as [DelayL1TransformationFlag]
from sys.tables as t
inner join sys.schemas as s
	on s.schema_id = t.schema_id
	and t.name in ('Customers','OrderLines','Orders')
left join sys.columns as c
	on c.object_id = t.object_id
	and c.name='LastEditedWhen';


SELECT lower(Tab.Table_Schema + '_' +  Tab.Table_Name) as [OutputDWTable]
, STRING_AGG(Col.Column_Name,'|') as [LookupColumns]
, 'append' as [OutputDWTableWriteMode]
from 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab, 
    INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Col 
WHERE 
    Col.Constraint_Name = Tab.Constraint_Name
    AND Col.Table_Name = Tab.Table_Name
    AND Tab.Constraint_Type = 'PRIMARY KEY'
GROUP BY lower(Tab.Table_Schema + '_' +  Tab.Table_Name);