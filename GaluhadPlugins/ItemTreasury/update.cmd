@REM powershell Set-ExecutionPolicy RemoteSigned -Scope Process
@REM powershell Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
@REM powershell Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
@REM powershell Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
powershell Unblock-File -Path ".\_update.ps1"
powershell -ExecutionPolicy RemoteSigned -File ".\_update.ps1"
update_en.cmd