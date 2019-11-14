$base_name = "oiaipdev"
$resource_group = "dacrook-oiaip-dev"
$aks_name = $base_name + "aks"
$acr_name = $base_name + "acr"
$acr_server = $acr_name + ".azurecr.io"
az aks get-credentials -n $aks_name -g $resource_group -f ./aks_creds.txt --overwrite-existing

kubectl apply -f ./k8_deploys/mongo.yaml --kubeconfig ./aks_creds.txt

#
# Docker Login
#
$acr_creds = az acr credential show --name $acr_name --resource-group $resource_group | ConvertFrom-Json
$acr_username = $acr_creds.username
$acr_password = $acr_creds.passwords[0].value
docker login -u $acr_username -p $acr_password $acr_server

#
# Register ACR w/ AKS via regsecret
#
kubectl create secret docker-registry regsecret --docker-server=$acr_server --docker-username=$acr_username --docker-password=$acr_password --docker-email=support@oiaip.com

#
# Docker Build & Push Apps
#
cd ..
cd ./src
cd ./admin_app
mkdir ./credentials
cp ../../deploy/aks_creds.txt ./credentials/aks_creds.txt
docker build -t $acr_server/oiaipadmin .
docker push $acr_server/oiaipadmin

cd ../../deploy
#
# Replace Tokens in oiaip_app for ADMIN Application
#
((Get-Content -path k8_deploys/oiaip_app.yaml -Raw) -replace '{{#APP_NAME#}}',"oiaipadmin") | Set-Content -Path ./k8_deploys/oiaip_admin_app.yaml
((Get-Content -path k8_deploys/oiaip_admin_app.yaml -Raw) -replace '{{#ACR_NAME#}}',$acr_name) | Set-Content -Path ./k8_deploys/oiaip_admin_app.yaml
((Get-Content -path k8_deploys/oiaip_admin_app.yaml -Raw) -replace '{{#KUBE_CONFIG_FILE_PATH#}}',"./credentials/aks_creds.txt") | Set-Content -Path ./k8_deploys/oiaip_admin_app.yaml

#
# Deploy OIAIP Applications
#
kubectl apply -f "./k8_deploys/oiaip_admin_app.yaml" --kubeconfig ./aks_creds.txt

#Remove-Item -Path ./aks_creds.txt