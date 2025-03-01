// ######################### CHANGE YOUR PARAMETERS AND VARIABLES BELOW #################################

// Scope
targetScope = 'subscription'


// Parameters
@description('Resource group where Azure SQL Server and Azure SQL Database will be deployed. Resource group will be created if it doesnt exist')
param rg_name string= 'Fabric-Accelerator-Resource-Group'

@description('Microsoft Fabric Resource group location')
param rglocation string = 'australiaeast'

@description('Timestamp that will be appended to the deployment name')
param deployment_suffix string = utcNow()

@description('Azure SQL Server name. This name must be unique in Azure, therefore, this name will be concateneted with random sufix on var section of resource group.')
param sqlserver_name string = 'asql-server'

@description('Azure SQL Database name (usually controlDB).')
param database_name string = 'controlDB'

@description('Microsoft Entra username to be the SQL Server admin.')
param entra_admin_username string = 'clay@ezdata.co.nz'

@description('Microsoft Entra Object ID of the user above.')
param entra_admin_object_id string = 'aebc135d-a0b7-4be4-9051-01b0ef24e4d0'

@description('Database auto pause in minutes.')
param auto_pause_duration int = 60

@description('Database SKU name, e.g P3. For valid values, run this CLI az sql db list-editions -l australiaeast -o table')
param database_sku_name string = 'GP_S_Gen5_1'


// Variables
var controldb_deployment_name = 'controldb_deployment_${deployment_suffix}'


// ######################### NO CHANGES AFTER THIS POINT ##################################


// Create data platform resource group
resource fabric_rg  'Microsoft.Resources/resourceGroups@2024-03-01' = {
 name: rg_name 
 location: rglocation
}

// Get created resource group
resource fabric_rg_ref 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: rg_name
}

// Set unique name for Azure SQL Server
var suffix = uniqueString(fabric_rg_ref.id)
var sqlserver_unique_name = '${sqlserver_name}-${suffix}'

//Deploy SQL control DB 
module controldb './modules/sqldb.bicep' = {
  name: controldb_deployment_name
  scope: fabric_rg_ref
  params:{
     sqlserver_name: sqlserver_unique_name
     database_name: database_name 
     location: fabric_rg_ref.location
     ad_admin_username:  entra_admin_username
     ad_admin_sid:  entra_admin_object_id  
     auto_pause_duration: auto_pause_duration
     database_sku_name: database_sku_name
  }
}
