FROM python:3.12-rc-bookworm
WORKDIR /com.docker.devenvironments.code

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.5.6/terraform_1.5.6_linux_amd64.zip
RUN unzip terraform_1.5.6_linux_amd64.zip
RUN mv terraform /usr/local/bin/

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install


