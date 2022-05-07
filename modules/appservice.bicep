param name string
param location string
param appSettings array = []
param kind string = 'linux'
param sku string = 'S1'
param dockerImageName string
param registryName string
param registryResourceGroupName string
param frontDoorId string

module law 'law.bicep' = {
  name: '${name}-law-deployment'
  params: {
    name: '${name}law'
    location: location
  }
}

module appInsights 'appinsights.bicep' = {
  name: '${name}-appinsights-deployment'
  params: {
    name: '${name}ai'
    location: location
    workspaceResourceId: law.outputs.id
  }
}

resource servicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  kind: kind
  name: '${name}plan'
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
}

resource appService 'Microsoft.Web/sites@2021-02-01' = {
  name: '${name}app'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: servicePlan.id
    siteConfig: {
      alwaysOn: true
      acrUseManagedIdentityCreds: true
      linuxFxVersion: 'DOCKER|${dockerImageName}'
      appSettings: union([
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.outputs.instrumentationKey
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVIC_STORAGE'
          value: 'false'
        }
      ], appSettings)
      ipSecurityRestrictions: [
        {
          ipAddress: 'AzureFrontDoor.Backend'
          tag: 'ServiceTag'
          action: 'Allow'
          priority: 100
          name: 'Frontdoor'
          headers: {
            'x-azure-fdid': [
              frontDoorId
            ]
          }
        }
      ]
    }
  }
}

module registryRoleAssigment 'rbac-acr.bicep' = {
  name: 'registryRoleAssigmentDeployment'
  scope: resourceGroup(registryResourceGroupName)
  params: {
    principalId: appService.identity.principalId
    registryName: registryName
  }
}

output hostName string = appService.properties.defaultHostName
output principalId string = appService.identity.principalId
