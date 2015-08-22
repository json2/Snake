Import-Module $PSScriptRoot\Snake.psd1

while(startGame){}

Write-Host ""
Write-Host ""
Write-Host "`t`t`tThanks for playing!" -ForegroundColor Green
Write-Host ""
Write-Host "This program will end in 3 seconds..." -NoNewline
sleep -Seconds 1
[System.Console]::SetCursorPosition(25, [System.Console]::WindowHeight + 3)
Write-Host "2" -NoNewline
Sleep -Seconds 1
[System.Console]::SetCursorPosition(25, [System.Console]::WindowHeight + 3)
Write-Host "1" -NoNewline
Sleep -Seconds 1
[System.Console]::SetCursorPosition(25, [System.Console]::WindowHeight + 3)
Write-Host "0"
[System.Console]::CursorVisible = $true
