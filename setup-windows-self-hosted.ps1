# Install Azure CLI
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri https://azcliprod.blob.core.windows.net/msi/azure-cli-2.51.0.msi -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I', 'AzureCLI.msi', '/quiet'
Remove-Item .\AzureCLI.msi

# Create symlink for pwsh alias that many Azure workflow steps use (Windows 10<)
New-Item -ItemType SymbolicLink -Path "C:\Windows\System32\pwsh.exe" -Target "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

# Ensure that long paths are enabled (Windows 10<)
Start-Process powershell -Verb RunAs -ArgumentList "-Command", "New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1 -PropertyType DWORD -Force;"

# Restart the GitHub actions runner service in order for environment variables to be useable (az)
Restart-Service -Name "actions.runner.*" -Force