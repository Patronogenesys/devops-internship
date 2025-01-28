ssh patronogen@$1 bash -s <<-END
  if [-d ./devops-internship]; then
    cd ./devops-internship
    git pull
  else
    # Clone repo
    git clone https://github.com/Patronogenesys/devops-internship.git
    cd ./devops-internship  
  fi

  cd ./task-12
  docker compose up
END
