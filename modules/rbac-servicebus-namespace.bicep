param name string
param principalId string 
param principalType string = 'ServicePrincipal'
@description('Defaults to Azure Service Bus Data Receiver')
param roleIds array = [ 
  '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'
]

resource namespace 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' existing = {
  name: name
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = [for roleId in roleIds: {
  name: guid(subscription().subscriptionId, name, roleId, principalId)
  scope: namespace
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: principalId
    principalType: principalType
  }
}]
