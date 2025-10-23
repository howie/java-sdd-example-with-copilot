#!/bin/bash

# 設定環境變數
export ENVIRONMENT=${1:-dev}
export PROJECT_NAME="thsr-booking"
export LOCATION="eastasia"

# 確保已登入 Azure
echo "確認 Azure 登入狀態..."
az account show > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "請先登入 Azure："
    az login
fi

# 建立並設定 Terraform 後端存儲
STORAGE_ACCOUNT_NAME="tfstate${PROJECT_NAME}${ENVIRONMENT}"
CONTAINER_NAME="tfstate"
RESOURCE_GROUP_NAME="rg-tfstate-${PROJECT_NAME}-${ENVIRONMENT}"

echo "建立 Terraform 後端存儲..."
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --sku Standard_LRS
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

# 取得存儲帳戶金鑰
STORAGE_ACCOUNT_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)

# 初始化 Terraform
echo "初始化 Terraform..."
terraform init \
    -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \
    -backend-config="container_name=$CONTAINER_NAME" \
    -backend-config="key=terraform.tfstate" \
    -backend-config="access_key=$STORAGE_ACCOUNT_KEY"

# 生成 Terraform 計劃
echo "生成 Terraform 部署計劃..."
terraform plan \
    -var="environment=${ENVIRONMENT}" \
    -var="project_name=${PROJECT_NAME}" \
    -var="location=${LOCATION}" \
    -out=tfplan

# 詢問是否執行部署
read -p "是否要執行部署？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "執行 Terraform 部署..."
    terraform apply tfplan
fi