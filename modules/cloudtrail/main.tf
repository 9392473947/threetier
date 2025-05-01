module "cloudtrail" {
    source = "./module"
    
    name = "cloudtrail-test"
    enable_logging = true
    s3_bucket_name = "cloudtrail-bucket-testmahindra"
    sns_topic_name = "cloudtrail_sns"
    cloud_watch_logs_role_arn = "arn:aws:iam::779527285137:role/service-role/123-role-khav55ci"
    cloud_watch_logs_group_arn = "arn:aws:logs:us-west-1:779527285137:log-group:cloudtrail_loggroup:*"
    kms_key_arn = "arn:aws:kms:us-west-1:779527285137:key/9df7b2af-f554-4391-9d6c-73b6a4f037b1"
    s3_key_prefix = "s3key"
    tags = {
        env = "test"
    }
}