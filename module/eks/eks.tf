resource "aws_eks_cluster" "global-cluster" {
  name = var.clustername
  role_arn = aws_iam_role.globalrole.arn
  version = "1.31"

  vpc_config {
    subnet_ids = [aws_subnet.pri01.id, aws_subnet.pri02.id]
  }
  depends_on = [
    aws_iam_role.globalrole
  ]
  tags = {
    Name = "clustertype"
    Environment = var.env
  }
}
