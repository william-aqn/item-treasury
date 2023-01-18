PowerShell.exe Set-ExecutionPolicy RemoteSigned -Scope Process
PowerShell.exe Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
PowerShell.exe -File ".\_update.ps1"