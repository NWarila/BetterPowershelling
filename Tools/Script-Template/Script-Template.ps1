


<#
    .SYNOPSIS
        Mount and Configure Default User Profile For All New User Profiles.

    .DESCRIPTION
        This script is used to mount the Default User Profile during the MDT process and configure various options that will adjust the standard user experience in a positive manner.

    .PARAMETER Debug
        

    .INPUTS
        None

    .OUTPUTS
        None

    .NOTES

    VERSION     DATE			NAME						DESCRIPTION
	___________________________________________________________________________________________________________
	1.0         05 March 2020	Warilia, Nicholas R.		Initial version

        Credits:
            (1) Script Template: https://github.com/HellBomb/BetterPowershelling/blob/master/Tools/Script-Template/Script-Template.ps1
#>

Param (
    [String]$test
    #Enable/Disable debug
    ,[Int]$Debug = 1

)
# ---------------------------------------------------- [Manual Configuration] ----------------------------------------------------
#------------------------------------------------------ [Required Functions] -----------------------------------------------------
#----------------------------------------------- [Initializations & Prerequisites] -----------------------------------------------
#If Script is running as non-interactive (i.e. running as scheduled task or similar)
IF ([Environment]::GetCommandLineArgs().Contains('-NonInteractive') -or ([Environment]::UserInteractive -ne $False)) {
    #Is Interactive
}

#Check if in ISE
If (Test-Path Variable:PSise) {
    
}

#Check if administrator
$IsAdministrator = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator
IF ($IsAdministrator) {

}

#Set Set Debug Level
Switch ($Debug) {
    1       { $DoDebug = $True;  $DoVerbose = $True; $InformationPreference = 'Continue'  }
    2       { $DoDebug = $False; $DoVerbose = $True  }
    Default { $DoDebug = $False; $DoVerbose = $False }
}
Write-Information
#--------------------------------------------------------- [Main Script] ---------------------------------------------------------
New-Variable -Name Script -Description "Main variable used to store all permanent variables used within the script." -Force -ErrorAction Stop -Value @{

}

Write-Information -MessageData "Test"
#-------------------------------------------------------- [End of Script] --------------------------------------------------------
Remove-Variable -Name @("Debug","DoDebug","DoVerbose","IsAdministrator") -ErrorAction SilentlyContinue -Force -WhatIf:$DoDebug -Verbose:$DoVerbose


#------------------------------------------------------ [Notes & Misc Code] ------------------------------------------------------
#Check for Admin & relauch if not.
<#
    $ver = $host | select version
    if ($ver.Version.Major -gt 1)  {$Host.Runspace.ThreadOptions = "ReuseThread"}

    # Verify that user running script is an administrator
    $IsAdmin=[Security.Principal.WindowsIdentity]::GetCurrent()
    If ((New-Object Security.Principal.WindowsPrincipal $IsAdmin).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) -eq $FALSE)
    {
      "`nERROR: You are NOT a local administrator.  Run this script after logging on with a local administrator account."
        # We are not running "as Administrator" - so relaunch as administrator

        # Create a new process object that starts PowerShell
        $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell_ise";

        # Specify the current script path and name as a parameter
        $newProcess.Arguments = $myInvocation.MyCommand.Definition;

        # Indicate that the process should be elevated
        $newProcess.Verb = "runas";

        # Start the new process
        [System.Diagnostics.Process]::Start($newProcess);

        # Exit from the current, unelevated, process
        exit
    }
#>
