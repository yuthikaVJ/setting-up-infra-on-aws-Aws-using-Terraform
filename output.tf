output "web1" {
  value = aws_instance.web1.public_ip
}
output "web2" {
  value = aws_instance.web2.public_ip
}

output "aws_lb_dns" {
  value = aws_lb.my_lb.dns_name

}