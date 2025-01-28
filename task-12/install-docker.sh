
ssh patronogen@$1 bash -s <<-END

  # Install packages
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh ./get-docker.sh

  # Group setup
  sudo groupadd docker
  sudo usermod -aG docker $USER
  newgrp docker
  docker run hello-world

  # Autostart setup
  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service
  
END
