FROM ubuntu:20.04

LABEL maintainer="Sumanth Bade <sumo1998sumanth@gmail.com>"

# Set DEBIAN_FRONTEND to noninteractive to avoid interactive prompts
ENV DEBIAN_FRONTEND noninteractive

# Install apt-utils along with other necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y git openssh-server openjdk-8-jdk maven && \
    apt-get install -y openjdk-11-jre-headless && \
    apt-get install -y iputils-ping && \
    apt-get install -y wget gnupg git software-properties-common vim sudo && \
    apt-get -y autoremove && \
    apt-get clean

# Install Python 3 and create virtual environment
RUN apt-get install -y python3 python3-venv && \
    python3 -m venv /venv

# Add HashiCorp GPG key
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository to sources.list
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

# Set password for jenkins user
RUN useradd -m -d /var/lib/jenkins -s /bin/bash jenkins && \
    echo 'jenkins:password' | chpasswd

# Adding jenkins to sudoers list
RUN echo 'jenkins ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers

# Copy authorized keys
COPY .ssh/authorized_keys /var/lib/jenkins/.ssh/authorized_keys

# Set permissions
RUN chown -R jenkins:jenkins /var/lib/jenkins/.ssh/ && \
    chmod 600 /var/lib/jenkins/.ssh/authorized_keys

# Creates new keys
RUN ssh-keygen -t rsa -b 2048 -f /var/lib/jenkins/.ssh/id_rsa -N ""
RUN chmod 644 /var/lib/jenkins/.ssh/id_rsa

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
