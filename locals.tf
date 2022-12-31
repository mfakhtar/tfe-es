locals {
  public_subnets = aws_subnet.fawaz-tfe-es-pub-sub[*].id
}

locals {
  private_subnets = aws_subnet.fawaz-tfe-es-pri-sub[*].id
}