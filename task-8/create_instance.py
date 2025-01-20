# Написать на питоне скрипт для создания VM.
# Далее питоном получить всю инфу о машине (IP, OS, metrics, size, type),
# сменить ключ от инстанса (после смены проверить подключение по новому ключу)
# и потом все убить (также кодом на питоне). 

# OS Images
from yandex.cloud.compute.v1.image_service_pb2 import GetImageLatestByFamilyRequest

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

# VPC manager
from yandex.cloud.vpc.v1.network_service_pb2 import *
from yandex.cloud.vpc.v1.network_service_pb2_grpc import NetworkServiceStub

# SDK
import yandexcloud 

# Other utils
import json
import git

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

# Select Net

net_service = sdk.client(NetworkServiceStub)

response = net_service.List(
    ListNetworksRequest(folder_id=folder.id)
)

for i in range(len(response.networks)):
    print(f"{i} - {response.networks[i].name}")

index = input_index_stubborn(response.networks, "сети")

net = response.networks[index]

# Select Subnet

response = net_service.ListSubnets(
    ListNetworkSubnetsRequest(
        network_id=net.id
    )
)

for i in range(len(response.subnets)):
    print(f"{i} - {response.subnets[i].name}")

index = input_index_stubborn(response.subnets, "подсети")

subnet = response.subnets[index]


# Enter name
instance_name = input("Введите имя инстанса: ")

while True:
    submit = input("Введенные данные верны? [y/n]: ")
    match submit:
        case "y":
            break
        case "n":
            print("Запустите скрипт снова!")
            exit()
        case _:
            print("Введите 'y' или 'n'")

instance_service = sdk.client(InstanceServiceStub)

ssh_key = None
with open('/home/patronogen/.ssh/min-vm-18-12-2024.pub') as f:
    ssh_key = f.read()
users_meta = '''#cloud-config
datasource:
 Ec2:
  strict_id: false
ssh_pwauth: no
users:
- name: patronogen
  sudo: ALL=(ALL) NOPASSWD:ALL
  shell: /bin/bash
  ssh_authorized_keys:
  - {ssh_key}'''.format(ssh_key=ssh_key)

operation = instance_service.Create(
    CreateInstanceRequest(
        folder_id=folder.id,
        name=instance_name,
        zone_id=subnet.zone_id,
        platform_id="standard-v2",
        resources_spec=ResourcesSpec(
            memory=2 * 2**30,
            cores=2,
            core_fraction=5,
        ),
        boot_disk_spec=AttachedDiskSpec(
            auto_delete=True,
            disk_spec=AttachedDiskSpec.DiskSpec(
                type_id="network-hdd",
                size=10 * 2**30,
                image_id="fd817upt6ubkr107osh7", # Ubuntu 24.04 LTS
            ),
        ),
        network_interface_specs=[
            NetworkInterfaceSpec(
                subnet_id=subnet.id,
                primary_v4_address_spec=PrimaryAddressSpec(
                    one_to_one_nat_spec=OneToOneNatSpec(
                        ip_version=IPV4,
                    )
                ),
            ),
        ],
        metadata={"user-data":users_meta, 
                  "ssh-keys": f"patronogen:{ssh_key}"}
    )
)

print("""###
Ждем ответ от сервера
###""")

operation_result = sdk.wait_operation_and_get_result(
    operation,
    response_type=Instance,
    meta_type=CreateInstanceMetadata,
)
print(operation_result.response)



