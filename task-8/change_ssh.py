import paramiko

# addr = input("Введите адрес: ")
# usr = input("Введите пользователя: ")

# curr_private = input("Введите путь до текущего ключа (private): ")

# new_private = input("Введите путь до нового ключа (private): ")
# new_pub = input("Введите путь до нового ключа (pub): ")

# test data
addr = '158.160.74.39'
usr = "patronogen"

curr_private = '/home/patronogen/.ssh/min-vm-18-12-2024'

new_private = '/home/patronogen/.ssh/min-vm-user1-18-12-2024'
new_pub = '/home/patronogen/.ssh/min-vm-user1-18-12-2024.pub'

# curr_private = '/home/patronogen/.ssh/min-vm-user1-18-12-2024'

# new_private = '/home/patronogen/.ssh/min-vm-18-12-2024'
# new_pub = '/home/patronogen/.ssh/min-vm-18-12-2024.pub'

with open(new_pub) as f:
    new_pub = f.read()


try:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(addr, username=usr, key_filename=curr_private)
except:
    print("Ошибка подключения!")
    exit()

# backup key
stdin, stdout, stderr = ssh.exec_command(f'cat ~/.ssh/authorized_keys')

curr_pub = stdout

# change key
stdin, stdout, stderr = ssh.exec_command(f'echo "{new_pub}" > ~/.ssh/authorized_keys')

# check new conn
try:
    check = paramiko.SSHClient()
    check.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    check.connect(addr, username=usr, key_filename=new_private)
except:
    print("Ошибка подключения по новой паре ключей!")
    # Revert
    stdin, stdout, stderr = ssh.exec_command(f'echo "{curr_pub}" > ~/.ssh/authorized_keys')



