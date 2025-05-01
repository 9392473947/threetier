locals {
  # Default tags
  default_tags = {
    Environment = "production"
    Owner       = "Team A"
  }

  final_tags = merge(
    local.default_tags,
    { Name = var.instances[count.index].name },  
    var.custom_tags                              
  )
}
