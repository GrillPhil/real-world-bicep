# Real World Infrastructure as Code in Azure with Bicep

## Deploy via Azure CLI
```bash
az deployment sub create --template-file solution.bicep --location NorthEurope --parameters params.json --parameters name=iacdemo1
```
## Cleanup deployment

### Step 1: Delete Resource Group
```bash
az deployment delete -n caratdemo01
```

### Step 2: Purge deleted KeyVaults

This is required to be able to reuse the same KeyVault name in a future deployment because KeyVaults are soft deleted.

#### List deleted KeyVaults
```bash
az keyvault list-deleted --output table
```

#### Purge deleted KeyVault
```bash
az keyvault purge --name caratdemo01
```