Function Load-Module {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$Module
    )

    #Ensure Module is not already loaded
    IF (!(Get-Module -Name $Module)) {
        IF (Get-Module -ListAvailable |Where-Object {$_.Name -EQ $Module}) {
            Try {
                Import-Module -Name $Module -ErrorAction Stop
                Write-Information -MessageData "Successfully loaded module: $Module"
            } Catch {
                Write-Error -Message "Unable to load module: $Module"
                $Script:tErrorCount++
            }
        }
    }
}
