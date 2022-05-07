param frontDoorName string
param originHostName string
param originGroupName string
param originPath string
param patternsToMatch array

resource frontDoor 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: frontDoorName
  resource endpoint 'afdEndpoints' existing = {
    name: frontDoorName
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: originGroupName
  parent: frontDoor
  properties:{
    healthProbeSettings: null
    sessionAffinityState: 'Disabled'
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
  }
  resource origin 'origins' = {
    name: originGroupName
    properties: {
      hostName: originHostName
      httpPort: 80
      httpsPort: 443
      originHostHeader: originHostName
      priority: 1
      weight: 1000
      sharedPrivateLinkResource: null
    }
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: originGroupName
  parent: frontDoor::endpoint
  properties: {
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: patternsToMatch
    linkToDefaultDomain: 'Enabled'
    originPath: originPath
    httpsRedirect: 'Enabled'
    forwardingProtocol: 'HttpsOnly'
  }
  dependsOn: [
    originGroup::origin
  ]
}
