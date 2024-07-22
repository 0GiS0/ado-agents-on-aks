FROM mcr.microsoft.com/dotnet/framework/sdk:4.8.1

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /azp/

RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
  iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));

RUN choco install dotnetcore-runtime --version 2.2.7 -y \
  choco install aspnetcore-runtimepackagestore --version 2.2.7 -y; \  
  choco install git -y; \
  choco install jfrog-cli -y; \
  choco install awscli -y; \
  choco install azure-cli -y; \
  # choco install azuresigntool -y; \
  # choco install sonarqube -y; \
  choco install sonarqube-scanner.portable -y; \
  choco install jdk8 -y; \
  choco install python -y; \
  choco install openssl -y; \
  choco install 7zip -y; \
  dotnet tool install --global AzureSignTool;

COPY ./start.ps1 ./

CMD powershell .\start.ps1