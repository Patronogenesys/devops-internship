ssh patronogen@$1 bash -s <<-END
  cd ~/devops-internship/task-12
  docker compose down
END