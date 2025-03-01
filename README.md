# Microsoft Fabric Accelerator

## Disclamer
This framework is based on **[Fabric Accelerator](https://bennyaustin.com/2024/11/17/fabric-accelerator/)** 

## Content

- ### iac-Azure-SQL-Server-Database.yml
GitHub Action to deploy **Azure SQL Server** and **Azure SQL Database (controlDB)**.
The controlDB database is used to control ELT framework for metadata-driven orchestration. This step is optional if you already have a new Azure SQL Database provisioned and want to use it instead.

- ### iac-controlDB.yml
GitHub Action to deploy **controlDB database objects** (tables and Stored Procedures).
The controlDB database is used to control ELT metadata-driven orchestration.

## Setup

### iac-Azure-SQL-Server-Database Setup

#### Pre-Requisites

- Create a Service Principal (Single tenant is enogh).

Give the Service Principal **Contributor** role to the subscription. Check the code snippet below. [Need help?](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal)

Azure Cloud Shell
```bash
az role assignment create --assignee <YOUR SERVICE PRINCIPAL CLIENT ID> --role Contributor --scope /subscriptions/<YOUR SUBSCRIPTION ID>
```

#### Steps

1. Clone or Fork this Repository.

2. On GitHub -> Settings -> Secrets and variables, create the following **secrets** with their respective values:

    - TENANT_ID
    - SUBSCRIPTION_ID
    - SERVICE_PRINCIPAL_CLIENT_ID
    - SERVICE_PRINCIPAL_CLIENT_SECRET

3. Review the parameters in the **/github/workflows/main.bicep** file. Update and override the default param values as need. The parameter @description tells you what those parameters represent.

4. Go to GitHub Actions and execute the **Provision Azure SQL Server and Database** workflow. [Wiki](https://github.com/claydsoncoelho/elt-framework/wiki)


### iac-controlDB Setup

#### Steps

1. On GitHub/Settings/Secrets and variables, set the **CONTROLDB_CONNECTIONSTRING** secret with the following connection string:

```
Server=**<YOUR SQL SERVER>**;Authentication=Active Directory Service Principal; Encrypt=True;Database=**<YOUR "controlDB" NAME>**;User Id=**<SERVICE_PRINCIPAL_CLIENT_ID>**
;Password=**<SERVICE_PRINCIPAL_CLIENT_SECRET>**
```

2. Connect to controlDB using any SQL tool, Azure Query editor for example, and execute the following command. This will grant db_owner role to the Service Principal:

```sql
CREATE USER [<YOUR SERVICE PRINCIPAL NAME, NOT THE CLIENT ID>] FROM EXTERNAL PROVIDER
GO
EXEC sp_addrolemember 'db_owner', [<YOUR SERVICE PRINCIPAL NAME, NOT THE CLIENT ID>]
GO
```

3. Go to GitHub Actions and execute the **Provision controlDB database objects** workflow. [Wiki](https://github.com/claydsoncoelho/elt-framework/wiki)