# Use an official Python runtime as a parent image
FROM python:3.9-slim-buster

# Install OpenSSH server and other necessary tools
RUN apt-get update && \
    apt-get install -y openssh-server sudo && \
    rm -rf /var/lib/apt/lists/*

# Create an SSH user and set a password
# Replace 'youruser' and 'yourpassword' with desired credentials
ARG SSH_USER=cl
ARG SSH_PASSWORD=workspace
RUN useradd -rm -d /home/${SSH_USER} -s /bin/bash ${SSH_USER} && \
    echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd && \
    adduser ${SSH_USER} sudo

# Expose the SSH port
EXPOSE 22

# Configure SSH daemon: PermitRootLogin no, PasswordAuthentication yes
# This line is important to allow password authentication for the created user
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config # Disable PAM for simpler password auth

# Start SSH service when the container runs
# This command keeps the container alive
CMD ["/usr/sbin/sshd", "-D"]
