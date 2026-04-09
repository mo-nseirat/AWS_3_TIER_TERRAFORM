resource "aws_ecr_repository" "node-todo-api" {
  name         = "node-todo-api"
  force_delete = true 

  tags = {
    Name = "node-todo-api"
  }
}