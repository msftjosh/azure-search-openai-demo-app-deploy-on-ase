# Deploy Web Application to Interact with OpenAI and Cognitive Search Demo

## Attribution
* The code in this repo is adapted from the Azure Samples [ChatGPT + Enterprise data with Azure OpenAI and Cognitive Search Demo](https://github.com/Azure-Samples/azure-search-openai-demo)

## Features
- Deploy a python based web application interface to an Azure App Service Environment that interacts with Azure OpenAI, Cognitive Search, and Azure Storage Blob.

## Getting Started

> **IMPORTANT:** In order to deploy and run this example, you'll need an existing **Azure subscription with deployed Azure OpenAI service, Cognitive Search, Azure Storage Account and documents loaded in per the Azure Samples [ChatGPT + Enterprise data with Azure OpenAI and Cognitive Search Demo](https://github.com/Azure-Samples/azure-search-openai-demo)**.

> **AZURE RESOURCE COSTS** by default this sample will create Azure App Service that have a monthly cost.

### Prerequisites

#### For Deployment to Existing App Service Environment
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Bicep](https://learn.microsoft.com/en-us/cli/azure/bicep?view=azure-cli-latest#az-bicep-install)

#### To Rebuild the Web App Source Code
- [Azure Developer CLI](https://aka.ms/azure-dev/install)
- [Python 3+](https://www.python.org/downloads/)
    - **Important**: Python and the pip package manager must be in the path in Windows for the setup scripts to work.
    - **Important**: Ensure you can run `python --version` from console. On Ubuntu, you might need to run `sudo apt install python-is-python3` to link `python` to `python3`.    
- [Node.js](https://nodejs.org/en/download/)
- [Git](https://git-scm.com/downloads)

>NOTE: Your Azure Account must have `Microsoft.Authorization/roleAssignments/write` permissions, such as [User Access Administrator](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#user-access-administrator) or [Owner](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#owner).

### Installation
1. Configure Environment Variables or Update main.parameters.json file with apprpriate values.
2. Deploy the App Service Plan and App Service from the Bicep file
```az cli
az deployment sub create --location <location> --template-file infra\main.bicep --parameters infra\main.parameters.json
```
3. Upload the web application code
```az cli
az webapp deploy --name <app service name> --resource-group <resource group name> --src-path app-deploy.zip
```

### Rebuild Web App and Redeploy
1. Run the azd package command
```azd cli
azd package
```
The output of successfully running the above command will show the path where the new .zip package will be located.
2. Upload the generaged zip package to your app service
```az cli
az webapp deploy --name <app service name> --resource-group <resource group name> --src-path <path/to/recompiled-app.zip>
```

### Quickstart

* In Azure: The URL is printed in the outputs when the bicep template completes (as "BACKEND_URI"), or you can find it in the Azure portal by browsing to the Application Service that was deployed.

Once in the web app:
* Try different topics in chat or Q&A context. For chat, try follow up questions, clarifications, ask to simplify or elaborate on answer, etc.
* Explore citations and sources
* Click on "settings" to try different options, tweak prompts, etc.

## Resources

* [Revolutionize your Enterprise Data with ChatGPT: Next-gen Apps w/ Azure OpenAI and Cognitive Search](https://aka.ms/entgptsearchblog)
* [Azure Cognitive Search](https://learn.microsoft.com/azure/search/search-what-is-azure-search)
* [Azure OpenAI Service](https://learn.microsoft.com/azure/cognitive-services/openai/overview)

