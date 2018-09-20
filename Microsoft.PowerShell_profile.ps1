# # Check if SSH agent is currently running. Start it if not.
# # Get-SshAgent returns the PID of the running process if running, else 0.
# # If ((Get-SshAgent) -eq 0) {
# #     Start-SshAgent
# # }

# # Test-Administrator check the currently logged in user to see
# # if they are running PowerShell as an Administrator. Test-Administrator returns
# # true if they are, else false.
# function Test-Administrator {
#     $user = [Security.Principal.WindowsIdentity]::GetCurrent()
#     (New-Object Security.Principal.WindowsPrincipal $user).ISInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
# }

# # Prompt is called each time the PowerShell command prompt is to be displayed.
# function Prompt {
#     $exitcode = $LASTEXITCODE

#     # Running PowerShell as Administrator?
#     If (Test-Administrator) {
#         Write-Host '(Elevated) ' -ForegroundColor Red -NoNewline
#     }

#     # Username and Hostname
#     Write-Host "$($ENV:USERNAME)@$($ENV:COMPUTERNAME)" -ForegroundColor Yellow -NoNewline

#     # Current path

#     Write-Host " : " -ForegroundColor DarkGray -NoNewline

#     If ($pwd.Path.Length -gt [Math]::Floor($Host.UI.RawUI.BufferSize.Width)) {
#         # Truncate path
#     }
#     Else {
#         # Full path
#     }
#     # Write-Host "$((Get-Location).Drive.Root)" -ForeGroundColor Green -NoNewline
#     # Write-Host $($(Get-Location) -Replace ($ENV:USERPROFILE).Replace('\', '\\'), "~") -ForegroundColor Green -NoNewline

#     # If ($pwd.Path.Length -gt [Math]::floor($Host.UI.RawUI.BufferSize.Width)) {
#     #     Write-Host $($(Get-Location) -Replace ($ENV:USERPROFILE).Replace('\', '\\'), "~") -ForegroundColor Green -NoNewline
#     # }
#     # Else {
#     #     $dirs = $pwd.Path.Split('\');
#     #     Write-Host "$($dirs[0])\$($dirs[1])\...\$($dirs[-1])".Replace($ENV:USERPROFILE, '~') -ForegroundColor Green -NoNewline
#     # }

#     $Global:LASTEXITCODE = $exitcode

#     # Git status (if applicable)
#     # Write-VCSStatus


#     # Command Prompt

#     Return " > "
# }

Import-Module -Name 'posh-git'
Import-Module -Name 'oh-my-posh'
Import-Module -Name 'PSColor'
Set-Theme 'paradox'

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# The function below implements a fully featured PowerShell version of the Unix touch command.
# Reference: https://ss64.com/ps/syntax-touch.html
function Set-FileTime {
    param(
        [string[]]$paths,
        [bool]$only_modification = $false,
        [bool]$only_access = $false
    );

    begin {
        function updateFileSystemInfo([System.IO.FileSystemInfo]$fsInfo) {
            $datetime = get-date
            if ( $only_access ) {
                $fsInfo.LastAccessTime = $datetime
            }
            elseif ( $only_modification ) {
                $fsInfo.LastWriteTime = $datetime
            }
            else {
                $fsInfo.CreationTime = $datetime
                $fsInfo.LastWriteTime = $datetime
                $fsInfo.LastAccessTime = $datetime
            }
        }
   
        function touchExistingFile($arg) {
            if ($arg -is [System.IO.FileSystemInfo]) {
                updateFileSystemInfo($arg)
            }
            else {
                $resolvedPaths = resolve-path $arg
                foreach ($rpath in $resolvedPaths) {
                    if (test-path -type Container $rpath) {
                        $fsInfo = new-object System.IO.DirectoryInfo($rpath)
                    }
                    else {
                        $fsInfo = new-object System.IO.FileInfo($rpath)
                    }
                    updateFileSystemInfo($fsInfo)
                }
            }
        }
   
        function touchNewFile([string]$path) {
            #$null > $path
            Set-Content -Path $path -value $null;
        }
    }
 
    process {
        if ($_) {
            if (test-path $_) {
                touchExistingFile($_)
            }
            else {
                touchNewFile($_)
            }
        }
    }
 
    end {
        if ($paths) {
            foreach ($path in $paths) {
                if (test-path $path) {
                    touchExistingFile($path)
                }
                else {
                    touchNewFile($path)
                }
            }
        }
    }
}

New-Alias touch Set-FileTime
New-Alias ll Get-ChildItem
