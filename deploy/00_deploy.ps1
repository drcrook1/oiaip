$resourceGroupName = "dacrook-oiaip-dev" # $RESOURCE_GROUP
$location = "eastus"


Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName "jayoung-Team Subscription"

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Creating resource group '$resourceGroupName' in location '$location'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

az ad sp create-for-rbac -n "dacrookoiaip"

$templateParamObject = @{
    "baseName" = "dacrook"
}

#Start Actual Deployment
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName `
                                    -Mode Incremental `
                                    -TemplateFile "./arm_templates/00_ml_template.json" `
                                    -TemplateParameterObject $templateParamObject