# https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops#linux

FROM ubuntu:20.04
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    software-properties-common \
    wget \
    libicu66 \
    openjdk-17-jdk \
    # cleanup
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
&& dpkg -i packages-microsoft-prod.deb \
&& rm packages-microsoft-prod.deb

RUN apt-get update && apt-get install -y dotnet-host dotnet-sdk-8.0

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
RUN export JAVA_HOME

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

# Create agent user and set up home directory
RUN useradd -m -d /home/agent agent
RUN chown -R agent:agent /azp /home/agent

USER agent

ENTRYPOINT [ "./start.sh" ]