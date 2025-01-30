ssh patronogen@$1 bash -s <<-END
  docker stop apache nginx
  docker rm apache nginx
  docker network rm app
END