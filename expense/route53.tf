resource "aws_route53_record" "expense" {
    count = length(var.instance_names)
    zone_id = 
}