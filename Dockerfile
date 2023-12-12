# Use a base image that matches the runner's operating system and architecture.
# For example, if you are using Linux ARM64 as shown in the screenshot:
# FROM hunglam2501/baseimage2:latest
FROM ubuntu:22.04

# Set the environment variable for the runner's version.
# Make sure to use the version shown in your screenshot or the latest available.
ENV RUNNER_VERSION="2.311.0"

# Install necessary dependencies for the GitHub Runner and any additional tools you require.
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    jq \
    tar \
    curl \
    unzip \
    gnupg \
    software-properties-common \
    lsb-release \
    gpg \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
    # && rm -rf /var/lib/apt/lists/*

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip ./aws

# Install containerd
# RUN apt-get install -y containerd
# Add Docker’s official GPG key
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Set up the Docker repository
RUN add-apt-repository \
    "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

# Install Docker CE
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose (optional, if you need it)
RUN curl -L "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Install Docker Buildx
RUN mkdir -p ~/.docker/cli-plugins/ \
    && curl -sSL "https://github.com/docker/buildx/releases/download/v0.7.1/buildx-v0.7.1.linux-$(uname -m)" -o ~/.docker/cli-plugins/docker-buildx \
    && chmod a+x ~/.docker/cli-plugins/docker-buildx

# Set up the environment to use Buildx by default
ENV DOCKER_CLI_EXPERIMENTAL=enabled
ENV DOCKER_BUILDKIT=1

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg;
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null;
RUN apt update && apt install -y gh;

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# Create a user for the runner and give it the necessary permissions.
# Replace 'runner' with your preferred user name.
RUN useradd -m runner && \
    usermod -aG sudo runner && \
    echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up the runner directory.
RUN mkdir /actions-runner && chown -R runner /actions-runner

# Set the working directory.
WORKDIR /actions-runner
 
COPY token.sh /actions-runner/

# RUN chmod u+x /actions-runner/token.sh && ./token.sh
# Switch to the runner user.
USER runner

# RUN sudo apt-get install -y binfmt-support qemu-user-static
# Download the runner package.
RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
# Optional: Validate the hash.
# The hash in the following line should match the one provided by GitHub in your screenshot.
# Ensure that the SHA256 hash matches the one for your downloaded version.
# RUN echo " actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz" | shasum -a 256 -c\
RUN sudo chmod u+x /actions-runner/token.sh
# Expose necessary ports (if any)
# For example, if you need to expose port 8080 for a web application, uncomment the next line.
# EXPOSE 80
ENTRYPOINT ["./token.sh"]
