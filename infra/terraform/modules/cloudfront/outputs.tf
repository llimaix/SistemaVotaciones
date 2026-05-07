output "distribution_id" {
  description = "ID del CloudFront Distribution"
  value       = aws_cloudfront_distribution.frontend.id
}

output "distribution_arn" {
  description = "ARN del CloudFront Distribution (usado en la bucket policy del S3 frontend)"
  value       = aws_cloudfront_distribution.frontend.arn
}

output "distribution_domain_name" {
  description = "Domain name público del CloudFront Distribution"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "oac_id" {
  description = "ID del Origin Access Control"
  value       = aws_cloudfront_origin_access_control.frontend.id
}
