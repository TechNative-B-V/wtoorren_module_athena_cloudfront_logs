output "cloudfront_logs_table_name" {
  value       = aws_glue_catalog_table.cloudfront_logs_catalog_table.name
  description = "The name of the table created."
}

output "athena_query_results_bucket_id" {
  description = "ID of the Athena query results S3 bucket"
  value       = aws_s3_bucket.athena_query_results.id
}

output "athena_workgroup_name" {
  description = "Name of the Athena workgroup"
  value       = aws_athena_workgroup.example.name
}

