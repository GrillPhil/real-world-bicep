param name string
param location string

resource storage 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }  
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'deployer'
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(resourceGroup().id, name, 'contributor')
  properties: {
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'enableStaticWebsiteInStorageAccount'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.26.0'
    retentionInterval: 'PT1H'
    scriptContent: 'az storage blob service-properties update --account-name ${storage.name} --static-website --404-document index.html --index-document index.html'
  }
  dependsOn: [
    roleAssignment
  ]
}

var endpoint = substring(storage.properties.primaryEndpoints.web, 0, length(storage.properties.primaryEndpoints.web) - 1)
output hostName string = substring(endpoint, 8)
