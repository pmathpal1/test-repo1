FROM jenkins/jenkins:lts

USER root

# Optional: Install Docker CLI (useful for jobs that use Docker)
RUN apt-get update && \
    apt-get install -y docker.io && \
    apt-get clean

# Optional: add Jenkins to Docker group so it can run docker commands
RUN usermod -aG docker jenkins

# Create the .ssh directory and set correct permissions for SSH keys
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Add GitHub's SSH key to known_hosts to avoid verification failures
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

USER jenkins

# Install Jenkins plugins using the provided plugins.txt
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
