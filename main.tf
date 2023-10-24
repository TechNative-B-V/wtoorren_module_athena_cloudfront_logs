locals {
  athena_db_name_snake_case = replace(lower(var.database_name), "-", "_")
}


resource "aws_athena_database" "access_logs_athena_database" {
  count  = var.create_database == true ? 1 : 0
  name   = local.athena_db_name_snake_case
  bucket = var.s3_bucket_name
}

resource "aws_glue_catalog_table" "cloudfront_logs_catalog_table" {
  name          = var.cloudfront_logs_table_name
  database_name = var.create_database == true ? aws_athena_database.access_logs_athena_database[0].name : var.database_name

  parameters = {
    EXTERNAL                 = "TRUE"
    "skip.header.line.count" = "2"
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket_name}/${var.cloudfront_access_log_prefix}/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "serde"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim" : "\t"
        "serialization.format" : "\t"
      }
    }

    dynamic "columns" {
      for_each = local.cloudfront_logs_table_columns
      content {
        name = columns.value.name
        type = columns.value.type
      }
    }
  }
}

# resource "aws_athena_named_query" "cloudfront_logs_saved_query" {
#   name     = var.queries.*.name
#   database = var.create_database == true ? aws_athena_database.access_logs_athena_database[0].name : var.database_name
#   query    = var.queries.*.query
# }

# resource "aws_s3_bucket" "athena_query_results" {
#   bucket = "${var.env}-${var.database_name}" 
# }

# resource "aws_s3_bucket_ownership_controls" "athena_query_ownership" {
#   bucket = aws_s3_bucket.athena_query_results.id
#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# resource "aws_s3_bucket_acl" "athena_query_acl" {
#   depends_on = [aws_s3_bucket_ownership_controls.athena_query_ownership]
#   bucket     = aws_s3_bucket_athena_query_results.id
#   acl        = "private"
# }

# resource "aws_athena_workgroup" "athena_query_workgroup" {
#   name = "Cloudfront Logs"

#   configuration {
#     enforce_workgroup_configuration    = true
#     publish_cloudwatch_metrics_enabled = true

#     result_configuration {
#       output_location = "s3://${aws_s3_bucket.athena_query_result.bucket}/output/"
#     }
#   }
# }






# resource "aws_athena_workgroup" "example" {
#   name = "${var.env}-${var.database_name}-workgroup"

#   configuration {
#     enforce_workgroup_configuration    = true
#     publish_cloudwatch_metrics_enabled = true

#     result_configuration {
#       output_location = "s3://${aws_s3_bucket.athena_query_results.bucket}/output/"

#       # encryption_configuration {
#       #   encryption_option = "SSE_KMS"
#       #   kms_key_arn       = aws_kms_key.example.arn
#       # }
#     }
#   }
# }