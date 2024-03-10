FROM mcr.microsoft.com/dotnet/framework/sdk:4.8.1

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /azp/

RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
  iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));

RUN choco install dotnetcore-runtime --version 2.2.7 -y;
RUN choco install aspnetcore-runtimepackagestore --version 2.2.7 -y;

COPY ./start.ps1 ./

CMD powershell .\start.ps1