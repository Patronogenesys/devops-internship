ssh patronogen@$1 bash -s <<-END
  if [ -d ~/devops-internship ]; then
    cd ~/devops-internship
    git pull
  else
    # Clone repo
    git clone https://github.com/Patronogenesys/devops-internship.git
    cd ./devops-internship  
  fi
  sudo rm -rf ./.secret
END

echo "SCP copying...\n"

sudo scp -ri /home/patronogen/.ssh/id_ed25519 ../.secret/ patronogen@$1:~/devops-internship

echo "Compose..."


ssh patronogen@$1 bash -s <<-END
  sudo chown -R 101:101 ./.secret/ssl
END