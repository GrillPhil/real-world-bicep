param name string

resource frontDoor 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: name
  location: 'Global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  resource endpoint 'afdEndpoints' = {
    name: name
    location: 'Global'
  }
}

output id string = frontDoor.properties.frontDoorId
output name string = frontDoor.name
