$resourceGroupName = "dacrook-oiaip-dev" # $RESOURCE_GROUP
$location = "eastus"

Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName "jayoung-Team Subscription"
az account set -s "jayoung-Team Subscription"
$sub_id = (az account show | ConvertFrom-Json).id
Write-Host "Subscription Id: '$sub_id'"

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

$sp_rbac = az ad sp create-for-rbac -n "dacrookoiaip" --skip-assignment | ConvertFrom-Json
#sleep to ensure ad credential exists
Start-Sleep -Seconds 30

ssh-keygen -t rsa -b 2048 -f ./rsa.txt -N mypassword
$pub_key = [string](Get-Content ./rsa.txt.pub)
$app_id_t = [string]$sp_rbac.appId 
$app_id = ConvertTo-SecureString -String $app_id_t -AsPlainText -Force
$app_secret_t = [string]$sp_rbac.password 
$app_secret = ConvertTo-SecureString -String $app_secret_t -AsPlainText -Force
Write-Host "SP ID: '$app_id_t' SP Secret: '$app_secret_t'"


az role assignment create --assignee $app_id_t --scope /subscriptions/$sub_id/resourceGroups/$resourceGroupName --role Contributor
#sleep to ensure ad credential changes exist
Start-Sleep -Seconds 30

$templateParamObject = New-Object -TypeName Hashtable
$templateParamObject.Add("baseName", "oiaipdev")
$templateParamObject.Add("servicePrincipalClientId", $app_id)
$templateParamObject.Add("servicePrincipalClientSecret", $app_secret)
$templateParamObject.Add("sshRSAPublicKey", $pub_key)
$templateParamObject.Add("linuxAdminUserName", "david")

#Start Actual Deployment
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName `
                                    -Mode Incremental `
                                    -TemplateFile "./arm_templates/00_template.json" `
                                    -TemplateParameterObject $templateParamObject

#
# Clean Up
#
Remove-Item -Path ./rsa.txt
Remove-Item -Path ./rsa.txt.pub