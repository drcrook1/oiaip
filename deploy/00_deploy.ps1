$resourceGroupName = "dacrook-oiaip-dev" # $RESOURCE_GROUP
$location = "eastus"


Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName "jayoung-Team Subscription"
az account set -s "jayoung-Team Subscription"

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

$sp_rbac = az ad sp create-for-rbac -n "dacrookoiaip" | ConvertFrom-Json
ssh-keygen -t rsa -b 2048 -f ./rsa.txt -N mypassword
$pub_key = Get-Content ./rsa.txt.pub 

Write-Host "Key is: '$pub_key' "

$templateParamObject = @{
    "baseName" = "dacrook"
    "dnsPrefix" = "oiaip"
    "servicePrincipalClientId" = ([string]$sp_rbac.appId | ConvertTo-SecureString -AsPlainText -Force)
    "servicePrincipalClientSecret" = ([string]$sp_rbac.password | ConvertTo-SecureString -AsPlainText -Force)
    "sshRSAPublicKey" = $pub_key
    "linuxAdminUserName" = "david"
}

#Start Actual Deployment
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName `
                                    -Mode Incremental `
                                    -TemplateFile "./arm_templates/00_template.json" `
                                    -TemplateParameterObject $templateParamObject