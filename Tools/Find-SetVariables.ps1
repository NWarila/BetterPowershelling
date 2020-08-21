[String[]]$ExcludedVariables = @("BuiltinVariables","ExcludedVariables","MaximumAliasCount","MaximumDriveCount","MaximumErrorCount","MaximumFunctionCount","MaximumVariableCount","psISE","psUnsupportedConsoleApplications")

#Create new variable to store all a list of built-in variables.
New-Variable -Name BuiltinVariables -ErrorAction Stop -Force -Value $(New-Object -TypeName System.Collections.ArrayList)

#Query OS funvtion it uses to generate the origional built-in variable list.
[psobject].Assembly.GetType('System.Management.Automation.SpecialVariables').GetFields('NonPublic,Static') |Where-Object {$_.FieldType -eq [String]} |ForEach-Object { [Void]$BuiltinVariables.Add($_.GetValue($Null)) }

#Add all the explicitly specified excluded variables to the BuiltinVariables variable.
$ExcludedVariables |ForEach-Object { [Void]$BuiltinVariables.Add($_) }

#This is where the magic happens.
Get-Variable -Scope 0 |Where-Object { $BuiltinVariables -NotContains $_.name }

<#
    Easy line to click & run to try and remove all variables bringing you back to a clean state. 
    Get-Variable -Scope 0 |Where-Object {$Left -NotContains $_.name} |remove-variable -ErrorAction SilentlyContinue -Force
#>
