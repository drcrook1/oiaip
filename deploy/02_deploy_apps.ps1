$base_name = "oiaipdev"
$resource_group = "dacrook-oiaip-dev"
$aks_name = $base_name + "aks"
$acr_name = $base_name + "acr"
$acr_server = $acr_name + ".azurecr.io"
az aks get-credentials -n $aks_name -g $resource_group -f ./aks_creds.txt

kubekubectl apply -f ./k8_deploys/mongo.yaml --kubeconfig ./aks_creds.txt

#
# Docker Login
#
$acr_creds = az acr credential show --name $acr_name --resource-group $resource_group | ConvertFrom-Json
$acr_username = $acr_creds.username
$acr_password = $acr_creds.passwords[0].value
docker login -u $acr_username -p $acr_password $acr_server
#Remove-Item -Path ./aks_creds.txt

#
# Docker Build & Push Apps
#
cd ..
cd ./src
cd ./admin_app
docker build -t $acr_server/admin_app .
docker push $acr_server/admin_app