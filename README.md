# Microsoft Fabric Accelerator

## Disclamer
This framework is based on **[Fabric Accelerator](https://bennyaustin.com/2024/11/17/fabric-accelerator/)** 

## Content

- ### Azure SQL Server and Database Provisioning
GitHub Action to deploy **Azure SQL Server** and **Azure SQL Database (ControlDB)**.
The ControlDB database is used to control ELT framework for metadata-driven orchestration. This step is optional if you already have a new Azure SQL Database provisioned and want to use it instead.

**Location:** .github/workflows/iac-Azure-SQL-Server-Database.yml

- ### ControlDB Database Objects Provisioning
GitHub Action to deploy **ControlDB database objects** (tables and Stored Procedures).
The ControlDB database is used to control ELT metadata-driven orchestration.

**Location:** .github/workflows/iac-ControlDB.yml

- ### Microsoft Fabric Accelerator
A Fabric Workspace with a metadata-driven orchestration framework designed for modern cloud data platforms. It simplifies ingestion and transformation pipelines, ensuring a consistent development experience and ease of maintenance.

**Location:** Fabric_Worspace


## Azure SQL Server and Database Provisioning Setup

### Pre-Requisites

- Create a Service Principal (Single tenant is enogh).

Give the Service Principal **Contributor** role to the subscription. Check the code snippet below. [Need help?](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal)

Azure Cloud Shell
```bash
az role assignment create --assignee <YOUR SERVICE PRINCIPAL CLIENT ID> --role Contributor --scope /subscriptions/<YOUR SUBSCRIPTION ID>
```

### Steps

1. Clone or Fork this Repository.

2. On GitHub -> Settings -> Secrets and variables, create the following **secrets** with their respective values:

    - TENANT_ID
    - SUBSCRIPTION_ID
    - SERVICE_PRINCIPAL_CLIENT_ID
    - SERVICE_PRINCIPAL_CLIENT_SECRET

3. Review the parameters in the **/github/workflows/main.bicep** file. Update and override the default param values as need. The parameter @description tells you what those parameters represent.

4. Go to GitHub Actions and execute the **Azure SQL Server and Database Provisioning** workflow. [Wiki](https://github.com/claydsoncoelho/elt-framework/wiki)


## ControlDB Database Objects Provisioning Setup

### Steps

1. On GitHub -> Settings -> Secrets and variables, set the **CONTROLDB_CONNECTIONSTRING** secret with the following connection string:

```
Server=<YOUR SQL SERVER NAME>;Authentication=Active Directory Service Principal; Encrypt=True;Database=<YOUR "ControlDB" DATABASE NAME>;User Id=<SERVICE_PRINCIPAL_CLIENT_ID>;Password=<SERVICE_PRINCIPAL_CLIENT_SECRET>
```

2. Connect to ControlDB using any SQL tool and execute the following command to grant db_owner role to your Service Principal:

**Important!** If you are having problems to connect to ControlDB, maybe you need to add your IP range to the Firewall in the Networking config of the Azure SQL Server.

```sql
CREATE USER [<YOUR SERVICE PRINCIPAL NAME, NOT THE CLIENT ID>] FROM EXTERNAL PROVIDER
GO
EXEC sp_addrolemember 'db_owner', [<YOUR SERVICE PRINCIPAL NAME, NOT THE CLIENT ID>]
GO
```

3. Go to GitHub Actions and execute the **ControlDB Database Objects Provisioning** workflow. [Wiki](https://github.com/claydsoncoelho/elt-framework/wiki)


## Fabric Worspace Setup

### Steps

1. On Fabric create a **Workspace**. Take note of the Worspace ID, you will need this later.

2. On Setting -> Connections and Getways, **create ControlDB connection**. Take note of the Connection ID, you will need this later.

3. **Refactor Connection IDs**: Open the repo folder in VS Code. Create a branch from main. Search and replace all these GUIDs with the values you took note earlier.

| Description | Find | Replace All |
| ----------- | ---- | ----------- |
| Fabric Capacity ID | e4eb626a-4082-4143-983d-6fc9284b74cd | your Capacity ID |
| Fabric Workspace ID | 00000000-0000-0000-0000-000000000000 | your Workspace ID |
| Fabric Workspace ID | 8d8d00a7-0e8a-4e3b-8c0e-8dcafac7adec | your Workspace ID|
| ControlDB Connection ID | 91ecdff4-3ab7-4bbb-b6e0-682881c0540d | your Control DB Connection ID |
| Wide World Importers Connection ID | a0a57e51-5032-4e46-b0f0-493c9d2f51c9 | your WWI Connection ID from step 6 |