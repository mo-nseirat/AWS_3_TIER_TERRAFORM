resource "aws_ecr_repository" "todo_app" {
  name         = "todo-app"
  force_delete = true

  tags = {
    Name = "todo-app"
  }
}