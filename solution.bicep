targetScope = 'subscription'

param name string
param location string = 'northeurope'
param serviceBusConfig object
param registryConfig object
param legacyBackendConfig object
param frontendConfig object
param containerAConfig object
param containerBConfig object
param containerCConfig object

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: name
  location: location
}

module services 'services.bicep' = {
  name: 'services-deployment'
  scope: rg
  params: {
    name: name
    location: location
    serviceBusConfig: serviceBusConfig
    containerAConfig: containerAConfig
    containerBConfig: containerBConfig
    containerCConfig: containerCConfig
    frontendConfig: frontendConfig
    legacyBackendConfig: legacyBackendConfig
    registryConfig: registryConfig
  }
}
