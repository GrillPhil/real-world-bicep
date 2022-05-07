param name string
param subscriptions array = []
param namespaceName string

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' existing = {
  name: namespaceName
}

resource serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2021-06-01-preview' = {
  name: name
  parent: serviceBusNamespace
}

resource serviceBusSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-06-01-preview' = [for subscription in subscriptions: {
  name: subscription.name
  parent: serviceBusTopic
}]
