Param (
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$wslname,
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$wslvhdxpath,
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$username,
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$distro
)

function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}

function Red
{
    process { Write-Host $_ -ForegroundColor Red }
}

switch ($distro) {
    debian {
        Write-Output "You have selected $distro"
        if (-not(Test-Path $Env:windir\temp\wslprep)) {
            New-Item -Path $Env:windir\temp\wslprep -ItemType Directory
        }
        else {
            Write-host "Folder '$Env:windir\temp\wslprep' already exists, no need to create the folder." | Green
        }

        if (Test-Path $Env:windir\temp\wslprep\Debian.appx -PathType leaf) {
            Write-Output "File does Exist Debian.appx from last run exists." | Green
        }
        else {
            Write-Output "Downloading the Debian appx installer, this could take a while..." | Red
            Invoke-WebRequest -Uri https://aka.ms/wsl-debian-gnulinux -OutFile $Env:windir\temp\wslprep\Debian.appx -UseBasicParsing
        }

        Copy-Item $Env:windir\temp\wslprep\Debian.appx $Env:windir\temp\wslprep\$wslname.zip
        Expand-Archive $Env:windir\temp\wslprep\$wslname.zip $Env:windir\temp\wslprep\x64 -Force
        Move-Item -Path $Env:windir\temp\wslprep\x64\*_x64.appx -Destination $Env:windir\temp\wslprep\x64\$wslname.zip
        Expand-Archive $Env:windir\temp\wslprep\x64\$wslname.zip $Env:windir\temp\wslprep\x64\$wslname

        if (-Not (Test-Path -Path $wslvhdxpath)) {
            New-Item -Path $wslvhdxpath -ItemType Directory
        }
        else {
            Write-host "Folder '$wslvhdxpath' already exists, no need to create the folder." | Green
        }

        Write-Output "Install Debian with VHDX path $wslvhdxpath and WSL installation name $wslname" | Green
        wsl --import $wslname $wslvhdxpath $Env:windir\temp\wslprep\x64\$wslname\install.tar.gz
        Remove-Item -r $Env:windir\temp\wslprep\x64\
        wsl -d $wslname -u root bash -ic "apt update && apt upgrade -y && apt autoremove -y"
        wsl -d $wslname -u root bash -ic "./wsl/bash/createUser.sh $username ubuntu"
        wsl -t $wslname
        wsl -d $wslname -u root bash -ic "./wsl/bash/sudoNoPasswd.sh $username"
        wsl -d $wslname -u $username bash -ic "./wsl/bash/prepare.sh"
        Remove-Item $Env:windir\temp\wslprep\$wslname.zip
    }
    ubuntu {
        Write-Output "You have selected $distro"
        if (-not(Test-Path $Env:windir\temp\wslprep)) {
            New-Item -Path $Env:windir\temp\wslprep -ItemType Directory
        }
        else {
            Write-host "Folder '$Env:windir\temp\wslprep' already exists, no need to create the folder." | Green
        }

        if (Test-Path $Env:windir\temp\wslprep\Ubuntu.appx -PathType leaf) {
            Write-Output "File does Exist Ubuntu.appx from last run exists." | Green
        }
        else {
            Write-Output "Downloading the Ubuntu appx installer, this could take a while..." | Red
            Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile $Env:windir\temp\wslprep\Ubuntu.appx -UseBasicParsing
        }

        Copy-Item $Env:windir\temp\wslprep\Ubuntu.appx $Env:windir\temp\wslprep\$wslname.zip
        Expand-Archive $Env:windir\temp\wslprep\$wslname.zip $Env:windir\temp\wslprep\x64 -Force
        Move-Item -Path $Env:windir\temp\wslprep\x64\*_x64.appx -Destination $Env:windir\temp\wslprep\x64\$wslname.zip
        Expand-Archive $Env:windir\temp\wslprep\x64\$wslname.zip $Env:windir\temp\wslprep\x64\$wslname

        if (-Not (Test-Path -Path $wslvhdxpath)) {
            New-Item -Path $wslvhdxpath -ItemType Directory
        }
        else {
            Write-host "Folder '$wslvhdxpath' already exists, no need to create the folder." | Green
        }

        Write-Output "Install Ubuntu with VHDX path $wslvhdxpath and WSL installation name $wslname"
        wsl --import $wslname $wslvhdxpath $Env:windir\temp\wslprep\x64\$wslname\install.tar.gz
        Remove-Item -r $Env:windir\temp\wslprep\x64\
        wsl -d $wslname -u root bash -ic "apt update && apt upgrade -y && apt autoremove -y"
        wsl -d $wslname -u root bash -ic "./wsl/bash/createUser.sh $username ubuntu"
        wsl -t $wslname
        wsl -d $wslname -u root bash -ic "./wsl/bash/sudoNoPasswd.sh $username"
        wsl -d $wslname -u $username bash -ic "./wsl/bash/prepare.sh $username"
        wsl -d $wslname -u $username bash -ic "runAnsipansi"
        Remove-Item $Env:windir\temp\wslprep\$wslname.zip
    }
}

## copy global wslconfig
Copy-Item .\wsl\files\.wslconfig $Env:userprofile\.wslconfig -Force






