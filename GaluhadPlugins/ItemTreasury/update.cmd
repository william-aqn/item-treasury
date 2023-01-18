@REM powershell Set-ExecutionPolicy RemoteSigned -Scope Process
@REM powershell Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
@REM powershell Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
@REM powershell Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
powershell Unblock-File -Path '%~dp0\_update.ps1'
powershell -ExecutionPolicy RemoteSigned -File "%~dp0\_update.ps1"
"%~dp0\update_en.cmd"