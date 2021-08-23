output "instance_id" {
  value = aws_instance.web_app.*.id
}
output "subnet" {
  value = aws_subnet.public_subnet.id
}
