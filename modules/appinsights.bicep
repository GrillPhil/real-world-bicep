param name string
param location string
param workspaceResourceId string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    DisableIpMasking: false // GDPR
    DisableLocalAuth: false
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    Request_Source: 'rest'
    RetentionInDays: 30 // 30 is the lowest possible
    WorkspaceResourceId: workspaceResourceId
  }
}

output instrumentationKey string = appInsights.properties.InstrumentationKey
