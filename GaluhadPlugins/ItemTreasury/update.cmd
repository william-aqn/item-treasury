powershell Set-ExecutionPolicy RemoteSigned -Scope Process
powershell Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
powershell Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
powershell -File ".\_update.ps1"
@REM powershell -File ".\_update_en.ps1"
update_en.cmd