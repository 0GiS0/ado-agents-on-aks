FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Install nuget


# Install .NET Framework 3.5
RUN powershell -Command Add-WindowsFeature NET-Framework-45-ASPNET ; \
    Add-WindowsFeature Web-Asp-Net45

WORKDIR /azp/

COPY ./start.ps1 ./

CMD powershell .\start.ps1