# --- SSH key ---
resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "demo" {
  key_name   = "demo-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh.private_key_openssh
  filename        = "${path.module}/demo-key.pem"
  file_permission = "0600"
}

# --- EC2 Instance ---
resource "aws_instance" "web" {
  ami                    = "ami-ubuntu2404-arm64"
  instance_type          = "m7g.medium"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.demo.key_name

  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    index_html_gz = base64gzip(templatefile("${path.module}/index.html", {
      vpc_id      = aws_vpc.main.id
      vpc_cidr    = aws_vpc.main.cidr_block
      subnet_id   = aws_subnet.public.id
      subnet_cidr = aws_subnet.public.cidr_block
      sg_id       = aws_security_group.web.id
    }))
  })

  tags = { Name = "demo-web" }
}

# --- Security group ---
resource "aws_security_group" "web" {
  name   = "demo-web"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
