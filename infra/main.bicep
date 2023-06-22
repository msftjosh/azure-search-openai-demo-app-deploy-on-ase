targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

param appServicePlanName string = ''
param appServiceName string = ''
param resourceGroupName string = ''

param appResourceGroupName string = ''

param appServiceEnvironmentName string = ''

param searchServiceName string = ''
param searchIndexName string = 'gptkbindex'

param storageAccountName string = ''
param storageContainerName string = 'content'

param openAiServiceName string = ''

param gptDeploymentName string = ''
param chatGptDeploymentName string = ''


var abbrs = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }
var gptDeployment = empty(gptDeploymentName) ? 'davinci' : gptDeploymentName
var chatGptDeployment = empty(chatGptDeploymentName) ? 'chat' : chatGptDeploymentName


// Refrence an existing App Service Environment
resource appServiceEnvironment 'Microsoft.Web/hostingEnvironments@2022-03-01' existing = {
  name: appServiceEnvironmentName
  scope: resourceGroup(appResourceGroupName)
}

// Create an App Service Plan to group applications under the same payment plan and SKU within the App Service Environment
module appServicePlan 'core/host/appserviceplan.bicep' = {
  name: 'appServicePlan-linux'
  scope: resourceGroup(appResourceGroupName)
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: 'I1V2'
      tier: 'IsolatedV2'
    }
    kind: 'linux'
    properties:{
      name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}'
      hostingEnvironmentProfile:{
        id: appServiceEnvironment.id
      }
      reserved: true
      zoneRedundant: false
    }
  }
}

// Create the App Service to run our Python App
module backend 'core/host/appservice.bicep' = {
  name: 'appService-python'
  scope: resourceGroup(appResourceGroupName)
  params: {
    name: !empty(appServiceName) ? appServiceName : '${abbrs.webSitesAppService}python-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': 'backend' })
    appServicePlanId: appServicePlan.outputs.id
    runtimeName: 'python'
    runtimeVersion: '3.10'
    scmDoBuildDuringDeployment: true
    managedIdentity: true
    appSettings: {
      AZURE_STORAGE_ACCOUNT: storageAccountName
      AZURE_STORAGE_CONTAINER: storageContainerName
      AZURE_OPENAI_SERVICE: openAiServiceName
      AZURE_SEARCH_INDEX: searchIndexName
      AZURE_SEARCH_SERVICE: searchServiceName
      AZURE_OPENAI_GPT_DEPLOYMENT: gptDeployment
      AZURE_OPENAI_CHATGPT_DEPLOYMENT: chatGptDeployment
    }
  }
}

// SYSTEM IDENTITIES - To allow the App Service Access to the OpenAI, Storage, and Search Resources and Data
module openAiRoleBackend 'core/security/role.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'openai-role-backend'
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    principalType: 'ServicePrincipal'
  }
}

module storageRoleBackend 'core/security/role.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'storage-role-backend'
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
    principalType: 'ServicePrincipal'
  }
}

module searchRoleBackend 'core/security/role.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'search-role-backend'
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
    principalType: 'ServicePrincipal'
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = resourceGroupName

output BACKEND_URI string = backend.outputs.uri
