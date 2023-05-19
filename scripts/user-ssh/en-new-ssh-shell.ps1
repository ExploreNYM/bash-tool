function cleanup {
    Remove-Item $MyInvocation.MyCommand.Path
    Remove-Variable sshkey_filename
    Remove-Variable public_key
    Remove-Variable permission
    $args = $args | Select-Object -Skip 1
}
trap { cleanup } EXIT
Clear-Host
Write-Host " _____            _                _   ___   ____  __ " -ForegroundColor Yellow
Write-Host "| ____|_  ___ __ | | ___  _ __ ___| \ | \ \ / /  \/  |" -ForegroundColor Yellow
Write-Host "|  _| \ \/ / '_ \| |/ _ \| '__/ _ \  \| |\ V /| |\/| |" -ForegroundColor Yellow
Write-Host "| |___ >  <| |_) | | (_) | | |  __/ |\  | | | | |  | |" -ForegroundColor Yellow
Write-Host "|_____/_/\_\ .__/|_|\___/|_|  \___|_| \_| |_| |_|  |_|" -ForegroundColor Yellow
Write-Host "           |_| $($ExecutionContext.InvokeCommand.ExpandString('`rhttps://explorenym.net/official-links`r'))" -ForegroundColor Yellow
Write-Host "`nScript Contents:" -ForegroundColor Cyan
Write-Host "`n  • Create new ssh-key"
Write-Host "  • Copy public ssh-key to your server"
Write-Host "  • Test ssh-key login`n"
$permission = Read-Host "Do you want to continue? (Y/n)"
if ($permission -eq "Y" -or $permission -eq "") {
    Push-Location $env:USERPROFILE\.ssh
    $sshkey_filename = ""
    while (-not $sshkey_filename) {
        $sshkey_filename = Read-Host "Enter SSH key filename"
    }
    ssh-keygen -f $sshkey_filename
    Start-Sleep -Seconds 2
    ssh-add $sshkey_filename
    $public_key = "$sshkey_filename.pub"
    Write-Host "Copying $public_key to your server"
    ssh-copy-id -i ~/.ssh/$public_key $args[0]
    Write-Host "Testing connect via ssh key"
    ssh $args[0]
    Start-Sleep -Seconds 1
    Invoke-WebRequest -OutFile en-new-ssh.sh https://github.com/explorenym/en-new-ssh.sh
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
    ./en-new-ssh.sh
}
else {
    Write-Host "Exiting Script."
}
