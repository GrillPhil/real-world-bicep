param name string
param location string
param topics array = []

resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

module serviceBusTopics 'servicebus-topic.bicep' = [for topic in topics: {
  name: 'serviceBusTopic${topic.name}Deployment'
  params: {
    name: topic.name
    subscriptions: topic.subscriptions
    namespaceName: serviceBus.name
  }
}]

output namespaceName string = serviceBus.name
