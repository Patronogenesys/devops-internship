ssh patronogen@$1 bash -s <<-END
  
  docker stop apache nginx
  docker rm apache nginx

  docker network create --driver bridge app

  docker run --network app --name apache -d patronogenesys/myapache 
  docker run --network app \
    -v /home/patronogen/devops-internship/.secret/ssl/patronogen.ru:/ssl/patronogen.ru \
    -p 80:8080 \
    -p 443:8443 \
    --name nginx \
    -d \
    patronogenesys/mynginx:latest
END