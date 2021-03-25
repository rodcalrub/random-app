resource "aws_instance" "alea" {
  ami                         = "ami-0d9a499b43edd7ae0" // "ami-2757f631"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.PRACTICAS_DEVOPS.id]

  root_block_device {
    volume_size = 20 #20 Gb
  }

  tags = {
    Name        = "${var.author}.alea"
    Author      = var.author
    Date        = "2020.03.25"
    Environment = "LAB"
    Location    = "Paris"
    Project     = "PRACTICAS_DEVOPS"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.key_path)
  }

  # provisioner "file" {
  #   source      = "file1.txt"
  #   destination = "/home/ec2-user/file1.txt"
  # }
  provisioner "file" {
    content     = <<EOF
{
    "log-driver": "awslogs",
    "log-opts": {
      "awslogs-group": "docker-logs-test",
      "tag": "{{.Name}}/{{.ID}}"
    }
}
EOF
    destination = "/home/ec2-user/daemon.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker httpd-tools",
      "sudo usermod -a -G docker ec2-user",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.22.0-rc2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo chkconfig docker on",
      "sudo service docker start",
      # portainer
      # "sudo bash ../docker-build.sh",
      # "sudo bash ../docker-run.sh",
      # "sudo docker run -d --name Alea -p 80:80 rodrasna/alea",
      "npm install",
      "npm start",
      "sudo echo -n ${var.portainer_passwd} > /tmp/portainer_passwd",
      "sudo docker run -d --name portainer -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/portainer_passwd:/tmp/portainer_passwd portainer/portainer-ce --admin-password-file /tmp/portainer_passwd",
    ]
  }

  # provisioner "remote-exec" {
  #   script = "./launch-containers.sh"
  # }

}
