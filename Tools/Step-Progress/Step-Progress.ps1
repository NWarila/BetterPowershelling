function Step-Progress {
	param (
        [Parameter(Mandatory=$True,Position=0)]
        [Int]$ID,
        [Parameter(Mandatory=$True,Position=0)]
        [Int]$Step,
        [Parameter(Mandatory=$True,Position=0)]
	    [string]$Message,
        [ValidateRange(1,9999)]
        [Int]$StepCount
	)

    If ($StepCount) {
        New-Variable -Scope Script -Name sp$ID -Value $StepCount -Force
    } ElseIf (-Not (Test-Path -Path variable:script:sp$ID)) {
        New-Variable -Scope Script -Name sp$ID -Value (Select-String -Path $psISE.CurrentFile.FullPath -Pattern ("Step-Progress.*-id(?:\:| (?:`"|')?)\d+(?: |'|`").*$") -AllMatches).count -Force
    }

    New-Variable -Name Arguments -Value @{
        'Id'              = $ID
        'Activity'        = $Message
        'PercentComplete' = (($Step / (Get-Variable -Name sp$ID -Scope Script -ValueOnly)) * 100)
    }

    #Automatically detect ParentID
    If (Test-path -Path variable:script:sp$($ID-1)) {
        $Arguments.ParentId = $ID-1
    }
	Write-Progress @Arguments
}
