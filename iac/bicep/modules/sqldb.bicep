@description('Name of SQL Server')
param sqlserver_name string

@description('Name of Database')
param database_name string

@description('Azure Location SQL Server')
param location string

@description('AD server admin user name')
@secure()
param ad_admin_username string

@description('SID (object ID) of the server administrator')
@secure()
param ad_admin_sid string

@description('Time in minutes after which database is automatically paused')
param auto_pause_duration int

@description('Database SKU name, e.g P3. For valid values, run this CLI az sql db list-editions -l australiaeast -o table')
param database_sku_name string

// Deploy SQL Server
resource sqlserver 'Microsoft.Sql/servers@2023-08-01-preview' ={
  name: sqlserver_name
  location: location
  identity:{ type: 'SystemAssigned'}
  properties: {
    administrators:{
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: ad_admin_username
      sid: ad_admin_sid
      principalType: 'User'
      tenantId: subscription().tenantId
    }
    minimalTlsVersion: '1.2'

  }
}

// Create firewall rule to Allow Azure services and resources to access this SQL Server
resource allowAzure_Firewall 'Microsoft.Sql/servers/firewallRules@2021-11-01' ={
  name: 'AllowAllWindowsAzureIps'
  parent: sqlserver
  properties:{
    startIpAddress:'0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Deploy database
resource database 'Microsoft.Sql/servers/databases@2021-11-01' ={
  name: database_name
  location: location
  sku:{name: database_sku_name}
  parent: sqlserver
  properties: {
    autoPauseDelay:auto_pause_duration
  }
}

// Outputs
output sqlserver_name string = sqlserver.name
output database_name string = database.name
output sqlserver_resource object = sqlserver
output database_resource object = database
