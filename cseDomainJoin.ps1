param(
    [string] $joinUsername,
    [string] $joinPassword,
    [string] $domain,
    [string] $logDir="$env:windir\system32\logfiles"
)

function LogWriter($message) {
    $message="$(Get-Date ([datetime]::UtcNow) -Format "o") $message"
	write-host($message)
	if ([System.IO.Directory]::Exists($logDir)) {write-output($message) | Out-File $LogFile -Append}
}

# Define logfile
$LogFile=$LogDir+"\CustomExtension.log"

# Bool to determine if reboot is required
$RebootRequired = $false

# Logic begins here
LogWriter("Starting BOP Custom Script Extension Script")

if((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain) {
    LogWriter("Computer is already a domain member, not doing a domain join.")
}
else {
    LogWriter("Attempting domain join")
    $domainJoinCredential = New-Object System.Management.Automation.PSCredential($joinUsername,(ConvertTo-SecureString $joinPassword -AsPlainText -Force))
    Add-Computer -Credential $domainJoinCredential -DomainName $domain -Force -ErrorAction Stop
    $RebootRequired = $true
    LogWriter("Completed domain join")
}

# Final Reboot to finish domain join and finish
if($rebootRequired) {
    LogWriter("Rebooting")
    Restart-Computer -Force
}
else {
    LogWriter("Reboot not required. Exiting.")
}
