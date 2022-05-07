param name string
param location string
param secrets array = []

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: name
  location: location
  properties: {
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
  resource secret 'secrets' = [for secret in secrets: {
    name: secret.name
    properties: {
      value: secret.value
    }
  }]
}

output name string = keyVault.name
