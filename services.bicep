param name string
param location string
param serviceBusConfig object
param registryConfig object
param legacyBackendConfig object
param frontendConfig object
param containerAConfig object
param containerBConfig object
param containerCConfig object

var sampleSecret = {
  name: 'sampleSecret'
  value: '#GlobalAzure'
}

module keyVault 'modules/keyvault.bicep' = {
  name: 'keyvault-deployment'
  params: {
    name: name
    location: location
    secrets: [
      sampleSecret
    ]
  }
}

module sampleSecretUri 'modules/keyvault-secreturi.bicep' = {
  name: 'sampleSecret'
  params: {
    keyVaultName: keyVault.outputs.name
    secretName: sampleSecret.name
  }
}

module serviceBus 'modules/servicebus.bicep' = {
  name: 'servicebus-deployment'
  params: {
    name: name
    location: location
    topics: serviceBusConfig.topics
  }
}

module frontDoor 'modules/frontdoor.bicep' = {
  name: 'frontdoor-deployment'
  params: {
    name: name
  }  
}

var legacybackendName = '${name}lb'
module legacybackend 'modules/appservice.bicep' = {
  name: 'legacybackend-deployment'
  params: {
    name: legacybackendName
    location: location
    appSettings: union([
      {
        name: 'SampleSecret'
        value: '@Microsoft.KeyVault(SecretUri=${sampleSecretUri.outputs.uri})'
      }
    ],legacyBackendConfig.appSettings)
    dockerImageName: legacyBackendConfig.imageName
    registryName: registryConfig.name
    registryResourceGroupName: registryConfig.resourceGroup
    frontDoorId: frontDoor.outputs.id
  }
}

module legacyBackendRbacKeyVault 'modules/rbac-keyvault.bicep' = {
  name: 'appservice-${legacybackendName}-rbac-keyvault-deployment'
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: legacybackend.outputs.principalId
  }
}

module legacyBackendRbacServiceBus 'modules/rbac-servicebus-namespace.bicep' = {
  name: 'appservice-${legacybackendName}-rbac-servicebus-deployment'
  params: {
    name: serviceBus.outputs.namespaceName
    roleIds: [
      '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'
      '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'
    ]
    principalId: legacybackend.outputs.principalId
  }
}

module legacybackendFrontDoorRoute 'modules/frontdoor-route.bicep' = {
  name: 'legacybackend-frontdoor-route-deployment'
  params: {
    frontDoorName: frontDoor.outputs.name
    originHostName: legacybackend.outputs.hostName
    originGroupName: legacyBackendConfig.frontDoor.groupName
    originPath: legacyBackendConfig.frontDoor.originPath
    patternsToMatch: legacyBackendConfig.frontDoor.patternsToMatch
  }
}

module frontend 'modules/staticweb.bicep' = {
  name: 'frontend-deployment'
  params: {
    name: name
    location: location
  }
}

module frontendFrontDoorRoute 'modules/frontdoor-route.bicep' = {
  name: 'frontend-frontdoor-route-deployment'
  params: {
    frontDoorName: frontDoor.outputs.name
    originHostName: frontend.outputs.hostName
    originGroupName: frontendConfig.frontDoor.groupName
    originPath: frontendConfig.frontDoor.originPath
    patternsToMatch: frontendConfig.frontDoor.patternsToMatch
  }
}

module containerEnvironment 'modules/container-environment.bicep' = {
  name: 'container-environment-deployment'
  params: {
    name: '${name}env'
    location: location
  }
}

var containerAName = '${name}-${containerAConfig.ext}'
module containerA 'modules/container-app.bicep' = {
  name: 'container-${containerAName}-deployment'
  params: {
    name: containerAName
    location: location
    envId: containerEnvironment.outputs.id
    registryName: registryConfig.name
    registryResourceGroup: registryConfig.resourceGroup
    useExternalIngress: containerAConfig.useExternalIngress
    containerImage: containerAConfig.imageName
    containerPort: containerAConfig.port
    appSettings: union([
      {
        name: 'keyVaultName'
        value: keyVault.outputs.name
      }
    ], containerAConfig.appSettings)
  }
}

module containerARbacKeyVault 'modules/rbac-keyvault.bicep' = {
  name: 'container-${containerAName}-rbac-keyvault-deployment'
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: containerA.outputs.principalId
  }
}

module containerARbacServiceBus 'modules/rbac-servicebus-subscription.bicep' = {
  name: 'container-${containerAName}-rbac-servicebus-deployment'
  params: {
    namespaceName: serviceBus.outputs.namespaceName
    topicName: 'neworder'
    subscriptionName: 'processneworder'
    principalId: containerA.outputs.principalId
  }
}

module containerAFrontDoorRoute 'modules/frontdoor-route.bicep' = {
  name: 'container-${containerAName}-frontdoor-route-deployment'
  params: {
    frontDoorName: frontDoor.outputs.name
    originHostName: containerA.outputs.hostName
    originGroupName: containerAConfig.frontDoor.groupName
    originPath: containerAConfig.frontDoor.originPath
    patternsToMatch: containerAConfig.frontDoor.patternsToMatch
  }
}

var containerBName = '${name}-${containerBConfig.ext}'
module containerB 'modules/container-app.bicep' = {
  name: 'container-${containerBName}-deployment'
  params: {
    name: containerBName
    location: location
    envId: containerEnvironment.outputs.id
    registryName: registryConfig.name
    registryResourceGroup: registryConfig.resourceGroup
    useExternalIngress: containerBConfig.useExternalIngress
    containerImage: containerBConfig.imageName
    containerPort: containerBConfig.port
    appSettings: union([
      {
        name: 'keyVaultName'
        value: keyVault.outputs.name
      }
    ], containerBConfig.appSettings)
  }
}

module containerBRbacKeyVault 'modules/rbac-keyvault.bicep' = {
  name: 'container-${containerBName}-rbac-keyvault-deployment'
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: containerB.outputs.principalId
  }
}

module containerBFrontDoorRoute 'modules/frontdoor-route.bicep' = {
  name: 'container-${containerBName}-frontdoor-route-deployment'
  params: {
    frontDoorName: frontDoor.outputs.name
    originHostName: containerB.outputs.hostName
    originGroupName: containerBConfig.frontDoor.groupName
    originPath: containerBConfig.frontDoor.originPath
    patternsToMatch: containerBConfig.frontDoor.patternsToMatch
  }
}

var containerCName = '${name}-${containerCConfig.ext}'
module containerC 'modules/container-app.bicep' = {
  name: 'container-${containerCName}-deployment'
  params: {
    name: containerCName
    location: location
    envId: containerEnvironment.outputs.id
    registryName: registryConfig.name
    registryResourceGroup: registryConfig.resourceGroup
    useExternalIngress: containerCConfig.useExternalIngress
    containerImage: containerCConfig.imageName
    containerPort: containerCConfig.port
    appSettings: union([
      {
        name: 'keyVaultName'
        value: keyVault.outputs.name
      }
    ], containerCConfig.appSettings)
  }
}

module containerCRbacKeyVault 'modules/rbac-keyvault.bicep' = {
  name: 'container-${containerCName}-rbac-keyvault-deployment'
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: containerC.outputs.principalId
  }
}
