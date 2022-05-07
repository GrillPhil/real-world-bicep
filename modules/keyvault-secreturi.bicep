param keyVaultName string
param secretName string

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: keyVaultName
  resource secret 'secrets' existing = {
    name: secretName
  }
}

output uri string = keyVault::secret.properties.secretUri
