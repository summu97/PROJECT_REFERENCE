# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set the maintainer label
LABEL maintainer="Sumanth Bade <sumo1998sumanth@gmail.com>"

# Set DEBIAN_FRONTEND to noninteractive to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y git openssh-server openjdk-8-jdk maven && \
    apt-get install -y openjdk-11-jre-headless && \
    apt-get install -y iputils-ping && \
    apt-get install -y wget gnupg git software-properties-common vim sudo && \
    apt-get install -y python3-pip && \
    pip3 install requests google-auth && \
    apt-get -y autoremove && \
    apt-get clean

# Install Python 3 and create a virtual environment
RUN apt-get install -y python3 python3-venv && \
    python3 -m venv /venv

# Add HashiCorp GPG key and repository
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com focal main" | tee /etc/apt/sources.list.d/hashicorp.list

# Add Ansible repository and install Ansible
RUN apt-add-repository --yes --update ppa:ansible/ansible && \
    apt-get install -y ansible

# Update package lists and install Terraform
RUN apt-get update && \
    apt-get install -y terraform

# Install crcmod package within the virtual environment
RUN /venv/bin/pip install crcmod

# Install the Google Cloud SDK
RUN wget -q https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz && \
    tar -xf google-cloud-sdk.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet && \
    rm google-cloud-sdk.tar.gz && \
    ln -s /google-cloud-sdk/bin/gcloud /usr/bin/gcloud && \
    /google-cloud-sdk/bin/gcloud components install kubectl

# Set up SSH server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd

# Set password for Jenkins user and add to sudoers list
RUN useradd -m -d /var/lib/jenkins -s /bin/bash jenkins && \
    echo 'jenkins:password' | chpasswd
RUN echo 'jenkins ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers

# Copy authorized keys and set permissions
COPY .ssh/authorized_keys /var/lib/jenkins/.ssh/authorized_keys
RUN chown -R jenkins:jenkins /var/lib/jenkins/.ssh/ && \
    chmod 600 /var/lib/jenkins/.ssh/authorized_keys

# Generate new SSH keys
RUN ssh-keygen -t rsa -b 2048 -f /var/lib/jenkins/.ssh/id_rsa -N ""
RUN chmod 644 /var/lib/jenkins/.ssh/id_rsa

# Create inventory directory and touch the service-account.json file
RUN mkdir -p /var/lib/jenkins/inventory && \
    chown -R jenkins:jenkins /var/lib/jenkins/inventory && \
    chmod -R 755 /var/lib/jenkins && \
    touch /var/lib/jenkins/inventory/service-account.json && \
    chown -R jenkins:jenkins /var/lib/jenkins/inventory/service-account.json

# Expose the standard SSH port
EXPOSE 22

# Start the SSH server
CMD ["/usr/sbin/sshd", "-D"]
