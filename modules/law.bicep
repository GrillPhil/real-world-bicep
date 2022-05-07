param name string
param location string
param retentionInDays int = 31 // 31 is the limit without additional payment
param sku string = 'PerGB2018' // this is the lowest tier without reservation

resource law 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: name
  location: location
  properties: {
    features: {
      disableLocalAuth: false
      enableDataExport: true
      enableLogAccessUsingOnlyResourcePermissions: false
    }
    forceCmkForQuery: false
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: retentionInDays
    sku: {
      name: sku
    }
  }
}

output id string = law.id
output name string = law.name
