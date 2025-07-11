provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Name        = "comments"
      Project     = "opsmaster"
      Environment = "prod"
    }
  }
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"

  default_tags {
    tags = {
      Name        = "comments"
      Project     = "opsmaster"
      Environment = "prod"
    }
  }
}
