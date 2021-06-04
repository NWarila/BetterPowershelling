Function New-Function {
    <#
        .SYNOPSIS
            
        .DESCRIPTION
            
        .PARAMETER 
        .PARAMETER Confirm
            [Int] Determine what type of changes should be prompted before executing.
                0 - Confirm both environment and object changes.
                1 - Confirm only object changes. (Default)
                2 - Confirm nothing!
                Object Changes are changes that are permanent such as file modifications, registry changes, etc.
                Environment changes are changes that can normally be restored via restart, such as opening/closing applications.
                Note: This configuration will take priority over Debugger settings for confirm action preference.
        .PARAMETER Debugger
            [Int] Used primarily to quickly apply multiple arguments making script development and debugging easier. Useful only for developers.
                1. Incredibly detailed play-by-play execution of the script. Equivilent to '-Change 0',  '-LogLevel Verbose', script wide 'ErrorAction Stop', 'Set-StrictMode -latest', and lastly 'Set-PSDebug -Trace 1'
                2. Equivilent to '-Change 0', '-LogLevel Verbose', and script wide 'ErrorAction Stop'.
                3. Equivilent to '-Change 1', '-LogLevel Info', and enables verbose on PS commands.
        .PARAMETER LogLevel
            [String] Used to display log output with definitive degrees of verboseness. 
                Verbose = Display everything the script is doing with extra verbose messages, helpful for debugging, useless for everything else.
                Debug   = Display all messages at a debug or higher level, useful for debugging.
                Info    = Display all informational messages and higher. (Default)
                Warn    = Display only warning and error messages.
                Error   = Display only error messages.
                None    = Display absolutely nothing.
        .INPUTS
            None
        .OUTPUTS
            None
        .NOTES
        VERSION     DATE			NAME						DESCRIPTION
	    ___________________________________________________________________________________________________________
	    1.0         28 Sept 2020	Warilia, Nicholas R.		Initial version
        
        Script tested on the following Powershell Versions
         1.0   2.0   3.0   4.0   5.0   5.1 
        ----- ----- ----- ----- ----- -----
          X    X      X     X     ✓    ✓
        Credits:
            (1) Script Template: https://gist.github.com/9to5IT/9620683
        To Do List:
            (1) Get Powershell Path based on version (stock powershell, core, etc.)
        Additional Information:
            #About '#Requires': https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_requires?view=powershell-5.1
            Show-Command Creates GUI window with all parameter; super easy to see what options are available for a command.
            Get-Verb Shows all approved powershell versb
    #>

    [CmdletBinding(
        ConfirmImpact="None",
        DefaultParameterSetName="Site",
        HelpURI="",
        SupportsPaging=$False,
        SupportsShouldProcess=$True,
        PositionalBinding=$True
    )] Param (
        [Parameter(Mandatory=$True)]
        [ValidateSet('TitanSpheres')]
        $Activity,
        [Parameter(Mandatory=$True)]
        [ValidateRange(10,10000)]
        [Int]$Count,
        [ValidateSet('File','GUI')]
        [String]$HeaderInput='Auto',
        [Int]$Buffer=50,
        [ValidateSet(0,1,2)]
        [Int]$Confim = 1,
        [ValidateSet(0,1,2)]
        [Int]$Debugger = 3,
        [ValidateSet("Verbose","Debug","Info","Warn","Error","Fatal","Off")]
        [String]$LogLevel = "Info",
        [ValidateSet("Log","Host","LogHost","Auto")]
        [String]$LogOutput='Auto',
        [Switch]$Testing
    )

    #region --------------------------------------------- [Manual Configuration] ----------------------------------------------------
        #Require Admin Privilages.
        New-Variable -Force -Name ScriptConfig -value @{
            #Should script enforce running as admin.
            RequireAdmin = $False
        }

    #endregion,#')}]#")}]#'")}]
    #region ----------------------------------------------- [Required Functions] -----------------------------------------------------
        #Requires -Version 5.0
        #Requires -PSEdition Desktop

        Function Write-nLog {
            <#
                .SYNOPSIS
                    Standardized & Easy to use logging function.
                .DESCRIPTION
                    Easy and highly functional logging function that can be dropped into any script to add logging capability without hindering script performance.
                .PARAMETER type
                    Set the event level of the log event.
                    [Options]
                        Info, Warning, Error, Debug
        
                .PARAMETER message
                    Set the message text for the event.

                .PARAMETER ErrorCode
                    Set the Error code for Error & fatal level events. The error code will be displayed in front of the message text for the event.
            
                .PARAMETER WriteHost
                    Force writing to host reguardless of SetWriteLog setting for this specific instance.

                .PARAMETER WriteLog
                    Force writing to log reguardless of SetWriteLog setting for this specific instance.

                .PARAMETER SetLogLevel
                    Set the log level for the nLog function for all future calls. When setting a log level all logs at 
                    the defined level will be logged. If you set the log level to warning (default) warning messages 
                    and all events above that such as error and fatal will also be logged. 
                    (1) Debug: Used to document events & actions within the script at a very detailed level. This level 
                    is normally used during script debugging or development and is rarely set once a script is put into
                    production
                    (2) Information: Used to document normal application behavior and milestones that may be useful to 
                    keep track of such. (Ex. File(s) have been created/removed, script completed successfully, etc)
                    (3) Warning: Used to document events that should be reviewed or might indicate there is possibly
                    unwanted behavior occuring.
                    (4) Error: Used to document non-fatal errors indicating something within the script has failed.
                    (5) Fatal: Used to document errors significant enough that the script cannot continue. When fatal
                    errors are called with this function the script will terminate. 
        
                    [Options]
                        1,2,3,4,5
                .PARAMETER SetLogFile
                    Set the fully quallified path to the log file you want used. If not defined, the log will use the 
                    "$Env:SystemDrive\ProgramData\Scripts\Logs" directory and will name the log file the same as the 
                    script name. 
                .PARAMETER SetWriteHost
                    Configure if the script should write events to the screen. (Default: $False)
                    [Options]
                        $True,$False
        
                .PARAMETER SetWriteLog
                    Configure if the script should write events to the screen. (Default: $True)
                    [Options]
                        $True,$False
        
                .PARAMETER Close
                    Removes all script-level variables set while nLog creates while running.
                .INPUTS
                    None
                .OUTPUTS
                    None
                .NOTES
                VERSION     DATE			NAME						DESCRIPTION
	            ___________________________________________________________________________________________________________
	            1.0			25 May 2020		Warila, Nicholas R.			Initial version
                2.0			28 Aug 2020		Warila, Nicholas R.			Complete rewrite of major portions of the script, significant improvement in script performance (about 48%), and updated log format.
        
                Credits:
                    (1) Script Template: https://gist.github.com/9to5IT/9620683
            #>
            Param (
                [Parameter(Mandatory=$True,Position=0)]
                [ValidateSet('Debug','Info','Warning','Error','Fatal')]
                [String]$Type,
                [Parameter(Mandatory=$True,ValueFromPipeline=$False,Position=1)]
                [String]$Message,
                [Parameter(Mandatory=$False,ValueFromPipeline=$False,Position=2)][ValidateRange(0,9999)]
                [Int]$ErrorCode = 0,
                [Switch]$WriteHost,
                [Switch]$WriteLog,
                [Switch]$Initialize,
                [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
                [ValidateSet('Debug','Info','Warning','Error','Fatal')]
                [String]$SetLogLevel,
                [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
                [String]$SetLogFile,
                [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
                [String]$SetLogDir,
                [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
                [Bool]$SetWriteHost,
                [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
                [Bool]$SetWriteLog,
                [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
                [ValidateSet('Local','UTC')]
                [String]$SetTimeLocalization,
                [ValidateSet('nLog','CMTrace')]
                [String]$SetLogFormat,
                [Int]$Line,
                [Switch]$Close
            )

            #Best practices to ensure function works exactly as expected, and prevents adding "-ErrorAction Stop" to so many critical items.
            #$Local:ErrorActionPreference = 'Stop'
            #Set-StrictMode -Version Latest

            #Allows us to turn on verbose on all powershell commands when adding -verbose
            IF ($PSBoundParameters.ContainsKey('Verbose')) {
                Set-Variable -Name Verbose -Value $True
            } Else {
                IF (Test-Path -Path Variable:\verbose) {
                    Set-Variable -Name Verbose -Value ([Bool]$Script:Verbose)
                } Else {
                    Set-Variable -Name Verbose -Value $False
                }
            }

            New-Variable -Name StartTime -Value ([DateTime]::Now) -Force -Verbose:$Verbose -Description "Used to calculate timestamp differences between log calls."

            #Ensure all the required script-level variables are set.
            IF ((-Not (Test-Path variable:Script:nLogInitialize)) -OR $Initialize) {
                New-Variable -Name SetTimeLocalization -Verbose:$Verbose -Scope Script -Force -Value ([DateTime]::Now)
                New-Variable -Name nLogFormat          -Verbose:$Verbose -Scope Script -Force -Value "nLog"
                New-Variable -Name nLogLevel           -Verbose:$Verbose -Scope Script -Force -Value ([String]"Info")
                New-Variable -Name nLogInitialize      -Verbose:$Verbose -Scope Script -Force -Value $True
                New-Variable -Name nLogWriteHost       -Verbose:$Verbose -Scope Script -Force -Value $False
                New-Variable -Name nLogWriteLog        -Verbose:$Verbose -Scope Script -Force -Value $True
                New-Variable -Name nLogLastTimeStamp   -Verbose:$Verbose -Scope Script -Force -Value $StartTime
            
                New-Variable -Name nLogDir             -Verbose:$Verbose -Scope Script -Force -Value $ScriptEnv.Script.DirectoryName
                New-Variable -Name nLogFile            -Verbose:$Verbose -Scope Script -Force -Value "$($ScriptEnv.Script.BaseName)`.log"
                New-Variable -Name nLogFullName        -Verbose:$Verbose -Scope Script -Force -Value "$nLogDir\$nLogFile"
                New-Variable -Name nLogFileValid       -Verbose:$Verbose -Scope Script -Force -Value $False

                New-Variable -Name nLogLevels        -Verbose:$Verbose -Scope Script -Force -Value $([HashTable]@{
                    Debug   = @{ Text = "[DEBUG]  "; LogLevel = [Int]'1'; tForeGroundColor = "Cyan";   }
                    Info    = @{ Text = "[INFO]   "; LogLevel = [Int]'2'; tForeGroundColor = "White";  }
                    Warning = @{ Text = "[WARNING]"; LogLevel = [Int]'3'; tForeGroundColor = "DarkRed";}
                    Error   = @{ Text = "[ERROR]  "; LogLevel = [Int]'4'; tForeGroundColor = "Red";    }
                    Fatal   = @{ Text = "[FATAL]  "; LogLevel = [Int]'5'; tForeGroundColor = "Red";    }
                })
            }

            Switch($PSBoundParameters.Keys) {
                'SetLogLevel'  {Set-Variable -Name nLogLevel     -Verbose:$Verbose -Scope Script -Force -Value $SetLogLevel  }
                'SetLogFormat' {Set-Variable -Name nLogFormat    -Verbose:$Verbose -Scope Script -Force -Value $SetLogFormat}
                'SetWriteHost' {Set-Variable -Name nLogWriteHost -Verbose:$Verbose -Scope Script -Force -Value $SetWriteHost }
                'SetWriteLog'  {Set-Variable -Name nLogWriteLog  -Verbose:$Verbose -Scope Script -Force -Value $SetWriteLog  }
                'SetLogDir'    {
                    Set-Variable -Name nLogDir       -Verbose:$Verbose -Scope Script -Force -Value $SetLogDir
                    Set-Variable -Name nLogFileValid -Verbose:$Verbose -Scope Script -Force -Value $False
                }
                'SetLogFile'   {
                    Set-Variable -Name nLogFile      -Verbose:$Verbose -Scope Script -Force -Value "$($SetLogFile -replace "[$([string]::join('',([System.IO.Path]::GetInvalidFileNameChars())) -replace '\\','\\')]",'_')"
                    Set-Variable -Name nLogFileValid -Verbose:$Verbose -Scope Script -Force -Value $False
                }
                'SetTimeLocalization' {
                    #Prevent issues where timestamp will show huge differences in time between code calls when converting UCT and Local
                    If ($Script:nLogTimeLocalization -ne $SetTimeLocalization -AND -NOT [String]::IsNullOrWhiteSpace($Script:nLogLastTimeStamp)) {
                        If ($Script:nLogTimeLocalization -eq 'Local') {
                            Set-Variable -Name nLogLastTimeStamp -Verbose:$Verbose -Scope Script -Force -Value $nLogLastTimeStamp.ToLocalTime()
                        } Else {
                            Set-Variable -Name nLogLastTimeStamp -Verbose:$Verbose -Scope Script -Force -Value $nLogLastTimeStamp.ToUniversalTime()
                        }
                    }
                    Set-Variable -Name nLogTimeLocalization -Verbose:$Verbose -Scope Script -Force -Value $SetTimeLocalization
                }
            }

            IF (-NOT $PSBoundParameters.ContainsKey('Line')) {
                Set-Variable Line -Verbose:$Verbose -Force -Value $MyInvocation.ScriptLineNumber
            }
            IF ($PSBoundParameters.ContainsKey('WriteHost')) { $tWriteHost = $True } Else { $tWriteHost = $Script:nLogWriteHost }
            IF ($PSBoundParameters.ContainsKey('WriteLog'))  { $tWriteLog  = $True } Else { $tWriteLog  = $Script:nLogWriteLog  }

            #Determine if script log level greater than or equal to current log event level and we actually are configured to write something.
            IF ($Script:nLogLevels[$Type]["LogLevel"] -ge $Script:nLogLevels[$Script:nLogLevel]["LogLevel"] -AND $Script:nLogLevel -ne 0 -AND ($tWriteHost -EQ $True -OR $tWriteLog -EQ $True)) {

                #Convert TimeStamp if needed
                IF ($Script:nLogTimeLocalization -eq 'UTC') {
                    Set-Variable -Name StartTime -Value ($StartTime.ToUniversalTime().ToString("s",[System.Globalization.CultureInfo]::InvariantCulture))
                }

                #Code Block if writing out to log file.
                If ($tWriteLog) {
                    IF ($Script:nLogFileValid -eq $False) {
                        Set-Variable -Name nLogFullName      -Verbose:$Verbose -Scope Script -Force -Value (Join-Path -Path $Script:nLogDir -ChildPath $Script:nLogFile)

                        #[Test Write access to results file.]
                        If ([system.io.file]::Exists($Script:nLogFullName)) {
                            Try {
                                (New-Object -TypeName 'System.IO.FileStream' -ArgumentList $Script:nLogFullName,([System.IO.FileMode]::Open),([System.IO.FileAccess]::Write),([System.IO.FileShare]::Write),4096,([System.IO.FileOptions]::None)).Close()
                            } Catch {
                                Write-Error -Message "Unable to open $Script:nLogFile. (Full Path: '$Script:nLogFullName')"
                                exit
                            }
                        } Else {
                            Try {
                                (New-Object -TypeName 'System.IO.FileStream' -ArgumentList $Script:nLogFullName,([System.IO.FileMode]::Create),([System.IO.FileAccess]::ReadWrite),([System.IO.FileShare]::ReadWrite),4096,([System.IO.FileOptions]::DeleteOnClose)).Close()
                            } Catch {
                                Write-Error -Message "Unable to create $Script:nLogFile. (Full Path: '$Script:nLogFullName')"
                            }
                        }
                        Set-Variable -Name nLogFileValid -Verbose:$Verbose -Scope Script -Force -Value $True
                    }

                    New-Variable -Force -Verbose:$Verbose -Name FileStream   -Value (New-Object -TypeName 'System.IO.FileStream' -ArgumentList $Script:nLogFullName,([System.IO.FileMode]::Append),([System.IO.FileAccess]::Write),([System.IO.FileShare]::Write),4096,([System.IO.FileOptions]::WriteThrough))
                    New-Variable -Force -Verbose:$Verbose -Name StreamWriter -Value (New-Object -TypeName 'System.IO.StreamWriter' -ArgumentList $FileStream,([Text.Encoding]::Default),4096,$False)

                    Switch ($Script:nLogFormat) {
                        'CMTrace'    {
                            [String]$WriteLine = '<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="" type="{4}" thread="" file="">' -f `
                            $Message,
                            ([DateTime]$StartTime).ToString('HH:mm:ss.fff+000'),
                            ([DateTime]$StartTime).ToString('MM-dd-yyyy'),
                            "$($ScriptEnv.Script.Name):$($Line)",
                            "1"
                        }
                        'nLog' {
                            $WriteLine = "$StartTime||$Env:COMPUTERNAME||$Type||$($ErrorCode.ToString(`"0000`"))||$Line)||$Message"
                        }
                    }
                    $StreamWriter.WriteLine($WriteLine)
                    $StreamWriter.Close()
                }

                #Code Block if writing out to log host.
                IF ($tWriteHost) {
                    Write-Host -ForegroundColor $Script:nLogLevels[$Type]["tForeGroundColor"] -Verbose:$Verbose "$StartTime ($(((New-TimeSpan -Start $Script:nLogLastTimeStamp -End $StartTime -Verbose:$Verbose).Seconds).ToString('0000'))s) $($Script:nLogLevels[$Type]['Text']) [$($ErrorCode.ToString('0000'))] [Line: $($Line.ToString('0000'))] $Message"
                }

                #Ensure we have the timestamp of the last log execution.
                Set-Variable -Name nLogLastTimeStamp -Scope Script -Value $StartTime -Force -Verbose:$Verbose
            }
        
            #Remove Function Level Variables. This isn't needed unless manually running portions of the code instead of calling it via a funtion.
            #Remove-Variable -Name @("Message","SetLogLevel","SetLogFile","Close","SetWriteLog","SetWriteHost","LineNumber","ErrorCode","tWriteHost","WriteHost","tWriteLog","WriteLog","StartTime") -ErrorAction SilentlyContinue

            IF ($PSBoundParameters.ContainsKey('Close') -or $Type -eq 'Fatal') {
                Remove-Variable -Name @("nLogLastTimeStamp","nLogFileValid","nLogFile","nLogDir","nLogWriteLog","nLogWriteHost","nLogInitialize","nLogLastTimeStamp","nLogLevels","nLogFullName","nLogLevel") -Scope Script -ErrorAction SilentlyContinue
            }

            #Allow us to exit the script from the logging function.
            If ($Type -eq 'Fatal') {
                Exit
            }
        }
        Function RC {
        [CmdletBinding()]
        Param (
            [Parameter(Mandatory=$True)]
            [ScriptBlock]$Command,
            [ValidateSet("Error","Fatal")]
            [Alias("EL")]
            [String]$ErrorLevel="Error",
            [Alias("EM")]
            [String]$ErrorMessage,
            [Alias("SM")]
            [String]$SuccessMessage,
            [ValidateSet("Results","None","Status")]
            [String]$Return = "Results",
            [Switch]$NoParsing,
            [Switch]$NoExpansion
        )

        New-Variable -Force -Name CommandString -Value (new-object -TypeName System.Text.StringBuilder)
        New-Variable -Force -Name CommandRaw    -Value (new-object -TypeName System.Text.StringBuilder)

        IF ($NoParsing) {
            $Null = $CommandString.append($Command.ToString().trim())
        } Else {
            # No errors, let's search the AST for the first command invocation
            $CommandInvocations = (([System.Management.Automation.Language.Parser]::ParseInput($command, [ref]$null, [ref]$Null)).FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $True)).where({$_.parent.extent.text -eq $Command.tostring().trim()})

            if ($CommandInvocations.count -eq 0) {
                Write-nLog -Type Fatal -Message "Unable to extract command from scriptblock."
            }
            New-Variable -Force -Name FinalCommands -Value (New-Object -TypeName 'System.Collections.Generic.Dictionary[[Int],[Object]]')
            @("R","E","F","C","P","N","NE") | ForEach {New-Variable -Force -Name $_ -value ([Int]0)}
            ForEach ($CommandInvocation in $CommandInvocations) {
                $FinalCommands.Add($FinalCommands.count+1,[PSCustomObject]@{
                    Name          = $CommandInvocation.GetCommandName();
                    Command       = Get-Command -Name $CommandInvocation.GetCommandName()
                    Parameters    = New-Object 'System.Collections.Specialized.OrderedDictionary'
                    CommandJoiner = ";"
                })

                #Check to see if the passed command is an alias or not.
                IF ($FinalCommands[$FinalCommands.count+1].Command.CommandType -eq 'Alias') {
                    Write-nLog -Type Debug -Message "WARNING: Command '$($FinalCommands[$FinalCommands.count+1].name)' is an alias of '$($FinalCommands[$FinalCommands.count+1].command.ReferencedCommand.Name)'. You should consider removing the alias."
                    $FinalCommands[$FinalCommands.count+1].command = $FinalCommands[$FinalCommands.count+1].command.ReferencedCommand
                }

                #Set Variables to default values on each run to ensure value consistency
                @(@{n="F";v=$FinalCommands.count},@{n="c";v=$CommandInvocation.CommandElements.count},@{n="p";v=0},,@{n="NE";v=([int]1)}) |ForEach {Set-Variable -Name $_.n -Value $_.v}
                IF ($CommandInvocations.Parent.PipelineElements.IndexOf($CommandInvocation) -lt $CommandInvocations.Count-1) {
                    $FinalCommands[$f].CommandJoiner = "|"
                }

                #Itterate through all elements
                While ($NE+1 -le $C) {
                    @(@{n="N";v="PARAM$P"},@{n="R";v=([String]::Empty)},@{n="E";v=([String]::Empty)}) |ForEach {Set-Variable -Name $_.n -Value $_.v}
                    Switch ($CommandInvocation.CommandElements[$NE].getType()) {
                        'System.Management.Automation.Language.CommandParameterAst' {
                            #If this is the last element
                            [String]$N = $CommandInvocation.CommandElements[$NE].ParameterName
                            #    Last Element | Has A Value                                                  |  Next object is a parameter
                            IF ($NE+1 -eq $C -OR $CommandInvocation.CommandElements[$NE].Argument -ne $Null -OR $CommandInvocation.CommandElements[$NE+1].getType().ToString() -eq 'System.Management.Automation.Language.CommandParameterAst') {
                                [string]$R = $CommandInvocation.CommandElements[$NE].Argument.extent.text
                            } Else {
                                #If the next element is not a paremeter or empty then add this element with next elements value.
                                [string]$R = $CommandInvocation.CommandElements[$NE+1].extent.text
                                $NE++
                            }
                        }
                        Default {
                            [string]$R = $CommandInvocation.CommandElements[$NE].extent.text
                        }
                    }
                    IF ($N -eq "PARAM$P") {
                        Write-nLog -Type Debug -Message "WARNING: Ambigious parameter with value of '$R' passed."
                    }

                    IF ($NoExpansion) {
                        $E = $R
                    } Else {
                        $E = $ExecutionContext.InvokeCommand.ExpandString($R.replace('$_','`$`_'))
                    }
                    $FinalCommands[$F].Parameters.Add($N.ToUpper(),[PSCustomObject]@{Name=$N;RawValue=$R;ExpandedValue=$E;Property=$N.TOUPPER()})
                    $P++
                    $NE++
                }
            }
    
            #Lets build our final command string with any adjustments we want.
            ForEach ($FinalCommand in $FinalCommands.values) {
                #If the command is variable then ensure it processes properly.
                IF ($FinalCommand.Command.noun -eq 'Variable') {
                    #If scope is not defined then 
                    if ($FinalCommand.Parameters.Values.Property -notcontains "SCOPE") {
                        $FinalCommand.Parameters.add("SCOPE",[PSCustomObject]@{Name="Scope";RawValue=1;ExpandedValue=1;Property="SCOPE"})
                    }

                    #IF the command is new-variable
                    IF ($FinalCommand.command.verb -eq 'New') {
                        #IF name was defined specifically.
                        IF ($FinalCommand.Parameters.Contains("NAME")) {
                            
                            If ($ScriptEnv.Variables.Contains($FinalCommand.Parameters.NAME.ExpandedValue)) {
                                Write-nLog -Type Debug -Message "Variable '$($FinalCommand.Parameters.NAME.ExpandedValue)' already exists. Considering changing code to set-variable instead." -Line $MyInvocation.ScriptLineNumber

                                If ($FinalCommand.Parameters.keys -notcontains "FORCE") {
                                    Write-nLog -Type Debug -Message "Variable already exists but attempted to create a new variable, adding force option." -Line $MyInvocation.ScriptLineNumber
                                    $FinalCommand.Parameters.add("FORCE",[PSCustomObject]@{Name="Force";RawValue=$NULL;ExpandedValue=$NULL;Property="FORCE"})
                                }
                            } Else {
                                Write-nLog -Type Debug -Message "Adding variable '$($FinalCommand.Parameters.NAME.ExpandedValue)' to '`$ScriptEnv.Variables' list." -Line $MyInvocation.ScriptLineNumber
                                $Null = $Script:ScriptEnv.Variables.Add($FinalCommand.Parameters.NAME.ExpandedValue)
                            }
                        }
                    }
                }
        
                #Now that we have made any needed changes for this command lets itterate throught it building it into the stringbuilder.
                $Null = $CommandString.Append("$($FinalCommand.name)")
                $Null = $CommandRaw.Append("$($FinalCommand.name)")
                ForEach ($Parameter in $FinalCommand.Parameters.values) {
                    Switch ($Parameter) {
                        {$_.name -match "^PARAM[0-9]+$"}                 { $Null = $CommandString.Append(" $($Parameter.ExpandedValue)");$Null = $CommandRaw.Append(" $($Parameter.RawValue)") }
                        {[String]::IsNullOrWhiteSpace($_.RawValue)}      { $Null = $CommandString.Append(" -$($Parameter.Name)");$Null = $CommandRaw.Append(" -$($Parameter.Name)") }
                        Default                                          { $Null = $CommandString.Append(" -$($Parameter.Name):$($Parameter.ExpandedValue)");$Null = $CommandRaw.Append(" -$($Parameter.Name):$($Parameter.RawValue)") }
                    }
                }
                $Null = $CommandString.Append("$($FinalCommand.CommandJoiner)")
                $Null = $CommandRaw.Append("$($FinalCommand.CommandJoiner)")
            }
        }

        New-Variable -Force -Name CommandResult -Value $True
        Write-nLog -Type Debug -Message "Executing Command: '$($CommandString.tostring())" -Line $MyInvocation.ScriptLineNumber

        $Result = Invoke-command -NoNewScope -ScriptBlock ([scriptblock]::Create({
            Trap {
                Switch ($ErrorActionPreference) {
                    'SilentlyContinue' {return}
                    Default {Set-Variable -Name CommandResult -Value $False -Scope 1}
                }
                Throw $_
            }
            invoke-expression -Command $CommandRaw.ToString()
        }))

        If ($Script:LogLevelInt -LE 1) {
            Set-Variable -Name Debug -Value $Result -Scope Global
        }
        if (Test-path variable:CommandError) {
            IF ([String]::IsNullOrEmpty($ErrorMessage)) {
                Write-nLog -Type $ErrorLevel -message "$($CommandError.Exception.Message) [$($CommandError.Exception.GetType().FullName)]" -Line $MyInvocation.ScriptLineNumber
            } Else {
                Write-nLog -Type $ErrorLevel -message $ErrorMessage -Line $MyInvocation.ScriptLineNumber
            }
        } Else {
            If (-Not [String]::IsNullOrEmpty($SuccessMessage)) {
                Write-nLog -Type Info -Message $SuccessMessage -Line $MyInvocation.ScriptLineNumber
            }
            Write-nLog -Type Debug -Message "Command executed Successfully" -Line $MyInvocation.ScriptLineNumber
        }
    
        #Exit function returning desired information.
        Switch ($Return) {
            'Results' { IF ($CommandResult) {Return $Result} Else {Throw $Result}}
            'Status'  { Return $CommandResult}
            'None'    { Return $Null}
        }

    }

    #endregion,#')}]#")}]#'")}]
    #region----------------------------------------- [Initializations & Prerequisites] -----------------------------------------------

        #region [configure environment variables] ---------------------------------------------------------
            
            #Determine the Log Output Level
            Switch ($LogLevel) {
                "Debug"   {$DebugPreference = 'Continue'        ; $VerbosePreference = 'Continue'        ; $InformationPreference = 'Continue'        ; $WarningPreference = 'Continue'        ; $ErrorPreference = 'Continue'        }
                "Verbose" {$DebugPreference = 'SilentlyContinue'; $VerbosePreference = 'Continue'        ; $InformationPreference = 'Continue'        ; $WarningPreference = 'Continue'        ; $ErrorPreference = 'Continue'        }
                "Info"    {$DebugPreference = 'SilentlyContinue'; $VerbosePreference = 'SilentlyContinue'; $InformationPreference = 'Continue'        ; $WarningPreference = 'Continue'        ; $ErrorPreference = 'Continue'        }
                "Warn"    {$DebugPreference = 'SilentlyContinue'; $VerbosePreference = 'SilentlyContinue'; $InformationPreference = 'SilentlyContinue'; $WarningPreference = 'Continue'        ; $ErrorPreference = 'Continue'        }
                "Error"   {$DebugPreference = 'SilentlyContinue'; $VerbosePreference = 'SilentlyContinue'; $InformationPreference = 'SilentlyContinue'; $WarningPreference = 'SilentlyContinue'; $ErrorPreference = 'Continue'        }
                "Off"     {$DebugPreference = 'SilentlyContinue'; $VerbosePreference = 'SilentlyContinue'; $InformationPreference = 'SilentlyContinue'; $WarningPreference = 'SilentlyContinue'; $ErrorPreference = 'SilentlyContinue'}
            }

            #Converts Verbose Prefernce to bool so it can be used in "-Verbose:" arguments.
            [Bool]$Verbose = ($VerbosePreference -eq 'Continue')

            #Create CommandSplat variable.
            New-Variable -Force -Verbose:$Verbose -Name CommandSplat    -Value (New-Object -TypeName HashTable -ArgumentList 0,([StringComparer]::OrdinalIgnoreCase))
            $CommandSplat.Add('Verbose',$Verbose)

            #Set Set Debug Level
            Switch ($Debugger) {
                0       { $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Inquire  ; Set-StrictMode -Version Latest ; Set-PsDebug -Trace 2}
                1       { $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Inquire  ; Set-StrictMode -Version Latest ; Set-PsDebug -Trace 1}
                2       { $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Inquire  ; Set-StrictMode -Version Latest }
                Default { $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop     }
            }
        #endregion [configure environment variables],#')}]#")}]#'")}]
            
        #region [Determine ScriptEnv properties] ---------------------------------------------------------
            #Variable used to store certain sometimes useful script related information.
            New-Variable -Name ScriptEnv -Force -scope Script -value @{
                RunMethod      = [String]::Empty
                Interactive    = [Bool]$([Environment]::GetCommandLineArgs().Contains('-NonInteractive') -or ([Environment]::UserInteractive -EQ $False))
                IsAdmin        = [Bool]$((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
                Parameters     = New-Object -TypeName "System.Text.StringBuilder"
                Script         = [System.IO.FileInfo]$Null
                Powershellpath = New-object -TypeName 'System.io.fileinfo' -ArgumentList (get-command powershell).source
                Variables      = New-Object -TypeName 'System.Collections.ArrayList'
            }
    
            #Create a proper parameter string.
            ForEach ($Parameter in $Script:PSBoundParameters.GetEnumerator()) {
                [void]$ScriptEnv.Parameters.Append(" -$($Parameter.key): ""$($Parameter.Value)""")
                $ScriptEnv.Parameters.Add($Parameter.key)
            }

            #Determine The Environment The Script is Running in.
            IF (Test-Path -Path Variable:PSise) {
                #Running as PSISE
                [String]$ScriptEnv.RunMethod = 'ISE'
                [System.IO.FileInfo]$ScriptEnv.Script = New-Object -TypeName 'System.IO.FileInfo' -ArgumentList $psISE.CurrentFile.FullPath
                If ($LogOutput -eq 'Auto') {Set-Variable -Force -Name LogOutput -Value 'Host'}
            } ElseIF (Test-Path -Path Variable:pseditor) {
                #Running as VSCode
                [String]$ScriptEnv.RunMethod = 'VSCode'
                [System.IO.FileInfo]$ScriptEnv.Script = New-Object -TypeName 'System.IO.FileInfo' -ArgumentList $pseditor.GetEditorContext().CurrentFile.Path
                If ($LogOutput -eq 'Auto') {Set-Variable -Force -Name LogOutput -Value 'Host'}
            } Else {
                #Running as AzureDevOps or Powershell
                [String]$ScriptEnv.RunMethod = 'ADPS'
                If ($LogOutput -eq 'Auto') {Set-Variable -Force -Name LogOutput -Value 'Log'}
                IF ($Host.Version.Major -GE 3) {
                    [System.IO.FileInfo]$ScriptEnv.Script = New-Object -TypeName 'System.IO.FileInfo' -ArgumentList $PSCommandPath
                } Else {
                    [System.IO.FileInfo]$ScriptEnv.Script = New-Object -TypeName 'System.IO.FileInfo' -ArgumentList $MyInvocation.MyCommand.Definition
                }
            }
        #endregion [Determine ScriptEnv properties],#')}]#")}]#'")}]

        #region [If Administrator check] ---------------------------------------------------------
        IF ($ScriptConfig.RequreAdmin -eq $True) {
            IF ($ScriptEnv.IsAdmin -eq $False) {
                Write-Warning -Message 'Warning: Script not running as administrator, relaunching as administrator.'
                IF ($ScriptEnv.RunMethod -eq 'ISE') {
                    IF ($psISE.CurrentFile.IsUntitled-eq $True) {
                        Write-Error -Message 'Unable to elevate script, please save script before attempting to run.'
                        break
                    } Else {
                        IF ($psISE.CurrentFile.IsSaved -eq $False) {
                            Write-Warning 'ISE Script unsaved, unexpected results may occur.'
                        }
                    }
                }
                $Process = [System.Diagnostics.Process]::new()
                $Process.StartInfo = [System.Diagnostics.ProcessStartInfo]::new()
                $Process.StartInfo.Arguments = "-NoLogo -ExecutionPolicy Bypass -noprofile -command &{start-process '$($ScriptEnv.Powershellpath)' {$runthis} -verb runas}"
                $Process.StartInfo.FileName = $ScriptEnv.Powershellpath
                $Process.startinfo.WorkingDirectory = $ScriptEnv.ScriptDir
                $Process.StartInfo.UseShellExecute = $False
                $Process.StartInfo.CreateNoWindow  = $True
                $Process.StartInfo.RedirectStandardOutput = $True
                $Process.StartInfo.RedirectStandardError = $False
                $Process.StartInfo.RedirectStandardInput = $False
                $Process.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
                $Process.StartInfo.LoadUserProfile = $False
                [Void]$Process.Start()
                [Void]$Process.WaitForExit()
                [Void]$Process.Close()
                exit
            }
        }
        #endregion,#')}]#")}]#'")}]

        #region [Universal Error Trapping with easier to understand output] ---------------------------------------------------------
        Trap {
            Write-nLog -Type Debug -Message "Failed to execute command: $([string]::join(`"`",$_.InvocationInfo.line.split(`"`n`")))"
            Write-nLog -Type Error -Message "$($_.Exception.Message) [$($_.Exception.GetType().FullName)]" -Line $_.InvocationInfo.ScriptLineNumber
            Continue
        }
        #endregion [Universal Error Trapping with easier to understand output],#')}]#")}]#'")}]

        #Startup Write-nLog function.
        Write-nLog -Initialize -Type Debug -Message "Starting nLog function."-SetLogLevel $LogLevel -SetWriteHost $True -SetWriteLog $True -SetTimeLocalization Local -SetLogFormat CMTrace

        #region [Script Prerequisits] ---------------------------------------------------------
        #endregion [Script Prerequisits],#')}]#")}]#'")}]

        #Remove-Variable -Name @('ScriptConfig','ScriptEnv','Process') -Force -ErrorAction SilentlyContinue
    #endregion [Initializations & Prerequisites],#')}]#")}]#'")}]
    #region ------------------------------------------------- [Main Script] ---------------------------------------------------------

    #endregion [Main Script]
}
