# SPDX-FileCopyrightText: Copyright Yuniel Acosta, CU
# SPDX-License-Identifier: MIT

resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}