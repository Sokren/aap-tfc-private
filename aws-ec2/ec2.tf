####################################################################
# EC2 web servers + réseau associé
# EC2 web servers and their network resources
####################################################################

# --- Clé SSH / SSH key pair ----------------------------------------
# Suffixe aléatoire dédié à la clé / Dedicated random suffix for the key
resource "random_string" "key_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Nom en partie aléatoire (tag-pet-suffixe) et unique.
# Partly random, unique name (tag-pet-suffix).
resource "aws_key_pair" "boundary" {
  key_name   = "${var.tag}-${random_pet.test.id}-${random_string.key_suffix.result}"
  public_key = var.pub_ssh_key

  tags = local.tags
}

# --- Groupe de sécurité / Security group ---------------------------
resource "aws_security_group" "worker" {
  vpc_id = data.terraform_remote_state.aws_infra.outputs.vpc_id

  tags = {
    Name = "${var.tag}-worker-${random_pet.test.id}"
  }
}

# SSH (22)
resource "aws_security_group_rule" "allow_ingress_controller" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

# HTTP (80)
resource "aws_security_group_rule" "allow_ingress_controller_httpds" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

# HTTP alternatif utilisé par le site / Alternate HTTP port used by the site (8080)
resource "aws_security_group_rule" "allow_ingress_controller_httpds8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

# Sortie / Egress (tout / all)
resource "aws_security_group_rule" "allow_egress_controller" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

# --- Instances EC2 (serveurs web) / EC2 web servers ----------------
resource "aws_instance" "web_server" {
  count                       = var.num_web_servers
  ami                         = "ami-0fd3ac4abb734302a" # RHEL
  instance_type               = "t3.micro"
  subnet_id                   = data.terraform_remote_state.aws_infra.outputs.subnet.*.id[count.index]
  key_name                    = aws_key_pair.boundary.key_name
  vpc_security_group_ids      = [aws_security_group.worker.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.tag}-web_server-${random_pet.test.id}-${count.index}"
  }
}
