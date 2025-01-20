# SDK
import yandexcloud 

# Other utils
import json
import git

# Instance management
from yandex.cloud.compute.v1.instance_pb2 import *
from yandex.cloud.compute.v1.instance_service_pb2 import *
from yandex.cloud.compute.v1.instance_service_pb2_grpc import InstanceServiceStub

# Cloud management
from yandex.cloud.resourcemanager.v1.cloud_service_pb2 import *
from yandex.cloud.resourcemanager.v1.cloud_service_pb2_grpc import CloudServiceStub

# Folder management
from yandex.cloud.resourcemanager.v1.folder_service_pb2 import *
from yandex.cloud.resourcemanager.v1.folder_service_pb2_grpc import FolderServiceStub

# Organizations manager
from yandex.cloud.organizationmanager.v1.organization_service_pb2 import *
from yandex.cloud.organizationmanager.v1.organization_service_pb2_grpc import OrganizationServiceStub


def input_index_stubborn(list, name):
    index = None
    while True:
        try:
            index = int(input(f"Введите номер {name}: "))
        except:
            print("Ошибка: Неверный номер попробуйте еще.")
            continue

        if index not in range(len(list)):
            print("Ошибка: Неверный номер попробуйте еще.")
        else:
            break
    return index


root_dir = git.Repo('.', search_parent_directories=True).working_dir
with open(f'{root_dir}/.secret/ya-oauth.json', 'r') as file:
    oauth_token = json.load(file)["token"]

sdk = yandexcloud.SDK(token=oauth_token)


# Select organization

org_service = sdk.client(OrganizationServiceStub)

response = org_service.List(
    ListOrganizationsRequest()
)


for i in range(len(response.organizations)):
    print(f"{i} - {response.organizations[i].title}")

index = input_index_stubborn(response.organizations, "организации")

organization = response.organizations[index]

# Select cloud
cloud_service = sdk.client(CloudServiceStub)

response = cloud_service.List(
    ListCloudsRequest(organization_id=organization.id)
)

for i in range(len(response.clouds)):
    print(f"{i} - {response.clouds[i].name}")

index = input_index_stubborn(response.clouds, "Облака")

cloud = response.clouds[index]

# Select folder
folder_service = sdk.client(FolderServiceStub)

response = folder_service.List(
    ListFoldersRequest(cloud_id=cloud.id)
)

for i in range(len(response.folders)):
    print(f"{i} - {response.folders[i].name}")

index = input_index_stubborn(response.folders, "папки")

folder = response.folders[index]

# Select instance

instance_service = sdk.client(InstanceServiceStub)

response = instance_service.List(
    ListInstancesRequest(folder_id=folder.id)
)

for i in range(len(response.instances)):
    print(f"{i} - {response.instances[i].name}")

index = input_index_stubborn(response.instances, "инстанса")

instance = response.instances[index]

# delete

operation = instance_service.Delete(DeleteInstanceRequest(instance_id=instance.id))
operation_result = sdk.wait_operation_and_get_result(
    operation,
    meta_type=DeleteInstanceMetadata,
)

