param name string
param location string
param envId string

param registryName string
param registryResourceGroup string
param useExternalIngress bool = false
param containerPort int
param containerImage string
param appSettings array = []

resource registry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: registryName
  scope: resourceGroup(registryResourceGroup)
}

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: name
  location: location
  properties: {
    managedEnvironmentId: envId    
    configuration: {
      secrets: [
        {
          name: 'container-registry-password'
          value: registry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: '${registryName}.azurecr.io'
          username: registry.listCredentials().username
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: {
        external: useExternalIngress
        targetPort: containerPort
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: name
          env: appSettings
        }
      ]
      scale: {
        minReplicas: 0        
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output hostName string = containerApp.properties.configuration.ingress.fqdn
output principalId string = containerApp.identity.principalId
