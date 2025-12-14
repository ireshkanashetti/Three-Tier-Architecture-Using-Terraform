output "public-sub-ip" {
  value = aws_instance.public-server.public_ip
}
output "private-sub-ip" {
  value = aws_instance.private-server.private_ip
}