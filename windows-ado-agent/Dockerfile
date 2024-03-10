# FROM mcr.microsoft.com/windows/servercore:ltsc2022
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8.1

# # Install chocolatey and nuget
# RUN Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); \
#     choco install nuget.commandline -y; \
#     choco install git -y; \
#     choco install 7zip -y; 
#     # choco install dotnet-4.5.2 -y; 
#     # choco install visualstudio2017-workload-vctools -y; `
#     # choco install visualstudio2017-workload-netcorebuildtools -y; `
#     # choco install visualstudio2017-workload-webbuildtools -y; `
#     # choco install visualstudio2017-workload-netweb -y; `
#     # choco install visualstudio2017-workload-netcoretools

# # Install .NET Framework 4.5
# RUN powershell -Command Add-WindowsFeature NET-Framework-45-ASPNET ; \
#     Add-WindowsFeature Web-Asp-Net45

WORKDIR /azp/

COPY ./start.ps1 ./

CMD powershell .\start.ps1