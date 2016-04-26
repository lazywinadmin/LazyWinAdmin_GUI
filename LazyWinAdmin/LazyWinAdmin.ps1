#========================================================================
# Name		: LazyWinAdmin-v0.4.ps1
# Author 	: Francois-Xavier Cat
# Website	: http://lazyWinAdmin.com
# Twitter	: @LazyWinAdm
#
# History Version
# 	0.4		20120614 Public Version
#========================================================================

#----------------------------------------------
#region Import Assemblies
#----------------------------------------------
[void][Reflection.Assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
[void][Reflection.Assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
[void][Reflection.Assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
[void][Reflection.Assembly]::Load("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
[void][Reflection.Assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
#endregion Import Assemblies

function Main {
	Param ([String]$Commandline)
	#Note: This function starts the application
	#Note: $Commandline contains the complete argument string passed to the packager
	#Note: $Args contains the parsed arguments passed to the packager (Type: System.Array) 
	#Note: To get the script directory in the Packager use: Split-Path $hostinvocation.MyCommand.path
	#Note: To get the console output in the Packager (Windows Mode) use: $ConsoleOutput (Type: System.Collections.ArrayList)
	#TODO: Initialize and add Function calls to forms
	
	if(Call-MainForm_pff -eq "OK")
	{
		
	}
	
	$script:ExitCode = 0 #Set the exit code for the Packager
}


#region Call-Global_ps1
	#--------------------------------------------
	# Declare Global Variables and Functions here
	#--------------------------------------------
	
	#region Get-ComputerTxtBox
	function Get-ComputerTxtBox
	{	$global:ComputerName = $textbox_computername.Text}
	#endregion
	
	#region Add-RichTextBox
	# Function - Add Text to RichTextBox
	function Add-RichTextBox{
		[CmdletBinding()]
		param ($text)
		#$richtextbox_output.Text += "`tCOMPUTERNAME: $ComputerName`n"
		$richtextbox_output.Text += "$text"
		$richtextbox_output.Text += "`n# # # # # # # # # #`n"
	}
	#Set-Alias artb Add-RichTextBox -Description "Add content to the RichTextBox"
	#endregion
	
	#region Get-DateSortable
	function Get-datesortable {
		$global:datesortable = Get-Date -Format "yyyyMMdd-HH':'mm':'ss"
		return $global:datesortable
	}#endregion Get-DateSortable
	
	#region Add-Logs
	function Add-Logs{
		[CmdletBinding()]
		param ($text)
		Get-datesortable
		$richtextbox_logs.Text += "[$global:datesortable] - $text`r"
		Set-Alias alogs Add-Logs -Description "Add content to the RichTextBoxLogs"
		Set-Alias Add-Log Add-Logs -Description "Add content to the RichTextBoxLogs"
	}#endregion Add Logs
	
	#region Clear-RichTextBox
	# Function - Clear the RichTextBox
	function Clear-RichTextBox {$richtextbox_output.Text = ""}
	
	#endregion
	
	#region Clear-Logs
	# Function - Clear the Logs
	function Clear-Logs {$richtextbox_logs.Text = ""}
	
	#endregion
	
	#region Add-ClipBoard
	function Add-ClipBoard ($text){
			Add-Type -AssemblyName System.Windows.Forms
		    $tb = New-Object System.Windows.Forms.TextBox
		    $tb.Multiline = $true
		    $tb.Text = $text
		    $tb.SelectAll()
		    $tb.Copy()	
		}
	#endregion
	
	#region Test-TcpPort
	function Test-TcpPort ($ComputerName,[int]$port = 80) {
			$socket = new-object Net.Sockets.TcpClient
			$socket.Connect($ComputerName, $port)
			if ($socket.Connected) {
			$status = "Open"
			$socket.Close()
			}
			else {
			$status = "Closed / Filtered"
			}
			$socket = $null
			Add-RichTextBox "ComputerName:$ComputerName`nPort:$port`nStatus:$status"
	 	}
	#endregion
	
	#region Set-RDPEnable
	# Function RDP Enable
	function Set-RDPEnable ($ComputerName = '.') {
		    $regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ComputerName)
		    $regKey = $regKey.OpenSubKey("SYSTEM\\CurrentControlSet\\Control\\Terminal Server" ,$True)
		    $regkey.SetValue("fDenyTSConnections",0)
		    $regKey.flush()
		    $regKey.Close()
			}
	#endregion
	
	#region Set-RDPDisable
	# Function RDP Disable
	function Set-RDPDisable ($ComputerName = '.') {
		    $regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ComputerName)
		    $regKey = $regKey.OpenSubKey("SYSTEM\\CurrentControlSet\\Control\\Terminal Server" ,$True)
		    $regkey.SetValue("fDenyTSConnections",1)
		    $regKey.flush()
		    $regKey.Close()
			}
	#endregion
	
	#region Start-Proc
	function Start-Proc  {
		param (
			[string]$exe = $(Throw "An executable must be specified"),
			[string]$arguments,
			[switch]$hidden,
			[switch]$waitforexit
		)
		# Build Startinfo and set options according to parameters
		$startinfo = new-object System.Diagnostics.ProcessStartInfo 
		$startinfo.FileName = $exe
		$startinfo.Arguments = $arguments
		if ($hidden){
			$startinfo.WindowStyle = "Hidden"
			$startinfo.CreateNoWindow = $TRUE
		}
		$process = [System.Diagnostics.Process]::Start($startinfo)
		if ($waitforexit) {$process.WaitForExit()}
	}
	#endregion
	
	#region Get-Uptime
	function Get-Uptime{
		param($ComputerName = "localhost")
		$wmi = Get-WmiObject -class Win32_OperatingSystem -computer $ComputerName
		$LBTime = $wmi.ConvertToDateTime($wmi.Lastbootuptime)
		[TimeSpan]$uptime = New-TimeSpan $LBTime $(get-date)
		Write-Output "$($uptime.days) Days $($uptime.hours) Hours $($uptime.minutes) Minutes $($uptime.seconds) Seconds"
	}
	#endregion Get-Uptime
	
	#region Invoke-GPUpdate
	function Invoke-GPUpdate(){
		param($ComputerName = ".")
		$targetOSInfo = Get-WmiObject -ComputerName $ComputerName -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
		
		If (
			$targetOSInfo -eq $null){return "Unable to connect to $ComputerName"}
		Else{
			If ($targetOSInfo.version -ge 5.1){Invoke-WmiMethod -ComputerName $ComputerName -Path win32_process -Name create -ArgumentList "gpupdate /target:Computer /force /wait:0"}
			Else{Invoke-WmiMethod -ComputerName $ComputerName -Path win32_process -Name create –ArgumentList "secedit /refreshpolicy machine_policy /enforce"}
		}
	}
	#endregion
	
	#region Get-Scriptdirectory
	#Sample function that provides the location of the script
	function Get-Scriptdirectory
	{ 
		if($hostinvocation -ne $null)
		{
			Split-Path $hostinvocation.MyCommand.path
		}
		else
		{
			$invocation=(get-variable MyInvocation -Scope 1).Value
			Split-Path -Parent $invocation.MyCommand.Definition
		}
	}
	#Sample variable that provides the location of the script
	[string]$ScriptDirectory = Get-Scriptdirectory
	#endregion
	
	### BSONPOSH / Boe Prox http://bsonposh.com/
	
	#region Get-PageFile
	
	function Get-PageFile
	{
	
	    <#
	        .Synopsis 
	            Gets the Page File info for specified host
	            
	        .Description
	            Gets the Page File info for specified host
	            
	        .Parameter ComputerName
	            Name of the Computer to get the Paging File info from (Default is localhost.)
	            
	        .Example
	            Get-PageFile
	            Description
	            -----------
	            Gets Page File from local machine
	    
	        .Example
	            Get-PageFile -ComputerName MyServer
	            Description
	            -----------
	            Gets Page File from MyServer
	            
	        .Example
	            $Servers | Get-PageFile
	            Description
	            -----------
	            Gets Page File for each machine in the pipeline
	            
	        .OUTPUTS
	            PSObject
	            
	        .Notes
	            NAME:      Get-PageFile 
	            AUTHOR:    YetiCentral\bshell
	            Website:   www.bsonposh.com
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	    )
	    
	    Process 
	    {
	        Write-Verbose " [Get-PageFile] :: Process Start"
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        if(Test-Connection $ComputerName -Count 1 -Quiet)
	        {
	            try
	            {
	                Write-Verbose " [Get-PageFile] :: Collecting Paging File Info"
	                $PagingFiles = Get-WmiObject Win32_PageFile -ComputerName $ComputerName -ErrorAction SilentlyContinue
	                if($PagingFiles)
	                {
	                    foreach($PageFile in $PagingFiles)
	                    {
	                        $myobj = @{
	                            ComputerName = $ComputerName
	                            Name         = $PageFile.Name
	                            SizeGB       = [int]($PageFile.FileSize / 1GB)
	                            InitialSize  = $PageFile.InitialSize
	                            MaximumSize  = $PageFile.MaximumSize
	                        }
	                        
	                        $obj = New-Object PSObject -Property $myobj
	                        $obj.PSTypeNames.Clear()
	                        $obj.PSTypeNames.Add('BSonPosh.Computer.PageFile')
	                        $obj
	                    }
	                }
	                else
	                {
	                    $Pagefile = Get-ChildItem \\$ComputerName\c$\pagefile.sys -Force -ErrorAction SilentlyContinue 
	                    if($PageFile)
	                    {
	                        $myobj = @{
	                            ComputerName = $ComputerName
	                            Name         = $PageFile.Name
	                            SizeGB       = [int]($Pagefile.Length / 1GB)
	                            InitialSize  = "System Managed"
	                            MaximumSize  = "System Managed"
	                        }
	                        
	                        $obj = New-Object PSObject -Property $myobj
	                        $obj.PSTypeNames.Clear()
	                        $obj.PSTypeNames.Add('BSonPosh.Computer.PageFile')
	                        $obj
	                    }
	                    else
	                    {
	                        Write-Host "[Get-PageFile] :: No Paging File setting found. Most likely set to system managed or you do not have access."
	                    }
	                }
	            }
	            catch
	            {
	                 Write-Verbose " [Get-PageFile] :: [$ComputerName] Failed with Error: $($Error[0])" 
	            }
	        }
	    }        
	}
	
	#endregion 
	
	#region Get-PageFileSetting
	
	function Get-PageFileSetting
	{
	
	    <#
	        .Synopsis 
	            Gets the Page File setting info for specified host
	            
	        .Description
	            Gets the Page File setting info for specified host
	            
	        .Parameter ComputerName
	            Name of the Computer to get the Page File setting info from (Default is localhost.)
	            
	        .Example
	            Get-PageFileSetting
	            Description
	            -----------
	            Gets Page File setting from local machine
	    
	        .Example
	            Get-PageFileSetting -ComputerName MyServer
	            Description
	            -----------
	            Gets Page File setting from MyServer
	            
	        .Example
	            $Servers | Get-PageFileSetting
	            Description
	            -----------
	            Gets Page File setting for each machine in the pipeline
	            
	        .OUTPUTS
	            PSObject
	            
	        .Notes
	            NAME:      Get-PageFileSetting 
	            AUTHOR:    YetiCentral\bshell
	            Website:   www.bsonposh.com
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	    )
	    
	    Process 
	    {
	        Write-Verbose " [Get-PageFileSetting] :: Process Start"
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        if(Test-Host $ComputerName -TCPPort 135)
	        {
	            try
	            {
	                Write-Verbose " [Get-PageFileSetting] :: Collecting Paging File Info"
	                $PagingFiles = Get-WmiObject Win32_PageFileSetting -ComputerName $ComputerName -EnableAllPrivileges
	                if($PagingFiles)
	                {
	                    foreach($PageFile in $PagingFiles)
	                    {
	                        $PageFile 
	                    }
	                }
	                else
	                {
	                   Return "No Paging File setting found. Most likely set to system managed"
	                }
	            }
	            catch
	            {
	                 Write-Verbose " [Get-PageFileSetting] :: [$ComputerName] Failed with Error: $($Error[0])" 
	            }
	        }
	    }        
	}
	
	#endregion 
	
	#region Get-HostsFile
	Function Get-HostsFile {
	<#
	.SYNOPSIS
	   Retrieves the contents of a hosts file on a specified system
	.DESCRIPTION
	   Retrieves the contents of a hosts file on a specified system
	.PARAMETER Computer
	    Computer name to view host file from
	.NOTES
	    Name: Get-HostsFile
	    Author: Boe Prox
	    DateCreated: 15Mar2011
	.LINK  
	
	http://boeprox.wordpress.com
	
	.EXAMPLE
	    Get-HostsFile "server1" 
	
	Description
	-----------
	Retrieves the contents of the hosts file on 'server1' 
	
	#>
	[cmdletbinding(
	    DefaultParameterSetName = 'Default',
	    ConfirmImpact = 'low'
	)]
	    Param(
	        [Parameter(
	            ValueFromPipeline = $True)]
	            [string[]]$Computer                                                
	
	        )
	Begin {
	    $psBoundParameters.GetEnumerator() | % {
	        Write-Verbose "Parameter: $_"
	        }
	        If (!$PSBoundParameters['computer']) {
	        Write-Verbose "No computer name given, using local computername"
	        [string[]]$computer = $Env:Computername
	        }
	    $report = @()
	    }
	Process {
	    Write-Verbose "Starting process of computers"
	    ForEach ($c in $computer) {
	        Write-Verbose "Testing connection of $c"
	        If (Test-Connection -ComputerName $c -Quiet -Count 1) {
	            Write-Verbose "Validating path to hosts file"
	            If (Test-Path "\\$c\C$\Windows\system32\drivers\etc\hosts") {
	                Switch -regex -file ("\\$c\c$\Windows\system32\drivers\etc\hosts") {
	                    "^\d\w+" {
	                        Write-Verbose "Adding IPV4 information to collection"
	                        $temp = "" | Select Computer, IPV4, IPV6, Hostname, Notes
	                        $new = $_.Split("") | ? {$_ -ne ""}
	                        $temp.Computer = $c
	                        $temp.IPV4 = $new[0]
	                        $temp.HostName = $new[1]
	                        If ($new[2] -eq $Null) {
	                            $temp.Notes = "NA"
	                            }
	                        Else {
	                            $temp.Notes = $new[2]
	                            }
	                        $report += $temp
	                        }
	                    Default {
	                        If (!("\s+" -match $_ -OR $_.StartsWith("#"))) {
	                            Write-Verbose "Adding IPV6 information to collection"
	                            $temp = "" | Select Computer, IPV4, IPV6, Hostname, Notes
	                            $new = $_.Split("") | ? {$_ -ne ""}
	                            $temp.Computer = $c
	                            $temp.IPV6 = $new[0]
	                            $temp.HostName = $new[1]
	                            If ($new[2] -eq $Null) {
	                                $temp.Notes = "NA"
	                                }
	                            Else {
	                                $temp.Notes = $new[2]
	                                }
	                            $report += $temp
	                            }
	                        }
	                    }
	                }#EndIF
	            ElseIf (Test-Path "\\$c\C$\WinNT\system32\drivers\etc\hosts") {
	                Switch -regex -file ("\\$c\c$\WinNT\system32\drivers\etc\hosts") {
	                    "^#\w+" {
	                        }
	                    "^\d\w+" {
	                        Write-Verbose "Adding IPV4 information to collection"
	                        $temp = "" | Select Computer, IPV4,IPV6, Hostname, Notes
	                        $new = $_.Split("") | ? {$_ -ne ""}
	                        $temp.Computer = $c
	                        $temp.IPV4 = $new[0]
	                        $temp.HostName = $new[1]
	                        If ($new[2] -eq $Null) {
	                            $temp.Notes = "NA"
	                            }
	                        Else {
	                            $temp.Notes = $new[2]
	                            }
	                        $report += $temp
	                        }
	                    Default {
	                        If (!("\s+" -match $_ -OR $_.StartsWith("#"))) {
	                            Write-Verbose "Adding IPV6 information to collection"
	                            $temp = "" | Select Computer, IPV4, IPV6, Hostname, Notes
	                            $new = $_.Split("") | ? {$_ -ne ""}
	                            $temp.Computer = $c
	                            $temp.IPV6 = $new[0]
	                            $temp.HostName = $new[1]
	                            If ($new[2] -eq $Null) {
	                                $temp.Notes = "NA"
	                                }
	                            Else {
	                                $temp.Notes = $new[2]
	                                }
	                            $report += $temp
	                            }
	                        }
	                    }
	                }#End ElseIf
	            Else {
	                Write-Verbose "No host file found"
	                $temp = "" | Select Computer, IPV4, IPV6, Hostname, Notes
	                $temp.Computer = $c
	                $temp.IPV4 = "NA"
	                $temp.IPV6 = "NA"
	                $temp.Hostname = "NA"
	                $temp.Notes = "Unable to locate host file"
	                $report += $temp
	                }#End Else
	            }
	        Else {
	            Write-Verbose "No computer found"
	            $temp = "" | Select Computer, IPV4, IPV6, Hostname, Notes
	            $temp.Computer = $c
	            $temp.IPV4 = "NA"
	            $temp.IPV6 = "NA"
	            $temp.Hostname = "NA"
	            $temp.Notes = "Unable to locate Computer"
	            $report += $temp
	            }
	        }
	    }
	End {
	    Write-Output $report
	    }
	}
	#endregion Get-HostFileContent
	
	#region Get-DiskPartition 
	
	function Get-DiskPartition
	{
	        
	    <#
	        .Synopsis 
	            Gets the disk partition info for specified host
	            
	        .Description
	            Gets the disk partition info for specified host
	            
	        .Parameter ComputerName
	            Name of the Computer to get the disk partition info from (Default is localhost.)
	            
	        .Example
	            Get-DiskPartition
	            Description
	            -----------
	            Gets Disk Partitions from local machine
	    
	        .Example
	            Get-DiskPartition -ComputerName MyServer
	            Description
	            -----------
	            Gets Disk Partitions from MyServer
	            
	        .Example
	            $Servers | Get-DiskPartition
	            Description
	            -----------
	            Gets Disk Partitions for each machine in the pipeline
	            
	        .OUTPUTS
	            PSObject
	            
	        .Notes
	        NAME:      Get-DiskPartition 
	        AUTHOR:    YetiCentral\bshell
	        Website:   www.bsonposh.com
	        #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	    )
	    
	    Process 
	    {
	        Write-Verbose " [Get-DiskPartition] :: Process Start"
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        if(Test-Host $ComputerName -TCPPort 135)
	        {
	            try
	            {
	                Write-Verbose " [Get-DiskPartition] :: Getting Partition info use WMI"
	                $Partitions = Get-WmiObject Win32_DiskPartition -ComputerName $ComputerName
	                Write-Verbose " [Get-DiskPartition] :: Found $($Partitions.Count) partitions" 
	                foreach($Partition in $Partitions)
	                {
	                    Write-Verbose " [Get-DiskPartition] :: Creating Hash Table"
	                    $myobj = @{}
	                    
	                    Write-Verbose " [Get-DiskPartition] :: Adding BlockSize        - $($Partition.BlockSize)"
	                    $myobj.BlockSize = $Partition.BlockSize
	                    
	                    Write-Verbose " [Get-DiskPartition] :: Adding BootPartition    - $($Partition.BootPartition)"
	                    $myobj.BootPartition = $Partition.BootPartition
	                    
	                    Write-Verbose " [Get-DiskPartition] :: Adding ComputerName     - $ComputerName"
	                    $myobj.ComputerName = $ComputerName
	                    
	                    Write-Verbose " [Get-DiskPartition] :: Adding Description      - $($Partition.name)"
	                    $myobj.Description = $Partition.Name
	                    
	                    Write-Verbose " [Get-DiskPartition] :: Adding PrimaryPartition - $($Partition.PrimaryPartition)"
	                    $myobj.PrimaryPartition = $Partition.PrimaryPartition
	                    
	                    Write-Verbose " [Get-DiskPartition] :: Adding Index            - $($Partition.Index)"
	                    $myobj.Index = $Partition.Index
	                    
	                    Write-Verbose " [Get-DiskPartition] :: Adding SizeMB           - $($Partition.Size)"
	                    $myobj.SizeMB = ($Partition.Size/1mb).ToString("n2",$Culture)
	                    
	                    Write-Verbose " [Get-DiskPartition] :: Adding Type             - $($Partition.Type)"
	                    $myobj.Type = $Partition.Type
	                    
	                    Write-Verbose " [Get-DiskPartition] :: Setting IsAligned "
	                    $myobj.IsAligned = $Partition.StartingOffset%64kb -eq 0
	                    
	                    Write-Verbose " [Get-DiskPartition] :: Creating Object"
	                    $obj = New-Object PSObject -Property $myobj
	                    $obj.PSTypeNames.Clear()
	                    $obj.PSTypeNames.Add('BSonPosh.DiskPartition')
	                    $obj
	                }
	            }
	            catch
	            {
	                Write-Verbose " [Get-DiskPartition] :: [$ComputerName] Failed with Error: $($Error[0])" 
	            }
	        }
	        Write-Verbose " [Get-DiskPartition] :: Process End"
	    }
	}
	    
	#endregion 
	
	#region Get-DiskSpace
	
	function Get-DiskSpace 
	{
	        
	    <#
	        .Synopsis  
	            Gets the disk space for specified host
	            
	        .Description
	            Gets the disk space for specified host
	            
	        .Parameter ComputerName
	            Name of the Computer to get the diskspace from (Default is localhost.)
	            
	        .Example
	            Get-Diskspace
	            # Gets diskspace from local machine
	    
	        .Example
	            Get-Diskspace -ComputerName MyServer
	            Description
	            -----------
	            Gets diskspace from MyServer
	            
	        .Example
	            $Servers | Get-Diskspace
	            Description
	            -----------
	            Gets diskspace for each machine in the pipeline
	            
	        .OUTPUTS
	            PSCustomObject
	            
	        .Notes
	            NAME:      Get-DiskSpace 
	            AUTHOR:    YetiCentral\bshell
	            Website:   www.bsonposh.com
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	    )
	    
	    Begin 
	    {
	        Write-Verbose " [Get-DiskSpace] :: Start Begin"
	        $Culture = New-Object System.Globalization.CultureInfo("en-US") 
	        Write-Verbose " [Get-DiskSpace] :: End Begin"
	    }
	    
	    Process 
	    {
	        Write-Verbose " [Get-DiskSpace] :: Start Process"
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	            
	        }
	        Write-Verbose " [Get-DiskSpace] :: `$ComputerName - $ComputerName"
	        Write-Verbose " [Get-DiskSpace] :: Testing Connectivity"
	        if(Test-Host $ComputerName -TCPPort 135)
	        {
	            Write-Verbose " [Get-DiskSpace] :: Connectivity Passed"
	            try
	            {
	                Write-Verbose " [Get-DiskSpace] :: Getting Operating System Version using - Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName -Property Version"
	                $OSVersionInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName -Property Version -ea STOP
	                Write-Verbose " [Get-DiskSpace] :: Getting Operating System returned $($OSVersionInfo.Version)"
	                if($OSVersionInfo.Version -gt 5.2)
	                {
	                    Write-Verbose " [Get-DiskSpace] :: Version high enough to use Win32_Volume"
	                    Write-Verbose " [Get-DiskSpace] :: Calling Get-WmiObject -class Win32_Volume -ComputerName $ComputerName -Property `"Name`",`"FreeSpace`",`"Capacity`" -filter `"DriveType=3`""
	                    $DiskInfos = Get-WmiObject -class Win32_Volume                          `
	                                            -ComputerName $ComputerName                  `
	                                            -Property "Name","FreeSpace","Capacity"      `
	                                            -filter "DriveType=3" -ea STOP
	                    Write-Verbose " [Get-DiskSpace] :: Win32_Volume returned $($DiskInfos.count) disks"
	                    foreach($DiskInfo in $DiskInfos)
	                    {
	                        $myobj = @{}
	                        $myobj.ComputerName = $ComputerName
	                        $myobj.OSVersion    = $OSVersionInfo.Version
	                        $Myobj.Drive        = $DiskInfo.Name
	                        $Myobj.CapacityGB   = [float]($DiskInfo.Capacity/1GB).ToString("n2",$Culture)
	                        $Myobj.FreeSpaceGB  = [float]($DiskInfo.FreeSpace/1GB).ToString("n2",$Culture)
	                        $Myobj.PercentFree  = "{0:P2}" -f ($DiskInfo.FreeSpace / $DiskInfo.Capacity)
	                        $obj = New-Object PSObject -Property $myobj
	                        $obj.PSTypeNames.Clear()
	                        $obj.PSTypeNames.Add('BSonPosh.DiskSpace')
	                        $obj
	                    }
	                }
	                else
	                {
	                    Write-Verbose " [Get-DiskSpace] :: Version not high enough to use Win32_Volume using Win32_LogicalDisk"
	                    $DiskInfos = Get-WmiObject -class Win32_LogicalDisk                       `
	                                            -ComputerName $ComputerName                       `
	                                            -Property SystemName, DeviceID, FreeSpace, Size   `
	                                            -filter "DriveType=3" -ea STOP
	                    foreach($DiskInfo in $DiskInfos)
	                    {
	                        $myobj = @{}
	                        $myobj.ComputerName = $ComputerName
	                        $myobj.OSVersion    = $OSVersionInfo.Version
	                        $Myobj.Drive       = "{0}\" -f $DiskInfo.DeviceID
	                        $Myobj.CapacityGB   = [float]($DiskInfo.Capacity/1GB).ToString("n2",$Culture)
	                        $Myobj.FreeSpaceGB  = [float]($DiskInfo.FreeSpace/1GB).ToString("n2",$Culture)
	                        $Myobj.PercentFree  = "{0:P2}" -f ($DiskInfo.FreeSpace / $DiskInfo.Capacity)
	                        $obj = New-Object PSObject -Property $myobj
	                        $obj.PSTypeNames.Clear()
	                        $obj.PSTypeNames.Add('BSonPosh.DiskSpace')
	                        $obj
	                    }
	                }
	            }
	            catch
	            {
	                Write-Host " Host [$ComputerName] Failed with Error: $($Error[0])" -ForegroundColor Red
	            }
	        }
	        else
	        {
	            Write-Host " Host [$ComputerName] Failed Connectivity Test " -ForegroundColor Red
	        }
	        Write-Verbose " [Get-DiskSpace] :: End Process"
	    
	    }
	}
	    
	#endregion 
	
	#region Get-Processor
	
	function Get-Processor
	{
	        
	    <#
	        .Synopsis 
	            Gets the Computer Processor info for specified host.
	            
	        .Description
	            Gets the Computer Processor info for specified host.
	            
	        .Parameter ComputerName
	            Name of the Computer to get the Computer Processor info from (Default is localhost.)
	            
	        .Example
	            Get-Processor
	            Description
	            -----------
	            Gets Computer Processor info from local machine
	    
	        .Example
	            Get-Processor -ComputerName MyServer
	            Description
	            -----------
	            Gets Computer Processor info from MyServer
	            
	        .Example
	            $Servers | Get-Processor
	            Description
	            -----------
	            Gets Computer Processor info for each machine in the pipeline
	            
	        .OUTPUTS
	            PSCustomObject
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            N/A
	            
	        .Notes
	            NAME:      Get-Processor
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	    )
	    
	    Process 
	    {
	    
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        if(Test-Host -ComputerName $ComputerName -TCPPort 135)
	        {
	            try
	            {
	                $CPUS = Get-WmiObject Win32_Processor -ComputerName $ComputerName -ea STOP
	                foreach($CPU in $CPUs)
	                {
	                    $myobj = @{
	                        ComputerName = $ComputerName
	                        Name         = $CPU.Name
	                        Manufacturer = $CPU.Manufacturer
	                        Speed        = $CPU.MaxClockSpeed
	                        Cores        = $CPU.NumberOfCores
	                        L2Cache      = $CPU.L2CacheSize
	                        Stepping     = $CPU.Stepping
	                    }
	                }
	                $obj = New-Object PSObject -Property $myobj
	                $obj.PSTypeNames.Clear()
	                $obj.PSTypeNames.Add('BSonPosh.Computer.Processor')
	                $obj
	            }
	            catch
	            {
	                Write-Host " Host [$ComputerName] Failed with Error: $($Error[0])" -ForegroundColor Red
	            }
	        }
	        else
	        {
	            Write-Host " Host [$ComputerName] Failed Connectivity Test " -ForegroundColor Red
	        }
	    
	    }
	}
	    
	#endregion
	
	#region Get-IP 
	
	function Get-IP
	{
	        
	    <#
	        .Synopsis 
	            Get the IP of the specified host.
	            
	        .Description
	            Get the IP of the specified host.
	            
	        .Parameter ComputerName
	            Name of the Computer to get IP (Default localhost.)
	                
	        .Example
	            Get-IP
	            Description
	            -----------
	            Get IP information the localhost
	            
	            
	        .OUTPUTS
	            PSCustomObject
	            
	        .INPUTS
	            System.String
	        
	        .Notes
	            NAME:      Get-IP
	            AUTHOR:    YetiCentral\bshell
	            Website:   www.bsonposh.com
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	    )
	    Process
	    {
	        $NICs = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter "IPEnabled='$True'" -ComputerName $ComputerName
	        foreach($Nic in $NICs)
	        {
	            $myobj = @{
	                Name          = $Nic.Description
	                MacAddress    = $Nic.MACAddress
	                IP4           = $Nic.IPAddress | where{$_ -match "\d+\.\d+\.\d+\.\d+"}
	                IP6           = $Nic.IPAddress | where{$_ -match "\:\:"}
	                IP4Subnet     = $Nic.IPSubnet  | where{$_ -match "\d+\.\d+\.\d+\.\d+"}
	                DefaultGWY    = $Nic.DefaultIPGateway | Select -First 1
	                DNSServer     = $Nic.DNSServerSearchOrder
	                WINSPrimary   = $Nic.WINSPrimaryServer
	                WINSSecondary = $Nic.WINSSecondaryServer
	            }
	            $obj = New-Object PSObject -Property $myobj
	            $obj.PSTypeNames.Clear()
	            $obj.PSTypeNames.Add('BSonPosh.IPInfo')
	            $obj
	        }
	    }
	}
	    
	#endregion 
	
	#region Get-InstalledSoftware
	
	function Get-InstalledSoftware
	{
	
	    <#
	        .Synopsis
	            Gets the installed software using Uninstall regkey for specified host.
	
	        .Description
	            Gets the installed software using Uninstall regkey for specified host.
	
	        .Parameter ComputerName
	            Name of the Computer to get the installed software from (Default is localhost.)
	
	        .Example
	            Get-InstalledSoftware
	            Description
	            -----------
	            Gets installed software from local machine
	
	        .Example
	            Get-InstalledSoftware -ComputerName MyServer
	            Description
	            -----------
	            Gets installed software from MyServer
	
	        .Example
	            $Servers | Get-InstalledSoftware
	            Description
	            -----------
	            Gets installed software for each machine in the pipeline
	
	        .OUTPUTS
	            PSCustomObject
	
	        .Notes
	            NAME:      Get-InstalledSoftware
	            AUTHOR:    YetiCentral\bshell
	            Website:   www.bsonposh.com
	            #Requires -Version 2.0
	    #>
	
	    [Cmdletbinding()]
	    Param(
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	    )
	    begin 
	    {
	
	            Write-Verbose " [Get-InstalledPrograms] :: Start Begin"
	            $Culture = New-Object System.Globalization.CultureInfo("en-US")
	            Write-Verbose " [Get-InstalledPrograms] :: End Begin"
	
	    }
	    process 
	    {
	
	        Write-Verbose " [Get-InstalledPrograms] :: Start Process"
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	
	        }
	        Write-Verbose " [Get-InstalledPrograms] :: `$ComputerName - $ComputerName"
	        Write-Verbose " [Get-InstalledPrograms] :: Testing Connectivity"
	        if(Test-Host $ComputerName -TCPPort 135)
	        {
	            try
	            {
	                $RegKey = Get-RegistryKey -Path "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -ComputerName $ComputerName
	                foreach($key in $RegKey.GetSubKeyNames())   
	                {   
	                    $SubKey = $RegKey.OpenSubKey($key)
	                    if($SubKey.GetValue("DisplayName"))
	                    {
	                        $myobj = @{
	                            Name    = $SubKey.GetValue("DisplayName")   
	                            Version = $SubKey.GetValue("DisplayVersion")   
	                            Vendor  = $SubKey.GetValue("Publisher")
	                        }
	                        $obj = New-Object PSObject -Property $myobj
	                        $obj.PSTypeNames.Clear()
	                        $obj.PSTypeNames.Add('BSonPosh.SoftwareInfo')
	                        $obj
	                    }
	                }   
	            }
	            catch
	            {
	                Write-Host " Host [$ComputerName] Failed with Error: $($Error[0])" -ForegroundColor Red
	            }
	        }
	        else
	        {
	            Write-Host " Host [$ComputerName] Failed Connectivity Test " -ForegroundColor Red
	        }
	        Write-Verbose " [Get-InstalledPrograms] :: End Process"
	
	    }
	}
	
	#endregion 
	
	#region Get-RegistryHive 
	
	function Get-RegistryHive 
	{
	    param($HiveName)
	    Switch -regex ($HiveName)
	    {
	        "^(HKCR|ClassesRoot|HKEY_CLASSES_ROOT)$"               {[Microsoft.Win32.RegistryHive]"ClassesRoot";continue}
	        "^(HKCU|CurrentUser|HKEY_CURRENTt_USER)$"              {[Microsoft.Win32.RegistryHive]"CurrentUser";continue}
	        "^(HKLM|LocalMachine|HKEY_LOCAL_MACHINE)$"          {[Microsoft.Win32.RegistryHive]"LocalMachine";continue} 
	        "^(HKU|Users|HKEY_USERS)$"                          {[Microsoft.Win32.RegistryHive]"Users";continue}
	        "^(HKCC|CurrentConfig|HKEY_CURRENT_CONFIG)$"          {[Microsoft.Win32.RegistryHive]"CurrentConfig";continue}
	        "^(HKPD|PerformanceData|HKEY_PERFORMANCE_DATA)$"    {[Microsoft.Win32.RegistryHive]"PerformanceData";continue}
	        Default                                                {1;continue}
	    }
	}
	    
	#endregion 
	
	#region Get-RegistryKey 
	
	function Get-RegistryKey 
	{
	        
	    <#
	        .Synopsis 
	            Gets the registry key provide by Path.
	            
	        .Description
	            Gets the registry key provide by Path.
	                        
	        .Parameter Path 
	            Path to the key.
	            
	        .Parameter ComputerName 
	            Computer to get the registry key from.
	            
	        .Parameter Recurse 
	            Recursively returns registry keys starting from the Path.
	        
	        .Parameter ReadWrite
	            Returns the Registry key in Read Write mode.
	            
	        .Example
	            Get-registrykey HKLM\Software\Adobe
	            Description
	            -----------
	            Returns the Registry key for HKLM\Software\Adobe
	            
	        .Example
	            Get-registrykey HKLM\Software\Adobe -ComputerName MyServer1
	            Description
	            -----------
	            Returns the Registry key for HKLM\Software\Adobe on MyServer1
	        
	        .Example
	            Get-registrykey HKLM\Software\Adobe -Recurse
	            Description
	            -----------
	            Returns the Registry key for HKLM\Software\Adobe and all child keys
	                    
	        .OUTPUTS
	            Microsoft.Win32.RegistryKey
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            New-RegistryKey
	            Remove-RegistryKey
	            Test-RegistryKey
	        .Notes
	            NAME:      Get-RegistryKey
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	        
	    [Cmdletbinding()]
	    Param(
	    
	        [Parameter(mandatory=$true)]
	        [string]$Path,
	        
	        [Alias("Server")]
	        [Parameter(ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:ComputerName,
	        
	        [Parameter()]
	        [switch]$Recurse,
	        
	        [Alias("RW")]
	        [Parameter()]
	        [switch]$ReadWrite
	        
	    )
	    
	    Begin 
	    {
	        
	        Write-Verbose " [Get-RegistryKey] :: Start Begin"
	        Write-Verbose " [Get-RegistryKey] :: `$Path = $Path"
	        Write-Verbose " [Get-RegistryKey] :: Getting `$Hive and `$KeyPath from $Path "
	        $PathParts = $Path -split "\\|/",0,"RegexMatch"
	        $Hive = $PathParts[0]
	        $KeyPath = $PathParts[1..$PathParts.count] -join "\"
	        Write-Verbose " [Get-RegistryKey] :: `$Hive = $Hive"
	        Write-Verbose " [Get-RegistryKey] :: `$KeyPath = $KeyPath"
	        
	        Write-Verbose " [Get-RegistryKey] :: End Begin"
	        
	    }
	    
	    Process 
	    {
	    
	        Write-Verbose " [Get-RegistryKey] :: Start Process"
	        Write-Verbose " [Get-RegistryKey] :: `$ComputerName = $ComputerName"
	        
	        $RegHive = Get-RegistryHive $hive
	        
	        if($RegHive -eq 1)
	        {
	            Write-Host "Invalid Path: $Path, Registry Hive [$hive] is invalid!" -ForegroundColor Red
	        }
	        else
	        {
	            Write-Verbose " [Get-RegistryKey] :: `$RegHive = $RegHive"
	            
	            $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegHive,$ComputerName)
	            Write-Verbose " [Get-RegistryKey] :: `$BaseKey = $BaseKey"
	    
	            if($ReadWrite)
	            {
	                try
	                {
	                    $Key = $BaseKey.OpenSubKey($KeyPath,$true)
	                    $Key = $Key | Add-Member -Name "ComputerName" -MemberType NoteProperty -Value $ComputerName -PassThru
	                    $Key = $Key | Add-Member -Name "Hive" -MemberType NoteProperty -Value $RegHive -PassThru 
	                    $Key = $Key | Add-Member -Name "Path" -MemberType NoteProperty -Value $KeyPath -PassThru
	                    $Key.PSTypeNames.Clear()
	                    $Key.PSTypeNames.Add('BSonPosh.Registry.Key')
	                    $Key
	                }
	                catch
	                {
	                    Write-Verbose " [Get-RegistryKey] ::  ERROR :: Unable to Open Key:$KeyPath in $KeyPath with RW Access"
	                }
	                
	            }
	            else
	            {
	                try
	                {
	                    $Key = $BaseKey.OpenSubKey("$KeyPath")
	                    if($Key)
	                    {
	                        $Key = $Key | Add-Member -Name "ComputerName" -MemberType NoteProperty -Value $ComputerName -PassThru
	                        $Key = $Key | Add-Member -Name "Hive" -MemberType NoteProperty -Value $RegHive -PassThru 
	                        $Key = $Key | Add-Member -Name "Path" -MemberType NoteProperty -Value $KeyPath -PassThru
	                        $Key.PSTypeNames.Clear()
	                        $Key.PSTypeNames.Add('BSonPosh.Registry.Key')
	                        $Key
	                    }
	                }
	                catch
	                {
	                    Write-Verbose " [Get-RegistryKey] ::  ERROR :: Unable to Open SubKey:$Name in $KeyPath"
	                }
	            }
	            
	            if($Recurse)
	            {
	                Write-Verbose " [Get-RegistryKey] :: Recurse Passed: Processing Subkeys of [$($Key.Name)]"
	                $Key
	                $SubKeyNames = $Key.GetSubKeyNames()
	                foreach($Name in $SubKeyNames)
	                {
	                    try
	                    {
	                        $SubKey = $Key.OpenSubKey($Name)
	                        if($SubKey.GetSubKeyNames())
	                        {
	                            Write-Verbose " [Get-RegistryKey] :: Calling [Get-RegistryKey] for [$($SubKey.Name)]"
	                            Get-RegistryKey -ComputerName $ComputerName -Path $SubKey.Name -Recurse
	                        }
	                        else
	                        {
	                            Get-RegistryKey -ComputerName $ComputerName -Path $SubKey.Name 
	                        }
	                    }
	                    catch
	                    {
	                        Write-Verbose " [Get-RegistryKey] ::  ERROR :: Write-Host Unable to Open SubKey:$Name in $($Key.Name)"
	                    }
	                }
	            }
	        }
	        Write-Verbose " [Get-RegistryKey] :: End Process"
	    
	    }
	}
	    
	#endregion 
	
	#region Get-RegistryValue 
	
	function Get-RegistryValue
	{
	    
	    <#
	        .Synopsis 
	            Get the value for given the registry value.
	            
	        .Description
	            Get the value for given the registry value.
	                        
	        .Parameter Path 
	            Path to the key that contains the value.
	            
	        .Parameter Name 
	            Name of the Value to check.
	            
	        .Parameter ComputerName 
	            Computer to get value.
	            
	        .Parameter Recurse 
	            Recursively gets the Values on the given key.
	            
	        .Parameter Default 
	            Returns the default value for the Value.
	        
	        .Example
	            Get-RegistryValue HKLM\SOFTWARE\Adobe\SwInstall -Name State 
	            Description
	            -----------
	            Returns value of State under HKLM\SOFTWARE\Adobe\SwInstall.
	            
	        .Example
	            Get-RegistryValue HKLM\Software\Adobe -Name State -ComputerName MyServer1
	            Description
	            -----------
	            Returns value of State under HKLM\SOFTWARE\Adobe\SwInstall on MyServer1
	            
	        .Example
	            Get-RegistryValue HKLM\Software\Adobe -Recurse
	            Description
	            -----------
	            Returns all the values under HKLM\SOFTWARE\Adobe.
	    
	        .Example
	            Get-RegistryValue HKLM\Software\Adobe -ComputerName MyServer1 -Recurse
	            Description
	            -----------
	            Returns all the values under HKLM\SOFTWARE\Adobe on MyServer1
	            
	        .Example
	            Get-RegistryValue HKLM\Software\Adobe -Default
	            Description
	            -----------
	            Returns the default value for HKLM\SOFTWARE\Adobe.
	                    
	        .OUTPUTS
	            PSCustomObject
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            New-RegistryValue
	            Remove-RegistryValue
	            Test-RegistryValue
	            
	        .Notes    
	            NAME:      Get-RegistryValue
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [Parameter(mandatory=$true)]
	        [string]$Path,
	    
	        [Parameter()]
	        [string]$Name,
	        
	        [Alias("dnsHostName")]
	        [Parameter(ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:ComputerName,
	        
	        [Parameter()]
	        [switch]$Recurse,
	        
	        [Parameter()]
	        [switch]$Default
	    )
	    
	    Process
	    {
	    
	        Write-Verbose " [Get-RegistryValue] :: Begin Process"
	        Write-Verbose " [Get-RegistryValue] :: Calling Get-RegistryKey -Path $path -ComputerName $ComputerName"
	        
	        if($Recurse)
	        {
	            $Keys = Get-RegistryKey -Path $path -ComputerName $ComputerName -Recurse
	            foreach($Key in $Keys)
	            {
	                if($Name)
	                {
	                    try
	                    {
	                        Write-Verbose " [Get-RegistryValue] :: Getting Value for [$Name]"
	                        $myobj = @{} #| Select ComputerName,Name,Value,Type,Path
	                        $myobj.ComputerName = $ComputerName
	                        $myobj.Name = $Name
	                        $myobj.value = $Key.GetValue($Name)
	                        $myobj.Type = $Key.GetValueKind($Name)
	                        $myobj.path = $Key
	                        
	                        $obj = New-Object PSCustomObject -Property $myobj
	                        $obj.PSTypeNames.Clear()
	                        $obj.PSTypeNames.Add('BSonPosh.Registry.Value')
	                        $obj
	                    }
	                    catch
	                    {
	                        Write-Verbose " [Get-RegistryValue] ::  ERROR :: Unable to Get Value for:$Name in $($Key.Name)"
	                    }
	                
	                }
	                elseif($Default)
	                {
	                    try
	                    {
	                        Write-Verbose " [Get-RegistryValue] :: Getting Value for [(Default)]"
	                        $myobj = @{} #"" | Select ComputerName,Name,Value,Type,Path
	                        $myobj.ComputerName = $ComputerName
	                        $myobj.Name = "(Default)"
	                        $myobj.value = if($Key.GetValue("")){$Key.GetValue("")}else{"EMPTY"}
	                        $myobj.Type = if($Key.GetValue("")){$Key.GetValueKind("")}else{"N/A"}
	                        $myobj.path = $Key
	                        
	                        $obj = New-Object PSCustomObject -Property $myobj
	                        $obj.PSTypeNames.Clear()
	                        $obj.PSTypeNames.Add('BSonPosh.Registry.Value')
	                        $obj
	                    }
	                    catch
	                    {
	                        Write-Verbose " [Get-RegistryValue] ::  ERROR :: Unable to Get Value for:(Default) in $($Key.Name)"
	                    }
	                }
	                else
	                {
	                    try
	                    {
	                        Write-Verbose " [Get-RegistryValue] :: Getting all Values for [$Key]"
	                        foreach($ValueName in $Key.GetValueNames())
	                        {
	                            Write-Verbose " [Get-RegistryValue] :: Getting all Value for [$ValueName]"
	                            $myobj = @{} #"" | Select ComputerName,Name,Value,Type,Path
	                            $myobj.ComputerName = $ComputerName
	                            $myobj.Name = if($ValueName -match "^$"){"(Default)"}else{$ValueName}
	                            $myobj.value = $Key.GetValue($ValueName)
	                            $myobj.Type = $Key.GetValueKind($ValueName)
	                            $myobj.path = $Key
	                            
	                            $obj = New-Object PSCustomObject -Property $myobj
	                            $obj.PSTypeNames.Clear()
	                            $obj.PSTypeNames.Add('BSonPosh.Registry.Value')
	                            $obj
	                        }
	                    }
	                    catch
	                    {
	                        Write-Verbose " [Get-RegistryValue] ::  ERROR :: Unable to Get Value for:$ValueName in $($Key.Name)"
	                    }
	                }
	            }
	        }
	        else
	        {
	            $Key = Get-RegistryKey -Path $path -ComputerName $ComputerName 
	            Write-Verbose " [Get-RegistryValue] :: Get-RegistryKey returned $Key"
	            if($Name)
	            {
	                try
	                {
	                    Write-Verbose " [Get-RegistryValue] :: Getting Value for [$Name]"
	                    $myobj = @{} # | Select ComputerName,Name,Value,Type,Path
	                    $myobj.ComputerName = $ComputerName
	                    $myobj.Name = $Name
	                    $myobj.value = $Key.GetValue($Name)
	                    $myobj.Type = $Key.GetValueKind($Name)
	                    $myobj.path = $Key
	                    
	                    $obj = New-Object PSCustomObject -Property $myobj
	                    $obj.PSTypeNames.Clear()
	                    $obj.PSTypeNames.Add('BSonPosh.Registry.Value')
	                    $obj
	                }
	                catch
	                {
	                    Write-Verbose " [Get-RegistryValue] ::  ERROR :: Unable to Get Value for:$Name in $($Key.Name)"
	                }
	            }
	            elseif($Default)
	            {
	                try
	                {
	                    Write-Verbose " [Get-RegistryValue] :: Getting Value for [(Default)]"
	                    $myobj = @{} #"" | Select ComputerName,Name,Value,Type,Path
	                    $myobj.ComputerName = $ComputerName
	                    $myobj.Name = "(Default)"
	                    $myobj.value = if($Key.GetValue("")){$Key.GetValue("")}else{"EMPTY"}
	                    $myobj.Type = if($Key.GetValue("")){$Key.GetValueKind("")}else{"N/A"}
	                    $myobj.path = $Key
	                    
	                    $obj = New-Object PSCustomObject -Property $myobj
	                    $obj.PSTypeNames.Clear()
	                    $obj.PSTypeNames.Add('BSonPosh.Registry.Value')
	                    $obj
	                }
	                catch
	                {
	                    Write-Verbose " [Get-RegistryValue] ::  ERROR :: Unable to Get Value for:$Name in $($Key.Name)"
	                }
	            }
	            else
	            {
	                Write-Verbose " [Get-RegistryValue] :: Getting all Values for [$Key]"
	                foreach($ValueName in $Key.GetValueNames())
	                {
	                    Write-Verbose " [Get-RegistryValue] :: Getting all Value for [$ValueName]"
	                    $myobj = @{} #"" | Select ComputerName,Name,Value,Type,Path
	                    $myobj.ComputerName = $ComputerName
	                    $myobj.Name = if($ValueName -match "^$"){"(Default)"}else{$ValueName}
	                    $myobj.value = $Key.GetValue($ValueName)
	                    $myobj.Type = $Key.GetValueKind($ValueName)
	                    $myobj.path = $Key
	                    
	                    $obj = New-Object PSCustomObject -Property $myobj
	                    $obj.PSTypeNames.Clear()
	                    $obj.PSTypeNames.Add('BSonPosh.Registry.Value')
	                    $obj
	                }
	            }
	        }
	        
	        Write-Verbose " [Get-RegistryValue] :: End Process"
	    
	    }
	}
	    
	#endregion 
	
	#region New-RegistryKey 
	
	function New-RegistryKey
	{
	    
	    <#
	        .Synopsis 
	            Creates a new key in the provide by Path.
	            
	        .Description
	            Creates a new key in the provide by Path.
	                        
	        .Parameter Path 
	            Path to create the key in.
	            
	        .Parameter ComputerName 
	            Computer to the create registry key on.
	            
	        .Parameter Name 
	            Name of the Key to create
	        
	        .Example
	            New-registrykey HKLM\Software\Adobe -Name DeleteMe
	            Description
	            -----------
	            Creates a key called DeleteMe under HKLM\Software\Adobe
	            
	        .Example
	            New-registrykey HKLM\Software\Adobe -Name DeleteMe -ComputerName MyServer1
	            Description
	            -----------
	            Creates a key called DeleteMe under HKLM\Software\Adobe on MyServer1
	                    
	        .OUTPUTS
	            Microsoft.Win32.RegistryKey
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            Get-RegistryKey
	            Remove-RegistryKey
	            Test-RegistryKey
	            
	        NAME:      New-RegistryKey
	        AUTHOR:    bsonposh
	        Website:   http://www.bsonposh.com
	        Version:   1
	        #Requires -Version 2.0
	    #>
	    [Cmdletbinding(SupportsShouldProcess=$true)]
	    Param(
	        [Parameter(mandatory=$true)]
	        [string]$Path,
	        
	        [Parameter(mandatory=$true)]
	        [string]$Name,
	        
	        [Alias("Server")]
	        [Parameter(ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:ComputerName
	    )
	    Begin 
	    {
	    
	        Write-Verbose " [New-RegistryKey] :: Start Begin"
	        $ReadWrite = [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree
	        
	        Write-Verbose " [New-RegistryKey] :: `$Path = $Path"
	        Write-Verbose " [New-RegistryKey] :: Getting `$Hive and `$KeyPath from $Path "
	        $PathParts = $Path -split "\\|/",0,"RegexMatch"
	        $Hive = $PathParts[0]
	        $KeyPath = $PathParts[1..$PathParts.count] -join "\"
	        Write-Verbose " [New-RegistryKey] :: `$Hive = $Hive"
	        Write-Verbose " [New-RegistryKey] :: `$KeyPath = $KeyPath"
	        
	        Write-Verbose " [New-RegistryKey] :: End Begin"
	        
	    }
	    Process 
	    {
	    
	        Write-Verbose " [Get-RegistryKey] :: Start Process"
	        Write-Verbose " [Get-RegistryKey] :: `$ComputerName = $ComputerName"
	        
	        $RegHive = Get-RegistryHive $hive
	        
	        if($RegHive -eq 1)
	        {
	            Write-Host "Invalid Path: $Path, Registry Hive [$hive] is invalid!" -ForegroundColor Red
	        }
	        else
	        {
	            Write-Verbose " [Get-RegistryKey] :: `$RegHive = $RegHive"
	            $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegHive,$ComputerName)
	            Write-Verbose " [Get-RegistryKey] :: `$BaseKey = $BaseKey"
	            $Key = $BaseKey.OpenSubKey($KeyPath,$True)
	            if($PSCmdlet.ShouldProcess($ComputerName,"Creating Key [$Name] under $Path"))
	            {
	                $Key.CreateSubKey($Name,$ReadWrite)
	            }
	        }
	        Write-Verbose " [Get-RegistryKey] :: End Process"
	    
	    }
	}
	    
	#endregion 
	
	#region New-RegistryValue 
	
	function New-RegistryValue
	{
	    
	    <#
	        .Synopsis 
	            Create a value under the registry key.
	            
	        .Description
	            Create a value under the registry key.
	                        
	        .Parameter Path 
	            Path to the key.
	            
	        .Parameter Name 
	            Name of the Value to create.
	            
	        .Parameter Value 
	            Value to for the new Value.
	            
	        .Parameter Type
	            Type for the new Value. Valid Types: Unknown, String (default,) ExpandString, Binary, DWord, MultiString, a
	    nd Qword
	            
	        .Parameter ComputerName 
	            Computer to create the Value on.
	            
	        .Example
	            New-RegistryValue HKLM\SOFTWARE\Adobe\MyKey -Name State -Value "Hi There"
	            Description
	            -----------
	            Creates the Value State and sets the value to "Hi There" under HKLM\SOFTWARE\Adobe\MyKey.
	            
	        .Example
	            New-RegistryValue HKLM\SOFTWARE\Adobe\MyKey -Name State -Value 0 -ComputerName MyServer1
	            Description
	            -----------
	            Creates the Value State and sets the value to "Hi There" under HKLM\SOFTWARE\Adobe\MyKey on MyServer1.
	            
	        .Example
	            New-RegistryValue HKLM\SOFTWARE\Adobe\MyKey -Name MyDWord -Value 0 -Type DWord
	            Description
	            -----------
	            Creates the DWORD Value MyDWord and sets the value to 0 under HKLM\SOFTWARE\Adobe\MyKey.
	                    
	        .OUTPUTS
	            System.Boolean
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            New-RegistryValue
	            Remove-RegistryValue
	            Get-RegistryValue
	            
	        NAME:      Test-RegistryValue
	        AUTHOR:    bsonposh
	        Website:   http://www.bsonposh.com
	        Version:   1
	        #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding(SupportsShouldProcess=$true)]
	    Param(
	        [Parameter(mandatory=$true)]
	        [string]$Path,
	        
	        [Parameter(mandatory=$true)]
	        [string]$Name,
	        
	        [Parameter()]
	        [string]$Value,
	        
	        [Parameter()]
	        [string]$Type,
	        
	        [Alias("dnsHostName")]
	        [Parameter(ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:ComputerName
	    )
	    Begin 
	    {
	    
	        Write-Verbose " [New-RegistryValue] :: Start Begin"
	        Write-Verbose " [New-RegistryValue] :: `$Path = $Path"
	        Write-Verbose " [New-RegistryValue] :: `$Name = $Name"
	        Write-Verbose " [New-RegistryValue] :: `$Value = $Value"
	        
	        Switch ($Type)
	        {
	            "Unknown"       {$ValueType = [Microsoft.Win32.RegistryValueKind]::Unknown;continue}
	            "String"        {$ValueType = [Microsoft.Win32.RegistryValueKind]::String;continue}
	            "ExpandString"  {$ValueType = [Microsoft.Win32.RegistryValueKind]::ExpandString;continue}
	            "Binary"        {$ValueType = [Microsoft.Win32.RegistryValueKind]::Binary;continue}
	            "DWord"         {$ValueType = [Microsoft.Win32.RegistryValueKind]::DWord;continue}
	            "MultiString"   {$ValueType = [Microsoft.Win32.RegistryValueKind]::MultiString;continue}
	            "QWord"         {$ValueType = [Microsoft.Win32.RegistryValueKind]::QWord;continue}
	            default         {$ValueType = [Microsoft.Win32.RegistryValueKind]::String;continue}
	        }
	        Write-Verbose " [New-RegistryValue] :: `$Type = $Type"
	        Write-Verbose " [New-RegistryValue] :: End Begin"
	        
	    }
	    
	    Process 
	    {
	    
	        if(Test-RegistryValue -Path $path -Name $Name -ComputerName $ComputerName)
	        {
	            "Registry value already exist"     
	        }
	        else
	        {
	            Write-Verbose " [New-RegistryValue] :: Start Process"
	            Write-Verbose " [New-RegistryValue] :: Calling Get-RegistryKey -Path $path -ComputerName $ComputerName"
	            $Key = Get-RegistryKey -Path $path -ComputerName $ComputerName -ReadWrite
	            Write-Verbose " [New-RegistryValue] :: Get-RegistryKey returned $Key"
	            Write-Verbose " [New-RegistryValue] :: Setting Value for [$Name]"
	            if($PSCmdlet.ShouldProcess($ComputerName,"Creating Value [$Name] under $Path with value [$Value]"))
	            {
	                if($Value)
	                {
	                    $Key.SetValue($Name,$Value,$ValueType)
	                }
	                else
	                {
	                    $Key.SetValue($Name,$ValueType)
	                }
	                Write-Verbose " [New-RegistryValue] :: Returning New Key: Get-RegistryValue -Path $path -Name $Name -ComputerName $ComputerName"
	                Get-RegistryValue -Path $path -Name $Name -ComputerName $ComputerName
	            }
	        }
	        Write-Verbose " [New-RegistryValue] :: End Process"
	    
	    }
	}
	    
	#endregion 
	
	#region Remove-RegistryKey 
	
	function Remove-RegistryKey
	{
	        
	    <#
	        .Synopsis 
	            Removes a new key in the provide by Path.
	            
	        .Description
	            Removes a new key in the provide by Path.
	                        
	        .Parameter Path 
	            Path to remove the registry key from.
	            
	        .Parameter ComputerName 
	            Computer to remove the registry key from.
	            
	        .Parameter Name 
	            Name of the registry key to remove.
	            
	        .Parameter Recurse 
	            Recursively removes registry key and all children from path.
	        
	        .Example
	            Remove-registrykey HKLM\Software\Adobe -Name DeleteMe
	            Description
	            -----------
	            Removes the registry key called DeleteMe under HKLM\Software\Adobe
	            
	        .Example
	            Remove-RegistryKey HKLM\Software\Adobe -Name DeleteMe -ComputerName MyServer1
	            Description
	            -----------
	            Removes the key called DeleteMe under HKLM\Software\Adobe on MyServer1
	            
	        .Example
	            Remove-RegistryKey HKLM\Software\Adobe -Name DeleteMe -ComputerName MyServer1 -Recurse
	            Description
	            -----------
	            Removes the key called DeleteMe under HKLM\Software\Adobe on MyServer1 and all child keys.
	                    
	        .OUTPUTS
	            $null
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            Get-RegistryKey
	            New-RegistryKey
	            Test-RegistryKey
	            
	        .Notes
	        NAME:      Remove-RegistryKey
	        AUTHOR:    bsonposh
	        Website:   http://www.bsonposh.com
	        Version:   1
	        #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding(SupportsShouldProcess=$true)]
	    Param(
	    
	        [Parameter(mandatory=$true)]
	        [string]$Path,
	        
	        [Parameter(mandatory=$true)]
	        [string]$Name,
	        
	        [Alias("Server")]
	        [Parameter(ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:ComputerName,
	        
	        [Parameter()]
	        [switch]$Recurse
	    )
	    Begin 
	    {
	    
	        Write-Verbose " [Remove-RegistryKey] :: Start Begin"
	        
	        Write-Verbose " [Remove-RegistryKey] :: `$Path = $Path"
	        Write-Verbose " [Remove-RegistryKey] :: Getting `$Hive and `$KeyPath from $Path "
	        $PathParts = $Path -split "\\|/",0,"RegexMatch"
	        $Hive = $PathParts[0]
	        $KeyPath = $PathParts[1..$PathParts.count] -join "\"
	        Write-Verbose " [Remove-RegistryKey] :: `$Hive = $Hive"
	        Write-Verbose " [Remove-RegistryKey] :: `$KeyPath = $KeyPath"
	        
	        Write-Verbose " [Remove-RegistryKey] :: End Begin"
	    
	    }
	    
	    Process 
	    {
	    
	        Write-Verbose " [Remove-RegistryKey] :: Start Process"
	        Write-Verbose " [Remove-RegistryKey] :: `$ComputerName = $ComputerName"
	        
	        if(Test-RegistryKey -Path $path\$name -ComputerName $ComputerName)
	        {
	            $RegHive = Get-RegistryHive $hive
	            
	            if($RegHive -eq 1)
	            {
	                Write-Host "Invalid Path: $Path, Registry Hive [$hive] is invalid!" -ForegroundColor Red
	            }
	            else
	            {
	                Write-Verbose " [Remove-RegistryKey] :: `$RegHive = $RegHive"
	                $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegHive,$ComputerName)
	                Write-Verbose " [Remove-RegistryKey] :: `$BaseKey = $BaseKey"
	                
	                $Key = $BaseKey.OpenSubKey($KeyPath,$True)
	                
	                if($PSCmdlet.ShouldProcess($ComputerName,"Deleteing Key [$Name]"))
	                {
	                    if($Recurse)
	                    {
	                        Write-Verbose " [Remove-RegistryKey] :: Calling DeleteSubKeyTree($Name)"
	                        $Key.DeleteSubKeyTree($Name)
	                    }
	                    else
	                    {
	                        Write-Verbose " [Remove-RegistryKey] :: Calling DeleteSubKey($Name)"
	                        $Key.DeleteSubKey($Name)
	                    }
	                }
	            }
	        }
	        else
	        {
	            "Key [$path\$name] does not exist"
	        }
	        Write-Verbose " [Remove-RegistryKey] :: End Process"
	    
	    }
	}
	    
	#endregion 
	
	#region Remove-RegistryValue 
	
	function Remove-RegistryValue 
	{
	        
	    <#
	        .Synopsis 
	            Removes the value.
	            
	        .Description
	            Removes the value.
	                        
	        .Parameter Path 
	            Path to the key that contains the value.
	            
	        .Parameter Name 
	            Name of the Value to Remove.
	    
	        .Parameter ComputerName 
	            Computer to remove value from.
	            
	        .Example
	            Remove-RegistryValue HKLM\SOFTWARE\Adobe\MyKey -Name State
	            Description
	            -----------
	            Removes the value STATE under HKLM\SOFTWARE\Adobe\MyKey.
	            
	        .Example
	            Remove-RegistryValue HKLM\Software\Adobe\MyKey -Name State -ComputerName MyServer1
	            Description
	            -----------
	            Removes the value STATE under HKLM\SOFTWARE\Adobe\MyKey on MyServer1.
	                    
	        .OUTPUTS
	            $null
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            New-RegistryValue
	            Test-RegistryValue
	            Get-RegistryValue
	            Set-RegistryValue
	            
	        NAME:      Remove-RegistryValue
	        AUTHOR:    bsonposh
	        Website:   http://www.bsonposh.com
	        Version:   1
	        #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding(SupportsShouldProcess=$true)]
	    Param(
	        [Parameter(mandatory=$true)]
	        [string]$Path,
	        
	        [Parameter(mandatory=$true)]
	        [string]$Name,
	        
	        [Alias("dnsHostName")]
	        [Parameter(ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:ComputerName
	    )
	    Begin 
	    {
	    
	        Write-Verbose " [Remove-RegistryValue] :: Start Begin"
	        
	        Write-Verbose " [Remove-RegistryValue] :: `$Path = $Path"
	        Write-Verbose " [Remove-RegistryValue] :: `$Name = $Name"
	        
	        Write-Verbose " [Remove-RegistryValue] :: End Begin"
	        
	    }
	    
	    Process 
	    {
	    
	        if(Test-RegistryValue -Path $path -Name $Name -ComputerName $ComputerName)
	        {
	            Write-Verbose " [Remove-RegistryValue] :: Start Process"
	            Write-Verbose " [Remove-RegistryValue] :: Calling Get-RegistryKey -Path $path -ComputerName $ComputerName"
	            $Key = Get-RegistryKey -Path $path -ComputerName $ComputerName -ReadWrite
	            Write-Verbose " [Remove-RegistryValue] :: Get-RegistryKey returned $Key"
	            Write-Verbose " [Remove-RegistryValue] :: Setting Value for [$Name]"
	            if($PSCmdlet.ShouldProcess($ComputerName,"Deleting Value [$Name] under $Path"))
	            {
	                $Key.DeleteValue($Name)
	            }
	        }
	        else
	        {
	            "Registry Value is already gone"
	        }
	        
	        Write-Verbose " [Remove-RegistryValue] :: End Process"
	    
	    }
	}
	    
	#endregion 
	
	#region Search-Registry 
	
	function Search-Registry 
	{
	        
	    <#
	        .Synopsis 
	            Searchs the Registry.
	            
	        .Description
	            Searchs the Registry.
	                        
	        .Parameter Filter 
	            The RegEx filter you want to search for.
	            
	        .Parameter Name 
	            Name of the Key or Value you want to search for.
	        
	        .Parameter Value
	            Value to search for (Registry Values only.)
	            
	        .Parameter Path
	            Base of the Search. Should be in this format: "Software\Microsoft\..." See the Examples for specific exampl
	    es.
	            
	        .Parameter Hive
	            The Base Hive to search in (Default to LocalMachine.)
	            
	        .Parameter ComputerName 
	            Computer to search.
	            
	        .Parameter KeyOnly
	            Only returns Registry Keys. Not valid with -value parameter.
	            
	        .Example
	            Search-Registry -Hive HKLM -Filter "Powershell" -Path "SOFTWARE\Clients"
	            Description
	            -----------
	            Searchs the Registry for Keys or Values that match 'Powershell" in path "SOFTWARE\Clients"
	            
	        .Example
	            Search-Registry -Hive HKLM -Filter "Powershell" -Path "SOFTWARE\Clients" -computername MyServer1
	            Description
	            -----------
	            Searchs the Registry for Keys or Values that match 'Powershell" in path "SOFTWARE\Clients" on MyServer1
	            
	        .Example
	            Search-Registry -Hive HKLM -Name "Powershell" -Path "SOFTWARE\Clients"
	            Description
	            -----------
	            Searchs the Registry keys and values with name 'Powershell' in "SOFTWARE\Clients"
	            
	        .Example
	            Search-Registry -Hive HKLM -Name "Powershell" -Path "SOFTWARE\Clients" -KeyOnly
	            Description
	            -----------
	            Searchs the Registry keys with name 'Powershell' in "SOFTWARE\Clients"
	        
	        .Example
	            Search-Registry -Hive HKLM -Value "Powershell" -Path "SOFTWARE\Clients"
	            Description
	            -----------
	            Searchs the Registry Values with Value of 'Powershell' in "SOFTWARE\Clients"
	            
	        .OUTPUTS
	            Microsoft.Win32.RegistryKey
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            Get-RegistryKey
	            Get-RegistryValue
	            Test-RegistryKey
	        
	        .Notes
	            NAME:      Search-Registry
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	        
	    [Cmdletbinding(DefaultParameterSetName="ByFilter")]
	    Param(
	        [Parameter(ParameterSetName="ByFilter",Position=0)]
	        [string]$Filter= ".*",
	        
	        [Parameter(ParameterSetName="ByName",Position=0)]
	        [string]$Name,
	        
	        [Parameter(ParameterSetName="ByValue",Position=0)]
	        [string]$Value,
	        
	        [Parameter()]
	        [string]$Path,
	        
	        [Parameter()]
	        [string]$Hive = "LocalMachine",
	        
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME,
	            
	        [Parameter()]
	        [switch]$KeyOnly
	    )
	    Begin 
	    {
	    
	        Write-Verbose " [Search-Registry] :: Start Begin"
	        
	        Write-Verbose " [Search-Registry] :: Active Parameter Set $($PSCmdlet.ParameterSetName)"
	        switch ($PSCmdlet.ParameterSetName)
	        {
	            "ByFilter"    {Write-Verbose " [Search-Registry] :: `$Filter = $Filter"}
	            "ByName"    {Write-Verbose " [Search-Registry] :: `$Name = $Name"}
	            "ByValue"    {Write-Verbose " [Search-Registry] :: `$Value = $Value"}
	        }
	        $RegHive = Get-RegistryHive $Hive
	        Write-Verbose " [Search-Registry] :: `$Hive = $RegHive"
	        Write-Verbose " [Search-Registry] :: `$KeyOnly = $KeyOnly"
	        
	        Write-Verbose " [Search-Registry] :: End Begin"
	    
	    }
	    
	    Process 
	    {
	    
	        Write-Verbose " [Search-Registry] :: Start Process"
	        
	        Write-Verbose " [Search-Registry] :: `$ComputerName = $ComputerName"
	        switch ($PSCmdlet.ParameterSetName)
	        {
	            "ByFilter"    {
	                            if($KeyOnly)
	                            {
	                                if($Path -and (Test-RegistryKey "$RegHive\$Path"))
	                                {
	                                    Get-RegistryKey -Path "$RegHive\$Path" -ComputerName $ComputerName -Recurse | ?{$_.Name -match "$Filter"}
	                                }
	                                else
	                                {
	                                $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegHive,$ComputerName)
	                                foreach($SubKeyName in $BaseKey.GetSubKeyNames())
	                                {
	                                    try
	                                    {
	                                        $SubKey = $BaseKey.OpenSubKey($SubKeyName,$true)
	                                        Get-RegistryKey -Path $SubKey.Name -ComputerName $ComputerName -Recurse | ?{$_.Name -match "$Filter"}
	                                    }
	                                    catch
	                                    {
	                                        Write-Host "Access Error on Key [$SubKeyName]... skipping."
	                                    }
	                                }
	                                }
	                            }
	                            else
	                            {
	                                if($Path -and (Test-RegistryKey "$RegHive\$Path"))
	                                {
	                                    Get-RegistryKey -Path "$RegHive\$Path" -ComputerName $ComputerName -Recurse | ?{$_.Name -match "$Filter"}
	                                    Get-RegistryValue -Path "$RegHive\$Path" -ComputerName $ComputerName -Recurse | ?{$_.Name -match "$Filter"}
	                                }
	                                else
	                                {
	                                    $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegHive,$ComputerName)
	                                    foreach($SubKeyName in $BaseKey.GetSubKeyNames())
	                                    {
	                                        try
	                                        {
	                                            $SubKey = $BaseKey.OpenSubKey($SubKeyName,$true)
	                                            Get-RegistryKey -Path $SubKey.Name -ComputerName $ComputerName -Recurse | ?{$_.Name -match "$Filter"}
	                                            Get-RegistryValue -Path $SubKey.Name -ComputerName $ComputerName -Recurse | ?{$_.Name -match "$Filter"}
	                                        }
	                                        catch
	                                        {
	                                            Write-Host "Access Error on Key [$SubKeyName]... skipping."
	                                        }
	                                    }
	                                }
	                            }
	                        }
	            "ByName"    {
	                            if($KeyOnly)
	                            {
	                                if($Path -and (Test-RegistryKey "$RegHive\$Path"))
	                                {
	                                    $NameFilter = "^.*\\{0}$" -f $Name
	                                    Get-RegistryKey -Path "$RegHive\$Path" -ComputerName $ComputerName -Recurse | ?{$_.Name -match $NameFilter}
	                                }
	                                else
	                                {
	                                    $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegHive,$ComputerName)
	                                    foreach($SubKeyName in $BaseKey.GetSubKeyNames())
	                                    {
	                                        try
	                                        {
	                                            $SubKey = $BaseKey.OpenSubKey($SubKeyName,$true)
	                                            $NameFilter = "^.*\\{0}$" -f $Name
	                                            Get-RegistryKey -Path "$RegHive\$Path" -ComputerName $ComputerName -Recurse | ?{$_.Name -match $NameFilter}
	                                        }
	                                        catch
	                                        {
	                                            Write-Host "Access Error on Key [$SubKeyName]... skipping."
	                                        }
	                                    }
	                                }
	                            }
	                            else
	                            {
	                                if($Path -and (Test-RegistryKey "$RegHive\$Path"))
	                                {
	                                    $NameFilter = "^.*\\{0}$" -f $Name
	                                    Get-RegistryKey -Path "$RegHive\$Path" -ComputerName $ComputerName -Recurse | ?{$_.Name -match $NameFilter}
	                                    Get-RegistryValue -Path "$RegHive\$Path" -ComputerName $ComputerName -Recurse | ?{$_.Name -eq $Name}
	                                }
	                                else
	                                {
	                                    $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegHive,$ComputerName)
	                                    foreach($SubKeyName in $BaseKey.GetSubKeyNames())
	                                    {
	                                        try
	                                        {
	                                            $SubKey = $BaseKey.OpenSubKey($SubKeyName,$true)
	                                            $NameFilter = "^.*\\{0}$" -f $Name
	                                            Get-RegistryKey -Path "$RegHive\$Path" -ComputerName $ComputerName -Recurse | ?{$_.Name -match $NameFilter}
	                                            Get-RegistryValue -Path $SubKey.Name -ComputerName $ComputerName -Recurse | ?{$_.Name -eq $Name}
	                                        }
	                                        catch
	                                        {
	                                            Write-Host "Access Error on Key [$SubKeyName]... skipping."
	                                        }
	                                    }
	                                }
	                            }
	                        }
	            "ByValue"    {
	                            if($Path -and (Test-RegistryKey "$RegHive\$Path"))
	                            {
	                                Get-RegistryValue -Path "$RegHive\$Path" -ComputerName $ComputerName -Recurse | ?{$_.Value -eq $Value}
	                            }
	                            else
	                            {
	                                $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegHive,$ComputerName)
	                                foreach($SubKeyName in $BaseKey.GetSubKeyNames())
	                                {
	                                    try
	                                    {
	                                        $SubKey = $BaseKey.OpenSubKey($SubKeyName,$true)
	                                        Get-RegistryValue -Path "$RegHive\$Path" -ComputerName $ComputerName -Recurse | ?{$_.Value -eq $Value}
	                                    }
	                                    catch
	                                    {
	                                        Write-Host "Access Error on Key [$SubKeyName]... skipping."
	                                    }
	                                }
	                            }
	                        }
	        }
	        
	        Write-Verbose " [Search-Registry] :: End Process"
	    
	    }
	}
	    
	#endregion 
	
	#region Set-RegistryValue 
	
	function Set-RegistryValue
	{
	        
	    <#
	        .Synopsis 
	            Sets a value under the registry key.
	            
	        .Description
	            Sets a value under the registry key.
	                        
	        .Parameter Path 
	            Path to the key.
	            
	        .Parameter Name 
	            Name of the Value to Set.
	            
	        .Parameter Value 
	            New Value.
	            
	        .Parameter Type
	            Type for the Value. Valid Types: Unknown, String (default,) ExpandString, Binary, DWord, MultiString, and Q
	    word
	            
	        .Parameter ComputerName 
	            Computer to set the Value on.
	            
	        .Example
	            Set-RegistryValue HKLM\SOFTWARE\Adobe\MyKey -Name State -Value "Hi There"
	            Description
	            -----------
	            Sets the Value State and sets the value to "Hi There" under HKLM\SOFTWARE\Adobe\MyKey.
	            
	        .Example
	            Set-RegistryValue HKLM\SOFTWARE\Adobe\MyKey -Name State -Value 0 -ComputerName MyServer1
	            Description
	            -----------
	            Sets the Value State and sets the value to "Hi There" under HKLM\SOFTWARE\Adobe\MyKey on MyServer1.
	            
	        .Example
	            Set-RegistryValue HKLM\SOFTWARE\Adobe\MyKey -Name MyDWord -Value 0 -Type DWord
	            Description
	            -----------
	            Sets the DWORD Value MyDWord and sets the value to 0 under HKLM\SOFTWARE\Adobe\MyKey.
	            
	        .OUTPUTS
	            PSCustomObject
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            New-RegistryValue
	            Remove-RegistryValue
	            Get-RegistryValue
	            Test-RegistryValue
	        
	        .Notes
	            NAME:      Set-RegistryValue
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding(SupportsShouldProcess=$true)]
	    Param(
	        [Parameter(mandatory=$true)]
	        [string]$Path,
	        
	        [Parameter(mandatory=$true)]
	        [string]$Name,
	        
	        [Parameter()]
	        [string]$Value,
	        
	        [Parameter()]
	        [string]$Type,
	        
	        [Alias("dnsHostName")]
	        [Parameter(ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:ComputerName
	    )
	    
	    Begin 
	    {
	    
	        Write-Verbose " [Set-RegistryValue] :: Start Begin"
	        
	        Write-Verbose " [Set-RegistryValue] :: `$Path = $Path"
	        Write-Verbose " [Set-RegistryValue] :: `$Name = $Name"
	        Write-Verbose " [Set-RegistryValue] :: `$Value = $Value"
	        
	        Switch ($Type)
	        {
	            "Unknown"       {$ValueType = [Microsoft.Win32.RegistryValueKind]::Unknown;continue}
	            "String"        {$ValueType = [Microsoft.Win32.RegistryValueKind]::String;continue}
	            "ExpandString"  {$ValueType = [Microsoft.Win32.RegistryValueKind]::ExpandString;continue}
	            "Binary"        {$ValueType = [Microsoft.Win32.RegistryValueKind]::Binary;continue}
	            "DWord"         {$ValueType = [Microsoft.Win32.RegistryValueKind]::DWord;continue}
	            "MultiString"   {$ValueType = [Microsoft.Win32.RegistryValueKind]::MultiString;continue}
	            "QWord"         {$ValueType = [Microsoft.Win32.RegistryValueKind]::QWord;continue}
	            default         {$ValueType = [Microsoft.Win32.RegistryValueKind]::String;continue}
	        }
	        Write-Verbose " [Set-RegistryValue] :: `$Type = $Type"
	        
	        Write-Verbose " [Set-RegistryValue] :: End Begin"
	    
	    }
	    
	    Process 
	    {
	    
	        Write-Verbose " [Set-RegistryValue] :: Start Process"
	        
	        Write-Verbose " [Set-RegistryValue] :: Calling Get-RegistryKey -Path $path -ComputerName $ComputerName"
	        $Key = Get-RegistryKey -Path $path -ComputerName $ComputerName -ReadWrite
	        Write-Verbose " [Set-RegistryValue] :: Get-RegistryKey returned $Key"
	        Write-Verbose " [Set-RegistryValue] :: Setting Value for [$Name]"
	        if($PSCmdlet.ShouldProcess($ComputerName,"Creating Value [$Name] under $Path with value [$Value]"))
	        {
	            if($Value)
	            {
	                $Key.SetValue($Name,$Value,$ValueType)
	            }
	            else
	            {
	                $Key.SetValue($Name,$ValueType)
	            }
	            Write-Verbose " [Set-RegistryValue] :: Returning New Key: Get-RegistryValue -Path $path -Name $Name -ComputerName $ComputerName"
	            Get-RegistryValue -Path $path -Name $Name -ComputerName $ComputerName
	        }
	        Write-Verbose " [Set-RegistryValue] :: End Process"
	    
	    }
	}
	    
	#endregion 
	
	#region Test-RegistryKey 
	
	function Test-RegistryKey 
	{
	        
	    <#
	        .Synopsis 
	            Test for given the registry key.
	            
	        .Description
	            Test for given the registry key.
	                        
	        .Parameter Path 
	            Path to the key.
	            
	        .Parameter ComputerName 
	            Computer to test the registry key on.
	            
	        .Example
	            Test-registrykey HKLM\Software\Adobe
	            Description
	            -----------
	            Returns $True if the Registry key for HKLM\Software\Adobe
	            
	        .Example
	            Test-registrykey HKLM\Software\Adobe -ComputerName MyServer1
	            Description
	            -----------
	            Returns $True if the Registry key for HKLM\Software\Adobe on MyServer1
	                    
	        .OUTPUTS
	            System.Boolean
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            New-RegistryKey
	            Remove-RegistryKey
	            Get-RegistryKey
	        
	        .Notes
	            NAME:      Test-RegistryKey
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding(SupportsShouldProcess=$true)]
	    Param(
	    
	        [Parameter(ValueFromPipelineByPropertyName=$True,mandatory=$true)]
	        [string]$Path,
	        
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	        
	    )
	    
	    Begin 
	    {
	    
	        Write-Verbose " [Test-RegistryKey] :: Start Begin"
	        
	        Write-Verbose " [Test-RegistryKey] :: `$Path = $Path"
	        Write-Verbose " [Test-RegistryKey] :: Getting `$Hive and `$KeyPath from $Path "
	        $PathParts = $Path -split "\\|/",0,"RegexMatch"
	        $Hive = $PathParts[0]
	        $KeyPath = $PathParts[1..$PathParts.count] -join "\"
	        Write-Verbose " [Test-RegistryKey] :: `$Hive = $Hive"
	        Write-Verbose " [Test-RegistryKey] :: `$KeyPath = $KeyPath"
	        
	        Write-Verbose " [Test-RegistryKey] :: End Begin"
	    
	    }
	    
	    Process 
	    {
	    
	        Write-Verbose " [Test-RegistryKey] :: Start Process"
	        
	        Write-Verbose " [Test-RegistryKey] :: `$ComputerName = $ComputerName"
	        
	        $RegHive = Get-RegistryHive $hive
	        
	        if($RegHive -eq 1)
	        {
	            Write-Host "Invalid Path: $Path, Registry Hive [$hive] is invalid!" -ForegroundColor Red
	        }
	        else
	        {
	            Write-Verbose " [Test-RegistryKey] :: `$RegHive = $RegHive"
	            
	            $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegHive,$ComputerName)
	            Write-Verbose " [Test-RegistryKey] :: `$BaseKey = $BaseKey"
	            
	            Try
	            {
	                $Key = $BaseKey.OpenSubKey($KeyPath) 
	                if($Key)
	                {
	                    $true
	                }
	                else
	                {
	                    $false
	                }
	            }
	            catch
	            {
	                $false
	            }
	        }
	        Write-Verbose " [Test-RegistryKey] :: End Process"
	    
	    }
	}
	    
	#endregion 
	
	#region Test-RegistryValue 
	
	function Test-RegistryValue
	{
	        
	    <#
	        .Synopsis 
	            Test the value for given the registry value.
	            
	        .Description
	            Test the value for given the registry value.
	                        
	        .Parameter Path 
	            Path to the key that contains the value.
	            
	        .Parameter Name 
	            Name of the Value to check.
	            
	        .Parameter Value 
	            Value to check for.
	            
	        .Parameter ComputerName 
	            Computer to test.
	            
	        .Example
	            Test-RegistryValue HKLM\SOFTWARE\Adobe\SwInstall -Name State -Value 0
	            Description
	            -----------
	            Returns $True if the value of State under HKLM\SOFTWARE\Adobe\SwInstall is 0
	            
	        .Example
	            Test-RegistryValue HKLM\Software\Adobe -ComputerName MyServer1
	            Description
	            -----------
	            Returns $True if the value of State under HKLM\SOFTWARE\Adobe\SwInstall is 0 on MyServer1
	                    
	        .OUTPUTS
	            System.Boolean
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            New-RegistryValue
	            Remove-RegistryValue
	            Get-RegistryValue
	        
	        .Notes    
	            NAME:      Test-RegistryValue
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	    
	        [Parameter(mandatory=$true)]
	        [string]$Path,
	    
	        [Parameter(mandatory=$true)]
	        [string]$Name,
	        
	        [Parameter()]
	        [string]$Value,
	        
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	        
	    )
	    
	    Process 
	    {
	    
	        Write-Verbose " [Test-RegistryValue] :: Begin Process"
	        Write-Verbose " [Test-RegistryValue] :: Calling Get-RegistryKey -Path $path -ComputerName $ComputerName"
	        $Key = Get-RegistryKey -Path $path -ComputerName $ComputerName 
	        Write-Verbose " [Test-RegistryValue] :: Get-RegistryKey returned $Key"
	        if($Value)
	        {
	            try
	            {
	                $CurrentValue = $Key.GetValue($Name)
	                $Value -eq $CurrentValue
	            }
	            catch
	            {
	                $false
	            }
	        }
	        else
	        {
	            try
	            {
	                $CurrentValue = $Key.GetValue($Name)
	                if($CurrentValue){$True}else{$false}
	            }
	            catch
	            {
	                $false
	            }
	        }
	        Write-Verbose " [Test-RegistryValue] :: End Process"
	    
	    }
	}
	    
	#endregion 
	
	#region Get-DiskRelationship
	function Get-DiskRelationship {
	param (
	    [string]$computername = "localhost"
	)
	    Get-WmiObject -Class Win32_DiskDrive -ComputerName $computername | foreach {
	        "`n {0} {1}" -f $($_.Name), $($_.Model)
	
	        $query = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" `
	         + $_.DeviceID + "'} WHERE ResultClass=Win32_DiskPartition"
	         
	        Get-WmiObject -Query $query -ComputerName $computername | foreach {
	            ""
	            "Name             : {0}" -f $_.Name
	            "Description      : {0}" -f $_.Description
	            "PrimaryPartition : {0}" -f $_.PrimaryPartition
	        
	            $query2 = "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" `
	            + $_.DeviceID + "'} WHERE ResultClass=Win32_LogicalDisk"
	                
	            Get-WmiObject -Query $query2 -ComputerName $computername | Format-List Name,
	            @{Name="Disk Size (GB)"; Expression={"{0:F3}" -f $($_.Size/1GB)}},
	            @{Name="Free Space (GB)"; Expression={"{0:F3}" -f $($_.FreeSpace/1GB)}}
	        
	        }
	    }
	}
	#endregion
	
	#region Get-MountPoint
	function Get-MountPoint {
	param (
	    [string]$computername = "localhost"
	)
	    Get-WmiObject -Class Win32_MountPoint -ComputerName $computername | 
	    where {$_.Directory -like 'Win32_Directory.Name="*"'} | 
	    foreach {
	        $vol = $_.Volume
	        Get-WmiObject -Class Win32_Volume -ComputerName $computername | where {$_.__RELPATH -eq $vol} | 
	        Select @{Name="Folder"; Expression={$_.Caption}}, 
	        @{Name="Size (GB)"; Expression={"{0:F3}" -f $($_.Capacity / 1GB)}},
	        @{Name="Free (GB)"; Expression={"{0:F3}" -f $($_.FreeSpace / 1GB)}},
	        @{Name="%Free"; Expression={"{0:F2}" -f $(($_.FreeSpace/$_.Capacity)*100)}}|ft -AutoSize
	    }
	}
	#endregion
	
	#region Get-MappedDrive
	function Get-MappedDrive {
	param (
	    [string]$computername = "localhost"
	)
	    Get-WmiObject -Class Win32_MappedLogicalDisk -ComputerName $computername | 
	    Format-List DeviceId, VolumeName, SessionID, Size, FreeSpace, ProviderName
	}
	#endregion
	
	#region Test-Host 
	
	function Test-Host
	{
	        
	    <#
	        .Synopsis 
	            Test a host for connectivity using either WMI ping or TCP port
	            
	        .Description
	            Allows you to test a host for connectivity before further processing
	            
	        .Parameter Server
	            Name of the Server to Process.
	            
	        .Parameter TCPPort
	            TCP Port to connect to. (default 135)
	            
	        .Parameter Timeout
	            Timeout for the TCP connection (default 1 sec)
	            
	        .Parameter Property
	            Name of the Property that contains the value to test.
	            
	        .Example
	            cat ServerFile.txt | Test-Host | Invoke-DoSomething
	            Description
	            -----------
	            To test a list of hosts.
	            
	        .Example
	            cat ServerFile.txt | Test-Host -tcp 80 | Invoke-DoSomething
	            Description
	            -----------
	            To test a list of hosts against port 80.
	            
	        .Example
	            Get-ADComputer | Test-Host -property dnsHostname | Invoke-DoSomething
	            Description
	            -----------
	            To test the output of Get-ADComputer using the dnshostname property
	            
	            
	        .OUTPUTS
	            System.Object
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            Test-Port
	            
	        NAME:      Test-Host
	        AUTHOR:    YetiCentral\bshell
	        Website:   www.bsonposh.com
	        LASTEDIT:  02/04/2009 18:25:15
	        #Requires -Version 2.0
	    #>
	    
	    [CmdletBinding()]
	    
	    Param(
	    
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$True)]
	        [string]$ComputerName,
	        
	        [Parameter()]
	        [int]$TCPPort=80,
	        
	        [Parameter()]
	        [int]$timeout=3000,
	        
	        [Parameter()]
	        [string]$property
	        
	    )
	    Begin 
	    {
	    
	        function PingServer 
	        {
	            Param($MyHost)
	            $ErrorActionPreference = "SilentlyContinue"
	            Write-Verbose " [PingServer] :: Pinging [$MyHost]"
	            try
	            {
	                $pingresult = Get-WmiObject win32_pingstatus -f "address='$MyHost'"
	                $ResultCode = $pingresult.statuscode
	                Write-Verbose " [PingServer] :: Ping returned $ResultCode"
	                if($ResultCode -eq 0) {$true} else {$false}
	            }
	            catch
	            {
	                Write-Verbose " [PingServer] :: Ping Failed with Error: ${error[0]}"
	                $false
	            }
	        }
	    
	    }
	    
	    Process 
	    {
	    
	        Write-Verbose " [Test-Host] :: Begin Process"
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        Write-Verbose " [Test-Host] :: ComputerName   : $ComputerName"
	        if($TCPPort)
	        {
	            Write-Verbose " [Test-Host] :: Timeout  : $timeout"
	            Write-Verbose " [Test-Host] :: Port     : $TCPPort"
	            if($property)
	            {
	                Write-Verbose " [Test-Host] :: Property : $Property"
	                $Result = Test-Port $_.$property -tcp $TCPPort -timeout $timeout
	                if($Result)
	                {
	                    if($_){ $_ }else{ $ComputerName }
	                }
	            }
	            else
	            {
	                Write-Verbose " [Test-Host] :: Running - 'Test-Port $ComputerName -tcp $TCPPort -timeout $timeout'"
	                $Result = Test-Port $ComputerName -tcp $TCPPort -timeout $timeout
	                if($Result)
	                {
	                    if($_){ $_ }else{ $ComputerName }
	                } 
	            }
	        }
	        else
	        {
	            if($property)
	            {
	                Write-Verbose " [Test-Host] :: Property : $Property"
	                try
	                {
	                    if(PingServer $_.$property)
	                    {
	                        if($_){ $_ }else{ $ComputerName }
	                    } 
	                }
	                catch
	                {
	                    Write-Verbose " [Test-Host] :: $($_.$property) Failed Ping"
	                }
	            }
	            else
	            {
	                Write-Verbose " [Test-Host] :: Simple Ping"
	                try
	                {
	                    if(PingServer $ComputerName){$ComputerName}
	                }
	                catch
	                {
	                    Write-Verbose " [Test-Host] :: $ComputerName Failed Ping"
	                }
	            }
	        }
	        Write-Verbose " [Test-Host] :: End Process"
	    
	    }
	    
	}
	    
	#endregion 
	
	#region Test-Port 
	
	function Test-Port
	{
	        
	    <#
	        .Synopsis 
	            Test a host to see if the specified port is open.
	            
	        .Description
	            Test a host to see if the specified port is open.
	                        
	        .Parameter TCPPort 
	            Port to test (Default 135.)
	            
	        .Parameter Timeout 
	            How long to wait (in milliseconds) for the TCP connection (Default 3000.)
	            
	        .Parameter ComputerName 
	            Computer to test the port against (Default in localhost.)
	            
	        .Example
	            Test-Port -tcp 3389
	            Description
	            -----------
	            Returns $True if the localhost is listening on 3389
	            
	        .Example
	            Test-Port -tcp 3389 -ComputerName MyServer1
	            Description
	            -----------
	            Returns $True if MyServer1 is listening on 3389
	                    
	        .OUTPUTS
	            System.Boolean
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            Test-Host
	            Wait-Port
	            
	        .Notes
	            NAME:      Test-Port
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [Parameter()]
	        [int]$TCPport = 135,
	        [Parameter()]
	        [int]$TimeOut = 3000,
	        [Alias("dnsHostName")]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [String]$ComputerName = $env:COMPUTERNAME
	    )
	    Begin 
	    {
	        Write-Verbose " [Test-Port] :: Start Script"
	        Write-Verbose " [Test-Port] :: Setting Error state = 0"
	    }
	    
	    Process 
	    {
	    
	        Write-Verbose " [Test-Port] :: Creating [system.Net.Sockets.TcpClient] instance"
	        $tcpclient = New-Object system.Net.Sockets.TcpClient
	        
	        Write-Verbose " [Test-Port] :: Calling BeginConnect($ComputerName,$TCPport,$null,$null)"
	        try
	        {
	            $iar = $tcpclient.BeginConnect($ComputerName,$TCPport,$null,$null)
	            Write-Verbose " [Test-Port] :: Waiting for timeout [$timeout]"
	            $wait = $iar.AsyncWaitHandle.WaitOne($TimeOut,$false)
	        }
	        catch [System.Net.Sockets.SocketException]
	        {
	            Write-Verbose " [Test-Port] :: Exception: $($_.exception.message)"
	            Write-Verbose " [Test-Port] :: End"
	            return $false
	        }
	        catch
	        {
	            Write-Verbose " [Test-Port] :: General Exception"
	            Write-Verbose " [Test-Port] :: End"
	            return $false
	        }
	    
	        if(!$wait)
	        {
	            $tcpclient.Close()
	            Write-Verbose " [Test-Port] :: Connection Timeout"
	            Write-Verbose " [Test-Port] :: End"
	            return $false
	        }
	        else
	        {
	            Write-Verbose " [Test-Port] :: Closing TCP Socket"
	            try
	            {
	                $tcpclient.EndConnect($iar) | out-Null
	                $tcpclient.Close()
	            }
	            catch
	            {
	                Write-Verbose " [Test-Port] :: Unable to Close TCP Socket"
	            }
	            $true
	        }
	    }
	    End 
	    {
	        Write-Verbose " [Test-Port] :: End Script"
	    }
	}  
	#endregion 
	
	#region Get-MemoryConfiguration 
	
	function Get-MemoryConfiguration
	{
	        
	    <#
	        .Synopsis 
	            Gets the Memory Config for specified host.
	            
	        .Description
	            Gets the Memory Config for specified host.
	            
	        .Parameter ComputerName
	            Name of the Computer to get the Memory Config from (Default is localhost.)
	            
	        .Example
	            Get-MemoryConfiguration
	            Description
	            -----------
	            Gets Memory Config from local machine
	    
	        .Example
	            Get-MemoryConfiguration -ComputerName MyServer
	            Description
	            -----------
	            Gets Memory Config from MyServer
	            
	        .Example
	            $Servers | Get-MemoryConfiguration
	            Description
	            -----------
	            Gets Memory Config for each machine in the pipeline
	            
	        .OUTPUTS
	            PSCustomObject
	            
	        .Notes
	            NAME:      Get-MemoryConfiguration 
	            AUTHOR:    YetiCentral\bshell
	            Website:   www.bsonposh.com
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	    )
	    
	    Process 
	    {
	    
	        Write-Verbose " [Get-MemoryConfiguration] :: Begin Process"
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        if(Test-Host $ComputerName -TCPPort 135)
	        {
	            Write-Verbose " [Get-MemoryConfiguration] :: Processing $ComputerName"
	            try
	            {
	                $MemorySlots = Get-WmiObject Win32_PhysicalMemory -ComputerName $ComputerName -ea STOP
	                foreach($Dimm in $MemorySlots)
	                {
	                    $myobj = @{}
	                    $myobj.ComputerName = $ComputerName
	                    $myobj.Description  = $Dimm.Tag
	                    $myobj.Slot         = $Dimm.DeviceLocator
	                    $myobj.Speed        = $Dimm.Speed
	                    $myobj.SizeGB       = $Dimm.Capacity/1gb
	                    
	                    $obj = New-Object PSObject -Property $myobj
	                    $obj.PSTypeNames.Clear()
	                    $obj.PSTypeNames.Add('BSonPosh.MemoryConfiguration')
	                    $obj
	                }
	            }
	            catch
	            {
	                Write-Host " Host [$ComputerName] Failed with Error: $($Error[0])" -ForegroundColor Red
	            }    
	        }
	        else
	        {
	            Write-Host " Host [$ComputerName] Failed Connectivity Test " -ForegroundColor Red
	        }
	        Write-Verbose " [Get-MemoryConfiguration] :: End Process"
	    
	    }
	}
	    
	#endregion 
	
	#region Get-NetStat 
	            #Need to Implement
	            #[Parameter()]
	            #[int]$ID,
	            #[Parameter()]
	            #[int]$RemotePort,
	            #[Parameter()]
	            #[string]$RemoteAddress,
	function Get-NetStat
	{
	
	    <#
	        .Synopsis 
	            Get the Network stats of the local host.
	            
	        .Description
	            Get the Network stats of the local host.
	            
	        .Parameter ProcessName
	            Name of the Process to get Network stats for.
	        
	        .Parameter State
	            State to return: Valid Values are: "LISTENING", "ESTABLISHED", "CLOSE_WAIT", or "TIME_WAIT"
	
	        .Parameter Interval
	            Number of times you want to run netstat. Cannot be used with Loop.
	            
	        .Parameter Sleep
	            Time between calls to netstat. Used with Interval or Loop.
	            
	        .Parameter Loop
	            Loops netstat calls until you press ctrl-c. Cannot be used with Internval.
	            
	        .Example
	            Get-NetStat
	            Description
	            -----------
	            Returns all Network stat information on the localhost
	        
	        .Example
	            Get-NetStat -ProcessName chrome
	            Description
	            -----------
	            Returns all Network stat information on the localhost for process chrome.
	            
	        .Example
	            Get-NetStat -State ESTABLISHED
	            Description
	            -----------
	            Returns all the established connections on the localhost
	            
	        .Example
	            Get-NetStat -State ESTABLISHED -Loop
	            Description
	            -----------
	            Loops established connections.
	            
	        .OUTPUTS
	            PSCustomObject
	            
	        .INPUTS
	            System.String
	        
	        .Notes
	            NAME:      Get-NetStat
	            AUTHOR:    YetiCentral\bshell
	            Website:   www.bsonposh.com
	            #Requires -Version 2.0
	
	    #>
	    
	    [Cmdletbinding(DefaultParameterSetName="All")]
	    Param(
	        [Parameter()]
	        [string]$ProcessName,
	
	        [Parameter()]
	        [ValidateSet("LISTENING", "ESTABLISHED", "CLOSE_WAIT","TIME_WAIT")]
	        [string]$State,
	        
	        [Parameter(ParameterSetName="Interval")]
	        [int]$Interval,
	        
	        [Parameter()]
	        [int]$Sleep = 1,
	        
	        [Parameter(ParameterSetName="Loop")]
	        [switch]$Loop
	    )
	
	    function Parse-Netstat ($NetStat)
	    {
	        Write-Verbose " [Parse-Netstat] :: Parsing Netstat results"
	        switch -regex ($NetStat)
	        {
	            $RegEx  
	            {
	                Write-Verbose " [Parse-Netstat] :: creating Custom object"
	                $myobj = @{
	                    Protocol      = $matches.Protocol
	                    LocalAddress  = $matches.LocalAddress.split(":")[0]
	                    LocalPort     = $matches.LocalAddress.split(":")[1]
	                    RemoteAddress = $matches.RemoteAddress.split(":")[0]
	                    RemotePort    = $matches.RemoteAddress.split(":")[1]
	                    State         = $matches.State
	                    ProcessID     = $matches.PID
	                    ProcessName   = Get-Process -id $matches.PID -ea 0 | %{$_.name}
	                }
	                
	                $obj = New-Object PSCustomObject -Property $myobj
	                $obj.PSTypeNames.Clear()
	                $obj.PSTypeNames.Add('BSonPosh.NetStatInfo')
	                Write-Verbose " [Parse-Netstat] :: Created object for [$($obj.LocalAddress):$($obj.LocalPort)]"
	                
	                if($ProcessName)
	                {
	                    $obj | where{$_.ProcessName -eq $ProcessName}
	                }
	                elseif($State)
	                {
	                    $obj | where{$_.State -eq $State}
	                }
	                else
	                {
	                    $obj
	                }
	                
	            }
	        }
	    }
	    
	    [RegEX]$RegEx = '\s+(?<Protocol>\S+)\s+(?<LocalAddress>\S+)\s+(?<RemoteAddress>\S+)\s+(?<State>\S+)\s+(?<PID>\S+)'
	    $Connections = @{}
	    
	    switch -exact ($pscmdlet.ParameterSetName)
	    {    
	        "All"           {
	                            Write-Verbose " [Get-NetStat] :: ParameterSet - ALL"
	                            $NetStatResults = netstat -ano | ?{$_ -match "(TCP|UDP)\s+\d"}
	                            Parse-Netstat $NetStatResults
	                        }
	        "Interval"      {
	                            Write-Verbose " [Get-NetStat] :: ParameterSet - Interval"
	                            for($i = 1 ; $i -le $Interval ; $i++)
	                            {
	                                Start-Sleep $Sleep
	                                $NetStatResults = netstat -ano | ?{$_ -match "(TCP|UDP)\s+\d"}
	                                Parse-Netstat $NetStatResults | Out-String
	                            }
	                        }
	        "Loop"          {
	                            Write-Verbose " [Get-NetStat] :: ParameterSet - Loop"
	                            Write-Host
	                            Write-Host "Protocol LocalAddress  LocalPort RemoteAddress  RemotePort State       ProcessName   PID"
	                            Write-Host "-------- ------------  --------- -------------  ---------- -----       -----------   ---" -ForegroundColor White
	                            $oldPos = $Host.UI.RawUI.CursorPosition
	                            [console]::TreatControlCAsInput = $true
	                            while($true)
	                            {
	                                Write-Verbose " [Get-NetStat] :: Getting Netstat data"
	                                $NetStatResults = netstat -ano | ?{$_ -match "(TCP|UDP)\s+\d"}
	                                Write-Verbose " [Get-NetStat] :: Getting Netstat data from Netstat"
	                                $Results = Parse-Netstat $NetStatResults 
	                                Write-Verbose " [Get-NetStat] :: Parse-NetStat returned $($results.count) results"
	                                foreach($Result in $Results)
	                                {
	                                    $Key = $Result.LocalPort
	                                    $Value = $Result.ProcessID
	                                    $msg = "{0,-9}{1,-14}{2,-10}{3,-15}{4,-11}{5,-12}{6,-14}{7,-10}" -f  $Result.Protocol,$Result.LocalAddress,$Result.LocalPort,
	                                                                                                         $Result.RemoteAddress,$Result.RemotePort,$Result.State,
	                                                                                                         $Result.ProcessName,$Result.ProcessID
	                                    if($Connections.$Key -eq $Value)
	                                    {
	                                        Write-Host $msg
	                                    }
	                                    else
	                                    {
	                                        $Connections.$Key = $Value
	                                        Write-Host $msg -ForegroundColor Yellow
	                                    }
	                                }
	                                if ($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character))
	                                {
	                                    Write-Host "Exiting now..." -foregroundcolor Yellow
	                                    Write-Host
	                                    [console]::TreatControlCAsInput = $false
	                                    break
	                                }
	                                $Host.UI.RawUI.CursorPosition = $oldPos
	                                start-sleep $Sleep
	                            }
	                        }
	    }
	}
	
	#endregion 
	
	#region Get-NicInfo 
	
	function Get-NICInfo
	{
	
	    <#
	        .Synopsis  
	            Gets the NIC info for specified host
	            
	        .Description
	            Gets the NIC info for specified host
	            
	        .Parameter ComputerName
	            Name of the Computer to get the NIC info from (Default is localhost.)
	            
	        .Example
	            Get-NicInfo
	            # Gets NIC info from local machine
	    
	        .Example
	            Get-NicInfo -ComputerName MyServer
	            Description
	            -----------
	            Gets NIC info from MyServer
	            
	        .Example
	            $Servers | Get-NicInfo
	            Description
	            -----------
	            Gets NIC info for each machine in the pipeline
	            
	        .OUTPUTS
	            PSCustomObject
	            
	        .Notes
	            NAME:      Get-NicInfo 
	            AUTHOR:    YetiCentral\bshell
	            Website:   www.bsonposh.com
	            #Requires -Version 2.0
	    #>
	    
		[Cmdletbinding()]
		Param(
		    [alias('dnsHostName')]
			[Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
			[string]$ComputerName = $Env:COMPUTERNAME
		)
	
		Process
		{
			if($ComputerName -match "(.*)(\$)$")
			{
				$ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
			}
			
			if(Test-Host -ComputerName $ComputerName -TCPPort 135)
			{
				try
				{
					$NICS = Get-WmiObject -class Win32_NetworkAdapterConfiguration -ComputerName $ComputerName
					
					foreach($NIC in $NICS)
					{
						$Query = "Select Name,NetConnectionID FROM Win32_NetworkAdapter WHERE Index='$($NIC.Index)'"
						$NetConnnectionID = Get-WmiObject -Query $Query -ComputerName $ComputerName
						
						$myobj = @{
	                        ComputerName = $ComputerName
							Name         = $NetConnnectionID.Name
							NetID        = $NetConnnectionID.NetConnectionID
							MacAddress   = $NIC.MacAddress
							IP           = $NIC.IPAddress | ?{$_ -match "\d*\.\d*\.\d*\."}
							Subnet       = $NIC.IPSubnet  | ?{$_ -match "\d*\.\d*\.\d*\."}
							Enabled      = $NIC.IPEnabled
							Index        = $NIC.Index
						}
						
						$obj = New-Object PSObject -Property $myobj
						$obj.PSTypeNames.Clear()
						$obj.PSTypeNames.Add('BSonPosh.NICInfo')
						$obj
					}
				}
				catch
				{
					Write-Host " Host [$ComputerName] Failed with Error: $($Error[0])" -ForegroundColor Red
				}
			}
			else
			{
				Write-Host " Host [$ComputerName] Failed Connectivity Test " -ForegroundColor Red
			}
		}
	} 
	
	#endregion 
	
	#region Get-MotherBoard
	
	function Get-MotherBoard
	{
	        
	    <#
	        .Synopsis 
	            Gets the Mother Board info for specified host.
	            
	        .Description
	            Gets the Mother Board info for specified host.
	            
	        .Parameter ComputerName
	            Name of the Computer to get the Mother Board info from (Default is localhost.) 
	            
	        .Example
	            Get-MotherBoard
	            Description
	            -----------
	            Gets Mother Board info from local machine
	    
	        .Example
	            Get-MotherBoard -ComputerName MyOtherDesktop
	            Description
	            -----------
	            Gets Mother Board info from MyOtherDesktop
	            
	        .Example
	            $Windows7Machines | Get-MotherBoard
	            Description
	            -----------
	            Gets Mother Board info for each machine in the pipeline
	            
	        .OUTPUTS
	            PSCustomObject
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            N/A
	            
	        .Notes
	            NAME:      Get-MotherBoard
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	    )
	    
	    Process 
	    {
	    
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        if(Test-Host -ComputerName $ComputerName -TCPPort 135)
	        {
	            try
	            {
	                $MBInfo = Get-WmiObject Win32_BaseBoard -ComputerName $ComputerName -ea STOP
	                $myobj = @{
	                    ComputerName     = $ComputerName
	                    Name             = $MBInfo.Product
	                    Manufacturer     = $MBInfo.Manufacturer
	                    Version          = $MBInfo.Version
	                    SerialNumber     = $MBInfo.SerialNumber
	                 }
	                
	                $obj = New-Object PSObject -Property $myobj
	                $obj.PSTypeNames.Clear()
	                $obj.PSTypeNames.Add('BSonPosh.Computer.MotherBoard')
	                $obj
	            }
	            catch
	            {
	                Write-Host " Host [$ComputerName] Failed with Error: $($Error[0])" -ForegroundColor Red
	            }
	        }
	        else
	        {
	            Write-Host " Host [$ComputerName] Failed Connectivity Test " -ForegroundColor Red
	        }
	    
	    }
	}
	    
	#endregion # Get-MotherBoard
	
	#region Get-Routetable 
	
	function Get-Routetable
	{
	    
	    <#
	        .Synopsis 
	            Gets the route table for specified host.
	            
	        .Description
	            Gets the route table for specified host.
	            
	        .Parameter ComputerName
	            Name of the Computer to get the route table from (Default is localhost.)
	            
	        .Example
	            Get-RouteTable
	            Description
	            -----------
	            Gets route table from local machine
	    
	        .Example
	            Get-RouteTable -ComputerName MyServer
	            Description
	            -----------
	            Gets route table from MyServer
	            
	        .Example
	            $Servers | Get-RouteTable
	            Description
	            -----------
	            Gets route table for each machine in the pipeline
	            
	        .OUTPUTS
	            PSCustomObject
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            N/A
	            
	        .Notes
	            NAME:      Get-RouteTable
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	    )
	    process 
	    {
	    
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        if(Test-Host $ComputerName -TCPPort 135)
	        {
	            $Routes = Get-WMIObject Win32_IP4RouteTable -ComputerName $ComputerName -Property Name,Mask,NextHop,Metric1,Type
	            foreach($Route in $Routes)
	            {
	                $myobj = @{}
	                $myobj.ComputerName = $ComputerName
	                $myobj.Name = $Route.Name
	                $myobj.NetworkMask = $Route.mask
	                $myobj.Gateway = if($Route.NextHop -eq "0.0.0.0"){"On-Link"}else{$Route.NextHop}
	                $myobj.Metric = $Route.Metric1
	                
	                $obj = New-Object PSObject -Property $myobj
	                $obj.PSTypeNames.Clear()
	                $obj.PSTypeNames.Add('BSonPosh.RouteTable')
	                $obj
	            }
	        }
	        else
	        {
	            Write-Host " Host [$ComputerName] Failed Connectivity Test " -ForegroundColor Red
	        }
	    
	    }
	}
	    
	#endregion 
	
	#region Get-SystemType 
	
	function Get-SystemType
	{
	        
	    <#
	        .Synopsis 
	            Gets the system type for specified host
	            
	        .Description
	            Gets the system type info for specified host
	            
	        .Parameter ComputerName
	            Name of the Computer to get the System Type from (Default is localhost.)
	            
	        .Example
	            Get-SystemType
	            Description
	            -----------
	            Gets System Type from local machine
	    
	        .Example
	            Get-SystemType -ComputerName MyServer
	            Description
	            -----------
	            Gets System Type from MyServer
	            
	        .Example
	            $Servers | Get-SystemType
	            Description
	            -----------
	            Gets System Type for each machine in the pipeline
	            
	        .OUTPUTS
	            PSObject
	            
	        .Notes
	            NAME:      Get-SystemType 
	            AUTHOR:    YetiCentral\bshell
	            Website:   www.bsonposh.com
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	    )
	    
	    Begin 
	    {
	    
	        function ConvertTo-ChassisType($Type)
	        {
	            switch ($Type)
	            {
	                1    {"Other"}
	                2    {"Unknown"}
	                3    {"Desktop"}
	                4    {"Low Profile Desktop"}
	                5    {"Pizza Box"}
	                6    {"Mini Tower"}
	                7    {"Tower"}
	                8    {"Portable"}
	                9    {"Laptop"}
	                10    {"Notebook"}
	                11    {"Hand Held"}
	                12    {"Docking Station"}
	                13    {"All in One"}
	                14    {"Sub Notebook"}
	                15    {"Space-Saving"}
	                16    {"Lunch Box"}
	                17    {"Main System Chassis"}
	                18    {"Expansion Chassis"}
	                19    {"SubChassis"}
	                20    {"Bus Expansion Chassis"}
	                21    {"Peripheral Chassis"}
	                22    {"Storage Chassis"}
	                23    {"Rack Mount Chassis"}
	                24    {"Sealed-Case PC"}
	            }
	        }
	        function ConvertTo-SecurityStatus($Status)
	        {
	            switch ($Status)
	            {
	                1    {"Other"}
	                2    {"Unknown"}
	                3    {"None"}
	                4    {"External Interface Locked Out"}
	                5    {"External Interface Enabled"}
	            }
	        }
	    
	    }
	    Process 
	    {
	    
	        Write-Verbose " [Get-SystemType] :: Process Start"
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        if(Test-Host $ComputerName -TCPPort 135)
	        {
	            try
	            {
	                Write-Verbose " [Get-SystemType] :: Getting System (Enclosure) Type info use WMI"
	                $SystemInfo = Get-WmiObject Win32_SystemEnclosure -ComputerName $ComputerName
	                $CSInfo = Get-WmiObject -Query "Select Model FROM Win32_ComputerSystem" -ComputerName $ComputerName
	                
	                Write-Verbose " [Get-SystemType] :: Creating Hash Table"
	                $myobj = @{}
	                Write-Verbose " [Get-SystemType] :: Setting ComputerName   - $ComputerName"
	                $myobj.ComputerName = $ComputerName
	                
	                Write-Verbose " [Get-SystemType] :: Setting Manufacturer   - $($SystemInfo.Manufacturer)"
	                $myobj.Manufacturer = $SystemInfo.Manufacturer
	                
	                Write-Verbose " [Get-SystemType] :: Setting Module   - $($CSInfo.Model)"
	                $myobj.Model = $CSInfo.Model
	                
	                Write-Verbose " [Get-SystemType] :: Setting SerialNumber   - $($SystemInfo.SerialNumber)"
	                $myobj.SerialNumber = $SystemInfo.SerialNumber
	                
	                Write-Verbose " [Get-SystemType] :: Setting SecurityStatus - $($SystemInfo.SecurityStatus)"
	                $myobj.SecurityStatus = ConvertTo-SecurityStatus $SystemInfo.SecurityStatus
	                
	                Write-Verbose " [Get-SystemType] :: Setting Type           - $($SystemInfo.ChassisTypes)"
	                $myobj.Type = ConvertTo-ChassisType $SystemInfo.ChassisTypes
	                
	                Write-Verbose " [Get-SystemType] :: Creating Custom Object"
	                $obj = New-Object PSCustomObject -Property $myobj
	                $obj.PSTypeNames.Clear()
	                $obj.PSTypeNames.Add('BSonPosh.SystemType')
	                $obj
	            }
	            catch
	            {
	                Write-Verbose " [Get-SystemType] :: [$ComputerName] Failed with Error: $($Error[0])" 
	            }
	        }
	    
	    }
	    
	}
	    
	#endregion 
	
	#region Get-RebootTime 
	
	function Get-RebootTime
	{
	    <#
	        .Synopsis 
	            Gets the reboot time for specified host.
	            
	        .Description
	            Gets the reboot time for specified host.
	            
	        .Parameter ComputerName
	            Name of the Computer to get the reboot time from (Default is localhost.)
	            
	        .Example
	            Get-RebootTime
	            Description
	            -----------
	            Gets OS Version from local     
	        
	        .Example
	            Get-RebootTime -Last
	            Description
	            -----------
	            Gets last reboot time from local machine
	
	        .Example
	            Get-RebootTime -ComputerName MyServer
	            Description
	            -----------
	            Gets reboot time from MyServer
	            
	        .Example
	            $Servers | Get-RebootTime
	            Description
	            -----------
	            Gets reboot time for each machine in the pipeline
	            
	        .OUTPUTS
	            PSCustomObject
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            N/A
	            
	        .Notes
	            NAME:      Get-RebootTime
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [cmdletbinding()]
	    Param(
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME,
	        
	        [Parameter()]
	        [Switch]$Last
	    )
	    process 
	    {
	    
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        if(Test-Host $ComputerName -TCPPort 135)
	        {
	            try
	            {
	                if($Last)
	                {
	                    $date = Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName -ea STOP | foreach{$_.LastBootUpTime}
	                    $RebootTime = [System.DateTime]::ParseExact($date.split('.')[0],'yyyyMMddHHmmss',$null)
	                    $myobj = @{}
	                    $myobj.ComputerName = $ComputerName
	                    $myobj.RebootTime = $RebootTime
	                    
	                    $obj = New-Object PSObject -Property $myobj
	                    $obj.PSTypeNames.Clear()
	                    $obj.PSTypeNames.Add('BSonPosh.RebootTime')
	                    $obj
	                }
	                else
	                {
	                    $Query = "Select * FROM Win32_NTLogEvent WHERE SourceName='eventlog' AND EventCode='6009'"
	                    Get-WmiObject -Query $Query -ea 0 -ComputerName $ComputerName | foreach {
	                        $myobj = @{}
	                        $RebootTime = [DateTime]::ParseExact($_.TimeGenerated.Split(".")[0],'yyyyMMddHHmmss',$null)
	                        $myobj.ComputerName = $ComputerName
	                        $myobj.RebootTime = $RebootTime
	                        
	                        $obj = New-Object PSObject -Property $myobj
	                        $obj.PSTypeNames.Clear()
	                        $obj.PSTypeNames.Add('BSonPosh.RebootTime')
	                        $obj
	                    }
	                }
	    
	            }
	            catch
	            {
	                Write-Host " Host [$ComputerName] Failed with Error: $($Error[0])" -ForegroundColor Red
	            }
	        }
	        else
	        {
	            Write-Host " Host [$ComputerName] Failed Connectivity Test " -ForegroundColor Red
	        }
	    
	    }
	}
	    
	#endregion 
	
	### BSONPOSH - KMS
	
	#region ConvertTo-KMSStatus 
	
	function ConvertTo-KMSStatus
	{
		[cmdletbinding()]
		Param(
			[Parameter(mandatory=$true)]
			[int]$StatusCode
		)
		switch -exact ($StatusCode)
		{
			0		{"Unlicensed"}
			1		{"Licensed"}
			2		{"OOBGrace"}
			3		{"OOTGrace"}
			4		{"NonGenuineGrace"}
			5		{"Notification"}
			6		{"ExtendedGrace"}
			default {"Unknown"}
		}
	}
	#endregion 
	
	#region Get-KMSActivationDetail 
	
	function Get-KMSActivationDetail
	{
	
	    <#
	        .Synopsis 
	            Gets the Activation Detail from the KMS Server.
	            
	        .Description
	            Gets the Activation Detail from the KMS Server.
	            
	        .Parameter KMS
	            KMS Server to connect to.
	            
	        .Parameter Filter
	            Filter for the Computers to get activation for.
	        
	        .Parameter After
	            The DateTime to start the query from. For example if I only want activations for the last thirty days:
	            the date time would be ((Get-Date).AddMonths(-1))
	            
	        .Parameter Unique
	            Only return Unique entries.
	            
	        .Example
	            Get-KMSActivationDetail -kms MyKMSServer
	            Description
	            -----------
	            Get all the activations for the target KMS server.
	            
	        .Example
	            Get-KMSActivationDetail -kms MyKMSServer -filter mypc
	            Description
	            -----------
	            Get all the activations for all the machines that are like "mypc" on the target KMS server.
	            
	        .Example
	            Get-KMSActivationDetail -kms MyKMSServer -After ((Get-Date).AddDays(-1))
	            Description
	            -----------
	            Get all the activations for the last day on the target KMS server.
	    
	        .Example
	            Get-KMSActivationDetail -kms MyKMSServer -unique
	            Description
	            -----------
	            Returns all the unique activate for the targeted KMS server.
	            
	        .OUTPUTS
	            PSCustomObject
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            Get-KMSServer
	            Get-KMSStatus
	            
	        .Notes
	            NAME:      Get-KMSActivationDetail
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	    
	        [Parameter(mandatory=$true)]
	        [string]$KMS,
	        
	        [Parameter()]
	        [string]$Filter="*",
	        
	        [Parameter()]
	        [datetime]$After,
	        
	        [Parameter()]
	        [switch]$Unique
	        
	    )
	    Write-Verbose " [Get-KMSActivationDetail] :: Cmdlet Start"
	    Write-Verbose " [Get-KMSActivationDetail] :: KMS Server   = $KMS"
	    Write-Verbose " [Get-KMSActivationDetail] :: Filter       = $Filter"
	    Write-Verbose " [Get-KMSActivationDetail] :: After Date   = $After"
	    Write-Verbose " [Get-KMSActivationDetail] :: Unique       = $Unique"
	    
	    if($After)
	    {
	        Write-Verbose " [Get-KMSActivationDetail] :: Processing Records after $After"
	        $Events = Get-Eventlog -LogName "Key Management Service" -ComputerName $KMS -After $After -Message "*$Filter*"
	    }
	    else
	    {
	        Write-Verbose " [Get-KMSActivationDetail] :: Processing Records"
	        $Events = Get-Eventlog -LogName "Key Management Service" -ComputerName $KMS -Message "*$Filter*"
	    }
	    
	    Write-Verbose " [Get-KMSActivationDetail] :: Creating Objects Collection"
	    $MyObjects = @()
	    
	    Write-Verbose " [Get-KMSActivationDetail] :: Processing {$($Events.count)} Events"
	    foreach($Event in $Events)
	    {
	        Write-Verbose " [Get-KMSActivationDetail] :: Creating Hash Table [$($Event.Index)]"
	        $Message = $Event.Message.Split(",")
	        
	        $myobj = @{}
	        Write-Verbose " [Get-KMSActivationDetail] :: Setting ComputerName to $($Message[3])"
	        $myobj.Computername = $Message[3]
	        Write-Verbose " [Get-KMSActivationDetail] :: Setting Date to $($Event.TimeGenerated)"
	        $myobj.Date = $Event.TimeGenerated
	        Write-Verbose " [Get-KMSActivationDetail] :: Creating Custom Object [$($Event.Index)]"
	        $MyObjects += New-Object PSObject -Property $myobj
	    }
	    
	    if($Unique)
	    {
	        Write-Verbose " [Get-KMSActivationDetail] :: Parsing out Unique Objects"
	        $UniqueObjects = $MyObjects | Group-Object -Property Computername
	        foreach($UniqueObject in $UniqueObjects)
	        {
	            $myobj = @{}
	            $myobj.ComputerName = $UniqueObject.Name
	            $myobj.Count = $UniqueObject.count
	    
	            $obj = New-Object PSObject -Property $myobj
	            $obj.PSTypeNames.Clear()
	            $obj.PSTypeNames.Add('BSonPosh.KMS.ActivationDetail')
	            $obj
	        }
	        
	    }
	    else
	    {
	        $MyObjects
	    }
	
	}
	#endregion 
	
	#region Get-KMSServer 
	
	function Get-KMSServer
	{
	    
	    <#
	        .Synopsis 
	            Gets the KMS Server.
	            
	        .Description
	            Gets a PSCustomObject (BSonPosh.KMS.Server) for the KMS Server.
	            
	        .Parameter KMS
	            KMS Server to get.
	            
	        .Example
	            Get-KMSServer -kms MyKMSServer
	            Description
	            -----------
	            Gets a KMS Server object for 'MyKMSServer'
	    
	        .OUTPUTS
	            PSCustomObject
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            Get-KMSActivationDetail
	            Get-KMSStatus
	            
	        .Notes
	            NAME:      Get-KMSServer
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$KMS
	    )
	    if(!$KMS)
	    {
	        Write-Verbose " [Get-KMSServer] :: No KMS Server Passed... Using Discovery"
	        $KMS = Test-KMSServerDiscovery | select -ExpandProperty ComputerName
	    }
	    try
	    {
	        Write-Verbose " [Get-KMSServer] :: Querying KMS Service using WMI"
	        $KMSService = Get-WmiObject "SoftwareLicensingService" -ComputerName $KMS
	        $myobj = @{
	            ComputerName            = $KMS
	            Version                 = $KMSService.Version
	            KMSEnable               = $KMSService.KeyManagementServiceActivationDisabled -eq $false
	            CurrentCount            = $KMSService.KeyManagementServiceCurrentCount
	            Port                    = $KMSService.KeyManagementServicePort
	            DNSPublishing           = $KMSService.KeyManagementServiceDnsPublishing
	            TotalRequest            = $KMSService.KeyManagementServiceTotalRequests
	            FailedRequest           = $KMSService.KeyManagementServiceFailedRequests
	            Unlicensed              = $KMSService.KeyManagementServiceUnlicensedRequests
	            Licensed                = $KMSService.KeyManagementServiceLicensedRequests
	            InitialGracePeriod      = $KMSService.KeyManagementServiceOOBGraceRequests
	            LicenseExpired          = $KMSService.KeyManagementServiceOOTGraceRequests
	            NonGenuineGracePeriod   = $KMSService.KeyManagementServiceNonGenuineGraceRequests
	            LicenseWithNotification = $KMSService.KeyManagementServiceNotificationRequests
	            ActivationInterval      = $KMSService.VLActivationInterval
	            RenewalInterval         = $KMSService.VLRenewalInterval
	        }
	    
	        $obj = New-Object PSObject -Property $myobj
	        $obj.PSTypeNames.Clear()
	        $obj.PSTypeNames.Add('BSonPosh.KMS.Server')
	        $obj
	    }
	    catch
	    {
	        Write-Verbose " [Get-KMSServer] :: Error: $($Error[0])"
	    }
	
	}
	#endregion 
	
	#region Get-KMSStatus 
	
	function Get-KMSStatus
	{
	
	    <#
	        .Synopsis 
	            Gets the KMS status from the Computer Name specified.
	            
	        .Description
	            Gets the KMS status from the Computer Name specified (Default local host.) Returns a custom object (BSonPosh.KMS.Status)
	            
	        .Parameter ComputerName
	            Computer to get the KMS Status for.
	        
	        .Example
	            Get-KMSStatus mypc
	            Description
	            -----------
	            Returns a KMS status object for Computer 'mypc'
	    
	        .OUTPUTS
	            PSCustomObject
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            Get-KMSActivationDetail
	            Get-KMSServer
	            
	        .Notes
	            NAME:      Get-KMSStatus
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	    )
	    Process 
	    {
	    
	        Write-Verbose " [Get-KMSStatus] :: Process Start"
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        $Query = "Select * FROM SoftwareLicensingProduct WHERE Description LIKE '%VOLUME_KMSCLIENT%'"
	        Write-Verbose " [Get-KMSStatus] :: ComputerName = $ComputerName"
	        Write-Verbose " [Get-KMSStatus] :: Query = $Query"
	        try
	        {
	            Write-Verbose " [Get-KMSStatus] :: Calling WMI"
	            $WMIResult = Get-WmiObject -ComputerName $ComputerName -query $Query
	            foreach($result in $WMIResult)
	            {
	                Write-Verbose " [Get-KMSStatus] :: Creating Hash Table"
	                $myobj = @{}
	                Write-Verbose " [Get-KMSStatus] :: Setting ComputerName to $ComputerName"
	                $myobj.ComputerName = $ComputerName
	                Write-Verbose " [Get-KMSStatus] :: Setting KMSServer to $($result.KeyManagementServiceMachine)"
	                $myobj.KMSServer = $result.KeyManagementServiceMachine
	                Write-Verbose " [Get-KMSStatus] :: Setting KMSPort to $($result.KeyManagementServicePort)"
	                $myobj.KMSPort = $result.KeyManagementServicePort
	                Write-Verbose " [Get-KMSStatus] :: Setting LicenseFamily to $($result.LicenseFamily)"
	                $myobj.LicenseFamily = $result.LicenseFamily
	                Write-Verbose " [Get-KMSStatus] :: Setting Status to $($result.LicenseStatus)"
	                $myobj.Status = ConvertTo-KMSStatus $result.LicenseStatus
	                Write-Verbose " [Get-KMSStatus] :: Creating Object"
	    
	                $obj = New-Object PSObject -Property $myobj
	                $obj.PSTypeNames.Clear()
	                $obj.PSTypeNames.Add('BSonPosh.KMS.Status')
	                $obj
	            }
	        }
	        catch
	        {
	            Write-Verbose " [Get-KMSStatus] :: Error - $($Error[0])"
	        }
	    
	    }
	
	}
	#endregion 
	
	#region Test-KMSIsActivated 
	
	function Test-KMSIsActivated 
	{
	        
	    <#
	        .Synopsis 
	            Test machine for activation.
	            
	        .Description
	            Test machine for activation.
	            
	        .Parameter ComputerName
	            Name of the Computer to test activation on (Default is localhost.)
	            
	        .Example
	            Test-KMSIsActivated
	            Description
	            -----------
	            Test activation on local machine
	    
	        .Example
	            Test-KMSIsActivated -ComputerName MyServer
	            Description
	            -----------
	            Test activation on MyServer
	            
	        .Example
	            $Servers | Test-KMSIsActivated
	            Description
	            -----------
	            Test activation for each machine in the pipeline
	            
	        .OUTPUTS
	            Object
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            N/A
	            
	        .Notes
	            NAME:      Test-KMSIsActivated
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	    
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	        
	    )
	    
	    Process 
	    {
	    
	        Write-Verbose " [Test-KMSActivation] :: Process start"
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        Write-Verbose " [Test-KMSActivation] :: ComputerName = $ComputerName"
	        if(Test-Host $ComputerName -TCP 135)
	        {
	            Write-Verbose " [Test-KMSActivation] :: Process start"
	            $status = Get-KMSStatus -ComputerName $ComputerName
	            if($status.Status -eq "Licensed")
	            {
	                $_
	            }
	        }
	    
	    }
	}
	    
	#endregion 
	
	#region Test-KMSServerDiscovery 
	
	function Test-KMSServerDiscovery
	{
	    
	    <#
	        .Synopsis 
	            Test KMS server discovery.
	            
	        .Description
	            Test KMS server discovery.
	            
	        .Parameter DNSSuffix
	            DNSSuffix to do discovery on.
	            
	        .Example
	            Test-KMSServerDiscovery
	            Description
	            -----------
	            Test KMS server discovery on local machine
	            
	        .OUTPUTS
	            PSCustomObject (BSonPosh.KMS.DiscoveryResult)
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            N/A
	            
	        .Notes
	            NAME:      Test-KMSServerDiscovery
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param($DNSSuffix)
	    
	    Write-Verbose " [Test-KMSServerDiscovery] :: cmdlet started"
	    Write-Verbose " [Test-KMSServerDiscovery] :: Getting dns primary suffix from registry"
	    if(!$DNSSuffix)
	    {
	        $key = get-item -path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters
	        $DNSSuffix = $key.GetValue("Domain")
	    }
	    Write-Verbose " [Test-KMSServerDiscovery] :: DNS Suffix = $DNSSuffix"
	    $record = "_vlmcs._tcp.${DNSSuffix}"
	    Write-Verbose " [Test-KMSServerDiscovery] :: SRV Record to query for = $record"
	    $NameRegEx = "\s+svr hostname   = (?<HostName>.*)$"
	    $PortRegEX = "\s+(port)\s+ = (?<Port>\d+)"
	    try
	    {
	        Write-Verbose " [Test-KMSServerDiscovery] :: Running nslookup"    
	        Write-Verbose " [Test-KMSServerDiscovery] :: Command - nslookup -type=srv $record 2>1 | select-string `"svr hostname`" -Context 4,0"
	        $results = nslookup -type=srv $record 2>1 | select-string "svr hostname" -Context 4,0
	        if($results)
	        {
	            Write-Verbose " [Test-KMSServerDiscovery] :: Found Entry: $Results"
	        }
	        else
	        {
	            Write-Verbose " [Test-KMSServerDiscovery] :: No Results found"
	            return
	        }
	        Write-Verbose " [Test-KMSServerDiscovery] :: Creating Hash Table"    
	        $myobj = @{}
	        switch -regex ($results -split "\n")
	        {
	            $NameRegEx  {
	                            Write-Verbose " [Test-KMSServerDiscovery] :: ComputerName = $($Matches.HostName)"    
	                            $myobj.ComputerName = $Matches.HostName
	                        }
	            $PortRegEX  {
	                            Write-Verbose " [Test-KMSServerDiscovery] :: IP = $($Matches.Port)"
	                            $myobj.Port = $Matches.Port
	                        }
	            Default     {
	                            Write-Verbose " [Test-KMSServerDiscovery] :: Processing line: $_"
	                        }
	        }
	        Write-Verbose " [Test-KMSServerDiscovery] :: Creating Object"
	        $obj = New-Object PSObject -Property $myobj
	        $obj.PSTypeNames.Clear()
	        $obj.PSTypeNames.Add('BSonPosh.KMS.DiscoveryResult')
	        $obj
	    }
	    catch
	    {
	        Write-Verbose " [Test-KMSServerDiscovery] :: Error: $($Error[0])"
	    }
	
	}
	#endregion 
	
	#region Test-KMSSupport 
	
	function Test-KMSSupport 
	{
	        
	    <#
	        .Synopsis 
	            Test machine for KMS Support.
	            
	        .Description
	            Test machine for KMS Support.
	            
	        .Parameter ComputerName
	            Name of the Computer to test KMS Support on (Default is localhost.)
	            
	        .Example
	            Test-KMSSupport
	            Description
	            -----------
	            Test KMS Support on local machine
	    
	        .Example
	            Test-KMSSupport -ComputerName MyServer
	            Description
	            -----------
	            Test KMS Support on MyServer
	            
	        .Example
	            $Servers | Test-KMSSupport
	            Description
	            -----------
	            Test KMS Support for each machine in the pipeline
	            
	        .OUTPUTS
	            Object
	            
	        .INPUTS
	            System.String
	            
	        .Link
	            N/A
	            
	        .Notes
	            NAME:      Test-KMSSupport
	            AUTHOR:    bsonposh
	            Website:   http://www.bsonposh.com
	            Version:   1
	            #Requires -Version 2.0
	    #>
	    
	    [Cmdletbinding()]
	    Param(
	    
	        [alias('dnsHostName')]
	        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName = $Env:COMPUTERNAME
	        
	    )
	    
	    Process 
	    {
	        Write-Verbose " [Test-KMSSupport] :: Process start"
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        Write-Verbose " [Test-KMSSupport] :: Testing Connectivity"
	        if(Test-Host -ComputerName $ComputerName -TCPPort 135)
	        {
	            $Query = "Select __CLASS FROM SoftwareLicensingProduct"
	            try
	            {
	                Write-Verbose " [Test-KMSSupport] :: Running WMI Query"
	                $Result = Get-WmiObject -Query $Query -ComputerName $ComputerName
	                Write-Verbose " [Test-KMSSupport] :: Result = $($Result.__CLASS)"
	                if($Result)
	                {
	                    Write-Verbose " [Test-KMSSupport] :: Return $_"
	                    $_
	                }
	            }
	            catch
	            {
	                Write-Verbose " [Test-KMSSupport] :: Error: $($Error[0])"
	            }
	        }
	        else
	        {
	            Write-Verbose " [Test-KMSSupport] :: Failed Connectivity Test"
	        }
	    
	    }
	}
	    
	#endregion 
	
	### IP Calculator - source: http://www.indented.co.uk/index.php/2010/01/23/powershell-subnet-math/
	
	#region ConvertTo-BinaryIP
	function ConvertTo-BinaryIP {
	  <#
	    .Synopsis
	      Converts a Decimal IP address into a binary format.
	    .Description
	      ConvertTo-BinaryIP uses System.Convert to switch between decimal and binary format. The output from this function is dotted binary.
	    .Parameter IPAddress
	      An IP Address to convert.
	  #>
	 
	  [CmdLetBinding()]
	  Param(
	    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
	    [Net.IPAddress]$IPAddress
	  )
	 
	  Process {
	    Return [String]::Join('.', $( $IPAddress.GetAddressBytes() |
	      ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') } ))
	  }
	}
	#endregion ConvertTo-BinaryIP
	
	#region ConvertTo-DecimalIP
	function ConvertTo-DecimalIP {
	  <#
	    .Synopsis
	      Converts a Decimal IP address into a 32-bit unsigned integer.
	    .Description
	      ConvertTo-DecimalIP takes a decimal IP, uses a shift-like operation on each octet and returns a single UInt32 value.
	    .Parameter IPAddress
	      An IP Address to convert.
	  #>
	 
	  [CmdLetBinding()]
	  Param(
	    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
	    [Net.IPAddress]$IPAddress
	  )
	 
	  Process {
	    $i = 3; $DecimalIP = 0;
	    $IPAddress.GetAddressBytes() | ForEach-Object { $DecimalIP += $_ * [Math]::Pow(256, $i); $i-- }
	 
	    Return [UInt32]$DecimalIP
	  }
	}
	#endregion ConvertTo-DecimalIP
	
	#region ConvertTo-DottedDecimalIP
	function ConvertTo-DottedDecimalIP {
	  <#
	    .Synopsis
	      Returns a dotted decimal IP address from either an unsigned 32-bit integer or a dotted binary string.
	    .Description
	      ConvertTo-DottedDecimalIP uses a regular expression match on the input string to convert to an IP address.
	    .Parameter IPAddress
	      A string representation of an IP address from either UInt32 or dotted binary.
	  #>
	 
	  [CmdLetBinding()]
	  Param(
	    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
	    [String]$IPAddress
	  )
	 
	  Process {
	    Switch -RegEx ($IPAddress) {
	      "([01]{8}\.){3}[01]{8}" {
	        Return [String]::Join('.', $( $IPAddress.Split('.') | ForEach-Object { [Convert]::ToUInt32($_, 2) } ))
	      }
	      "\d" {
	        $IPAddress = [UInt32]$IPAddress
	        $DottedIP = $( For ($i = 3; $i -gt -1; $i--) {
	          $Remainder = $IPAddress % [Math]::Pow(256, $i)
	          ($IPAddress - $Remainder) / [Math]::Pow(256, $i)
	          $IPAddress = $Remainder
	         } )
	 
	        Return [String]::Join('.', $DottedIP)
	      }
	      default {
	        Write-Error "Cannot convert this format"
	      }
	    }
	  }
	}
	#endregion ConvertTo-DottedDecimalIP
	
	#region ConvertTo-MaskLength
	function ConvertTo-MaskLength {
	  <#
	    .Synopsis
	      Returns the length of a subnet mask.
	    .Description
	      ConvertTo-MaskLength accepts any IPv4 address as input, however the output value
	      only makes sense when using a subnet mask.
	    .Parameter SubnetMask
	      A subnet mask to convert into length
	  #>
	 
	  [CmdLetBinding()]
	  Param(
	    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
	    [Alias("Mask")]
	    [Net.IPAddress]$SubnetMask
	  )
	 
	  Process {
	    $Bits = "$( $SubnetMask.GetAddressBytes() | ForEach-Object { [Convert]::ToString($_, 2) } )" -Replace '[\s0]'
	 
	    Return $Bits.Length
	  }
	}
	#endregion ConvertTo-MaskLength
	
	#region ConvertTo-Mask
	function ConvertTo-Mask {
	  <#
	    .Synopsis
	      Returns a dotted decimal subnet mask from a mask length.
	    .Description
	      ConvertTo-Mask returns a subnet mask in dotted decimal format from an integer value ranging
	      between 0 and 32. ConvertTo-Mask first creates a binary string from the length, converts
	      that to an unsigned 32-bit integer then calls ConvertTo-DottedDecimalIP to complete the operation.
	    .Parameter MaskLength
	      The number of bits which must be masked.
	  #>
	 
	  [CmdLetBinding()]
	  Param(
	    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
	    [Alias("Length")]
	    [ValidateRange(0, 32)]
	    $MaskLength
	  )
	 
	  Process {
	    Return ConvertTo-DottedDecimalIP ([Convert]::ToUInt32($(("1" * $MaskLength).PadRight(32, "0")), 2))
	  }
	}
	#endregion ConvertTo-Mask
	
	#region Get-NetworkAddress
	function Get-NetworkAddress {
	  <#
	    .Synopsis
	      Takes an IP address and subnet mask then calculates the network address for the range.
	    .Description
	      Get-NetworkAddress returns the network address for a subnet by performing a bitwise AND
	      operation against the decimal forms of the IP address and subnet mask. Get-NetworkAddress
	      expects both the IP address and subnet mask in dotted decimal format.
	    .Parameter IPAddress
	      Any IP address within the network range.
	    .Parameter SubnetMask
	      The subnet mask for the network.
	  #>
	 
	  [CmdLetBinding()]
	  Param(
	    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
	    [Net.IPAddress]$IPAddress,
	 
	    [Parameter(Mandatory = $True, Position = 1)]
	    [Alias("Mask")]
	    [Net.IPAddress]$SubnetMask
	  )
	 
	  Process {
	    Return ConvertTo-DottedDecimalIP ((ConvertTo-DecimalIP $IPAddress) -BAnd (ConvertTo-DecimalIP $SubnetMask))
	  }
	}
	#endregion Get-NetworkAddress
	
	#region Get-BroadcastAddress
	function Get-BroadcastAddress {
	  <#
	    .Synopsis
	      Takes an IP address and subnet mask then calculates the broadcast address for the range.
	    .Description
	      Get-BroadcastAddress returns the broadcast address for a subnet by performing a bitwise AND
	      operation against the decimal forms of the IP address and inverted subnet mask.
	      Get-BroadcastAddress expects both the IP address and subnet mask in dotted decimal format.
	    .Parameter IPAddress
	      Any IP address within the network range.
	    .Parameter SubnetMask
	      The subnet mask for the network.
	  #>
	 
	  [CmdLetBinding()]
	  Param(
	    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
	    [Net.IPAddress]$IPAddress, 
	 
	    [Parameter(Mandatory = $True, Position = 1)]
	    [Alias("Mask")]
	    [Net.IPAddress]$SubnetMask
	  )
	 
	  Process {
	    Return ConvertTo-DottedDecimalIP $((ConvertTo-DecimalIP $IPAddress) -BOr `
	      ((-BNot (ConvertTo-DecimalIP $SubnetMask)) -BAnd [UInt32]::MaxValue))
	  }
	}
	#endregion Get-BroadcastAddress
	
	#region Get-NetworkSummary
	function Get-NetworkSummary ( [String]$IP, [String]$Mask ) {
	  If ($IP.Contains("/"))
	  {
	    $Temp = $IP.Split("/")
	    $IP = $Temp[0]
	    $Mask = $Temp[1]
	  }
	 
	  If (!$Mask.Contains("."))
	  {
	    $Mask = ConvertTo-Mask $Mask
	  }
	 
	  $DecimalIP = ConvertTo-DecimalIP $IP
	  $DecimalMask = ConvertTo-DecimalIP $Mask
	 
	  $Network = $DecimalIP -BAnd $DecimalMask
	  $Broadcast = $DecimalIP -BOr
	    ((-BNot $DecimalMask) -BAnd [UInt32]::MaxValue)
	  $NetworkAddress = ConvertTo-DottedDecimalIP $Network
	  $RangeStart = ConvertTo-DottedDecimalIP ($Network + 1)
	  $RangeEnd = ConvertTo-DottedDecimalIP ($Broadcast - 1)
	  $BroadcastAddress = ConvertTo-DottedDecimalIP $Broadcast
	  $MaskLength = ConvertTo-MaskLength $Mask
	 
	  $BinaryIP = ConvertTo-BinaryIP $IP; $Private = $False
	  Switch -RegEx ($BinaryIP)
	  {
	    "^1111"  { $Class = "E"; $SubnetBitMap = "1111" }
	    "^1110"  { $Class = "D"; $SubnetBitMap = "1110" }
	    "^110"   {
	      $Class = "C"
	      If ($BinaryIP -Match "^11000000.10101000") { $Private = $True } }
	    "^10"    {
	      $Class = "B"
	      If ($BinaryIP -Match "^10101100.0001") { $Private = $True } }
	    "^0"     {
	      $Class = "A"
	      If ($BinaryIP -Match "^00001010") { $Private = $True } }
	   }   
	 
	  $NetInfo = New-Object Object
	  Add-Member NoteProperty "Network" -Input $NetInfo -Value $NetworkAddress
	  Add-Member NoteProperty "Broadcast" -Input $NetInfo -Value $BroadcastAddress
	  Add-Member NoteProperty "Range" -Input $NetInfo `
	    -Value "$RangeStart - $RangeEnd"
	  Add-Member NoteProperty "Mask" -Input $NetInfo -Value $Mask
	  Add-Member NoteProperty "MaskLength" -Input $NetInfo -Value $MaskLength
	  Add-Member NoteProperty "Hosts" -Input $NetInfo `
	    -Value $($Broadcast - $Network - 1)
	  Add-Member NoteProperty "Class" -Input $NetInfo -Value $Class
	  Add-Member NoteProperty "IsPrivate" -Input $NetInfo -Value $Private
	 
	  Return $NetInfo
	}
	#endregion Get-NetworkSummary
	
	#region Get-NetworkRange
	function Get-NetworkRange( [String]$IP, [String]$Mask ) {
	  If ($IP.Contains("/"))
	  {
	    $Temp = $IP.Split("/")
	    $IP = $Temp[0]
	    $Mask = $Temp[1]
	  }
	 
	  If (!$Mask.Contains("."))
	  {
	    $Mask = ConvertTo-Mask $Mask
	  }
	 
	  $DecimalIP = ConvertTo-DecimalIP $IP
	  $DecimalMask = ConvertTo-DecimalIP $Mask
	 
	  $Network = $DecimalIP -BAnd $DecimalMask
	  $Broadcast = $DecimalIP -BOr ((-BNot $DecimalMask) -BAnd [UInt32]::MaxValue)
	 
	  For ($i = $($Network + 1); $i -lt $Broadcast; $i++) {
	    ConvertTo-DottedDecimalIP $i
	  }
	}
	#endregion Get-NetworkRange
	
	### Technet Functions http://technet.com
	
	#region Test-Server
	#http://gallery.technet.microsoft.com/scriptcenter/Powershell-Test-Server-e0cdea9a
	function Test-Server{
	[cmdletBinding()]
	param(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[string[]]$ComputerName,
		[parameter(Mandatory=$false)]
		[switch]$CredSSP,
		[Management.Automation.PSCredential] $Credential)
		
	begin{
		$total = Get-Date
		$results = @()
		if($credssp){if(!($credential)){Write-Host "must supply Credentials with CredSSP test";break}}
	}
	process{
	    foreach($name in $computername)
	    {
		$dt = $cdt= Get-Date
		Write-verbose "Testing: $Name"
		$failed = 0
		try{
		$DNSEntity = [Net.Dns]::GetHostEntry($name)
		$domain = ($DNSEntity.hostname).replace("$name.","")
		$ips = $DNSEntity.AddressList | %{$_.IPAddressToString}
		}
		catch
		{
			$rst = "" |  select Name,IP,Domain,Ping,WSMAN,CredSSP,RemoteReg,RPC,RDP
			$rst.name = $name
			$results += $rst
			$failed = 1
		}
		Write-verbose "DNS:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"
		if($failed -eq 0){
		foreach($ip in $ips)
		{
		    
			$rst = "" |  select Name,IP,Domain,Ping,WSMAN,CredSSP,RemoteReg,RPC,RDP
		    $rst.name = $name
			$rst.ip = $ip
			$rst.domain = $domain
			####RDP Check (firewall may block rest so do before ping
			try{
	            $socket = New-Object Net.Sockets.TcpClient($name, 3389)
			  if($socket -eq $null)
			  {
				 $rst.RDP = $false
			  }
			  else
			  {
				 $rst.RDP = $true
				 $socket.close()
			  }
	       }
	       catch
	       {
	            $rst.RDP = $false
	       }
			Write-verbose "RDP:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"
	        #########ping
		    if(test-connection $ip -count 1 -Quiet)
		    {
		        Write-verbose "PING:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"
				$rst.ping = $true
				try{############wsman
					Test-WSMan $ip | Out-Null
					$rst.WSMAN = $true
					}
				catch
					{$rst.WSMAN = $false}
					Write-verbose "WSMAN:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"
				if($rst.WSMAN -and $credssp) ########### credssp
				{
					try{
						Test-WSMan $ip -Authentication Credssp -Credential $cred
						$rst.CredSSP = $true
						}
					catch
						{$rst.CredSSP = $false}
					Write-verbose "CredSSP:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"
				}
				try ########remote reg
				{
					[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ip) | Out-Null
					$rst.remotereg = $true
				}
				catch
					{$rst.remotereg = $false}
				Write-verbose "remote reg:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"
				try ######### wmi
				{	
					$w = [wmi] ''
					$w.psbase.options.timeout = 15000000
					$w.path = "\\$Name\root\cimv2:Win32_ComputerSystem.Name='$Name'"
					$w | select none | Out-Null
					$rst.RPC = $true
				}
				catch
					{$rst.rpc = $false}
				Write-verbose "WMI:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)" 
		    }
			else
			{
				$rst.ping = $false
				$rst.wsman = $false
				$rst.credssp = $false
				$rst.remotereg = $false
				$rst.rpc = $false
			}
			$results += $rst	
		}}
		Write-Verbose "Time for $($Name): $((New-TimeSpan $cdt ($dt)).totalseconds)"
		Write-Verbose "----------------------------"
	}
	}
	end{
		Write-Verbose "Time for all: $((New-TimeSpan $total ($dt)).totalseconds)"
		Write-Verbose "----------------------------"
	return $results
	}
	}
	#endregion
	
	#region Get-IpConfig
	# ==========================================================
	# Get-IPConfig.ps1
	# Made By : Assaf Miron
	#  http://assaf.miron.googlepages.com
	# Description : Formats the IP Config information into powershell
	# ==========================================================
	function Get-IPConfig{
		param ( $Computername="LocalHost",
	 	$OnlyConnectedNetworkAdapters=$true
	   )
			gwmi -Class Win32_NetworkAdapterConfiguration -ComputerName $ComputerName | Where { $_.IPEnabled -eq $OnlyConnectedNetworkAdapters } | Format-List @{ Label="Computer Name"; Expression= { $_.__SERVER }}, IPEnabled, Description, MACAddress, IPAddress, IPSubnet, DefaultIPGateway, DHCPEnabled, DHCPServer, @{ Label="DHCP Lease Expires"; Expression= { [dateTime]$_.DHCPLeaseExpires }}, @{ Label="DHCP Lease Obtained"; Expression= { [dateTime]$_.DHCPLeaseObtained }}
	}
	#endregion
	
	#region get-iisProperties http://gallery.technet.microsoft.com/scriptcenter/20a73ee4-5b17-49e8-8c33-3e08fd066af2
	function get-iisProperties {  
		<#    
		.SYNOPSIS    
		    Retrieves IIS properties for Virtual and Web Directories residing on a server. 
		.DESCRIPTION  
		    Retrieves IIS properties for Virtual and Web Directories residing on a server. 
		.PARAMETER name 
		    Name of the IIS server you wish to query.  
		.PARAMETER UseDefaultCredentials  
		    Use the currently authenticated user's credentials    
		.NOTES    
		    Name: Get-iisProperties 
		    Author: Marc Carter 
		    DateCreated: 18Mar2011          
		.EXAMPLE    
		    Get-iisProperties -ComputerName "localhost"  
		      
		Description  
		------------  
		Returns IIS properties for Virtual and Web Directories residing on a server.  
		#>   
		[cmdletbinding(  
		    DefaultParameterSetName = 'ComputerName',  
		    ConfirmImpact = 'low'  
		)]  
		Param(  
		    [Parameter(  
		        Mandatory = $True,  
		        Position = 0,  
		        ParameterSetName = '',  
		        ValueFromPipeline = $True)]  
		        [string][ValidatePattern(".{2,}")]$ComputerName 
		)  
		    Begin{       
		        $error.clear() 
		        $ComputerName = $ComputerName.toUpper() 
		        $array = @() 
		    } 
		 
		    Process{ 
		        #define ManagementObjectSearcher, Path and Authentication 
		        $objWMI = [WmiSearcher] "Select * From IIsWebServer" 
		        $objWMI.Scope.Path = "\\$ComputerName\root\microsoftiisv2" 
		        $objWMI.Scope.Options.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy 
		        $ComputerName 
		 
		        trap { 'An Error occured: {0}' -f $_.Exception.Message; break } 
		 
		        #Get System.Management.ManagementObjectCollection 
		        $obj = $objWMI.Get() 
		     
		        #Iterate through each object 
		        $obj | % {  
		            $Identifier = $_.Name 
		            [string]$adsiPath = "IIS://$ComputerName/"+$_.name 
		            $iis = [adsi]$("IIS://$ComputerName/"+$_.name) 
		            #Enum Child Items but only IIsWebVirtualDir & IIsWebDirectory 
		            $iis.Psbase.Children | where { $_.SchemaClassName -eq "IIsWebVirtualDir" -or $_.SchemaClassName -eq "IIsWebDirectory" } | % { 
		                $currentPath = $adsiPath+"/"+$_.Name 
		                #Enum Subordinate Child Items  
		                $_.Psbase.Children | where { $_.SchemaClassName -eq "IIsWebVirtualDir" } | Select Name, AppPoolId, SchemaClassName, Path | % { 
		                    $subIIS = [adsi]$("$currentPath/"+$_.name) 
		                    foreach($mapping in $subIIS.ScriptMaps){ 
		                        if($mapping.StartsWith(".aspx")){ $NETversion = $mapping.substring(($mapping.toLower()).indexOf("framework\")+10,9) } 
		                    } 
		                    #Define System.Object | add member properties 
		                    $tmpObj = New-Object Object 
		                    $tmpObj | add-member -membertype noteproperty -name "Name" -value $_.Name 
		                    $tmpObj | add-member -membertype noteproperty -name "Identifier" -value $Identifier 
		                    $tmpObj | add-member -membertype noteproperty -name "ASP.NET" -value $NETversion 
		                    $tmpObj | add-member -membertype noteproperty -name "AppPoolId" -value $($_.AppPoolId) 
		                    $tmpObj | add-member -membertype noteproperty -name "SchemaClassName" -value $_.SchemaClassName 
		                    $tmpObj | add-member -membertype noteproperty -name "Path" -value $($_.Path) 
		                     
		                    #Populate Array with Object properties 
		                    $array += $tmpObj 
		                } 
		            } 
		        } 
		    }#End process 
		    End{ 
		        #Display results 
		        $array | ft -auto 
		    } 
		}#End function Get-IISProperties
	#endregion
	
	#region Get-USB
	
	function Get-USB {
	    <#
	    .Synopsis
	        Gets USB devices attached to the system
	    .Description
	        Uses WMI to get the USB Devices attached to the system
	    .Example
	        Get-USB
	    .Example
	        Get-USB | Group-Object Manufacturer  
	    .Parameter ComputerName
	        The name of the computer to get the USB devices from
	    #>
	    param($computerName = "localhost")
	    Get-WmiObject Win32_USBControllerDevice -ComputerName $ComputerName `
	        -Impersonation Impersonate -Authentication PacketPrivacy | 
	        Foreach-Object { [Wmi]$_.Dependent }
	}
	#endregion
	
	#region Get-ComputerComment
	#http://gallery.technet.microsoft.com/5c5bb1f7-519b-43b3-9d3a-dce8b9390244
	function Get-ComputerComment( $ComputerName ) 
	{ 
		$Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey( "LocalMachine", $ComputerName ) 
	    if ( $Registry -eq $Null ) { 
	        return "Can't connect to the registry"
	    } 
	    $RegKey= $Registry.OpenSubKey( "SYSTEM\CurrentControlSet\Services\lanmanserver\parameters" ) 
	    if ( $RegKey -eq $Null ) { 
	        return "No Computer Description"
	    } 
	 
	    [string]$Description = $RegKey.GetValue("srvcomment") 
	    if ( $Description -eq $Null ) { 
	        $Description = "No Computer Description" 
	    } 
	    return "Computer Description: $Description "
	} 
	#endregion
	
	#region Set-ComputerComment
	#http://gallery.technet.microsoft.com/5c5bb1f7-519b-43b3-9d3a-dce8b9390244
	function Set-ComputerComment 
	{
		param(
		[string]$ComputerName,
		[string]$Description
		)
	    # $OsInfo = Get-WmiObject Win32_OperatingSystem -Computer $Computer 
	    # $Description  = $OsInfo 
	    $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey( "LocalMachine", $ComputerName ) 
	    if ( $Registry -eq $Null ) { 
	        return $Null 
	    } 
	    $RegPermCheck = [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree  
	    $RegKeyRights = [System.Security.AccessControl.RegistryRights]::SetValue 
	    $RegKey = $Registry.OpenSubKey( "SYSTEM\CurrentControlSet\Services\lanmanserver\parameters", $RegPermCheck, $RegKeyRights )
	    if ( $RegKey -eq $Null ) { 
	        return $Null 
	    }
	    $RegKey.SetValue("srvcomment", $Description ) 
	} 
	#endregion
	
	#region Get-DnsDomain
	function Get-DnsDomain()
	#http://gallery.technet.microsoft.com/5c5bb1f7-519b-43b3-9d3a-dce8b9390244
	{ 
		# --------------------------------------------------------- 
		# Get the name of the domain this computer belongs to. 
		# --------------------------------------------------------- 
	    if ( $Global:DnsDomain -eq $null ) { 
	        $WmiInfo = get-wmiobject "Win32_NTDomain" | where {$_.DnsForestName -ne $null } 
	        $Global:DnsDomain = $WmiInfo.DnsForestName 
	    } 
	    return $Global:DnsDomain 
	} 
	#endregion
	
	#region Get-AdDomainPath
	function Get-AdDomainPath()
	#http://gallery.technet.microsoft.com/5c5bb1f7-519b-43b3-9d3a-dce8b9390244
	{ 
	    $DnsDomain = Get-DnsDomain 
	    $Tokens = $DnsDomain.Split(".") 
	    $Seperator= "" 
	    $Path = "" 
	    foreach ( $Token in $Tokens ) 
	    {     
	        $Path+= $Seperator 
	        $Path+= "DC=" 
	        $Path+= $Token 
	        $Seperator = "," 
	    } 
	    return $Path 
	} 
	#endregion
	
	#region Get-ComputerAdDescription
	#http://gallery.technet.microsoft.com/5c5bb1f7-519b-43b3-9d3a-dce8b9390244
	function Get-ComputerAdDescription( $ComputerName ) 
	{ 
	    $Path = Get-AdDomainPath
	    $Dom = "LDAP://" + $Path 
	    $Root = New-Object DirectoryServices.DirectoryEntry $Dom  
	     
	    # Create a selector and start searching from the root 
	    $Selector = New-Object DirectoryServices.DirectorySearcher 
	    $Selector.SearchRoot = $Root  
	    $Selector.Filter = "(objectclass=computer)"; 
	 
	    $AdObjects = $Selector.findall() | where {$_.properties.cn -match $ComputerName  } 
	 
	    if ( !$AdObject -is [System.DirectoryServices.SearchResult] ) { 
	        return $Null 
	    } 
	 
	    $Description = $AdObjects.Properties["description"] 
	 
	    return $Description 
	} 
	#endregion
	
	#region Show-MsgBox
	<# 
	            .SYNOPSIS  
	            Shows a graphical message box, with various prompt types available. 
	 
	            .DESCRIPTION 
	            Emulates the Visual Basic MsgBox function.  It takes four parameters, of which only the prompt is mandatory 
	 
	            .INPUTS 
	            The parameters are:- 
	             
	            Prompt (mandatory):  
	                Text string that you wish to display 
	                 
	            Title (optional): 
	                The title that appears on the message box 
	                 
	            Icon (optional).  Available options are: 
	                Information, Question, Critical, Exclamation (not case sensitive) 
	                
	            BoxType (optional). Available options are: 
	                OKOnly, OkCancel, AbortRetryIgnore, YesNoCancel, YesNo, RetryCancel (not case sensitive) 
	                 
	            DefaultButton (optional). Available options are: 
	                1, 2, 3 
	 
	            .OUTPUTS 
	            Microsoft.VisualBasic.MsgBoxResult 
	 
	            .EXAMPLE 
	            C:\PS> Show-MsgBox Hello 
	            Shows a popup message with the text "Hello", and the default box, icon and defaultbutton settings. 
	 
	            .EXAMPLE 
	            C:\PS> Show-MsgBox -Prompt "This is the prompt" -Title "This Is The Title" -Icon Critical -BoxType YesNo -DefaultButton 2 
	            Shows a popup with the parameter as supplied. 
	 
	            .LINK 
	            http://msdn.microsoft.com/en-us/library/microsoft.visualbasic.msgboxresult.aspx 
	 
	            .LINK 
	            http://msdn.microsoft.com/en-us/library/microsoft.visualbasic.msgboxstyle.aspx 
	            #> 
	# By BigTeddy August 24, 2011 
	# http://social.technet.microsoft.com/profile/bigteddy/. 
	 
	function Show-MsgBox 
	{ 
	 
	 [CmdletBinding()] 
	    param( 
	    [Parameter(Position=0, Mandatory=$true)] [string]$Prompt, 
	    [Parameter(Position=1, Mandatory=$false)] [string]$Title ="", 
	    [Parameter(Position=2, Mandatory=$false)] [ValidateSet("Information", "Question", "Critical", "Exclamation")] [string]$Icon ="Information", 
	    [Parameter(Position=3, Mandatory=$false)] [ValidateSet("OKOnly", "OKCancel", "AbortRetryIgnore", "YesNoCancel", "YesNo", "RetryCancel")] [string]$BoxType ="OkOnly", 
	    [Parameter(Position=4, Mandatory=$false)] [ValidateSet(1,2,3)] [int]$DefaultButton = 1 
	    ) 
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null 
	switch ($Icon) { 
	            "Question" {$vb_icon = [microsoft.visualbasic.msgboxstyle]::Question } 
	            "Critical" {$vb_icon = [microsoft.visualbasic.msgboxstyle]::Critical} 
	            "Exclamation" {$vb_icon = [microsoft.visualbasic.msgboxstyle]::Exclamation} 
	            "Information" {$vb_icon = [microsoft.visualbasic.msgboxstyle]::Information}} 
	switch ($BoxType) { 
	            "OKOnly" {$vb_box = [microsoft.visualbasic.msgboxstyle]::OKOnly} 
	            "OKCancel" {$vb_box = [microsoft.visualbasic.msgboxstyle]::OkCancel} 
	            "AbortRetryIgnore" {$vb_box = [microsoft.visualbasic.msgboxstyle]::AbortRetryIgnore} 
	            "YesNoCancel" {$vb_box = [microsoft.visualbasic.msgboxstyle]::YesNoCancel} 
	            "YesNo" {$vb_box = [microsoft.visualbasic.msgboxstyle]::YesNo} 
	            "RetryCancel" {$vb_box = [microsoft.visualbasic.msgboxstyle]::RetryCancel}} 
	switch ($Defaultbutton) { 
	            1 {$vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton1} 
	            2 {$vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton2} 
	            3 {$vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton3}} 
	$popuptype = $vb_icon -bor $vb_box -bor $vb_defaultbutton 
	$ans = [Microsoft.VisualBasic.Interaction]::MsgBox($prompt,$popuptype,$title) 
	return $ans 
	} #end
	#endregion
	
	#region Run-RemoteCMD
	#http://gallery.technet.microsoft.com/scriptcenter/56962f03-0243-4c83-8cdd-88c37898ccc4
	function Run-RemoteCMD { 
	    param( 
	    [Parameter(Mandatory=$true,valuefrompipeline=$true)] 
	    [string]$ComputerName,
		[string]$Command)
	    begin { 
	        
	        [string]$cmd = "CMD.EXE /C " +$command 
	                        } 
	    process { 
	        $newproc = Invoke-WmiMethod -class Win32_process -name Create -ArgumentList ($cmd) -ComputerName $ComputerName 
	        if ($newproc.ReturnValue -eq 0 ) 
	                { Write-Output " Command $($command) invoked Sucessfully on $($ComputerName)" } 
	                # if command is sucessfully invoked it doesn't mean that it did what its supposed to do 
	                #it means that the command only sucessfully ran on the cmd.exe of the server 
	                #syntax errors can occur due to user input  
	    } 
	    End{Write-Output "Script ...END"}
	}
	#endregion
	
	# Lee Holmes - http://www.leeholmes.com
	
	#region Test-PSRemoting
	
	function Test-PSRemoting 
	{ 
	    Param(
	        [alias('dnsHostName')]
	        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	        [string]$ComputerName
	    )
	    Process
	    {
	        Write-Verbose " [Test-PSRemoting] :: Start Process"
	        if($ComputerName -match "(.*)(\$)$")
	        {
	            $ComputerName = $ComputerName -replace "(.*)(\$)$",'$1'
	        }
	        
	        try 
	        { 
	            
	            $result = Invoke-Command -ComputerName $computername { 1 } -ErrorAction SilentlyContinue
	            
	            if($result -eq 1 )
	            {
	                return $True
	            }
	            else
	            {
	                return $False
	            }
	        } 
	        catch 
	        { 
	            return $False 
	        } 
	    }
	} 
	
	#endregion
	
	# Sapien Forum
	
	#region Show-InputBox
	#http://www.sapien.com/forums/scriptinganswers/forum_posts.asp?TID=2890
	#$c=Show-Inputbox -message "Enter a computername" -title "Computername" -default $env:Computername
	#
	#if ($c.Trim()) {
	#  Get-WmiObject win32_computersystem -computer $c
	#  }
	Function Show-InputBox {
	 Param([string]$message=$(Throw "You must enter a prompt message"),
	       [string]$title="Input",
	       [string]$default
	       )
	       
	 [reflection.assembly]::loadwithpartialname("microsoft.visualbasic") | Out-Null
	 [microsoft.visualbasic.interaction]::InputBox($message,$title,$default)
	 
	}
	#endregion
	
	
#endregion

#region Call-About_pff
function Call-About_pff
{
	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	[void][reflection.assembly]::Load("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$form_Author = New-Object 'System.Windows.Forms.Form'
	$labelLastUpdateApplicatio = New-Object 'System.Windows.Forms.Label'
	$labelAbout = New-Object 'System.Windows.Forms.Label'
	$linklabel_Twitter = New-Object 'System.Windows.Forms.LinkLabel'
	$labelTwitter = New-Object 'System.Windows.Forms.Label'
	$labelLazyWinAdminIsAPower = New-Object 'System.Windows.Forms.Label'
	$labelAuthorName = New-Object 'System.Windows.Forms.Label'
	$labelEmail = New-Object 'System.Windows.Forms.Label'
	$linklabel_Blog = New-Object 'System.Windows.Forms.LinkLabel'
	$label_Blog = New-Object 'System.Windows.Forms.Label'
	$linklabel_Email = New-Object 'System.Windows.Forms.LinkLabel'
	$label_Author = New-Object 'System.Windows.Forms.Label'
	$button_AuthorOK = New-Object 'System.Windows.Forms.Button'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	function OnApplicationLoad {
		#Note: This function runs before the form is created
		#Note: To get the script directory in the Packager use: Split-Path $hostinvocation.MyCommand.path
		#Note: To get the console output in the Packager (Windows Mode) use: $ConsoleOutput (Type: System.Collections.ArrayList)
		#Important: Form controls cannot be accessed in this function
		#TODO: Add snapins and custom code to validate the application load	
		return $true #return true for success or false for failure
	}
	
	function OnApplicationExit {
		#Note: This function runs after the form is closed
		#TODO: Add custom code to clean up and unload snapins when the application exits
		
		$script:ExitCode = 0 #Set the exit code for the Packager
	}
	
	$FormEvent_Load={
		#TODO: Initialize Form Controls here
		$linklabel_Blog.text = $AuthorBlogName
		$linklabel_Email.Text = $AuthorEmail
	}
	
	$linklabel_AuthorBlog_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
		[System.Diagnostics.Process]::Start("$AuthorBlogURL")
	}
	
	$linklabel_AuthorEmail_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
		[System.Diagnostics.Process]::Start("mailto:$authoremail?subject=$AuthorBlogName")
	}
	
	$linklabel_Twitter_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
		[System.Diagnostics.Process]::Start("$global:AuthorTwitterURL")
	}	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$form_Author.WindowState = $InitialFormWindowState
	}
	
	$Form_StoreValues_Closing=
	{
		#Store the control values
	}

	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$linklabel_Twitter.remove_LinkClicked($linklabel_Twitter_LinkClicked)
			$linklabel_Blog.remove_LinkClicked($linklabel_AuthorBlog_LinkClicked)
			$linklabel_Email.remove_LinkClicked($linklabel_AuthorEmail_LinkClicked)
			$form_Author.remove_Load($FormEvent_Load)
			$form_Author.remove_Load($Form_StateCorrection_Load)
			$form_Author.remove_Closing($Form_StoreValues_Closing)
			$form_Author.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch [Exception]
		{ }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	#
	# form_Author
	#
	$form_Author.Controls.Add($labelLastUpdateApplicatio)
	$form_Author.Controls.Add($labelAbout)
	$form_Author.Controls.Add($linklabel_Twitter)
	$form_Author.Controls.Add($labelTwitter)
	$form_Author.Controls.Add($labelLazyWinAdminIsAPower)
	$form_Author.Controls.Add($labelAuthorName)
	$form_Author.Controls.Add($labelEmail)
	$form_Author.Controls.Add($linklabel_Blog)
	$form_Author.Controls.Add($label_Blog)
	$form_Author.Controls.Add($linklabel_Email)
	$form_Author.Controls.Add($label_Author)
	$form_Author.Controls.Add($button_AuthorOK)
	$form_Author.AcceptButton = $button_AuthorOK
	$form_Author.ClientSize = '290, 264'
	$form_Author.FormBorderStyle = 'FixedDialog'
	$form_Author.MaximizeBox = $False
	$form_Author.MinimizeBox = $False
	$form_Author.Name = "form_Author"
	$form_Author.Text = "Author"
	$form_Author.add_Load($FormEvent_Load)
	#
	# labelLastUpdateApplicatio
	#
	$labelLastUpdateApplicatio.Font = "Microsoft Sans Serif, 8.25pt, style=Bold"
	$labelLastUpdateApplicatio.Location = '21, 32'
	$labelLastUpdateApplicatio.Name = "labelLastUpdateApplicatio"
	$labelLastUpdateApplicatio.Size = '242, 23'
	$labelLastUpdateApplicatio.TabIndex = 11
	$labelLastUpdateApplicatio.Text = "Last Update: $ApplicationLastUpdate"
	#
	# labelAbout
	#
	$labelAbout.Font = "Microsoft Sans Serif, 8.25pt, style=Bold"
	$labelAbout.Location = '21, 9'
	$labelAbout.Name = "labelAbout"
	$labelAbout.Size = '242, 23'
	$labelAbout.TabIndex = 10
	$labelAbout.Text = "$ApplicationName $ApplicationVersion"
	#
	# linklabel_Twitter
	#
	$linklabel_Twitter.Location = '78, 206'
	$linklabel_Twitter.Name = "linklabel_Twitter"
	$linklabel_Twitter.Size = '185, 23'
	$linklabel_Twitter.TabIndex = 9
	$linklabel_Twitter.TabStop = $True
	$linklabel_Twitter.Text = "$AuthorTwitter"
	$linklabel_Twitter.add_LinkClicked($linklabel_Twitter_LinkClicked)
	#
	# labelTwitter
	#
	$labelTwitter.Location = '21, 206'
	$labelTwitter.Name = "labelTwitter"
	$labelTwitter.Size = '43, 23'
	$labelTwitter.TabIndex = 8
	$labelTwitter.Text = "Twitter"
	#
	# labelLazyWinAdminIsAPower
	#
	$labelLazyWinAdminIsAPower.Location = '21, 61'
	$labelLazyWinAdminIsAPower.Name = "labelLazyWinAdminIsAPower"
	$labelLazyWinAdminIsAPower.Size = '244, 67'
	$labelLazyWinAdminIsAPower.TabIndex = 7
	$labelLazyWinAdminIsAPower.Text = "LazyWinAdmin is a PowerShell Script.

The GUI/WinForm that was created using Sapien Powershell Studio 2012."
	#
	# labelAuthorName
	#
	$labelAuthorName.Location = '78, 137'
	$labelAuthorName.Name = "labelAuthorName"
	$labelAuthorName.Size = '198, 23'
	$labelAuthorName.TabIndex = 6
	$labelAuthorName.Text = "$AuthorName"
	#
	# labelEmail
	#
	$labelEmail.Location = '21, 160'
	$labelEmail.Name = "labelEmail"
	$labelEmail.Size = '51, 23'
	$labelEmail.TabIndex = 5
	$labelEmail.Text = "Email"
	#
	# linklabel_Blog
	#
	$linklabel_Blog.Location = '78, 183'
	$linklabel_Blog.Name = "linklabel_Blog"
	$linklabel_Blog.Size = '187, 23'
	$linklabel_Blog.TabIndex = 4
	$linklabel_Blog.TabStop = $True
	$linklabel_Blog.Text = "$AuthorBlogURL"
	$linklabel_Blog.add_LinkClicked($linklabel_AuthorBlog_LinkClicked)
	#
	# label_Blog
	#
	$label_Blog.Location = '21, 183'
	$label_Blog.Name = "label_Blog"
	$label_Blog.Size = '43, 23'
	$label_Blog.TabIndex = 3
	$label_Blog.Text = "Blog:"
	#
	# linklabel_Email
	#
	$linklabel_Email.Location = '78, 160'
	$linklabel_Email.Name = "linklabel_Email"
	$linklabel_Email.Size = '187, 23'
	$linklabel_Email.TabIndex = 1
	$linklabel_Email.TabStop = $True
	$linklabel_Email.Text = "$AuthorEmail"
	$linklabel_Email.add_LinkClicked($linklabel_AuthorEmail_LinkClicked)
	#
	# label_Author
	#
	$label_Author.Location = '21, 137'
	$label_Author.Name = "label_Author"
	$label_Author.Size = '43, 23'
	$label_Author.TabIndex = 2
	$label_Author.Text = "Author:"
	#
	# button_AuthorOK
	#
	$button_AuthorOK.DialogResult = 'OK'
	$button_AuthorOK.Location = '106, 234'
	$button_AuthorOK.Name = "button_AuthorOK"
	$button_AuthorOK.Size = '75, 23'
	$button_AuthorOK.TabIndex = 0
	$button_AuthorOK.Text = "OK"
	$button_AuthorOK.UseVisualStyleBackColor = $True
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $form_Author.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$form_Author.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$form_Author.add_FormClosed($Form_Cleanup_FormClosed)
	#Store the control values when form is closing
	$form_Author.add_Closing($Form_StoreValues_Closing)
	#Show the Form
	return $form_Author.ShowDialog()

}
#endregion

#region Call-MainForm_pff
function Call-MainForm_pff
{
	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	[void][reflection.assembly]::Load("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Design, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$form_MainForm = New-Object 'System.Windows.Forms.Form'
	$richtextbox_output = New-Object 'System.Windows.Forms.RichTextBox'
	$panel_RTBButtons = New-Object 'System.Windows.Forms.Panel'
	$button_formExit = New-Object 'System.Windows.Forms.Button'
	$button_outputClear = New-Object 'System.Windows.Forms.Button'
	$button_ExportRTF = New-Object 'System.Windows.Forms.Button'
	$button_outputCopy = New-Object 'System.Windows.Forms.Button'
	$tabcontrol_computer = New-Object 'System.Windows.Forms.TabControl'
	$tabpage_general = New-Object 'System.Windows.Forms.TabPage'
	$groupbox_InternetExplorer = New-Object 'System.Windows.Forms.GroupBox'
	$button_HTTP = New-Object 'System.Windows.Forms.Button'
	$button_FTP = New-Object 'System.Windows.Forms.Button'
	$button_IEHPHomepage = New-Object 'System.Windows.Forms.Button'
	$button_HTTPS = New-Object 'System.Windows.Forms.Button'
	$button_IEDellOpenManage = New-Object 'System.Windows.Forms.Button'
	$buttonSendCommand = New-Object 'System.Windows.Forms.Button'
	$groupbox_ManagementConsole = New-Object 'System.Windows.Forms.GroupBox'
	$button_mmcCompmgmt = New-Object 'System.Windows.Forms.Button'
	$buttonServices = New-Object 'System.Windows.Forms.Button'
	$buttonShares = New-Object 'System.Windows.Forms.Button'
	$buttonEventVwr = New-Object 'System.Windows.Forms.Button'
	$button_GPupdate = New-Object 'System.Windows.Forms.Button'
	$button_Applications = New-Object 'System.Windows.Forms.Button'
	$button_ping = New-Object 'System.Windows.Forms.Button'
	$button_remot = New-Object 'System.Windows.Forms.Button'
	$buttonRemoteAssistance = New-Object 'System.Windows.Forms.Button'
	$button_PsRemoting = New-Object 'System.Windows.Forms.Button'
	$buttonC = New-Object 'System.Windows.Forms.Button'
	$button_networkconfig = New-Object 'System.Windows.Forms.Button'
	$button_Restart = New-Object 'System.Windows.Forms.Button'
	$button_Shutdown = New-Object 'System.Windows.Forms.Button'
	$tabpage_ComputerOSSystem = New-Object 'System.Windows.Forms.TabPage'
	$groupbox_UsersAndGroups = New-Object 'System.Windows.Forms.GroupBox'
	$button_UsersGroupLocalUsers = New-Object 'System.Windows.Forms.Button'
	$button_UsersGroupLocalGroups = New-Object 'System.Windows.Forms.Button'
	$groupbox_software = New-Object 'System.Windows.Forms.GroupBox'
	$groupbox_ComputerDescription = New-Object 'System.Windows.Forms.GroupBox'
	$button_ComputerDescriptionChange = New-Object 'System.Windows.Forms.Button'
	$button_ComputerDescriptionQuery = New-Object 'System.Windows.Forms.Button'
	$groupbox2 = New-Object 'System.Windows.Forms.GroupBox'
	$buttonReportingEventslog = New-Object 'System.Windows.Forms.Button'
	$button_HotFix = New-Object 'System.Windows.Forms.Button'
	$buttonWindowsUpdateLog = New-Object 'System.Windows.Forms.Button'
	$groupbox_RemoteDesktop = New-Object 'System.Windows.Forms.GroupBox'
	$button_RDPDisable = New-Object 'System.Windows.Forms.Button'
	$button_RDPEnable = New-Object 'System.Windows.Forms.Button'
	$buttonApplications = New-Object 'System.Windows.Forms.Button'
	$button_PageFile = New-Object 'System.Windows.Forms.Button'
	$button_HostsFile = New-Object 'System.Windows.Forms.Button'
	$button_StartupCommand = New-Object 'System.Windows.Forms.Button'
	$groupbox_Hardware = New-Object 'System.Windows.Forms.GroupBox'
	$button_MotherBoard = New-Object 'System.Windows.Forms.Button'
	$button_Processor = New-Object 'System.Windows.Forms.Button'
	$button_Memory = New-Object 'System.Windows.Forms.Button'
	$button_SystemType = New-Object 'System.Windows.Forms.Button'
	$button_Printers = New-Object 'System.Windows.Forms.Button'
	$button_USBDevices = New-Object 'System.Windows.Forms.Button'
	$tabpage_network = New-Object 'System.Windows.Forms.TabPage'
	$button_ConnectivityTesting = New-Object 'System.Windows.Forms.Button'
	$button_NIC = New-Object 'System.Windows.Forms.Button'
	$button_networkIPConfig = New-Object 'System.Windows.Forms.Button'
	$button_networkTestPort = New-Object 'System.Windows.Forms.Button'
	$button_networkRouteTable = New-Object 'System.Windows.Forms.Button'
	$tabpage_processes = New-Object 'System.Windows.Forms.TabPage'
	$buttonCommandLineGridView = New-Object 'System.Windows.Forms.Button'
	$button_processAll = New-Object 'System.Windows.Forms.Button'
	$buttonCommandLine = New-Object 'System.Windows.Forms.Button'
	$groupbox1 = New-Object 'System.Windows.Forms.GroupBox'
	$textbox_processName = New-Object 'System.Windows.Forms.TextBox'
	$label_processEnterAProcessName = New-Object 'System.Windows.Forms.Label'
	$button_processTerminate = New-Object 'System.Windows.Forms.Button'
	$button_process100MB = New-Object 'System.Windows.Forms.Button'
	$button_ProcessGrid = New-Object 'System.Windows.Forms.Button'
	$button_processOwners = New-Object 'System.Windows.Forms.Button'
	$button_processLastHour = New-Object 'System.Windows.Forms.Button'
	$tabpage_services = New-Object 'System.Windows.Forms.TabPage'
	$button_servicesNonStandardUser = New-Object 'System.Windows.Forms.Button'
	$button_mmcServices = New-Object 'System.Windows.Forms.Button'
	$button_servicesAutoNotStarted = New-Object 'System.Windows.Forms.Button'
	$groupbox_Service_QueryStartStop = New-Object 'System.Windows.Forms.GroupBox'
	$textbox_servicesAction = New-Object 'System.Windows.Forms.TextBox'
	$button_servicesRestart = New-Object 'System.Windows.Forms.Button'
	$label_servicesEnterAServiceName = New-Object 'System.Windows.Forms.Label'
	$button_servicesQuery = New-Object 'System.Windows.Forms.Button'
	$button_servicesStart = New-Object 'System.Windows.Forms.Button'
	$button_servicesStop = New-Object 'System.Windows.Forms.Button'
	$button_servicesRunning = New-Object 'System.Windows.Forms.Button'
	$button_servicesAll = New-Object 'System.Windows.Forms.Button'
	$button_servicesGridView = New-Object 'System.Windows.Forms.Button'
	$button_servicesAutomatic = New-Object 'System.Windows.Forms.Button'
	$tabpage_diskdrives = New-Object 'System.Windows.Forms.TabPage'
	$button_DiskUsage = New-Object 'System.Windows.Forms.Button'
	$button_DiskPhysical = New-Object 'System.Windows.Forms.Button'
	$button_DiskPartition = New-Object 'System.Windows.Forms.Button'
	$button_DiskLogical = New-Object 'System.Windows.Forms.Button'
	$button_DiskMountPoint = New-Object 'System.Windows.Forms.Button'
	$button_DiskRelationship = New-Object 'System.Windows.Forms.Button'
	$button_DiskMappedDrive = New-Object 'System.Windows.Forms.Button'
	$tabpage_shares = New-Object 'System.Windows.Forms.TabPage'
	$button_mmcShares = New-Object 'System.Windows.Forms.Button'
	$button_SharesGrid = New-Object 'System.Windows.Forms.Button'
	$button_Shares = New-Object 'System.Windows.Forms.Button'
	$tabpage_eventlog = New-Object 'System.Windows.Forms.TabPage'
	$button_RebootHistory = New-Object 'System.Windows.Forms.Button'
	$button_mmcEvents = New-Object 'System.Windows.Forms.Button'
	$button_EventsSearch = New-Object 'System.Windows.Forms.Button'
	$button_EventsLogNames = New-Object 'System.Windows.Forms.Button'
	$button_EventsLast20 = New-Object 'System.Windows.Forms.Button'
	$tabpage_ExternalTools = New-Object 'System.Windows.Forms.TabPage'
	$groupbox3 = New-Object 'System.Windows.Forms.GroupBox'
	$label_SYDI = New-Object 'System.Windows.Forms.Label'
	$combobox_sydi_format = New-Object 'System.Windows.Forms.ComboBox'
	$textbox_sydi_arguments = New-Object 'System.Windows.Forms.TextBox'
	$button_SYDIGo = New-Object 'System.Windows.Forms.Button'
	$button_Rwinsta = New-Object 'System.Windows.Forms.Button'
	$button_Qwinsta = New-Object 'System.Windows.Forms.Button'
	$button_MsInfo32 = New-Object 'System.Windows.Forms.Button'
	$button_Telnet = New-Object 'System.Windows.Forms.Button'
	$button_DriverQuery = New-Object 'System.Windows.Forms.Button'
	$button_SystemInfoexe = New-Object 'System.Windows.Forms.Button'
	$button_PAExec = New-Object 'System.Windows.Forms.Button'
	$button_psexec = New-Object 'System.Windows.Forms.Button'
	$textbox_networktracertparam = New-Object 'System.Windows.Forms.TextBox'
	$button_networkTracert = New-Object 'System.Windows.Forms.Button'
	$button_networkNsLookup = New-Object 'System.Windows.Forms.Button'
	$button_networkPing = New-Object 'System.Windows.Forms.Button'
	$textbox_networkpathpingparam = New-Object 'System.Windows.Forms.TextBox'
	$textbox_pingparam = New-Object 'System.Windows.Forms.TextBox'
	$button_networkPathPing = New-Object 'System.Windows.Forms.Button'
	$groupbox_ComputerName = New-Object 'System.Windows.Forms.GroupBox'
	$label_UptimeStatus = New-Object 'System.Windows.Forms.Label'
	$textbox_computername = New-Object 'System.Windows.Forms.TextBox'
	$label_OSStatus = New-Object 'System.Windows.Forms.Label'
	$button_Check = New-Object 'System.Windows.Forms.Button'
	$label_PingStatus = New-Object 'System.Windows.Forms.Label'
	$label_Ping = New-Object 'System.Windows.Forms.Label'
	$label_PSRemotingStatus = New-Object 'System.Windows.Forms.Label'
	$label_Uptime = New-Object 'System.Windows.Forms.Label'
	$label_RDPStatus = New-Object 'System.Windows.Forms.Label'
	$label_OS = New-Object 'System.Windows.Forms.Label'
	$label_PermissionStatus = New-Object 'System.Windows.Forms.Label'
	$label_Permission = New-Object 'System.Windows.Forms.Label'
	$label_PSRemoting = New-Object 'System.Windows.Forms.Label'
	$label_RDP = New-Object 'System.Windows.Forms.Label'
	$richtextbox_Logs = New-Object 'System.Windows.Forms.RichTextBox'
	$statusbar1 = New-Object 'System.Windows.Forms.StatusBar'
	$menustrip_principal = New-Object 'System.Windows.Forms.MenuStrip'
	$ToolStripMenuItem_AdminArsenal = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_CommandPrompt = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_Powershell = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_Notepad = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_RemoteDesktopConnection = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_localhost = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_compmgmt = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_taskManager = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_services = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_regedit = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_mmc = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_shutdownGui = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_registeredSnappins = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_about = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_AboutInfo = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$contextmenustripServer = New-Object 'System.Windows.Forms.ContextMenuStrip'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Tools = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_ConsolesMMC = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Ping = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_RDP = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_compmgmt = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_services = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_eventvwr = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_InternetExplorer = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_TerminalAdmin = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_ADSearchDialog = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_ADPrinters = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_netstatsListening = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_systemInformationMSinfo32exe = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_otherLocalTools = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_addRemovePrograms = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_administrativeTools = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_authprizationManager = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_certificateManager = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_devicemanager = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_addRemoveProgramsWindowsFeatures = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$toolstripseparator1 = New-Object 'System.Windows.Forms.ToolStripSeparator'
	$toolstripseparator3 = New-Object 'System.Windows.Forms.ToolStripSeparator'
	$ToolStripMenuItem_systemproperties = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$toolstripseparator4 = New-Object 'System.Windows.Forms.ToolStripSeparator'
	$toolstripseparator5 = New-Object 'System.Windows.Forms.ToolStripSeparator'
	$ToolStripMenuItem_Wordpad = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_sharedFolders = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_performanceMonitor = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_networkConnections = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_groupPolicyEditor = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_localUsersAndGroups = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_diskManagement = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_localSecuritySettings = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_componentServices = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_scheduledTasks = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_PowershellISE = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_hostsFile = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_netstat = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$errorprovider1 = New-Object 'System.Windows.Forms.ErrorProvider'
	$tooltipinfo = New-Object 'System.Windows.Forms.ToolTip'
	$ToolStripMenuItem_sysInternals = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_adExplorer = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_hostsFileGetContent = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Qwinsta = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_rwinsta = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_GeneratePassword = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_scripts = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripMenuItem_WMIExplorer = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$imagelistAnimation = New-Object 'System.Windows.Forms.ImageList'
	$timerCheckJob = New-Object 'System.Windows.Forms.Timer'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	#################################
	######### CONFIGURATION #########
	#################################
	
	# LazyAdminKit information
	$ApplicationName		= "LazyWinAdmin"
	$ApplicationVersion		= "0.4"
	$ApplicationLastUpdate	= "2012/06/14"
	
	# Author Information
	$AuthorName			= "Francois-Xavier Cat"
	$AuthorEmail 		= "info@lazywinadmin.com"
	$AuthorBlogName 	= "LazyWinAdmin.com"
	$AuthorBlogURL 		= "http://www.lazywinadmin.com"
	$AuthorTwitter 		= "@LazyWinAdm"
	$AuthorTwitterURL	= "http://twitter.com/LazyWinAdm"
	
	# Text to show in the Status Bar when the form load
	$StatusBarStartUp	= "$AuthorName - $AuthorEmail"
	
	# Title of the MainForm
	$domain				= $env:userdomain.ToUpper()
	$MainFormTitle 		= "$ApplicationName $ApplicationVersion - Last Update: $ApplicationLastUpdate - $domain\$env:username"
	
	# Default Error Action
	$ErrorActionPreference 	= "SilentlyContinue"
	
	# Script Paths
	$ScriptPath 	= Split-Path $hostinvocation.MyCommand.path
	$ToolsFolder 	= $ScriptPath + "tools"
	$ScriptsFolder 	= $ScriptPath + "scripts"
	$SavePath 		= $env:userprofile + "\desktop"
	
	#reset Error
	$error = ""
	
	# Computers List Source
	#$ComputersList_File = "$pwd\computers.txt"
	Set-Location $ScriptPath
	$ComputersList_File = $ScriptPath + "computers.txt"
	$ComputersList	= Get-Content $ComputersList_File
	
	# RichTextBox OUTPUT form
	#  Output Default Parameters
	$richtextbox_output_DefaultFontFamily="Lucida Console"
	$richtextbox_output_DefaultFontSize="8"
	$richtextbox_output_DefaultFont = New-Object System.Drawing.Font ($richtextbox_output_DefaultFontFamily,$richtextbox_output_DefaultFontSize)
	#$global:richtextbox_output_DefaultFont.Bold = $false
	
	#  Title Default Parameters
	$richtextbox_output_TitleFontFamily="Lucida Console"
	$richtextbox_output_TitleFontSize="10"
	$richtextbox_output_TitleFont = New-Object System.Drawing.Font ($richtextbox_output_TitleFontFamily,$richtextbox_output_TitleFontSize)
	#$global:richtextbox_output_TitleFont.Bold = $true
	
	# RichTextBox LOGS form
	#  Message to show when the form load
	$RichTexBoxLogsDefaultMessage="Welcome on $ApplicationName $LAKVersion - Visit my Blog: $AuthorBlogURL"
	
	# Current Operating System Information
	$current_OS 			= Get-WmiObject Win32_OperatingSystem
	$current_OS_caption 	= $current_OS.caption
	
	# Background Jobs
	$JobTrackerList = New-Object System.Collections.ArrayList
	
	###############
	$OnLoadFormEvent={
		# Set the status bar name
		$statusbar1.Text = $StatusBarStartUp
		
		
		$form_MainForm.Text = $MainFormTitle
		$textbox_computername.Text = $env:COMPUTERNAME
		Add-Logs -text $RichTexBoxLogsDefaultMessage
		
		# Load the Computers list from $ComputersList
		if (Test-Path $ComputersList_File){
			Add-logs -text "Computers List loaded - $($ComputersList.Count) Items - File: $ComputersList_File" -ErrorAction 'SilentlyContinue'
			$textbox_computername.AutoCompleteCustomSource.AddRange($ComputersList)
			}#end if (Test-Path $ComputersList
			else {
				Add-Logs -text "No Computers List found at the following location: $ComputersList_File"  -ErrorAction 'SilentlyContinue'
			}
		
		# Verify External Tools are presents
		
		# PSExec.exe
		if(Test-Path "$ToolsFolder\psexec.exe" -ErrorAction 'SilentlyContinue'){
			$button_psexec.ForeColor = 'green'
			Add-Logs -text "External Tools check - PsExec.exe found" -ErrorAction 'SilentlyContinue'}
		else {$button_psexec.ForeColor = 'Red';$button_psexec.enabled = $false;Add-Logs -text "External Tools check - PsExec.exe not found - Button Disabled"  -ErrorAction 'SilentlyContinue'}
		
		# PAExec.exe
		if(Test-Path "$ToolsFolder\paexec.exe" -ErrorAction 'SilentlyContinue' ){
			$button_PAExec.ForeColor = 'Green'
			Add-Logs -text "External Tools check - PAExec.exe found" -ErrorAction 'SilentlyContinue'}
		else {$button_PAExec.ForeColor = 'Red';$button_paexec.enabled = $false;Add-Logs -text "External Tools check - PsExec.exe not found - Button Disabled"  -ErrorAction 'SilentlyContinue'}
		
		# ADExplorer.exe
		if(Test-Path "$ToolsFolder\adexplorer.exe" -ErrorAction 'SilentlyContinue'){
			$ToolStripMenuItem_adExplorer.ForeColor = 'Green'
			Add-Logs -text "External Tools check - ADExplorer.exe found" -ErrorAction 'SilentlyContinue'}
		else {$ToolStripMenuItem_adExplorer.enabled = $false;Add-Logs -text "External Tools check - ADExplorer.exe not found - Button Disabled"  -ErrorAction 'SilentlyContinue'}
		
		# MSRA.exe (Remote Assistance)
		if(Test-Path "$env:systemroot/system32/msra.exe" -ErrorAction 'SilentlyContinue'){
			Add-Logs -text "External Tools check - MSRA.exe found" -ErrorAction 'SilentlyContinue'}
		else {$buttonRemoteAssistance.enabled = $false;Add-Logs -text "External Tools check - MSRA.exe not found (Remote Assistance) - Button Disabled" -ErrorAction 'SilentlyContinue'}
		
		# Telnet.exe
		if(Test-Path "$env:systemroot/system32/telnet.exe" -ErrorAction 'SilentlyContinue'){
			Add-Logs -text "External Tools check - Telnet.exe found" -ErrorAction 'SilentlyContinue'}
		else {$button_Telnet.enabled = $false;Add-Logs -text "External Tools check - Telnet.exe not found - Button Disabled" -ErrorAction 'SilentlyContinue'}
		
		# SystemInfo.exe
		if(Test-Path "$env:systemroot/system32/systeminfo.exe" -ErrorAction 'SilentlyContinue'){
			Add-Logs -text "External Tools check - Systeminfo.exe found"}
		else {$button_SystemInfoexe.enabled = $false;Add-Logs -text "External Tools check - Systeminfo.exe not found - Button Disabled"}
		
		# MSInfo32.exe
		if(Test-Path "$env:programfiles\Common Files\Microsoft Shared\MSInfo\msinfo32.exe" -ErrorAction 'SilentlyContinue'){
			Add-Logs -text "External Tools check - msinfo32.exe found"}
		else {$button_MsInfo32.enabled = $false;Add-Logs -text "External Tools check - msinfo32.exe not found - Button Disabled"}
		
		# DriverQuery.exe
			if(Test-Path "$env:systemroot/system32/driverquery.exe" -ErrorAction 'SilentlyContinue'){
			Add-Logs -text "External Tools check - Driverquery.exe found"}
		else {$button_DriverQuery.enabled = $false;Add-Logs -text "External Tools check - Driverquery.exe not found - Button Disabled"}
		
		# SCRIPTS
		
		# WMIExplore.ps1 - http://thepowershellguy.com
		if(Test-Path "$ScriptsFolder\WMIExplorer.ps1" -ErrorAction 'SilentlyContinue'){
			$ToolStripMenuItem_WMIExplorer.ForeColor = 'green'
			Add-Logs -text "External Script check - WMIExplorer.ps1 found"}
		else {	$ToolStripMenuItem_WMIExplorer.ForeColor = 'Red';$ToolStripMenuItem_WMIExplorer.enabled = $false
				Add-Logs -text "External Script check - WMIExplorer.ps1 not found - Button Disabled"}
		
		# SYDI-Server.vbs - http://sydiproject.com/
		if(Test-Path "$ScriptsFolder\sydi-server.vbs" -ErrorAction 'SilentlyContinue'){
			$button_SYDIGo.ForeColor = 'green'
			Add-Logs -text "External Script check - Sydi-Server.vbs found"}
		else {
			$button_SYDIGo.enabled = $false
			$combobox_sydi_format.Enabled = $false
			$textbox_sydi_arguments.Enabled = $false
			Add-Logs -text "External Script check - Sydi-Server.vbs not found - Button Disabled"}
	}
	
	
	# TIMERS
	$timerCheckJob_Tick={
		Update-JobTracker
	}
	
	$timerCheckJob_Tick2={
		#Check if the process stopped
		if($timerCheckJob.Tag -ne $null)
		{		
			if($timerCheckJob.Tag.State -ne 'Running')
			{
				#Stop the Timer
				$buttonStart.ImageIndex = -1
				$buttonStart.Enabled = $true	
				$buttonStart.Visible = $true
				$timerCheckJob.Tag = $null
				$timerCheckJob.Stop()
			}
			else
			{
				if($buttonStart.ImageIndex -lt $buttonStart.ImageList.Images.Count - 1)
				{
					$buttonStart.ImageIndex += 1
				}
				else
				{
					$buttonStart.ImageIndex = 0		
				}
			}
		}
	}
	
	
	
	
	$ToolStripMenuItem_CommandPrompt_Click={Start-Process cmd.exe}
	$ToolStripMenuItem_Notepad_Click={Start-Process notepad.exe}
	$ToolStripMenuItem_Powershell_Click={start-process powershell.exe -verb runas}
	$ToolStripMenuItem_compmgmt_Click={compmgmt.msc}
	$ToolStripMenuItem_taskManager_Click={Taskmgr}
	$ToolStripMenuItem_services_Click={services.msc}
	$ToolStripMenuItem_regedit_Click={regedit}
	$ToolStripMenuItem_mmc_Click={mmc}
	$ToolStripMenuItem_shutdownGui_Click={Start-Process shutdown.exe -ArgumentList /i}
	
	$button_ping_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Test-Connection"
		$button_ping.Enabled = $False
		start-process ping -ArgumentList $($textbox_computername.Text),-t;
		#$result = Test-Connection -ComputerName $ComputerName -Count 1
		#Add-RichTextBox	 $result
		$button_ping.Enabled = $true
	}
	
	$button_remot_Click={
		Get-ComputerTxtBox
		add-logs -text "$ComputerName - Remote Desktop Connection"
		$port=":3389"
		$command = "mstsc"
		$argument = "/v:$computername$port /admin"
		Start-Process $command $argument
	}
	
	$ToolStripMenuItem_registeredSnappins_Click={
		add-logs -text "Localhost - Registered Snappin"
		$snappins = Get-PSSnapin -Registered |Out-String
		if ($snappins -eq ""){Add-RichTextBox "No Powershell Snappin registered"}
		$richtextbox_output.SelectionBackColor = [System.Drawing.Color]::black
		$richtextbox_output.SelectionColor = [System.Drawing.Color]::Red
		Add-RichTextBox $snappins
	}
	
	$button_outputClear_Click={Clear-RichTextBox}
	$ToolStripMenuItem_AboutInfo_Click={Call-About_pff}
	
	$button_mmcCompmgmt_Click={
		
		Get-ComputerTxtBox
		#disable the button to avoid multiple click
		$button_mmcCompmgmt.Enabled = $false
		if (($ComputerName -like "localhost") -or ($ComputerName -like ".") -or ($ComputerName -like "127.0.0.1") -or ($ComputerName -like "$env:computername")) {
			Add-logs -text "Localhost - Computer Management MMC (compmgmt.msc)"
			$command="compmgmt.msc"
			Start-Process $command 
			}
		else {
			Add-logs -text "$ComputerName - Computer Management MMC (compmgmt.msc /computer:$Computername)"
			$command="compmgmt.msc"
			$arguments = "/computer:$computername"
			Start-Process $command $arguments}
		#Enable the button
		$button_mmcCompmgmt.Enabled = $true
	}
	
	$ToolStripMenuItem_RemoteDesktopConnection_Click={Start-Process mstsc}
	$ToolStripMenuItem_InternetExplorer_Click={Start-Process iexplore}
	$button_Shares_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Shares list"
		$SharesList = Get-WmiObject win32_share -computer $ComputerName|Sort-Object name|Format-Table -AutoSize| Out-String -Width $richtextbox_output.Width
		Add-RichTextBox -text $SharesList
		}
	
	$button_formExit_Click={
		$ExitConfirmation = Show-MsgBox -Prompt "Do you really want to Exit ?" -Title "$ApplicationName $ApplicationVersion - Exit" -BoxType YesNo
		if ($ExitConfirmation -eq "YES"){$form_MainForm.Close()}
	}
	
	$button_mmcServices_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Services MMC (services.msc /computer:$ComputerName)"
		$command = "services.msc"
		$arguments = "/computer:$computername"
		Start-Process $command $arguments 
	}
	
	$button_servicesRunning_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Services - Status: Running"
		if ($ComputerName -eq "localhost") {$ComputerName = "."}
		$Services_running = Get-Service -ComputerName $ComputerName| Where-Object { $_.Status -eq "Running" }|Format-Table -AutoSize |Out-String
		Add-RichTextBox -text $Services_running
	}
	
	$button_process100MB_Click={
		#Clear-RichTextBox
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Processes >100MB"
		if ($ComputerName -eq "localhost") {$ComputerName = "."}
		$owners = @{}
		Get-WmiObject win32_process -ComputerName $ComputerName |% {$owners[$_.handle] = $_.getowner().user}
		$Processes_Over100MB = Get-Process -ComputerName $ComputerName| Where-Object { $_.WorkingSet -gt 100mb }|Select-Object Handles,NPM,PM,WS,VM,CPU,ID,ProcessName,@{l="Owner";e={$owners[$_.id.tostring()]}}|sort ws|ft -AutoSize|Out-String
		Add-RichTextBox $Processes_Over100MB
	}
	
	$button_mmcEvents_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Event Viewer MMC (eventvwr $Computername)"
		$command="eventvwr"
		$arguments = "$ComputerName"
		Start-Process $command $arguments
	}
	
	$button_EventsLast20_Click={
		#Clear-RichTextBox
		Get-ComputerTxtBox
		Add-Logs "$ComputerName - EventLog - Last 20"
		if ($ComputerName -like "localhost"){
			$Events_Last20Sytem = Get-EventLog -Newest 20 | Select-Object Index,EventID,Source,Message,MachineName,UserName,TimeGenerated,TimeWritten |Format-List|Out-String
		Add-RichTextBox $Events_Last20Sytem
		}
		else {
		$Events_Last20Sytem = Get-EventLog -Newest 20 -ComputerName $ComputerName | Select-Object Index,EventID,Source,Message,MachineName,UserName,TimeGenerated,TimeWritten |Format-List|Out-String
		Add-RichTextBox $Events_Last20Sytem}
		
	}
	
	
	
	$button_EventsSearch_Click={
		#Clear-RichTextBox
		Get-ComputerTxtBox
		Add-Logs "$ComputerName - EventLog - Search"
		if ($ComputerName -like "localhost"){$SearchEventText =  Show-Inputbox -message "Enter the text to search" -title "$ComputerName - Search in events" -default "error"
			if ($SearchEventText -ne ""){
				$SearchEvent = Get-EventLog | Where-Object { $_.Message -match "$SearchEventText" }|fl * |Out-String
				Add-RichTextBox $SearchEvent
			}
		}
		else {$SearchEventText =  Show-Inputbox -message "Enter the text to search" -title "$ComputerName - Search in events" -default "error"
			if ($SearchEventText -ne ""){
				$SearchEvent = Get-EventLog -ComputerName $ComputerName| Where-Object { $_.Message -match "$SearchEventText" }|fl|Out-String
				Add-RichTextBox $SearchEvent
			}
		}
	}
	
	$button_servicesAutomatic_Click={
		#Clear-RichTextBox
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Services - StartMode:Automatic"
		if ($ComputerName -eq "localhost") {$ComputerName = "."}
		$Services_StartModeAuto = Get-WmiObject Win32_Service -ComputerName $ComputerName -Filter "startmode='auto'" |Select-Object DisplayName,Name,ProcessID,StartMode,State|Format-Table -AutoSize|out-string
		Add-RichTextBox $Services_StartModeAuto
	}
	
	$button_servicesQuery_Click={
		#Button Types 
		#
		#$a = new-object -comobject wscript.shell
		#$intAnswer = $a.popup("Do you want to continue ?",0,"Shutdown",4)
		#if ($intAnswer -eq 6){do something}
		#Value  Description  
		#0 Show OK button.
		#1 Show OK and Cancel buttons.
		#2 Show Abort, Retry, and Ignore buttons.
		#3 Show Yes, No, and Cancel buttons.
		#4 Show Yes and No buttons.
		#5 Show Retry and Cancel buttons.
		#Clear-RichTextBox
		Get-ComputerTxtBox
		$a = new-object -comobject wscript.shell
		Add-Logs "$COMPUTERNAME - Query Service"
		#$Service_query = Read-Host "Enter the Service Name to Query `n"
		$Service_query = $textbox_servicesAction.text
		$intAnswer = $a.popup("Do you want to continue ?",0,"$ComputerName - Query Service: $Service_query",4)
		if (($ComputerName -like "localhost") -and ($intAnswer -eq 6)) {
			Add-Logs "$COMPUTERNAME - Checking Service $Service_query ..."
			$Service_query_return=Get-WmiObject Win32_Service -Filter "Name='$Service_query'" |Out-String
			Add-Logs "$COMPUTERNAME - Command Sent! Service $Service_query"
			Add-RichTextBox $Service_query_return
			Add-Logs -Text "$ComputerName - Query Service $Service_query - Done."
		}
		else {
			if($intAnswer -eq 6){
				Add-Logs "$COMPUTERNAME - Checking the Service $Service_query ..."
				$Service_query_return=Get-WmiObject -computername $ComputerName Win32_Service -Filter "Name='$Service_query'" |Out-String
				Add-Logs "$COMPUTERNAME - Command Sent! Service $Service_query"
				Add-RichTextBox $Service_query_return
				Add-Logs -Text "$ComputerName - Query Service $Service_query - Done."
			}
		}
		#Add-Logs $($error[0].Exception.Message)
	}
	
	$button_servicesAll_Click={
		#Clear-RichTextBox
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Services - All Services + Owners"
		if ($ComputerName -eq "localhost") {$ComputerName = "."}
		$Services_StartModeAuto = Get-WmiObject Win32_Service -ComputerName $ComputerName |select Name,ProcessID,StartMode,State,@{Name="Owner";Expression={$_.StartName}}|ft -AutoSize|out-string
		Add-RichTextBox $Services_StartModeAuto
		
	}
	
	$button_servicesStop_Click={
		#Button Types 
		#
		#$a = new-object -comobject wscript.shell
		#$intAnswer = $a.popup("Do you want to continue ?",0,"Shutdown",4)
		#if ($intAnswer -eq 6){do something}
		#Value  Description  
		#0 Show OK button.
		#1 Show OK and Cancel buttons.
		#2 Show Abort, Retry, and Ignore buttons.
		#3 Show Yes, No, and Cancel buttons.
		#4 Show Yes and No buttons.
		#5 Show Retry and Cancel buttons.
		#Clear-RichTextBox
		Get-ComputerTxtBox
		#Add-RichTextBox "# SERVICES - STOP SERVICE - COMPUTERNAME: $ComputerName `n`n"
		Add-logs -text "$ComputerName - Stop Service"
		#$Service_query = Read-Host "Enter the Service Name to Stop `n"
		$Service_query = $textbox_servicesAction.text
		Add-logs -text "$ComputerName - Service to Stop: $Service_query"
		$a = new-object -comobject wscript.shell
		$intAnswer = $a.popup("Do you want to continue ?",0,"$ComputerName - Stop Service: $Service_query",4)
		if (($ComputerName -like "localhost") -and ($intAnswer -eq 6)) {
			Add-logs -text "$ComputerName - Stopping Service: $Service_query ..."
			$Service_query_return=Get-WmiObject Win32_Service -Filter "Name='$Service_query'"
			$Service_query_return.stopservice()
			Add-Logs -Text "$ComputerName - Command Sent! $Service_query should be stopped"
			Add-RichTextBox $Service_query_return
			Add-Logs -Text "$ComputerName - Checking the status of $Service_Query ..."
			Start-Sleep -Milliseconds 1000
			$Service_query_result=Get-WmiObject Win32_Service -Filter "Name='$Service_query'"|Out-String
			Add-RichTextBox $Service_query_result
			Add-Logs -Text "$ComputerName - Stop Service $Service_query - Done."
		}#end IF
		else {
			if ($intAnswer -eq 6){
				Add-logs -text "$ComputerName - Stopping Service: $Service_query ..."
				$Service_query_return=Get-WmiObject Win32_Service -computername $ComputerName -Filter "Name='$Service_query'"
				$Service_query_return.stopservice()
				Add-Logs -Text "$ComputerName - Command Sent! $Service_query should be stopped"
				Add-RichTextBox $Service_query_return
				Add-Logs -Text "$ComputerName - Checking the status of $Service_Query ..."
				Start-Sleep -Milliseconds 1000
				$Service_query_result=Get-WmiObject Win32_Service -computername $ComputerName -Filter "Name='$Service_query'"|Out-String
				Add-RichTextBox $Service_query_result
				Add-Logs -Text "$ComputerName - Stop Service $Service_query - Done."
			}#end IF
		}#end ELSE
	}
	
	$mRemoteToolStripMenuItem_Click={Start-Process ./tools/mremote.exe}
	
	$button_DiskPhysical_Click={
		#Clear-RichTextBox
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Hard Drive - Physical Disk"
		if ($ComputerName -eq "localhost") {$ComputerName = "."}
		$Disks_Physical = Get-WmiObject Win32_DiskDrive -ComputerName $ComputerName|Select DeviceID, `
	    Model,`
	    Manufacturer,`
	    @{Name="SizeGB";Expression={$_.Size/1GB}}, `
	    Caption, `
	    Partitions, `
	    SystemName,`
	    Status,`
	    InterfaceType,`
	    MediaType,`
	    SerialNumber,`
	    SCSIBus,SCSILogicalUnit,SCSIPort,SCSITargetId| fl |Out-String
		Add-RichTextBox $Disks_Physical
		
	}
	
	$button_DiskLogical_Click={
		#Clear-RichTextBox
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Hard Drive - Logical Disk"
		if ($ComputerName -eq "localhost") {$ComputerName = "."}
		$Disks_Logical=Get-WMIObject Win32_LogicalDisk -ComputerName $ComputerName| select DeviceId,`
			DriveType,`
			@{Name="DriveTypeInfo";Expression={switch ($_.DriveType){0{"Unknown"}1{"No Root Directory"}2{"Removable Disk"}3{"Local Disk"}4{"Network Drive"}5{"Compact Disc"}6{"RAM Disk"}}}},`
			FileSystem,`
			@{Name="FreeSpaceGB";Expression={$_.FreeSpace/1GB}},`
			@{Name="SizeGB";Expression={$_.Size/1GB}},`
			@{Name="%Free";Expression={((100*($_.FreeSpace))/$_.Size)}}, 
			@{Name="%Usage";Expression={((($_.size) - ($_.Freespace))*100)/$_.size}}, 
			VolumeName,`
			SystemName,`
			Description,`
			InstallDate,`
			Compressed,`
			VolumeDirty,`
			VolumeSerialNumber|fl | Out-String
		Add-RichTextBox $Disks_Logical
		
	}
	
	$button_EventsLogNames_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - EventLog - LogNames list"
		if ($ComputerName -eq "localhost") {
			$EventsLog = Get-EventLog -list |Format-List|Out-String
			Add-RichTextBox $EventsLog	
		}
		else {
			$EventsLog = Get-EventLog -list -ComputerName $ComputerName |Format-List|Out-String
			Add-RichTextBox $EventsLog
		}
	}
	
	$button_servicesStart_Click={
		#Button Types 
		#
		#$a = new-object -comobject wscript.shell
		#$intAnswer = $a.popup("Do you want to continue ?",0,"Shutdown",4)
		#if ($intAnswer -eq 6){do something}
		#Value  Description  
		#0 Show OK button.
		#1 Show OK and Cancel buttons.
		#2 Show Abort, Retry, and Ignore buttons.
		#3 Show Yes, No, and Cancel buttons.
		#4 Show Yes and No buttons.
		#5 Show Retry and Cancel buttons.
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Start Service"
		$Service_query = $textbox_servicesAction.text
		Add-logs -text "$ComputerName - Service to start: $Service_query"
		$a = new-object -comobject wscript.shell
		$intAnswer = $a.popup("Do you want to continue ?",0,"$ComputerName - Start Service: $Service_query",4)
		if (($ComputerName -like "localhost") -and ($intAnswer -eq 6)) {
			Add-logs -text "$ComputerName - Starting Service: $Service_query ..."
			$Service_query_return=Get-WmiObject Win32_Service -Filter "Name='$Service_query'"
			$Service_query_return.startservice()
			Add-Logs -Text "$ComputerName - Command Sent! $Service_query should be started"
			Add-RichTextBox $Service_query_return
			Add-Logs -Text "$ComputerName - Checking the status of $Service_Query ..."
			Start-Sleep -Milliseconds 1000
			$Service_query_result=Get-WmiObject Win32_Service -Filter "Name='$Service_query'"|Out-String
			Add-RichTextBox $Service_query_result
			Add-Logs -Text "$ComputerName - Start Service $Service_query - Done."
		}
		else { 
			if ($intAnswer -eq 6){
				Add-logs -text "$ComputerName - Starting Service: $Service_query ..."
				$Service_query_return=Get-WmiObject Win32_Service -computername $ComputerName -Filter "Name='$Service_query'"
				$Service_query_return.startservice()
				Add-Logs -Text "$ComputerName - Command Sent! $Service_query should be started"
				Add-RichTextBox $Service_query_return
				Add-Logs -Text "$ComputerName - Checking the status of $Service_Query ..."
				Start-Sleep -Milliseconds 1000
				$Service_query_result=Get-WmiObject Win32_Service -computername $ComputerName -Filter "Name='$Service_query'"|Out-String
				Add-RichTextBox $Service_query_result
				Add-Logs -Text "$ComputerName - Start Service $Service_query - Done."
			}# IF
		}#ELSE
		#
	}
	
	$button_processOwners_Click={
		#Clear-RichTextBox
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Processes with owners"
		if ($ComputerName -eq "localhost") {$ComputerName = "."}
		$owners = @{}
		Get-WmiObject win32_process -ComputerName $ComputerName |% {$owners[$_.handle] = $_.getowner().user}
		$ProcessALL = get-process -ComputerName $ComputerName| Select ProcessName,@{l="Owner";e={$owners[$_.id.tostring()]}},CPU,WorkingSet,Handles,Id|ft -AutoSize|out-string
		Add-RichTextBox $ProcessALL
		
	}
	
	$button_processAll_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - All Processes"
		if ($ComputerName -eq "localhost") {$ComputerName = "."}
		$ProcessALL = get-process -ComputerName $ComputerName|out-string
		Add-RichTextBox $ProcessALL
	}
	
	$button_ProcessGrid_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - All Processes - GridView"
		if ($ComputerName -eq "localhost") {$ComputerName = "."}
		$owners = @{}
		Get-WmiObject win32_process -ComputerName $ComputerName |% {$owners[$_.handle] = $_.getowner().user}
		#$ProcessALL = get-process -ComputerName $ComputerName| select processname,Id,@{l="Owner";e={$owners[$_.id.tostring()]}}|out-string
		$ProcessALL = get-process -ComputerName $ComputerName| Select @{l="Owner";e={$owners[$_.id.tostring()]}},*|Out-GridView
	}
	
	$button_servicesGridView_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - All Services - GridView"
		if ($ComputerName -eq "localhost") {$ComputerName = "."}
		$Services_StartModeAuto = Get-WmiObject Win32_Service -ComputerName $ComputerName |Select-Object *,@{Name="Owner";Expression={$_.StartName}}|Out-GridView
	}
	
	$button_SharesGrid_Click={
		Get-ComputerTxtBox
		#Add-RichTextBox "$ComputerName - All Shares - GridView"
		if ($ComputerName -eq "localhost") {$ComputerName = "."}
		$SharesList = Get-WmiObject win32_share -computer $ComputerName |Select-Object -Property __SERVER,Name,Path,Status,Description,*|Sort-Object name| Out-GridView
	}
	
	$ToolStripMenuItem_TerminalAdmin_Click={
		if ($current_OS_caption -like "*2008*"){
			$cmd = "tsadmin.msc"
			Start-Process $cmd
		}
		else {
			Start-Process tsadmin.exe
		}
	}
	$ToolStripMenuItem_ADSearchDialog_Click={
		$cmd="$env:windir\system32\rundll32.exe"
		$param="dsquery.dll,OpenQueryWindow"
		Start-Process $cmd $param
	}
	
	$ToolStripMenuItem_ADPrinters_Click={
		$TemporaryFile = [System.IO.Path]::GetTempFileName().Replace(".tmp", ".qds")
		Add-Content $TemporaryFile "
		[CommonQuery]
		Handler=5EE6238AC231D011891C00A024AB2DBBC1
		Form=70F077B5E27ED011913F00AA00C16E65DB
		[DsQuery]
		ViewMode=0413000017
		EnableFilter=0000000000
		[Microsoft.Printers.MoreChoices]
		LocationLength=1200000012
		LocationValue=2400440079006E0061006D00690063004C006F0063006100740069006F006E002400000046
		color=0000000000
		duplex=0000000000
		stapling=0000000000
		resolution=0000000000
		speed=0100000001
		sizeLength=0100000001
		sizeValue=000000
		[Microsoft.PropertyWell]
		Items=0000000000
	"
		Start-Process $TemporaryFile
		Start-Sleep -Seconds 3
		Remove-Item -Force $TemporaryFile
	}
	
	$button_outputCopy_Click={
		
		Add-logs -text "Copying content of Logs Richtextbox to Clipboard"
		$texte = $richtextbox_output.Text
		Add-ClipBoard -text $texte}
	
	$button_ExportRTF_Click={
		$filename = [System.IO.Path]::GetTempFileName()
		$richtextbox_output.SaveFile($filename)
		Add-logs -text "Sending RichTextBox to wordpad (RTF)..."
		Start-Process wordpad $filename
		Start-Sleep -Seconds 5
		#Remove-Item -Force $filename
	}
	
	
	$button_networkPing_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Network - Ping"
		$cmd = "cmd"
		$param_user = $textbox_pingparam.text
		$param = "/k ping $param_user $computername"
		Start-Process $cmd $param
	}
	
	$button_networkPathPing_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Network - PathPing"
		$cmd = "cmd"
		$param_user = $textbox_networkpathpingparam.Text
		$param = "/k pathping $param_user $computername"
		Start-Process $cmd $param
	}
	
	$button_servicesNonStandardUser_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Services - Non-Standard Windows Service Accounts"
		$NormalAccount1="LocalSystem"
		$NormalAccount2="NT Authority\\LocalService"
		$NormalAccount3="NT Authority\\NetworkService"
		$wql = 'Select Name, DisplayName, StartName, __Server From Win32_Service WHERE ((StartName != "LocalSystem") and (StartName != "NT Authority\\LocalService") and (StartName != "NT Authority\\NetworkService"))'
		$query = Get-WmiObject -Query $wql -ComputerName $ComputerName -ErrorAction Stop | Select-Object __SERVER, StartName, Name, DisplayName|Format-Table -AutoSize |Out-String
		if ($query -eq $null){Add-RichTextBox "$Computername - All the services use Standard Windows Service Accounts"}
		else {Add-RichTextBox $query}
	}
	$button_networkTestPort_Click={
		#$error.clear()
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Network - Test-Port"
		$port = Show-Inputbox -message "Enter a port to test" -title "$ComputerName - Test-Port" -default "80"
		if ($port -ne ""){
			#$port = Read-Host -Prompt "Enter a port to test on $ComputerName"
			$result = Test-TcpPort $ComputerName $port
			Add-RichTextBox $result	
		}
	}
	
	$button_networkNsLookup_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Network - Nslookup"
		$cmd = "cmd"
		$param = "/k nslookup $ComputerName"
		Start-Process $cmd $param -WorkingDirectory c:\
	}
	
	$button_networkTracert_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Network - Trace Route (Tracert)"
		$cmd = "cmd"
		$param = "/k tracert $($tb_tracert_paramuser.text) $ComputerName"
		Start-Process $cmd $param -WorkingDirectory c:\
	}
	
	$button_networkRoutePrint_Click={
		#Clear-RichTextBox
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Network - Route Table (route print)"
		$Items = get-wmiobject -class "Win32_IP4RouteTable" -namespace "root\CIMV2" -computername $ComputerName|select destination, mask, NextHop, metric1 |Format-Table -AutoSize |Out-String
		Add-RichTextBox $Items
	}
	
	$button_processLastHour_Click={
		#Clear-RichTextBox
		Get-ComputerTxtBox
		Add-Logs "$ComputerName - Processes - Processes started in last hour"
		if ($ComputerName -eq "localhost") {$ComputerName = "."}
		$owners = @{}
		Get-WmiObject win32_process -ComputerName $ComputerName|% {$owners[$_.handle] = $_.getowner().user}
		$ProcessALL = get-process -ComputerName $ComputerName| Where-Object { trap { continue }  (New-Timespan $_.StartTime).TotalMinutes -le 10 }|Select ProcessName,@{l="StartTime";e={$_.StartTime}},@{l="Owner";e={$owners[$_.id.tostring()]}},CPU,WorkingSet,Handles,Id|fl|out-string
		Add-RichTextBox $ProcessALL
	}
	
	$button_PasswordGen_Click={
		#Clear-RichTextBox
		Add-Logs "Generating a Password"
		$Passwordlist = [Char[]]'abcdefgABCDEFG0123456&%$'
		$Newpass = -join (1..8 | Foreach-Object { Get-Random $Passwordlist -count 1 })|Out-String
		Add-RichTextBox $Newpass
	}
	$ToolStripMenuItem_systemInformationMSinfo32exe_Click={Start-Process msinfo32.exe}
	$ToolStripMenuItem_addRemovePrograms_Click={Start-Process appwiz.cpl;Add-logs -text "Localhost - Add/Remove Programs (appwiz.cpl)"}
	$ToolStripMenuItem_administrativeTools_Click={Start-Process (Control admintools);Add-logs -text "Localhost - Administrative Tools (Control admintools)"}
	$ToolStripMenuItem_certificateManager_Click={Start-Process certmgr.msc}
	$ToolStripMenuItem_addRemoveProgramsWindowsFeatures_Click={$cmd = "rundll32.exe";$param = "shell32.dll,Control_RunDLL appwiz.cpl,,2";Start-process $cmd -ArgumentList $param;Add-logs -text "Localhost - Add/Remove Programs - Windows Features ($cmd $param)"}
	$button_mmcShares_Click={$ComputerName=$textbox_computername.Text;Add-logs -text "$ComputerName - Shared Folders MMC (fsmgmt.msc /computer:$ComputerName";$cmd="fsmgmt.msc";$param="/computer:$ComputerName";Start-Process $cmd $param}
	$ToolStripMenuItem_systemproperties_Click={Start-Process "sysdm.cpl"}
	$ToolStripMenuItem_Wordpad_Click={Start-Process "wordpad"}
	$ToolStripMenuItem_sharedFolders_Click={Start-Process "fsmgmt.msc"}
	$ToolStripMenuItem_performanceMonitor_Click={Start-Process "Perfmon.msc"}
	$ToolStripMenuItem_networkConnections_Click={Start-Process "ncpa.cpl"}
	$ToolStripMenuItem_devicemanager_Click={Start-Process "devmgmt.msc"}
	$ToolStripMenuItem_groupPolicyEditor_Click={start-process "Gpedit.msc"}
	$ToolStripMenuItem_localUsersAndGroups_Click={start-process "lusrmgr.msc"}
	$ToolStripMenuItem_diskManagement_Click={start-process "diskmgmt.msc"}
	$ToolStripMenuItem_localSecuritySettings_Click={Start-Process "secpol.msc"}
	$ToolStripMenuItem_componentServices_Click={Start-Process "dcomcnfg"}
	$ToolStripMenuItem_scheduledTasks_Click={Start-Process (control schedtasks)}
	$ToolStripMenuItem_PowershellISE_Click={start-process powershell_ise.exe}
	
	$button_servicesAutoNotStarted_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Services - Services with StartMode: Automatic and Status: NOT Running"
		if ($ComputerName -eq "localhost") {$ComputerName = "."}
		$Services_StartModeAuto = Get-WmiObject Win32_Service -ComputerName $ComputerName -Filter "startmode='auto' AND state!='running'"|Select-Object DisplayName,Name,StartMode,State|ft -AutoSize|out-string
		Add-RichTextBox $Services_StartModeAuto
	}
	
	$textbox_computername_TextChanged={
		$label_OSStatus.Text = ""
		$label_PermissionStatus.Text = ""
		$label_PingStatus.Text = ""
		$label_RDPStatus.Text = ""
		$label_PSRemotingStatus.Text = ""
		$label_UptimeStatus.Text = ""
		$now = Get-DateSortable
		if ($textbox_computername.Text -eq "") {
			$textbox_computername.BackColor =  [System.Drawing.Color]::FromArgb(255, 128, 128);
			add-logs -text "Please Enter a ComputerName"
			$errorprovider1.SetError($textbox_computername, "Please enter a ComputerName.")
		}
		if ($textbox_computername.Text -ne "") {
			$textbox_computername.BackColor =  [System.Drawing.Color]::FromArgb(255, 255, 192)
			$errorprovider1.SetError($textbox_computername, "")
		}
		$tabcontrol_computer.Enabled = $textbox_computername.Text -ne ""
		$button_Check.Enabled = $textbox_computername.Text -ne ""
	}
	
	$button_IEHPHomepage_Click={
		Get-ComputerTxtBox
		$HPHomePage_command="iexplore.exe"
		$HPHomePage_arguments = "https://$ComputerName"+":2381"
		Add-Logs -text "$ComputerName - Internet Explorer - Launching HP Homepage (default port 2381)"
		Start-Process $HPHomePage_command $HPHomePage_arguments
	}
	
	$button_IEDellOpenManage_Click={
		Get-ComputerTxtBox
		$DellOM_command="iexplore.exe"
		$DellOM_arguments = "https://$ComputerName"+":1311"
		Add-Logs -text "$ComputerName - Internet Explorer - Launching Dell OpenManage (default port 1311)"
		Start-Process $DellOM_command $DellOM_arguments
	}
	
	$button_HTTP_Click={
		Get-ComputerTxtBox
		$HPHomePage_command="iexplore.exe"
		$HPHomePage_arguments = "http://$ComputerName"+":80"
		Add-Logs -text "$ComputerName - Internet Explorer - Default Website (default port 80)"
		Start-Process $HPHomePage_command $HPHomePage_arguments
	}
	
	$button_Processor_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Processor Information"
		$result = Get-Processor -ComputerName $ComputerName|Out-String
		Add-RichTextBox $result
	}
	
	$buttonShutdown_Click={
		$shutdown_gui_cmd = "shutdown"
		$shutdown_gui_arguments = "/i"
		Start-Process $shutdown_gui_cmd $shutdown_gui_arguments
	}
	
	
	$button_UsersGroupLocalUsers_Click={
		Get-ComputerTxtBox
		$result = Get-WmiObject -class "Win32_UserAccount" -namespace "root\CIMV2" -filter "LocalAccount = True" -computername $ComputerName|Select-Object AccountType,Caption,Description,Disabled,Domain,FullName,InstallDate,LocalAccount,Lockout,Name,PasswordChangeable,PasswordExpires,PasswordRequired,SID,SIDType,Status|fl|Out-String
		Add-RichTextBox $result
	}
	
	$button_UsersGroupLocalGroups_Click={
		$button_UsersGroupLocalGroups.Enabled = $false
		Get-ComputerTxtBox
		$result = Get-WmiObject -Class Win32_Group -ComputerName $ComputerName	| Where-Object {$_.LocalAccount}|ft -auto|Out-String
		Add-RichTextBox $result
		$button_UsersGroupLocalGroups.Enabled = $true
	}
	
	$button_SYDIGo_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - SYDI Tool (Script Your Documentation Instantly) - Microsoft Word required for DOC format."
		$SYDI_Cmd = "cmd.exe"
		$SYDI_VBS = "$ScriptsFolder\sydi-server.vbs"
		$SYDI_GuiParam = $textbox_sydi_arguments.Text
		$SYDI_SelectedFormat = $combobox_sydi_format.SelectedItem
		$SYDI_date = get-date -Format "yyyyMMddHH_mmss" |Out-String
		$SYDI_SavingFile = ""
		if ($SYDI_SelectedFormat -eq "XML"){
			#Add-RichTextBox "SYDI - Selected Format: $SYDI_SelectedFormat`n"
			$argument = "-t$ComputerName -wabefghipPqrsu -racdklp -ex -o`"$SavePath\$ComputerName-$SYDI_date.xml`""
			Start-Proc -exe "cmd.exe" -arguments "/k cscript $SYDI_VBS $argument"
			Add-RichTextBox "SYDI - File will be placed on desktop: $env:userprofile\desktop\$ComputerName-<date>.xml`n"
			ii $env:userprofile\desktop
		}
		if ($SYDI_SelectedFormat -eq "DOC"){
			#Add-RichTextBox "SYDI - Selected Format: $SYDI_SelectedFormat`n"
			$argument = "-t$ComputerName -wabefghipPqrsu -racdklp -ew -o`"$SavePath\$ComputerName-$SYDI_date.doc`""
			Start-Proc -exe "cmd.exe" -arguments "/k cscript $SYDI_VBS $argument"
			Add-RichTextBox "SYDI - File will be placed on desktop: $env:userprofile\desktop\$ComputerName-<date>.doc/docx`n"
			ii $env:userprofile\desktop
		}
		if ($SYDI_SelectedFormat -eq ""){Add-RichTextBox "SYDI - No Format Selected, please choose between DOC and XML`n"}	
	}
	
	$button_PageFile_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Page File Information and Settings"
		$ResultPageFile = Get-PageFile -ComputerName $ComputerName | Out-String
		$ResultPageFileSettings = Get-PageFileSetting -ComputerName $ComputerName | Out-String
		Add-RichTextBox "$resultPageFile `r $resultPageFileSettings"
	}
	
	$button_DiskPartition_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Hard Drive - Partition"
		
		$result = Get-DiskPartition -ComputerName $ComputerName | Out-String
		Add-RichTextBox $result
		
	}
	
	$button_DiskUsage_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Hard Drive - DiskSpace"
		$result = Get-DiskSpace -ComputerName $ComputerName | Out-String
		Add-RichTextBox -text $result
	}
	
	$button_networkIPConfig_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Network - Configuration"
		$result = Get-IP -ComputerName $ComputerName | Format-Table Name,IP4,IP4Subnet,DefaultGWY,MacAddress,DNSServer,WinsPrimary,WinsSecondary -AutoSize | Out-String -Width $richtextbox_output.Width
		Add-RichTextBox "$result`n"
	}
	
	$button_DiskRelationship_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Hard Disk - Disks Relationship"
		$result = Get-DiskRelationship -ComputerName $ComputerName | Out-String
		Add-RichTextBox $result
	}
	
	$button_DiskMountPoint_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Hard Disk - MountPoint"
		$result = Get-MountPoint -ComputerName $ComputerName | Out-String
		if ($result -ne $null){Add-RichTextBox $result}
		else {Show-MsgBox -BoxType "OKOnly" -Title "$ComputerName - Hard Disk - MountPoint" -Prompt "$ComputerName - No MountPoint detected" -Icon "Information"}
	}
	
	$button_DiskMappedDrive_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Hard Disk - Mapped Drive"
		$result = Get-MappedDrive -ComputerName $ComputerName | Out-String
		if ($result -ne $null){Add-RichTextBox $result}
		else {Show-MsgBox -BoxType "OKOnly" -Title "$ComputerName - Mapped Drive" -Prompt "$ComputerName - No Mapped Drive detected" -Icon "Information"}
	}
	
	$button_Memory_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Memory Configuration"
		$result = Get-MemoryConfiguration -ComputerName $ComputerName | Out-String
		Add-RichTextBox $result
	}
	
	$button_NIC_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Network Interface Card Configuration (slow)"
		$result = Get-NICInfo -ComputerName $ComputerName | Out-String
		Add-RichTextBox $result
	}
	
	$button_MotherBoard_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - MotherBoard"
		$result = Get-MotherBoard -ComputerName $ComputerName | Out-String
		Add-RichTextBox $result
	}
	
	$button_networkRouteTable_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Route table"
		$result = Get-Routetable  -ComputerName $ComputerName |ft -auto| Out-String
		Add-RichTextBox $result
	}
	
	$button_SystemType_Click={
		#Clear-RichTextBox
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - System Type"
		$result = get-systemtype -ComputerName $ComputerName| Out-String
		Add-RichTextBox $result
	}
	
	$richtextbox_output_TextChanged={
		#Scroll to Bottom when text is changed
		$richtextbox_output.SelectionStart=$richtextbox_output.Text.Length
		$richtextbox_output.ScrollToCaret()
	}
	
	$richtextbox_Logs_TextChanged={
		$richtextbox_Logs.SelectionStart=$richtextbox_Logs.Text.Length
		$richtextbox_Logs.ScrollToCaret()
		if ($error[0]){Add-logs -text $($error[0].Exception.Message)}
	}
	$ToolStripMenuItem_adExplorer_Click={
		Add-logs -text "Localhost - SysInternals AdExplorer"
		$command="AdExplorer.exe"
		Start-Process $command -WorkingDirectory $ToolsFolder		
	}
	
	$button_HTTPS_Click={
		Get-ComputerTxtBox
		$HPHomePage_command="iexplore.exe"
		$HPHomePage_arguments = "https://$ComputerName"
		Start-Process $HPHomePage_command $HPHomePage_arguments
		Add-Logs -text "$ComputerName - Internet Explorer - Default Website HTTPS (default port 81)"
	}
	
	$button_FTP_Click={
		Get-ComputerTxtBox
		$HPHomePage_command="iexplore.exe"
		$HPHomePage_arguments = "ftp://$ComputerName"+":21"
		Start-Process $HPHomePage_command $HPHomePage_arguments
		Add-Logs -text "$ComputerName - Internet Explorer - FTP Site (default port 21)"
	}
	
	$button_Telnet_Click={
		Get-ComputerTxtBox
		$Telnet_command="cmd.exe"
		$Telnet_Args = "/k telnet.exe $ComputerName"
		Start-Process $Telnet_command $Telnet_Args
		Add-Logs -text "$ComputerName - Telnet (default port 23)"
	}
	
	$textbox_servicesAction_Click={$textbox_servicesAction.text = ""}
	
	$button_servicesRestart_Click={
		#Button Types 
		#
		#$a = new-object -comobject wscript.shell
		#$intAnswer = $a.popup("Do you want to continue ?",0,"Shutdown",4)
		#if ($intAnswer -eq 6){do something}
		#Value  Description  
		#0 Show OK button.
		#1 Show OK and Cancel buttons.
		#2 Show Abort, Retry, and Ignore buttons.
		#3 Show Yes, No, and Cancel buttons.
		#4 Show Yes and No buttons.
		#5 Show Retry and Cancel buttons.
		
		#Clear-RichTextBox
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Restart Service"
		#Add-RichTextBox "# SERVICES - RESTART SERVICE - COMPUTERNAME: $ComputerName `n`n"
		#$Service_query = Read-Host "Enter the Service Name to Start `n"
		$Service_query = $textbox_servicesAction.text
		Add-logs -text "$ComputerName - Service to Restart: $Service_query"
		#Add-RichTextBox "SERVICE: $Service_query"
		$a = new-object -comobject wscript.shell
		$intAnswer = $a.popup("Do you want to continue ?",0,"$ComputerName - Start Service: $Service_query",4)
		if (($ComputerName -like "localhost") -and ($intAnswer -eq 6)) {
			Add-logs -text "$ComputerName - Stopping Service: $Service_query ..."
			$Service_query_return=Get-WmiObject Win32_Service -Filter "Name='$Service_query'"
			$Service_query_return.stopservice()
			Add-Logs -Text "$ComputerName - Command Sent! $Service_query should be stopped"
			Add-RichTextBox $Service_query_return
			Add-Logs -Text "$ComputerName - Checking the status of $Service_Query ..."
			Start-Sleep -Milliseconds 1000
			$Service_query_result=Get-WmiObject Win32_Service -Filter "Name='$Service_query'"|Out-String
			Add-RichTextBox $Service_query_result
			Add-Logs -Text "$ComputerName - Stop Service $Service_query - Done."
			Add-Logs -Text "$ComputerName - Restarting the Service $Service_query ..."
			#Add-RichTextBox "Starting Service: $Service_query...`r"
			$Service_query_return=Get-WmiObject Win32_Service -Filter "Name='$Service_query'"
			$Service_query_return.startservice()
			Add-Logs -Text "$ComputerName - Command Sent! $Service_query should be started"
			Add-RichTextBox $Service_query_return
			Add-Logs -Text "$ComputerName - Checking the status of $Service_Query ..."
			Start-Sleep -Milliseconds 1000
			$Service_query_result=Get-WmiObject Win32_Service -Filter "Name='$Service_query'"|Out-String
			Add-RichTextBox $Service_query_result
			Add-Logs -Text "$ComputerName - Start Service $Service_query - Done."
		}
		else { 
			if ($intAnswer -eq 6){
				Add-logs -text "$ComputerName - Stopping Service: $Service_query ..."
				$Service_query_return=Get-WmiObject Win32_Service -Filter "Name='$Service_query'"
				$Service_query_return.stopservice()
				Add-Logs -Text "$ComputerName - Command Sent! $Service_query should be stopped"
				Add-RichTextBox $Service_query_return
				Add-Logs -Text "$ComputerName - Checking the status of $Service_Query ..."
				Start-Sleep -Milliseconds 1000
				$Service_query_result=Get-WmiObject Win32_Service -Filter "Name='$Service_query'"|Out-String
				Add-RichTextBox $Service_query_result
				Add-Logs -Text "$ComputerName - Stop Service $Service_query - Done."
				Add-Logs -Text "$ComputerName - Restarting the Service $Service_query ..."
				$Service_query_return=Get-WmiObject Win32_Service -computername $ComputerName -Filter "Name='$Service_query'"
				$Service_query_return.startservice()
				Add-Logs -Text "$ComputerName - Command Sent! $Service_query should be started"
				Add-RichTextBox $Service_query_return
				Add-Logs -Text "$ComputerName - Checking the status of $Service_Query ..."
				Start-Sleep -Milliseconds 1000
				$Service_query_result=Get-WmiObject Win32_Service -computername $ComputerName -Filter "Name='$Service_query'"|Out-String
				Add-RichTextBox $Service_query_result
				Add-Logs -Text "$ComputerName - Start Service $Service_query - Done."
			}# IF
		}#ELSE
		#
	}
	
	$ToolStripMenuItem_hostsFileGetContent_Click={
		#TODO: Place custom script here
		$resultHostFile = Get-HostsFile | Out-String
		Add-RichTextBox $resultHostFile
		Add-logs -text "LocalHost - Checking the hosts file"
	}
	
	$button_HostsFile_Click={
		$button_HostsFile.Enabled = $false
		Get-ComputerTxtBox
		Add-logs -text "LocalHost - Checking the hosts file"
		$IP=(get-ip $ComputerName).ip4
		if ($IP -eq $null) {$IP=(get-ip $ComputerName).ip6}
		if (($ComputerName -eq "localhost") -or ($ComputerName -eq "127.0.0.1") -or ($ComputerName -eq "$env:ComputerName") -or ($ComputerName -eq $IP)) {
			$resultHostFile = Get-HostsFile | Out-String
			if ($resultHostFile -ne $null){
				Add-RichTextBox $resultHostFile
			}
		}
		Else {
			$resultHostsFileRemote = Get-HostsFile -computername $ComputerName | Out-String
			if ($resultHostFile -ne $null){
				Add-RichTextBox $resultHostsFileRemote
			}
		}
		$button_HostsFile.Enabled = $true
	}
	
	$button_processTerminate_Click={
		#Button Types 
		#
		#$a = new-object -comobject wscript.shell
		#$intAnswer = $a.popup("Do you want to continue ?",0,"Shutdown",4)
		#if ($intAnswer -eq 6){do something}
		#Value  Description  
		#0 Show OK button.
		#1 Show OK and Cancel buttons.
		#2 Show Abort, Retry, and Ignore buttons.
		#3 Show Yes, No, and Cancel buttons.
		#4 Show Yes and No buttons.
		#5 Show Retry and Cancel buttons.
		#Clear-RichTextBox
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Terminate Process"
		#$Service_query = Read-Host "Enter the Service Name to Stop `n"
		$Process_query = $textbox_processName.text
		Add-logs -text "$ComputerName - Process to Terminate: $Process_query"
		$a = new-object -comobject wscript.shell
		$intAnswer = $a.popup("Do you want to continue ?",0,"$ComputerName - Terminate Process: $Process_query",4)
		
		#localhost
		if (($ComputerName -like "localhost") -and ($intAnswer -eq 6)) {
			Add-logs -text "$ComputerName - Terminate Process: $Process_query - Terminating..."
			$Process_query_return = (Get-WmiObject Win32_Process -Filter "Name='$Process_query'").Terminate() | Out-String
			#$Process_query_return.Terminate()
			#Add-Logs -Text "$ComputerName - Terminate Process: $Process_query ..."
			Add-RichTextBox $Process_query_return
			Add-logs -text "$ComputerName - Terminate Process: $Process_query - Checking Status... "
			Start-Sleep -Milliseconds 1000
			$Process_query_return = Get-WmiObject Win32_Process -Filter "Name='$Process_query'"|Out-String
			if (!($Process_query_return)){Add-Logs -Text "$ComputerName - $Process_query  has been terminated"}
			Add-logs -text "$ComputerName - Terminate Process: $Process_query - Terminated "
		}#end IF
		
		#RemoteHost
		else {
			if ($intAnswer -eq 6){
				Add-logs -text "$ComputerName - Terminate Process: $Process_query - Terminating..."
				$Process_query_return = (Get-WmiObject Win32_Process -Filter "Name='$Process_query'").Terminate() | Out-String
				#$Process_query_return.Terminate()
				Add-RichTextBox $Process_query_return
				Add-logs -text "$ComputerName - Terminate Process: $Process_query - Checking Status... "
				Start-Sleep -Milliseconds 1000
				$Process_query_return=Get-WmiObject Win32_Process -computername $ComputerName -Filter "Name='$Process_query'"|Out-String
				if (!($Process_query_return)){Add-Logs -Text "$ComputerName - Terminate Process: $Process_query - Terminated "}
				#Add-logs -text "$ComputerName - Terminate Process: $Process_query - Terminated "
			}#end IF
		}#end ELSE
	}
	
	
	$button_StartupCommand_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Startup Commands"
		$result = Get-WmiObject Win32_StartupCommand –ComputerName $ComputerName |Sort-Object Caption |Format-Table __Server,Caption,Command,User -auto | out-string -Width $richtextbox_output.Width
		Add-richtextbox $result
		Add-Logs -text "$ComputerName - Startup Commands - Done."
	}
	
	$button_ConnectivityTesting_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Connectivity Testing..."
		$result = Test-Server -computername $ComputerName | Out-String
		Add-richtextbox "$result`n"
	}
	$button_Check_Click={
		#Disable the button
		$button_Check.Enabled = $false
		
		#Get the current computer in txt box
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Check Connectivity and Basic Properties"
		# Test Connection
		if (Test-Connection $ComputerName -Count 1 -Quiet) {
			$label_PingStatus.Text = "OK";$label_PingStatus.ForeColor = "green"
	
			# Test Permissions
			if (Test-Path "\\$ComputerName\c$"){
				$label_PermissionStatus.Text = "OK";$label_PermissionStatus.ForeColor = "green"
				
				# Test PSRemoting
				if (Test-PSRemoting -computername $ComputerName){$label_PSRemotingStatus.Text = "OPEN";$label_PSRemotingStatus.ForeColor = "green"}	
				else{$label_PSRemotingStatus.Text = "CLOSED";$label_PSRemotingStatus.ForeColor = "red"}
				
				# Test RDP
				if (Test-Port -tcp 3389 -computername $ComputerName ){$label_RDPStatus.Text = "OPEN";$label_RDPStatus.ForeColor = "green"}
				else{$label_RDPStatus.Text = "CLOSED";$label_RDPStatus.ForeColor = "red"}
				
				# Get the OS
				 $OSWin32_OS = Get-WmiObject -Query "SELECT * FROM Win32_OperatingSystem" -ComputerName $ComputerName
				 $OSCaption = ($OSWin32_OS|Select-Object caption).Caption
				 $OSVersion = $OSWin32_OS.Version
				#2003/xp+
				 $OSOther = $OSWin32_OS.OtherTypeDescription
				 $OSSP = $OSWin32_OS.CSDVersion
				#2008/win7+
				 $OSArchi = $OSWin32_OS.OSArchitecture
				
				$OSFullCaption = "$OSCaption $OSOther $OSArchi $OSSP"
				if ($OSFullCaption -contains "64"){$OSFullCaption = "$OSCaption $OSOther x86 $OSSP"}
				
				$label_OSStatus.Text = $OSFullCaption.Replace('  ',' ')
				$label_OSStatus.ForeColor = "blue"
				
				# Get the uptime
				#$label_UptimeStatus.Text = $(Get-Uptime -ComputerName $ComputerName);$label_UptimeStatus.ForeColor = "blue"
				$LBTime = $OSWin32_OS.ConvertToDateTime($OSWin32_OS.Lastbootuptime)
				[TimeSpan]$uptime = New-TimeSpan $LBTime $(get-date)
				$label_UptimeStatus.Text = "$($uptime.days) Days $($uptime.hours) Hours $($uptime.minutes) Minutes $($uptime.seconds) Seconds"
				
				
			}#end if (Test-Path "\\$ComputerName\c$")
			else {$label_PermissionStatus.Text = "FAIL";$label_PermissionStatus.ForeColor = "red"}
		}#end if (Test-Connection $ComputerName -Count 1 -Quiet)
		else {$label_PingStatus.Text = "FAIL";$label_PingStatus.ForeColor = "red"}
	$button_Check.Enabled = $true
	}
	$button_psexec_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - PSEXEC (Terminal)"
		if(Test-Path "$ToolsFolder\psexec.exe"){
			$argument = "/k $ToolsFolder\psexec.exe \\$ComputerName cmd.exe"
			Start-Process cmd.exe $argument
		}
		else {$button_psexec.ForeColor = 'Red'}
	}
	
	$button_PAExec_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - PAEXEC (Terminal)"
		$argument = "/k $ToolsFolder\paexec.exe \\$ComputerName -s cmd.exe"
		Start-Process cmd.exe $argument
	}
	$button_GPupdate_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - GPUpdate (Remotly via WMI)"
		$result = Invoke-GPUpdate -ComputerName $ComputerName
		if ($result -ne $null)
		{
			if ($result.ReturnValue -eq 0){
				Show-MsgBox -BoxType "OKOnly" -Title "$ComputerName - Group Policy Update" -Prompt "Gpupdate ran successfully!" -Icon "Information"
				Add-RichTextBox $($result|Out-String)
			}
		}
		else {Show-MsgBox -BoxType "OKOnly" -Title "$ComputerName - Group Policy Update" -Prompt "Gpupdate does not seem to work! Are you in a Domain ?" -Icon "Exclamation"}
	}
	
	$button_Applications_Click={
		Get-ComputerTxtBox
		$result = Get-InstalledSoftware -ComputerName $ComputerName |Format-Table * -AutoSize| Out-String -Width $richtextbox_output.Width
		Add-Logs -text "$ComputerName - Installed Softwares List"
		Add-RichTextBox $result
	}
	
	$ToolStripMenuItem_netstatsListening_Click={
		$this.Enabled = $False
		Add-logs -text "$env:ComputerName - Netstat"
		$resultNetstat = Get-NetStat | Format-Table -AutoSize | Out-String
		Add-RichTextBox $resultNetstat
	}
	
	$ToolStripMenuItem_WMIExplorer_Click={
		Add-logs -text "Scripts - WMIExplorer.ps1 By www.ThePowerShellGuy.com (Marc van Orsouw)"
		& "$ScriptsFolder\WMIExplorer.ps1"
	}
	
	$button_DriverQuery_Click={
		$button_DriverQuery.Enabled = $False
		Get-ComputerTxtBox
		$DriverQuery_command="cmd.exe"
		$DriverQuery_arguments = "/k driverquery /s $ComputerName"
		Start-Process $DriverQuery_command $DriverQuery_arguments
		$button_DriverQuery.Enabled = $true
	}
	
	$button_PsRemoting_Click={
		Get-ComputerTXTBOX
		Add-logs -text "$ComputerName - Open a PowerShell Remoting Session"
		if (Test-PSRemoting -ComputerName $ComputerName){
			Add-logs -text "$ComputerName - Powershell Remote Session"
			Start-Process powershell.exe -ArgumentList "-noexit -command Enter-PSSession -ComputerName $ComputerName"
		}
		else {
			Add-logs -text "$ComputerName - PsRemoting does not seem to be enabled"
			Show-MsgBox -Title "PSRemoting" -BoxType "OKOnly" -Icon "Exclamation" -Prompt "PSRemoting does not seem to be enabled"
		}
	}
	$button_MsInfo32_Click={
		Get-ComputerTXTBOX
		Add-Logs "$ComputerName - System Information (MSinfo32.exe)"
		$cmd = "$env:programfiles\Common Files\Microsoft Shared\MSInfo\msinfo32.exe"
		$param = "/computer $ComputerName"
		Start-Process $cmd $param
	}
	
	$button_Qwinsta_Click={
		$button_Qwinsta.Enabled = $false
		Get-ComputerTXTBOX
		
		if ($current_OS_caption -notlike "*64*"){
			Add-Logs -text "$ComputerName - QWINSTA (Query Terminal Sessions) - 32 bits"
			$Qwinsta_cmd = "cmd"
			$Qwinsta_argument = "/k qwinsta /server:$computername"
			Start-Process $Qwinsta_cmd $Qwinsta_argument
		}
		else {
			Add-Logs -text "$ComputerName - QWINSTA (Query Terminal Sessions) - 64 bits"
			$Qwinsta_cmd = "cmd"
			$Qwinsta_argument = "/k $env:SystemRoot\Sysnative\qwinsta /server:$computername"
			Start-Process $Qwinsta_cmd $Qwinsta_argument
		}
		$button_Qwinsta.Enabled = $true
	}
	
	$button_Rwinsta_Click={
		$button_Rwinsta.Enabled = $false
		Get-ComputerTXTBOX
		Add-Logs -text "$ComputerName - RWINSTA (Reset Terminal Sessions)"
		if ($current_OS_caption -notlike "*64*"){
			Add-Logs -text "$ComputerName - RWINSTA (Reset Terminal Sessions) - 32 bits"
			$Rwinsta_ID = Show-Inputbox -message "Enter The Session ID to kill" -title "$ComputerName - Rwinsta (Reset Terminal Session)"
			if ($Rwinsta_ID -ne ""){
				$Rwinsta_cmd = "cmd"
				$Rwinsta_argument = "/k $env:SystemRoot\System32\rwinsta $Rwinsta_ID /server:$computername"
				Start-Process $Rwinsta_cmd $Rwinsta_argument
			}
		}
		else {
			Add-Logs -text "$ComputerName - RWINSTA (Reset Terminal Sessions) - 64 bits"
			$Rwinsta_cmd = "cmd"
			$Rwinsta_ID = Show-Inputbox -message "Enter The Session ID to kill" -title "$ComputerName - Rwinsta (Reset Terminal Session)"
			if ($Rwinsta_ID -ne ""){
				$Rwinsta_argument = "/k $env:SystemRoot\Sysnative\rwinsta $Rwinsta_ID /server:$computername"
				Start-Process $Rwinsta_cmd $Rwinsta_argument
			}
		}
		$button_Rwinsta.Enabled = $true
	}
	
	$button_RebootHistory_Click={
		$button_RebootHistory.Enabled = $false
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Reboot History (Scanning Event Logs for ID 6009) - By BSonPosh.com"
		start-sleep -s 1
		$job = get-reboottime -ComputerName $ComputerName |Out-string
		Add-Richtextbox $job
		$button_RebootHistory.Enabled = $true
	}
	
	$button_USBDevices_Click={
		$button_USBDevices.Enabled = $false
		Get-ComputerTxtBox
		Add-Logs "$ComputerName - USB Devices"
		$result = Get-USB -computerName $ComputerName|
			Select-Object SystemName,Manufacturer,Name|
			Sort-Object Manufacturer|
			Format-Table -AutoSize|Out-String
		Add-RichTextBox $result
		$button_USBDevices.Enabled = $true
	}
	
	$button_RDPEnable_Click={
		$button_RDPEnable.Enabled = $false
		Get-ComputerTxtBox
		Add-Logs "$ComputerName - Enable RDP"
		$result = Set-RDPEnable -ComputerName $ComputerName
		$button_RDPEnable.Enabled = $true
	}
	
	$button_RDPDisable_Click={
		$button_RDPDisable.Enabled = $false
		Get-ComputerTxtBox
		Add-Logs "$ComputerName - Disable RDP"
		Set-RDPDisable -ComputerName $ComputerName
		$button_RDPDisable.Enabled = $true
	}
	
	$button_HotFix_Click={
		$button_HotFix.Enabled = $false
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Get the Windows Updates Installed"
		$result = Get-HotFix -ComputerName $ComputerName | Sort-Object InstalledOn| Format-Table __SERVER, Description, HotFixID, InstalledBy, InstalledOn,Caption -AutoSize | Out-String -Width $richtextbox_output.Width
		Add-RichTextBox $result
		$button_HotFix.Enabled = $true
	}
	
	$button_Printers_Click={
		$button_Printers.Enabled = $false
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Printers"
		$result = Get-WmiObject Win32_Printer -ComputerName $ComputerName  | Format-table SystemName,Name,Comment,PortName,Location,DriverName -AutoSize | Out-String
		if ($result -ne $null){
			Add-RichTextBox $result}
		else {Add-RichTextBox "$ComputerName - No Printer detected"}
		$button_Printers.Enabled = $true
	}
	
	$button_Restart_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Restart Computer"
		#$result = Restart-Computer -ComputerName $ComputerName -Force -Confirm
		$Confirmation = Show-MsgBox -Prompt "You want to restart $ComputerName, Are you sure ?" -Title "$ComputerName - Restart Computer" -Icon Exclamation -BoxType YesNo
		#$result = (Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName).Reboot()
		if ($Confirmation -eq "YES")
		{ 
			#(Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName).Reboot()
			Restart-Computer -ComputerName $ComputerName -Force
			Show-MsgBox -Prompt "$ComputerName - Restart Initialized" -Title "$ComputerName - Restart Computer" -Icon Information -BoxType OKOnly
		}
		else {Show-MsgBox -BoxType "OKOnly" -Title "$ComputerName - Restart" -Prompt "$ComputerName - Restart Cancelled" -Icon "Information"}
	}
	
	$button_Shutdown_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Shutdown Computer"
		#$result = Stop-Computer -ComputerName $ComputerName -Force -Confirm
		$Confirmation = Show-MsgBox -Prompt "You want to shutdown $ComputerName, Are you sure ?" -Title "$ComputerName - Shutdown Computer" -Icon Exclamation -BoxType YesNo
		if ($Confirmation -eq "YES")
		{ 
			#(Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName).shutdown()
			Stop-Computer -ComputerName $ComputerName -Force
			Show-MsgBox -Prompt "$ComputerName - Shutdown Initialized" -Title "$ComputerName - Shutdown Computer" -Icon Information -BoxType OKOnly
		}
		else {Show-MsgBox -BoxType "OKOnly" -Title "$ComputerName - Shutdown" -Prompt "$ComputerName - Shutdown Cancelled" -Icon "Information"}
	}
	
	$buttonCommandLine_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Get the CommandLine Argument for each process"
		#Get-WmiObject Win32_Process -Filter "Name like '%powershell%'" | select-Object CommandLine
		$result = Get-WmiObject Win32_Process -ComputerName $ComputerName | select-Object Name,ProcessID,CommandLine| Format-Table -AutoSize |Out-String -Width $richtextbox_output.Width
		Add-RichTextBox $result
	}
	
	$button_ComputerDescriptionQuery_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Get the Computer Description"
		$result = Get-ComputerComment -ComputerName $ComputerName
		Add-RichTextBox $result
	}
	
	$button_ComputerDescriptionChange_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Set the Computer Description"
		$Description = Show-Inputbox -message "Enter a Computer Description" -title "$ComputerName" -default "<Role> - <Owner> - <Ticket#>"
		if ($Description -ne "" ){
			$result = Set-ComputerComment -ComputerName $ComputerName -Description $Description
		}
	}
	
	#$button_ADComputerDescriptionSet_Click={
	#	Get-ComputerTxtBox
	#	Add-Logs -text "$ComputerName - Set the Active Directory Computer Description"
	#	# Specify description
	#	$strDesc = Show-Inputbox -message "Enter the Active Directory Computer Description to set for $ComputerName" -title "$ComputerName - Set Computer Description (Active Directory)" -default "<Role> - <Owner> - <Ticket#>"
	#	if ($strDesc -ne ""){
	#		# Retrieve NetBIOS name of local computer.
	#		$strName = $ComputerName
	#		$strDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
	#		$strRoot = $strDomain.GetDirectoryEntry()
	#		$objSearcher = [System.DirectoryServices.DirectorySearcher]$strRoot
	#
	#		# Find AD computer object.
	#		$objSearcher.Filter = "(sAMAccountName=$strName`$)"
	#		$objSearcher.PropertiesToLoad.Add("distinguishedName") > $Null
	#
	#		$colResults = $objSearcher.FindAll()
	#		ForEach ($strComputer In $colResults)
	#		{
	#		  $strDN = $strComputer.properties.Item("distinguishedName")
	#		  $Computer = [ADSI]"LDAP://$strDN"
	#		  $Computer.description = $strDesc
	#		  $Computer.SetInfo()
	#		}	
	#	}
	#}
	#
	#$button_ADComputerDescriptionQuery_Click={
	#	Get-ComputerTxtBox
	#	Add-Logs -text "$ComputerName - Query the Active Directory Computer Description"
	#	$result = Get-ComputerAdDescription -ComputerName $ComputerName | Out-String
	#	Add-RichTextBox $result
	#}
	
	
	$buttonC_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Open C$ Drive"
		$PathToCDrive = "\\$ComputerName\c$"
		Explorer.exe $PathToCDrive
	}
	
	$buttonRemoteAssistance_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Remote Assistance"
		MSRA.exe /OfferRA $ComputerName
	}
	$buttonWindowsUpdateLog_Click={
		$buttonWindowsUpdateLog.Enabled = $false
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Windows Update Logs (WindowsUpdate.log)"
		$SystemDriveLetter = ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName).systemdrive).substring(0,1)
		$SystemDriveFolder = ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName).WindowsDirectory).substring(3)
		$pathToWindowsUpdateLog= "\\$computername\$SystemDriveLetter$\$SystemDriveFolder\WindowsUpdate.log"
		if (Test-Path $pathToWindowsUpdateLog)
			{Invoke-Item $pathToWindowsUpdateLog}
		else {Show-MsgBox -BoxType "OKOnly" -Title "$ComputerName - Windows Update Logs (WindowsUpdate.log)" -Prompt "$ComputerName - Can't find the WindowsUpdate.log file `rPath:$pathToWindowsUpdateLog" -Icon "Exclamation"}
		$buttonWindowsUpdateLog.Enabled = $true
	}
	
	$buttonReportingEventslog_Click={
		$buttonReportingEventslog.Enabled = $false
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - WSUS Report (ReportingEvents.log)"
		$SystemDriveLetter = ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName).systemdrive).substring(0,1)
		$SystemDriveFolder = ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName).WindowsDirectory).substring(3)
		$pathToWSUSReportLog= "\\$computername\$SystemDriveLetter$\$SystemDriveFolder\SoftwareDistribution\ReportingEvents.log"
		if (Test-Path $pathToWSUSReportLog)
			{Invoke-Item $pathToWSUSReportLog}
		else {Show-MsgBox -BoxType "OKOnly" -Title "$ComputerName - WSUS Report (ReportingEvents.log)" -Prompt "$ComputerName - Can't find the ReportingEvents.log file `rPath:$pathToWSUSReportLog" -Icon "Exclamation"}
		$buttonReportingEventslog.Enabled = $true
	}
	
	$buttonCommandLineGridView_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Get the CommandLine Argument for each process - Grid View"
		#Get-WmiObject Win32_Process -Filter "Name like '%powershell%'" | select-Object CommandLine
		Get-WmiObject Win32_Process -ComputerName $ComputerName | select-Object Name,ProcessID,CommandLine| Out-GridView
	}
	
	$buttonServices_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Services MMC (services.msc /computer:$ComputerName)"
		$command = "services.msc"
		$arguments = "/computer:$computername"
		Start-Process $command $arguments 
	}
	
	$buttonEventVwr_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Event Viewer MMC (eventvwr $Computername)"
		$command="eventvwr"
		$arguments = "$ComputerName"
		Start-Process $command $arguments
	}
	
	$buttonShares_Click={
		Get-ComputerTxtBox
		Add-logs -text "$ComputerName - Shared Folders MMC (fsmgmt.msc /computer:$ComputerName"
		$SharesCmd="fsmgmt.msc"
		$SharesParam="/computer:$ComputerName"
		Start-Process $SharesCmd $SharesParam
	}
	
	$buttonSendCommand_Click={
		Get-ComputerTxtBox
		Add-Logs -text "$ComputerName - Run a Remote Command"
		$RemoteCommand = Show-Inputbox -message "Enter a command to run" -title "$Computername - Run-RemoteCMD" -default "ipconfig /all"
		if ($RemoteCommand -ne ""){
			Run-RemoteCMD -ComputerName $ComputerName -Command $RemoteCommand	
			Add-Logs -text "$ComputerName - Remote Command Sent!"
		}
	}
	
	$button_SystemInfoexe_Click={
		$button_SystemInfoexe.Enabled = $false
		Get-ComputerTxtBox 		#Get the current ComputerName in the TextBox
		$SystemInfo_cmd_command	= "cmd" #Declare Main Command
		$SystemInfo_cmd_Args	= "/k systeminfo /s $Computername" #Declare Arguments
		# Run it
		Start-Process $SystemInfo_cmd_command $SystemInfo_cmd_Args -WorkingDirectory "c:\"
		$button_SystemInfoexe.Enabled = $true
	}
	
	$textbox_computername_KeyPress=[System.Windows.Forms.KeyPressEventHandler]{
	#Event Argument: $_ = [System.Windows.Forms.KeyPressEventArgs]
		If ($_.KeyChar -eq 13){
	 	$button_ping.PerformClick()
		$richtextbox_output.Focus()
		}
	}	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$form_MainForm.WindowState = $InitialFormWindowState
	}
	
	$Form_StoreValues_Closing=
	{
		#Store the control values
		$script:MainForm_richtextbox_output = $richtextbox_output.Text
		$script:MainForm_textbox_processName = $textbox_processName.Text
		$script:MainForm_textbox_servicesAction = $textbox_servicesAction.Text
		$script:MainForm_combobox_sydi_format = $combobox_sydi_format.Text
		$script:MainForm_textbox_sydi_arguments = $textbox_sydi_arguments.Text
		$script:MainForm_textbox_networktracertparam = $textbox_networktracertparam.Text
		$script:MainForm_textbox_networkpathpingparam = $textbox_networkpathpingparam.Text
		$script:MainForm_textbox_pingparam = $textbox_pingparam.Text
		$script:MainForm_textbox_computername = $textbox_computername.Text
		$script:MainForm_richtextbox_Logs = $richtextbox_Logs.Text
	}

	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$richtextbox_output.remove_TextChanged($richtextbox_output_TextChanged)
			$button_formExit.remove_Click($button_formExit_Click)
			$button_outputClear.remove_Click($button_outputClear_Click)
			$button_ExportRTF.remove_Click($button_ExportRTF_Click)
			$button_outputCopy.remove_Click($button_outputCopy_Click)
			$button_HTTP.remove_Click($button_HTTP_Click)
			$button_FTP.remove_Click($button_FTP_Click)
			$button_IEHPHomepage.remove_Click($button_IEHPHomepage_Click)
			$button_HTTPS.remove_Click($button_HTTPS_Click)
			$button_IEDellOpenManage.remove_Click($button_IEDellOpenManage_Click)
			$buttonSendCommand.remove_Click($buttonSendCommand_Click)
			$button_mmcCompmgmt.remove_Click($button_mmcCompmgmt_Click)
			$buttonServices.remove_Click($buttonServices_Click)
			$buttonShares.remove_Click($buttonShares_Click)
			$buttonEventVwr.remove_Click($buttonEventVwr_Click)
			$button_GPupdate.remove_Click($button_GPupdate_Click)
			$button_Applications.remove_Click($button_Applications_Click)
			$button_ping.remove_Click($button_ping_Click)
			$button_remot.remove_Click($button_remot_Click)
			$buttonRemoteAssistance.remove_Click($buttonRemoteAssistance_Click)
			$button_PsRemoting.remove_Click($button_PsRemoting_Click)
			$buttonC.remove_Click($buttonC_Click)
			$button_networkconfig.remove_Click($button_networkIPConfig_Click)
			$button_Restart.remove_Click($button_Restart_Click)
			$button_Shutdown.remove_Click($button_Shutdown_Click)
			$button_UsersGroupLocalUsers.remove_Click($button_UsersGroupLocalUsers_Click)
			$button_UsersGroupLocalGroups.remove_Click($button_UsersGroupLocalGroups_Click)
			$button_ComputerDescriptionChange.remove_Click($button_ComputerDescriptionChange_Click)
			$button_ComputerDescriptionQuery.remove_Click($button_ComputerDescriptionQuery_Click)
			$buttonReportingEventslog.remove_Click($buttonReportingEventslog_Click)
			$button_HotFix.remove_Click($button_HotFix_Click)
			$buttonWindowsUpdateLog.remove_Click($buttonWindowsUpdateLog_Click)
			$button_RDPDisable.remove_Click($button_RDPDisable_Click)
			$button_RDPEnable.remove_Click($button_RDPEnable_Click)
			$buttonApplications.remove_Click($button_Applications_Click)
			$button_PageFile.remove_Click($button_PageFile_Click)
			$button_HostsFile.remove_Click($button_HostsFile_Click)
			$button_StartupCommand.remove_Click($button_StartupCommand_Click)
			$button_MotherBoard.remove_Click($button_MotherBoard_Click)
			$button_Processor.remove_Click($button_Processor_Click)
			$button_Memory.remove_Click($button_Memory_Click)
			$button_SystemType.remove_Click($button_SystemType_Click)
			$button_Printers.remove_Click($button_Printers_Click)
			$button_USBDevices.remove_Click($button_USBDevices_Click)
			$button_ConnectivityTesting.remove_Click($button_ConnectivityTesting_Click)
			$button_NIC.remove_Click($button_NIC_Click)
			$button_networkIPConfig.remove_Click($button_networkIPConfig_Click)
			$button_networkTestPort.remove_Click($button_networkTestPort_Click)
			$button_networkRouteTable.remove_Click($button_networkRouteTable_Click)
			$buttonCommandLineGridView.remove_Click($buttonCommandLineGridView_Click)
			$button_processAll.remove_Click($button_processAll_Click)
			$buttonCommandLine.remove_Click($buttonCommandLine_Click)
			$button_processTerminate.remove_Click($button_processTerminate_Click)
			$button_process100MB.remove_Click($button_process100MB_Click)
			$button_ProcessGrid.remove_Click($button_ProcessGrid_Click)
			$button_processOwners.remove_Click($button_processOwners_Click)
			$button_processLastHour.remove_Click($button_processLastHour_Click)
			$button_servicesNonStandardUser.remove_Click($button_servicesNonStandardUser_Click)
			$button_mmcServices.remove_Click($button_mmcServices_Click)
			$button_servicesAutoNotStarted.remove_Click($button_servicesAutoNotStarted_Click)
			$textbox_servicesAction.remove_Click($textbox_servicesAction_Click)
			$button_servicesRestart.remove_Click($button_servicesRestart_Click)
			$button_servicesQuery.remove_Click($button_servicesQuery_Click)
			$button_servicesStart.remove_Click($button_servicesStart_Click)
			$button_servicesStop.remove_Click($button_servicesStop_Click)
			$button_servicesRunning.remove_Click($button_servicesRunning_Click)
			$button_servicesAll.remove_Click($button_servicesAll_Click)
			$button_servicesGridView.remove_Click($button_servicesGridView_Click)
			$button_servicesAutomatic.remove_Click($button_servicesAutomatic_Click)
			$button_DiskUsage.remove_Click($button_DiskUsage_Click)
			$button_DiskPhysical.remove_Click($button_DiskPhysical_Click)
			$button_DiskPartition.remove_Click($button_DiskPartition_Click)
			$button_DiskLogical.remove_Click($button_DiskLogical_Click)
			$button_DiskMountPoint.remove_Click($button_DiskMountPoint_Click)
			$button_DiskRelationship.remove_Click($button_DiskRelationship_Click)
			$button_DiskMappedDrive.remove_Click($button_DiskMappedDrive_Click)
			$button_mmcShares.remove_Click($button_mmcShares_Click)
			$button_SharesGrid.remove_Click($button_SharesGrid_Click)
			$button_Shares.remove_Click($button_Shares_Click)
			$button_RebootHistory.remove_Click($button_RebootHistory_Click)
			$button_mmcEvents.remove_Click($button_mmcEvents_Click)
			$button_EventsSearch.remove_Click($button_EventsSearch_Click)
			$button_EventsLogNames.remove_Click($button_EventsLogNames_Click)
			$button_EventsLast20.remove_Click($button_EventsLast20_Click)
			$button_SYDIGo.remove_Click($button_SYDIGo_Click)
			$button_Rwinsta.remove_Click($button_Rwinsta_Click)
			$button_Qwinsta.remove_Click($button_Qwinsta_Click)
			$button_MsInfo32.remove_Click($button_MsInfo32_Click)
			$button_Telnet.remove_Click($button_Telnet_Click)
			$button_DriverQuery.remove_Click($button_DriverQuery_Click)
			$button_SystemInfoexe.remove_Click($button_SystemInfoexe_Click)
			$button_PAExec.remove_Click($button_PAExec_Click)
			$button_psexec.remove_Click($button_psexec_Click)
			$button_networkTracert.remove_Click($button_networkTracert_Click)
			$button_networkNsLookup.remove_Click($button_networkNsLookup_Click)
			$button_networkPing.remove_Click($button_networkPing_Click)
			$button_networkPathPing.remove_Click($button_networkPathPing_Click)
			$textbox_computername.remove_TextChanged($textbox_computername_TextChanged)
			$textbox_computername.remove_KeyPress($textbox_computername_KeyPress)
			$button_Check.remove_Click($button_Check_Click)
			$richtextbox_Logs.remove_TextChanged($richtextbox_Logs_TextChanged)
			$form_MainForm.remove_Load($OnLoadFormEvent)
			$ToolStripMenuItem_CommandPrompt.remove_Click($ToolStripMenuItem_CommandPrompt_Click)
			$ToolStripMenuItem_Powershell.remove_Click($ToolStripMenuItem_Powershell_Click)
			$ToolStripMenuItem_Notepad.remove_Click($ToolStripMenuItem_Notepad_Click)
			$ToolStripMenuItem_RemoteDesktopConnection.remove_Click($ToolStripMenuItem_RemoteDesktopConnection_Click)
			$ToolStripMenuItem_compmgmt.remove_Click($ToolStripMenuItem_compmgmt_Click)
			$ToolStripMenuItem_taskManager.remove_Click($ToolStripMenuItem_taskManager_Click)
			$ToolStripMenuItem_services.remove_Click($ToolStripMenuItem_services_Click)
			$ToolStripMenuItem_regedit.remove_Click($ToolStripMenuItem_regedit_Click)
			$ToolStripMenuItem_mmc.remove_Click($ToolStripMenuItem_mmc_Click)
			$ToolStripMenuItem_shutdownGui.remove_Click($ToolStripMenuItem_shutdownGui_Click)
			$ToolStripMenuItem_registeredSnappins.remove_Click($ToolStripMenuItem_registeredSnappins_Click)
			$ToolStripMenuItem_AboutInfo.remove_Click($ToolStripMenuItem_AboutInfo_Click)
			$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Ping.remove_Click($button_ping_Click)
			$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_RDP.remove_Click($button_remot_Click)
			$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_compmgmt.remove_Click($button_mmcCompmgmt_Click)
			$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_services.remove_Click($button_mmcServices_Click)
			$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_eventvwr.remove_Click($button_mmcEvents_Click)
			$ToolStripMenuItem_InternetExplorer.remove_Click($ToolStripMenuItem_InternetExplorer_Click)
			$ToolStripMenuItem_TerminalAdmin.remove_Click($ToolStripMenuItem_TerminalAdmin_Click)
			$ToolStripMenuItem_ADSearchDialog.remove_Click($ToolStripMenuItem_ADSearchDialog_Click)
			$ToolStripMenuItem_ADPrinters.remove_Click($ToolStripMenuItem_ADPrinters_Click)
			$ToolStripMenuItem_netstatsListening.remove_Click($ToolStripMenuItem_netstatsListening_Click)
			$ToolStripMenuItem_systemInformationMSinfo32exe.remove_Click($ToolStripMenuItem_systemInformationMSinfo32exe_Click)
			$ToolStripMenuItem_addRemovePrograms.remove_Click($ToolStripMenuItem_addRemovePrograms_Click)
			$ToolStripMenuItem_administrativeTools.remove_Click($ToolStripMenuItem_administrativeTools_Click)
			$ToolStripMenuItem_certificateManager.remove_Click($ToolStripMenuItem_certificateManager_Click)
			$ToolStripMenuItem_devicemanager.remove_Click($ToolStripMenuItem_devicemanager_Click)
			$ToolStripMenuItem_addRemoveProgramsWindowsFeatures.remove_Click($ToolStripMenuItem_addRemoveProgramsWindowsFeatures_Click)
			$ToolStripMenuItem_systemproperties.remove_Click($ToolStripMenuItem_systemproperties_Click)
			$ToolStripMenuItem_Wordpad.remove_Click($ToolStripMenuItem_Wordpad_Click)
			$ToolStripMenuItem_sharedFolders.remove_Click($ToolStripMenuItem_sharedFolders_Click)
			$ToolStripMenuItem_performanceMonitor.remove_Click($ToolStripMenuItem_performanceMonitor_Click)
			$ToolStripMenuItem_networkConnections.remove_Click($ToolStripMenuItem_networkConnections_Click)
			$ToolStripMenuItem_groupPolicyEditor.remove_Click($ToolStripMenuItem_groupPolicyEditor_Click)
			$ToolStripMenuItem_localUsersAndGroups.remove_Click($ToolStripMenuItem_localUsersAndGroups_Click)
			$ToolStripMenuItem_diskManagement.remove_Click($ToolStripMenuItem_diskManagement_Click)
			$ToolStripMenuItem_localSecuritySettings.remove_Click($ToolStripMenuItem_localSecuritySettings_Click)
			$ToolStripMenuItem_componentServices.remove_Click($ToolStripMenuItem_componentServices_Click)
			$ToolStripMenuItem_scheduledTasks.remove_Click($ToolStripMenuItem_scheduledTasks_Click)
			$ToolStripMenuItem_PowershellISE.remove_Click($ToolStripMenuItem_PowershellISE_Click)
			$ToolStripMenuItem_adExplorer.remove_Click($ToolStripMenuItem_adExplorer_Click)
			$ToolStripMenuItem_hostsFileGetContent.remove_Click($ToolStripMenuItem_hostsFileGetContent_Click)
			$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Qwinsta.remove_Click($button_Qwinsta_Click)
			$ToolStripMenuItem_rwinsta.remove_Click($button_Rwinsta_Click)
			$ToolStripMenuItem_GeneratePassword.remove_Click($button_PasswordGen_Click)
			$ToolStripMenuItem_WMIExplorer.remove_Click($ToolStripMenuItem_WMIExplorer_Click)
			$timerCheckJob.remove_Tick($timerCheckJob_Tick2)
			$form_MainForm.remove_Load($Form_StateCorrection_Load)
			$form_MainForm.remove_Closing($Form_StoreValues_Closing)
			$form_MainForm.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch [Exception]
		{ }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	#
	# form_MainForm
	#
	$form_MainForm.Controls.Add($richtextbox_output)
	$form_MainForm.Controls.Add($panel_RTBButtons)
	$form_MainForm.Controls.Add($tabcontrol_computer)
	$form_MainForm.Controls.Add($groupbox_ComputerName)
	$form_MainForm.Controls.Add($richtextbox_Logs)
	$form_MainForm.Controls.Add($statusbar1)
	$form_MainForm.Controls.Add($menustrip_principal)
	$form_MainForm.AutoScaleMode = 'Inherit'
	$form_MainForm.AutoSize = $True
	$form_MainForm.BackColor = 'Control'
	$form_MainForm.ClientSize = '1170, 719'
	$form_MainForm.Font = "Microsoft Sans Serif, 8.25pt"
	$form_MainForm.MainMenuStrip = $menustrip_principal
	$form_MainForm.MinimumSize = '1178, 746'
	$form_MainForm.Name = "form_MainForm"
	$form_MainForm.Text = "LazyWinAdmin"
	$form_MainForm.add_Load($OnLoadFormEvent)
	#
	# richtextbox_output
	#
	$richtextbox_output.Dock = 'Fill'
	$richtextbox_output.Font = "Consolas, 8.25pt"
	$richtextbox_output.Location = '0, 224'
	$richtextbox_output.Name = "richtextbox_output"
	$richtextbox_output.Size = '1170, 365'
	$richtextbox_output.TabIndex = 3
	$richtextbox_output.Text = ""
	$tooltipinfo.SetToolTip($richtextbox_output, "Output")
	$richtextbox_output.add_TextChanged($richtextbox_output_TextChanged)
	#
	# panel_RTBButtons
	#
	$panel_RTBButtons.Controls.Add($button_formExit)
	$panel_RTBButtons.Controls.Add($button_outputClear)
	$panel_RTBButtons.Controls.Add($button_ExportRTF)
	$panel_RTBButtons.Controls.Add($button_outputCopy)
	$panel_RTBButtons.Dock = 'Bottom'
	$panel_RTBButtons.Location = '0, 589'
	$panel_RTBButtons.Name = "panel_RTBButtons"
	$panel_RTBButtons.Size = '1170, 34'
	$panel_RTBButtons.TabIndex = 63
	#
	# button_formExit
	#
	$button_formExit.Dock = 'Right'
	$button_formExit.Font = "Trebuchet MS, 9.75pt, style=Bold"
	$button_formExit.ForeColor = 'Red'
	#region Binary Data
	$button_formExit.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAlwSFlz
AAAG6AAABugB4Yi/JwAABShJREFUSEuVlntMU3cUx0+1oEYUHR0KEivKkGEUFOzo5FFACgyGCKgh
yoYzSgaiIupEpw7NHHtEndohTibToGaa/eFjU5Np1M34gPG0IBZExLdzMqrCcHx3TteSjcysa/LJ
vW3v/X7OOf3de0sAyF6IaJg2KKAmampopS5UWzlFG1ipCfSr9J/gW+mp9ijj7/f2Yrnd4VIEv3wO
lBbhSVsLbrfUoK7mR1w89x1OHt2PuXNS5IDuXuz934J9ewthbmtmQTXqql8o+INFwp7/FPBBbu5E
frYO9uzeiscPTWhtroKx+hwunD2GE0ekg2RbB8/5nC7md3sFnrFEDV5EATKiXUWbcP+2ETdM5ait
OIPzZ47g+OFSpKVOF4EtuIP3ha/t6cCzUOViXubU/+pwBSXvMBRYqjfVX0RV2SmcPnkI+3Zvwczp
sTL/TuYZ85R5wpTYJShRu5srJvtixRDH62tzM9HUcMky/8vnv8fhgztRUvQxZkyLFoGES7CZaWd2
y8oYoiVaF0yU35sQBeUH9qFNpV7uz4xh/qjXeCLf2xVHvylGdflpnDp+AIdKDSg2bETym1EikHAJ
bmMeM1+JwNPg7GyuSEpCRUoKfk5IQFl0NMrCdagIC0JNyETU6fxhihiPptAxuKFxxZbAkThYshXH
vi3G/pItKPp8PabHR4pAwiX4V+YRU2wR7FCpzHWLFsGYlYXaefNQlZqK2hmJMCbq0RAXDFP0JDRH
+qBVp8adKSo8CBqAbVp3GArysGfnp9j+2RokxIbLspRwCX7IPGB2WQSFLi7mmvR0VKeloXLWLFQl
TcOVxGjUx4fCFBOIZv043IrwxD3dcPwSPhhtkUo8jSEYdG7YuCoLmzeuRLw+TAS28Pu8f4/5smdE
5XFxuKzX43JEOCrCX0dt2CRcDR3HY/FCS/AI3A1W4ZHOCe3RDuiYpkTHnGHozPBGQYwv8pYuQOzU
YBFI5RJ+l7ndI9jMsztOBOEHJeEnJ0K5C+HKCIJpNKH1VcKDQEJ7BKEj0REd76jRmTMZjUvCkJ0U
gQ2rFkIfrpULTMYi4beYVmanpYO/C073I1xwJlS6EupHEpq9CXcnEB6HcHg8k+6BztwgNK6IQfZM
PQrW5WDt8gxEhmhEIGORym8yN5gd/xCcUBDODiBcGkqodiNc8yTc9PmrevNUDp81BJ3ZfmhapreE
f5Kfi/V5C/HeorkI0waI4I61cgm/3iOYQWTMZhYryJjrSMa8gWRc40zGDSoyfuRGxtoAev40lgVv
e6AxU4PslCgUfJCDDauzsXrpfORkzEbIa/5ym5DqW6zhjbwttOtKPjGB2jviFTClqp+nhvrhwzWL
kb8yC+/nzseyrLeQmZ4Cjb+vCGTuUr2EX2O+sEtw0o/aG6P6dMWrBx5ITY6zBOctmWcJn5kQ1T1m
1Ihnyr59ZfXI7GU0JqaeMfyrQH4Y60vB29HFY6ktyY3bJRqX+EY4cjPTMDs5tnvsGHWXUqn8jT+X
1WMbTxPvNzB1zPYeAb+RMKEP05dxYPoxPtpBlnvKQGa8ZqIvxnqN6nZwUMrtWG4NcnFJ9TaBjOcq
c4XZZhFYgyVUAiXImVExbgw/CkjNeDCjHR0deFVTLrOY4bVBmcy7TAazwMp83go6m0CqdmQGM67W
QB/e+jMaJoiZzPgx3sxI5mXGiZFOFS/649BbMMh6ogRIkAQGWiXyRBvPvMJINy6MdKu0R8DHWOYu
XQxgRPSStRsZkzDcKh9qrby/rXo5+UUd/AkTStTbDGPagwAAAABJRU5ErkJggg==')
	#endregion
	$button_formExit.Location = '1129, 0'
	$button_formExit.Name = "button_formExit"
	$button_formExit.Size = '41, 34'
	$button_formExit.TabIndex = 15
	$tooltipinfo.SetToolTip($button_formExit, "Exit")
	$button_formExit.UseVisualStyleBackColor = $True
	$button_formExit.add_Click($button_formExit_Click)
	#
	# button_outputClear
	#
	#region Binary Data
	$button_outputClear.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAABDNJREFU
SEutlX1M1HUcx793PEii0nGaNx68kIc8hXjIEBiCLolVym4JE2RsbLJKVmJZrbI/1MZktkAwh8UG
WC7joYelPMlBPByPB4XAeRzHs9xNWooWiUHdu89nww3L2qD7bu/97r6/3/fz+nzen+/v9xViYWTv
l0hOJ9snnk11fi8nSfrE/XmbXXOS7BIuZ4ZbL5+MwrfHQu5kJ0k32Sw4B8pPk2VVntyOK/mpaM3b
joKXXQtsCshJlMY15e6yao7K0HxcgUvHg2aoisdsBslOEKIwXVHSnhuGhvdd0JjljzMpjkdtBuBA
VIW89O2NE/XHPFH57joUp8snaM6puUhEaYuFu01gtIOeLXvTc74sYw2+fGMNtJ+5dU907bU2F4tE
mwA4yLk0h9PVH8kw3hGHuZuZmJ3KRL5aWn5QiOD/BdEWCdFyXpraV+U1ecu0D3/8nIHBymRcfMYf
GqUSWY6OAwSRLBtCNkhaLzhkXqvznTNqQlCS4IP6zSrMqNWo8PXBF/tVf3aWuuZSP1yWDeGFp0LF
iQInCdrXUA+8vVH6fDhGNCmYt+zGLdOL6K8OGCZI0LIhrwpxqEQIfOLhgs5PqQ83XsfvlgOYm4zB
beMmmK9uheH7yGmC7FoW5BUh7F9bIeIHNDum5yZ34t51NWZG4zE7FoPpaypMdKzHcLs3htrUs62f
O+4j0NIHLZIaGyLMvwxtxb3xSNwdew4/9YTgtsEf5m53GBsVGGrxwlh36nz7RdnhJUN4QV/V5q6p
/hD8OhSAaX0gZkxPw6LzwqjWAyNtcgw0eMGk9YVZn2Ht+lpZRGtWLqkUXZm8cLInHJZuN5g7N+Du
aDCGGzxg+dGfGr0Sw21uMDY9CUO9D24MHrHqayMHteelcQT6z63MN+1JTt/liZdGddEwNT6K650U
uMsTNw0RMFyRkz2B6KuWYlS3hUAR6K3aAIvhCHTl7jUEWPGwSjiwI4n3+HqSMjZCbNPXhf1mbPTB
WIcChloFpvpUGGoOxXCrHwGUMNTZwdwfR71IsdYV2JUfUAtXWiv9O4CDP0KSkzxJfKLxZyHiqzxZ
xcTVveivccBgUzAGG1bBot+DnktyTPbuJogKvTWBM4UnpB84OoiNC8mtpqvdYghbwpm7kXxJgRyc
FBMZLNL09VGz+lo/siMIvZVuGNOFYvyHZPRWh8x/8/E6TUy4iKdnnyLxKcgJcqJOiwFMY6qCxFkE
kLaRdpJeyDpsf26kM8lqaonFWFcK2ko87lz4cG3FnmiRTvf5ZeNkgkh+JP6sy0hs9wODq2AI+/84
SUVim8KkUhGd85bk1Jl3JLkHE8Sh1c4iluZ3LATmzLeQvEnsAAd/aJOZdr/RDFq7sEBJVx8S94Ut
YDD/Ziu9SB4kPlrZYrblHw1+oIxFfxjG1nGpvAH4JVq1IOeFOc6UK//XoH8BnFniKnIn4rAAAAAA
SUVORK5CYII=')
	#endregion
	$button_outputClear.Location = '1, 1'
	$button_outputClear.Name = "button_outputClear"
	$button_outputClear.Size = '38, 31'
	$button_outputClear.TabIndex = 5
	$tooltipinfo.SetToolTip($button_outputClear, "Clear !")
	$button_outputClear.UseVisualStyleBackColor = $True
	$button_outputClear.add_Click($button_outputClear_Click)
	#
	# button_ExportRTF
	#
	#region Binary Data
	$button_ExportRTF.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAA5BJREFU
SEuVVUtPE2EU5Qe4cScxvHZG9xIxupOAKxfqgqiBkKpJSyASSoEGTVxQISEkEh8rgkJSFiRq7IYE
3bg1PErHQoFCKY+W0hct0AL3+p0vM83Q9AGT3MzXZuaee885905Jie4aGxszT01NDZ4nHA7H4OTk
5KDRaKzT5yh4drlcCouLxIV79ln/G8+cnJyweCfV2Nj47FwgFwVAHdvb26woSrqpqelpURAAoDL9
dRyLUvzvH0qlUhSLxc7E8fExBYNBCoVCtLS0lG5ubn5yIYpODw95a6iXwj9H+fT0lEVCBGl3UCQA
eG9vjwKBAC8uLqYMBsPjvCB6itC+b6Cfva8aKGQf4kMBJhLJZNr96OiIRfXs9/slwObmJjudzmR5
efnlnCB6igL2r+TtttC/umsU/PKOBAASZwK0IHZ3dyVNAoD29/flc5WVlVcKAXD093cKTzv4JJFg
T8NtCo7aznSAqqEJKEKAtnQ6jf/wHFVVVeUHANfhRYVifh/HRdt7LidFPG4+ODiQkUwmSQQnEglU
zPF4HAHxZRHimcIAeHF+fp4EXSREo9XVVfL5fCT4pZ2dHRk4r6+v0/LyMrndbhK809zcHEWjUYAX
pijXoEFwdIYQlEgXCUpgXYbQoEXtjqFDQQ2QIFtMCKkXE4KiEzFktLW1JTvCGd2DrmIAGStCTDW5
9DusqNKECUZyaU3YFGdogmE8F4CaXALokusTk0jMGxsbDI1whtCRSKS4TbEqVL4zk6vZUHAOr0s3
CUpk1ZqLhMgcDofzAywsLCjwtMa3NkDZfIMSUbl0F9y0trYmz6ge+lVUVOSeAxUAfMvR1zjHxtTz
jf+tvV1Uc+cm36u/ywbjQ6p7VMMj45+wOvIDCD8roEJ1CQTNFhOcwzFsbHlB74ctPP3rM//49oaM
bQ94+OOALC5vB2LAFKyAYpTAmqaWlzRh7yX7uIkmJvrI+vo59fW/lTupIIAqJqkDJEdfJ6a0IcRs
bTNS7f1qNrTV863a63Sj+ip/GOmXNs4LIMZdwUSqwwN/S0qEgCzEZCEme71eCCzdgrWtzYpmZcxH
XoDZ2VkF9sNk5nIKkmM3raysyD3k8XjwJZM7CzsJTioIMDMzIzvI9jgoERZE1XLKs6vWTKG6jcrK
ynLb1GQytVqtVhuip6dHRnd3t4yuri6bxWKR0dnZmQmz2WxDdHR0yGhvb+8rLS29pH1w/gOdNdPK
bNoi9AAAAABJRU5ErkJggg==')
	#endregion
	$button_ExportRTF.Location = '95, 1'
	$button_ExportRTF.Name = "button_ExportRTF"
	$button_ExportRTF.Size = '41, 31'
	$button_ExportRTF.TabIndex = 23
	$tooltipinfo.SetToolTip($button_ExportRTF, "Export to Wordpad (RTF)")
	$button_ExportRTF.UseVisualStyleBackColor = $True
	$button_ExportRTF.add_Click($button_ExportRTF_Click)
	#
	# button_outputCopy
	#
	#region Binary Data
	$button_outputCopy.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAATdJREFU
SEvFlr+KhDAQxn2Ee5R7Swt9BjvFSrCxvcZSud5rRaw8EAv/z+4XiER3N05uhQt8ojiZn/OZCbEs
ZSRJQmeK45g8z0Pc712f6nz1nogsSFykkJwz8jynLMsA+b7r4xnkLUDTNNR1nRZyCjizCu91drEA
79h1GeCVXZcBqqoShR7/yWWAsiw3JwFJ01SsrssAfd9T27ZU1zUVRSEAYRgCqu8Dbk8cF8K6ruaA
r/yHOJIwx3H0FeAr/loBMtu2/c+AZVl2FXDsQYwcpxWoANhlIpZF8zxvFZgkRywLME3TBkA1XIsQ
ywIMw7ADYCJXLMA4jhsAdpmIBUCQ7APYxbUIsVpAFEXkuq5oFAmAXSbSAo4HAARjMzPRAwBJt53v
cMI4bmTc512jvQLAriAIyPd9Y6mAG6gAZUPR6LYBAAAAAElFTkSuQmCC')
	#endregion
	$button_outputCopy.Location = '45, 1'
	$button_outputCopy.Name = "button_outputCopy"
	$button_outputCopy.Size = '44, 31'
	$button_outputCopy.TabIndex = 20
	$tooltipinfo.SetToolTip($button_outputCopy, "Copy to Clipboard")
	$button_outputCopy.UseVisualStyleBackColor = $True
	$button_outputCopy.add_Click($button_outputCopy_Click)
	#
	# tabcontrol_computer
	#
	$tabcontrol_computer.Controls.Add($tabpage_general)
	$tabcontrol_computer.Controls.Add($tabpage_ComputerOSSystem)
	$tabcontrol_computer.Controls.Add($tabpage_network)
	$tabcontrol_computer.Controls.Add($tabpage_processes)
	$tabcontrol_computer.Controls.Add($tabpage_services)
	$tabcontrol_computer.Controls.Add($tabpage_diskdrives)
	$tabcontrol_computer.Controls.Add($tabpage_shares)
	$tabcontrol_computer.Controls.Add($tabpage_eventlog)
	$tabcontrol_computer.Controls.Add($tabpage_ExternalTools)
	$tabcontrol_computer.Dock = 'Top'
	$tabcontrol_computer.Location = '0, 87'
	$tabcontrol_computer.Multiline = $True
	$tabcontrol_computer.Name = "tabcontrol_computer"
	$tabcontrol_computer.SelectedIndex = 0
	$tabcontrol_computer.Size = '1170, 137'
	$tabcontrol_computer.TabIndex = 11
	#
	# tabpage_general
	#
	$tabpage_general.Controls.Add($groupbox_InternetExplorer)
	$tabpage_general.Controls.Add($buttonSendCommand)
	$tabpage_general.Controls.Add($groupbox_ManagementConsole)
	$tabpage_general.Controls.Add($button_GPupdate)
	$tabpage_general.Controls.Add($button_Applications)
	$tabpage_general.Controls.Add($button_ping)
	$tabpage_general.Controls.Add($button_remot)
	$tabpage_general.Controls.Add($buttonRemoteAssistance)
	$tabpage_general.Controls.Add($button_PsRemoting)
	$tabpage_general.Controls.Add($buttonC)
	$tabpage_general.Controls.Add($button_networkconfig)
	$tabpage_general.Controls.Add($button_Restart)
	$tabpage_general.Controls.Add($button_Shutdown)
	$tabpage_general.BackColor = 'Control'
	$tabpage_general.Location = '4, 22'
	$tabpage_general.Name = "tabpage_general"
	$tabpage_general.Size = '1162, 111'
	$tabpage_general.TabIndex = 12
	$tabpage_general.Text = "General"
	#
	# groupbox_InternetExplorer
	#
	$groupbox_InternetExplorer.Controls.Add($button_HTTP)
	$groupbox_InternetExplorer.Controls.Add($button_FTP)
	$groupbox_InternetExplorer.Controls.Add($button_IEHPHomepage)
	$groupbox_InternetExplorer.Controls.Add($button_HTTPS)
	$groupbox_InternetExplorer.Controls.Add($button_IEDellOpenManage)
	$groupbox_InternetExplorer.Location = '992, 4'
	$groupbox_InternetExplorer.Name = "groupbox_InternetExplorer"
	$groupbox_InternetExplorer.Size = '141, 104'
	$groupbox_InternetExplorer.TabIndex = 51
	$groupbox_InternetExplorer.TabStop = $False
	$groupbox_InternetExplorer.Text = "Internet Explorer"
	#
	# button_HTTP
	#
	$button_HTTP.Location = '6, 48'
	$button_HTTP.Name = "button_HTTP"
	$button_HTTP.Size = '58, 23'
	$button_HTTP.TabIndex = 31
	$button_HTTP.Text = "HTTP"
	$tooltipinfo.SetToolTip($button_HTTP, "HTTP://<ComputerName>")
	$button_HTTP.UseVisualStyleBackColor = $True
	$button_HTTP.add_Click($button_HTTP_Click)
	#
	# button_FTP
	#
	$button_FTP.Location = '6, 77'
	$button_FTP.Name = "button_FTP"
	$button_FTP.Size = '58, 23'
	$button_FTP.TabIndex = 38
	$button_FTP.Text = "FTP"
	$tooltipinfo.SetToolTip($button_FTP, "FTP://<ComputerName>")
	$button_FTP.UseVisualStyleBackColor = $True
	$button_FTP.add_Click($button_FTP_Click)
	#
	# button_IEHPHomepage
	#
	$button_IEHPHomepage.Location = '6, 19'
	$button_IEHPHomepage.Name = "button_IEHPHomepage"
	$button_IEHPHomepage.Size = '58, 23'
	$button_IEHPHomepage.TabIndex = 29
	$button_IEHPHomepage.Text = "HP"
	$tooltipinfo.SetToolTip($button_IEHPHomepage, "HP HomePage")
	$button_IEHPHomepage.UseVisualStyleBackColor = $True
	$button_IEHPHomepage.add_Click($button_IEHPHomepage_Click)
	#
	# button_HTTPS
	#
	$button_HTTPS.Location = '70, 48'
	$button_HTTPS.Name = "button_HTTPS"
	$button_HTTPS.Size = '58, 23'
	$button_HTTPS.TabIndex = 37
	$button_HTTPS.Text = "HTTPS"
	$tooltipinfo.SetToolTip($button_HTTPS, "HTTPS://<ComputerName>")
	$button_HTTPS.UseVisualStyleBackColor = $True
	$button_HTTPS.add_Click($button_HTTPS_Click)
	#
	# button_IEDellOpenManage
	#
	$button_IEDellOpenManage.Location = '70, 19'
	$button_IEDellOpenManage.Name = "button_IEDellOpenManage"
	$button_IEDellOpenManage.Size = '58, 23'
	$button_IEDellOpenManage.TabIndex = 30
	$button_IEDellOpenManage.Text = "Dell OM"
	$tooltipinfo.SetToolTip($button_IEDellOpenManage, "Dell OpenManage")
	$button_IEDellOpenManage.UseVisualStyleBackColor = $True
	$button_IEDellOpenManage.add_Click($button_IEDellOpenManage_Click)
	#
	# buttonSendCommand
	#
	#region Binary Data
	$buttonSendCommand.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAArdJREFU
aEPtmVurElEUx70LmgdDsxfxgtiDD4KSoqh4v9++Rg89HXroQFBRUK99oDreLeolqkOn6ELU5/i3
1+CInqPO0WmaUUb449Y9s12/ddlrcGsAaPZZe208OV4FkDv9DiMCj548u/v46XPsg04ePDzWaDQm
Ju28BsjwD+c/ZdOdkxcg8TZs+ky2MuNvEoRiALZx3gzgFgO4tgRw9vUXXk8ngpqya6YT0nilJuz7
yZg0WqsxmxuPSEOMSMMBp+Ggz2nQ76HfO0Xv9NWSCHQGEGIAR0sAX378QbfbnavT6aDdbnNqtVpo
NpucGo0G6vU6arUaqtUqKpUKyuUySqUSisUiCoUC8vk8crkcstksMpkM0uk0UqkUkskkEokE4vE4
YrEYIpEIwuEwQqEQgsEg/H4/3G43XC4XbDYbjEYjpctchw1w/v33fkdgFQDLMe61LoVoTjEpdBGA
jONrgMZ8DdCYrwEeUBE1sAlgUxHzELIX8a4AlEL8S9ZdaJcUWtxGeQjZttHP3y7vQkJFfLEP0PU8
wDwsKwZWqxUkk8m0tM/r9XruO4PBABprtdqr94HRu7Odt1FqWNSQfD4fHA7HpQa02IzEjF9O3q/v
xNsCUGel7mm325e8JMZAoXtFA1DKUNu3WCz/zehFqJ0B6LnG6/VyuSnkJSnntwaghhUIBKDT6WQ1
nHfKRoDh209LRRyNRmE2mxVh+FYA9Pjg8XgUZfiVAShlnE6nIo0niI0p1H/zkWsuUhah2LU3AtCk
2B+Q+n4VQGoPC62vRkDIQ1LPqxGQ2sNC66sREPKQ1PNqBKT2sND6hx8BIlS6Vv69fnzvfnkfjpdm
xt9mqRZgsszPB9gHI9MNpiATHR4oWWT8dSb9IoB2BmFl70cKl4WMZ+JOWA/jmFXuw2oxv69GQIz3
/sW9ex+BvyqSIHA3g0ULAAAAAElFTkSuQmCC')
	#endregion
	$buttonSendCommand.ImageAlign = 'TopCenter'
	$buttonSendCommand.Location = '595, 4'
	$buttonSendCommand.Name = "buttonSendCommand"
	$buttonSendCommand.Size = '66, 77'
	$buttonSendCommand.TabIndex = 50
	$buttonSendCommand.Text = "Send Command"
	$buttonSendCommand.TextAlign = 'BottomCenter'
	$buttonSendCommand.UseVisualStyleBackColor = $True
	$buttonSendCommand.add_Click($buttonSendCommand_Click)
	#
	# groupbox_ManagementConsole
	#
	$groupbox_ManagementConsole.Controls.Add($button_mmcCompmgmt)
	$groupbox_ManagementConsole.Controls.Add($buttonServices)
	$groupbox_ManagementConsole.Controls.Add($buttonShares)
	$groupbox_ManagementConsole.Controls.Add($buttonEventVwr)
	$groupbox_ManagementConsole.Location = '815, 4'
	$groupbox_ManagementConsole.Name = "groupbox_ManagementConsole"
	$groupbox_ManagementConsole.Size = '171, 77'
	$groupbox_ManagementConsole.TabIndex = 49
	$groupbox_ManagementConsole.TabStop = $False
	$groupbox_ManagementConsole.Text = "Management Console (MMC)"
	#
	# button_mmcCompmgmt
	#
	$button_mmcCompmgmt.Font = "Trebuchet MS, 8.25pt"
	$button_mmcCompmgmt.ForeColor = 'ForestGreen'
	$button_mmcCompmgmt.Location = '2, 19'
	$button_mmcCompmgmt.Name = "button_mmcCompmgmt"
	$button_mmcCompmgmt.Size = '82, 23'
	$button_mmcCompmgmt.TabIndex = 7
	$button_mmcCompmgmt.Text = "Compmgmt"
	$tooltipinfo.SetToolTip($button_mmcCompmgmt, "Launch Computer Management Console (compmgmt.msc)")
	$button_mmcCompmgmt.UseVisualStyleBackColor = $True
	$button_mmcCompmgmt.add_Click($button_mmcCompmgmt_Click)
	#
	# buttonServices
	#
	$buttonServices.Font = "Trebuchet MS, 8.25pt"
	$buttonServices.ForeColor = 'ForestGreen'
	$buttonServices.Location = '84, 19'
	$buttonServices.Name = "buttonServices"
	$buttonServices.Size = '71, 23'
	$buttonServices.TabIndex = 45
	$buttonServices.Text = "Services"
	$tooltipinfo.SetToolTip($buttonServices, "Launch Services.msc")
	$buttonServices.UseVisualStyleBackColor = $True
	$buttonServices.add_Click($buttonServices_Click)
	#
	# buttonShares
	#
	$buttonShares.Font = "Trebuchet MS, 8.25pt"
	$buttonShares.ForeColor = 'ForestGreen'
	$buttonShares.Location = '84, 48'
	$buttonShares.Name = "buttonShares"
	$buttonShares.Size = '71, 23'
	$buttonShares.TabIndex = 46
	$buttonShares.Text = "Shares"
	$tooltipinfo.SetToolTip($buttonShares, "Launch Fsmgmt.msc")
	$buttonShares.UseVisualStyleBackColor = $True
	$buttonShares.add_Click($buttonShares_Click)
	#
	# buttonEventVwr
	#
	$buttonEventVwr.Font = "Trebuchet MS, 8.25pt"
	$buttonEventVwr.ForeColor = 'ForestGreen'
	$buttonEventVwr.Location = '2, 48'
	$buttonEventVwr.Name = "buttonEventVwr"
	$buttonEventVwr.Size = '82, 23'
	$buttonEventVwr.TabIndex = 47
	$buttonEventVwr.Text = "Event Vwr"
	$tooltipinfo.SetToolTip($buttonEventVwr, "Launch Eventvwr")
	$buttonEventVwr.UseVisualStyleBackColor = $True
	$buttonEventVwr.add_Click($buttonEventVwr_Click)
	#
	# button_GPupdate
	#
	$button_GPupdate.Font = "Microsoft Sans Serif, 8.25pt"
	#region Binary Data
	$button_GPupdate.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAlwSFlz
AAAK/wAACv8BNGKaggAAEutJREFUaEOlWQdYVNfWvRgTRUWRIr0OwzDUGaoUQUCRKqKIBX0qYEMF
6Yp0FMSOItJRBMGKXewa4wPFXtAkmqJJTIy/eTFqLMH173MBxYKBhO+7H+3MzFln77322utwALh/
+zjFirrbhgv8LUP0qiQTdS5bBGvfNh+vfc9srNbv9Dyj37+XTtI9ZhWql2c9TT/MdqZA899+Ztvr
//HmjZZ3k+nnz4Wqj+x+QC9A/olJoAbEI9Rh6KMKQy9ViPzUYTxKAwQAht6qEHqp8N9FfqrQ9OjT
PMBb5oSMGzfy3wL5RwAUgzgPUbBikyRYG3TSsAjWgWOUITyXmGHUBluM2WyPMTUDEURPy3c7+BdZ
wSPHHIMSjGA6ugWU+pBe6O/G3e3jzaVxqly3fwKmSwBkAzmBzkTZfaKJSq8sp+hiUJwIvmulCKyy
ReBGO4xcb4uAUhuMKLHGiOJ2D/0eUGbD/5+tY8C8VlqA0okio0aRUwNFsUnOl7PoKohOA1CZxM00
mz7ghV24AA5RQvislrRsurxlw8OLpPApMIdnvjE81hq9efLF8FxnAu8CM/gWSmidJb+egRldZYcR
9HoGhKWe5rA+L3q5c4s6A4Jz4fpQTRV2CoB6GJdhMUvllUO0kNLEAiM30GnSBw8vlsKLNueeZ4Dh
hVLM2ByA1P2zsPRYIpbRs/zYAvp5HlL3zULktrGYXDkMo8rseTB+BJgHQu8zumoghmaZ8jXE0krJ
Q+a8zBBOviMgcl5chM7wfg9NgzQ/zkAG2ZyM0ew+xZZR6hg0T0ybtOQ/0K9IAg86WdfVAkTtGIeq
xnXYcXkDNp1bh/KGlSg8vRirT6TzAHIOx2PxwRgsqotC+oEIHkzUjmAEljoQEHM+cgGl1hhVwdLP
GlZhehD5qkHXX/5m/wBOqT2Ibu7cEIWhMjc0h/XmCeKjAPpO5D6zXaC1a3CSMVzTTCinrTCi1IrS
wRhuq/WRdmAWDt2sxeEvd2Hn5UpsvlBMQPKx/kwuSv67HAVfLEbe55lYdTwFy44mYjEBWXgwCmn7
5yBl30wk7ZuOyO1jEFBsw6eWP73/yHJKq0o72ITrt4Dw63tbK7iHWv8RnK6yT7cDGkP6vGKpRpQN
yURdBuBVhylkNq9/4ZBMEz607GT8iiVwWyPAhA1uOHnrABq//wLHv96HuhvbsedqNYHYiK0Xy1B9
vpCPSEVjHsrPrkQRRYMBWUlAlh6dj+xDscisi0T6/tlI3j8TyXunY/x6F/gUmreCsOFJwS7cgAdh
OkbrFzrt5yJfVZiN0YLnMgsE73SE5WSdjgEI4j4d7ZCui6E5ZgigPPUpMofTKi2s/Xwhvvu/r3H5
p0bUf3scn9+qw7Gv9uLol7txhJ4Tt/fh1Pd1OPL1TlSczUPukQxsrM/DjqYyVF5cg8KGHKw6mUoR
mY+sQzHIqKOUIiCsbiZVevAkwEeCGCuw0pZO2gBCTxWI/dXhmmrCR4enaWIxyQRtAqD1fgREiZ/p
OWfrP/JcRm9GOe9daAqHFRr8Cd//42d8ef8aLv94FufvnMbZ707i3N0vcOXnRgKyG2HF/rCeqwPh
pL4QTe4P0SRFCCfIwzREBcPTByG5JgLl9StQ1JCNlSeS+fpYdDCagEQiY38Eplb7vAVi1EZbuCSJ
edIIZDVCwFjhB20aCPMWAM1vpZB+Bvfp4GWCMz65UvjlW7aevCa++OYwHr/4A3d/+xa3fr2Bm79c
QdO9i7j14Dou/3wGYUUBMJ2lAMtIDZjMUm7WD+t9SSWYq1OewFXqhcoeFocpPZFO1YL4PwMgmaKN
tK1RqLiYi7WnMlrrIw6LKCJZVOxjywdRTVjwfYT1FLbpto239RYGwOJDAIwzey0fvs6S3/yIEis4
5+pgI6UC+3r49AHu/X6XB3Hn4Te4//gnNHx/HI7perCJ14I0VvW+UaTcYvkpnPa79Mc5cp9QH3HV
myK7VjhR/qV4ghKCMj1QeSEPxQ1LkXsila+PnMMJVCPRfK9gTPdWM2zXGDsEoJfOhbrnCR8OL7Ci
DivB5AoPfvPs6/GzR3j45Fc8eHwfT188wcHr22GdrAaHZD3YJmod15zBKXamAalN4qQmU5VumIWq
w2aGADl7ElB+bgXWUDRWHEuiZwEV+BwMo4boX0wH2b6jt/7cDsBf77EQgVC0X6FW4rZa8Mp5uQ6m
VQbgyfNHPIjmV3/x328/uAGLZCVYJanCNEF+lUFW13SMVZS6o81svcdGkxVhENQfK3anElst4Uli
9ck05J1MR9gmH77hfRBANaUQaTCqgfcBtJ2i2eLejm55BlfdVwthna2IdZ9nv46GZ64ZnLOIi5MV
Czpz6m1r5II5ZcE02QpRmHyz8VRFjM/yQU1jCbZfLcWGM6upfyyj/pFNQBYR9S7kuzzfsd+JQhAB
YCKSaLVjAOxDKRrdKRpxLqv1/nSiaPjmSRC9bSIGLSEht1j3nCCT+6wzADh3rjvVR7w0Su2R9Vzi
8mRrVJ0uxKnv6rCvqQbbLlH/OFfI11sZdXIGpJSa4bzdIa2pRE30nRqguYMBeMl5r5RECBdzPT+2
EQKiPXCF6k4CAu98Czgv1/ufOF1WtzObZ2v6h3JLrBM0eEr0zLDCtV8a0fTgAjXE/dh/fQt2X63C
jksbqJuXkBwpoB6yBusbVqHybD5GlthSk2thpbZnNLGQdJIOi8JLzm6WwW9Gk5R+ESb2GPd3GzLL
7u1HEblNbOXzd2vf/b/OnG4+tvM1v7GfrwfLGHUsqo0jIOdQ/91RkiO12HttM3ZdqcL2S+ux+XyL
LKkibcUYakieYYuKbQXBxJ9liC7JCZ0XHMnj3wyo22kM6Q2iubP6mZz5xzannNi1gm3/Xn3GcJ+a
xMkvkMSqPmUghqaaY8+Fzbh0rwGf367DwRs7CEjNa1lSc6GIAG3AVCpor3Wm7QDYwWqqPqSTdZ9z
JIx+c42RYHCaCAbDVKDt07fZcLZchWiZjEJXT7mz6xVCOA1xlNxm07kKr8wjlTGneAIu3q2nrn6S
9NVeSqutlFabeIVbe7mCF4ruFIW23sAkhe10AWgeeM4i8L/RyV6YVOsG/1IpKKWg5zYABmMUnpjN
7x9nuETmk85urKvrtGfJuEjjVK9YxWrAPl6AksOrcO3+eZz+9givdFl97KH6qLu+DfN3h/ESnqni
QAJgN0sAm+n6fAR+D0hwxcovEuFZaMyLKL98Kd+qBUMGwDhE+Rtxas9hXd1cZ9fTzNHNOKZfhEXs
gN8togdg/FIvnLxeh8t8Wh0gINtxoGk7pVctPAtMeZnBJsGBcwyYrH7GADzyix+E3V9WILBkIHyL
aOJi4x5V+tAsMxgNV4PG0N4wmNrriGARp9/ZjXV1Xf8pnKJRtFypyVz5ZqsYTSyqnodLPzbizJ0T
OPb1Hpz4ej8vyUkp8MOPfaSQgfiTI4/mkW+8I2pvrseSo/MwlOZZJmmZkGLSdRShHZQggmDoAOiN
6PeXOLpvrmipTO+ubrCz6xWnc9bCSNkG4exe8Em3Q+3pGl4w1t85hsY7p/gJbni5BI4xhrCfKyQA
4YInPvEOqG0qRyVR1/j1g3lJy1NWq5vAQsaGGptpAqoPZRiOV/hNkqIYZpgjI9PZjXV1nWY4F2IW
o/irNFoF0QWhqL9xHDceXEZx/VJ4FBnCKdaQgXjK+sBT7wR77Lq5kTrhGqyh6eld3n0zfNvBJ1cC
M2rjzLwynTbgimlWb7uubq6z6+VDODnDqD6rxFH9/nJdYIqyffn49tevMKbKHg4JBhgUL3rMUR49
9Z3vgP1fVfMdsIZGwpBNXh8UUmw6Y/XB1OCQhSYwDtCgubXfK8NwuW2UVqqd3VhX11EnFwsiehwz
mC2LyDWTsGpvBpwSBXCeb/SYo2L402eBAw7e2tbS/WieLa5fRrXwhnffFVOv64MmJWeqDza7Go5T
fEZzdBqlVaf00YdAqKZ8vEmqz+RGm8cq/eCRZgHH+UIMThL/wTnMFT7zTnLA0W920ekXUfvOB+uA
bE5lBlX7Fv4hty2wgmxDqhdb6h9G5OuYT1f90Si5R5c9T6O0nua6U2TvSVKUZpA267C2lGdwPcUx
/RbaJGg+c001fsQ5Rhs+80mxx4nv9pKrUMq7CpvOr+N/Dqv25V01xkodTUesPhhbjSU/lNmFZmO1
oTuiH/Rjutf0iu14I+0jQFHrYzZD5Y5JoBbMyKySzFE7b5rd66OShrq5nnuGSSVHlfzcN2UgTt85
yLfuNhCsFmrOFfMbf81K7+hylkqsJhgvD04Ww3wczb2TlV/SkLOChpxOU61RZN+dZqM1ya6U8r3H
fLwOyDxuNo3rnyfM+fj7cE5xohc+qXZo+OFYi6xtA3GBAJwv4Scl1hv8yHxqHwW2eeYUeJD1YjlZ
l6hVEeK5/faR9Oi0zGZRMIjrHimgqcw1xYTvsLxDV2YNR6JJZs2bh6v9KkruEdRR4XPUpF54p9vi
wr1T2Hd982ttvuVCKUWgCFsvlJGjNpdAiN6qB+YUOMaKSHLogA6heVixeHhX2UUQ/1mM0WSlZvsI
A9o4uQ+tzjbvC1FtMQPZhkSb4TgFOhy5YzSXvKcEOOd5Ri+8Mmyo2zWgjjRHmy5nAwYDwbT5jksV
mF7t/9agzdvl5JNSIfERIP/0J9OFvVw6A4KKtIdprHyNiNwJh2hDvkny1km7FOUpm6zGUcR0Qxaa
wjKUrMRpKi+I6dJVkrjubZ/DuSSKX3qlS3H9fiMO39z5QRAsCuxh7hlzC9os8jY69c2TkrDSh2mY
SrNZokKpxVK5wcLs98dN2riCJFUxXhKp9q3VFD24pZvwptW7vs9rIEwJUFSYfPamBmodpg+beZpH
aJR9zVIccelLzwwpbj64hONkEzIQh0j5Hbq5CwebdmDPtU3YQozEorH9Ujmm1fjxspZpkja5wSLB
NsGMYOYuk8yFdK7ac+Oovsd1I7oVkWzeZRTRt4HY5YX1VF0QdcObGIuxF582/Mkzpnuf7XhjiyJk
N9sAVjEadyUr+vZrH2VucLLxX0MzzXH74XWcunUQp8mFO3vnJHZcXU9Grjt2N1Vif9OWVhAl/IDB
XGUmN5i05Sm29aRG8Tc01vxpuZOjzRQjiUUMjBDyRemaYgw/dqNDhdp2McJezyIaVO5I8y/rKW9A
tLCcDd0EGTJqfW6yUPY9auUoh5uHZprihz++xZV7jThLU1HEtjGQxCrDKEQRblli7Gmqfg2CDd5b
yUXIPZHCe6esT7SPRpsdyMAwRgkkf5M97Gf+CqrV32zbODv14A2DMW6DC0aXORAIm9eHwt6D5b/5
DLogTO458UP1xVEeNnsttsTjV4+QeyoVtskasAhXI2YRvqRGcdVylhbcs0VvIkHUuon1COrW1ecL
6OaFRUPE10abz99h06NUYRtnXg/rLWPLnRFa5YXJVcMwocINY9c7t4AobYkQSzN7ip5FskJ+hzTq
nmn6yiPHFEHrHGE+hxTmHGWYzZffQ7mm67RW41OHdJ091pHacMs2xtYrZVTk27DtYjlJjgLeNdhE
IJifk0Q+/2i6PmIDB6uRtnsx5q6xhw3l7G9e+SaYuNENEdvHYs7WIEyv8ScQ3jxBMBDjKlwwduMg
eC03b9H8qdr1BovesM67QDgWIicSZI7xhrBL1rpmnC7r2n4RMUp3x0ydWttoPThk6iDzcCQOf1VL
zkFFy+bpIoN5OOsbcnl3jblqzGWetysU4VtG0b3ZSETTldL83aF0MzMDyfvC6X8hdM00gQcQTv+f
Vj0cYVU+CKn2wsQKV3hQN3akG1CHDN1DFsvkOrwrY/vkWOsemKT90CZ7wExC+sG7WsFC7hNpquIG
CxoubBO1MbbMGbVXK4ihqvk+UXFmDcqY7396KQrpain/VBbWnszEmhNpvGG7hF0v0R0ZE4gL9kxD
AgGIrf0P5m4fz4OYvSUQs7aOQjBFwDlZBKs49WZphnImfe7fDkwccfhSWti3Mw1InCYbSFF6ODBB
Dy45AiTuD+ELmkkQJgJZJJj0WEcA1pzM4GfYtvsx/iKDLvlSKAIMBHMZmHWYsGcKoneOx6gCBzgv
EMEuSesPcUbPThtnnbpmbQ+OBnslisYO6wRmrevDIUsboTW+KPzvYuy+VkV0W0KjaR5K65dTNHJ4
k3Y1RWL5sWQsPcLuAOKRfTgWqQdmYupmf/itssKgFCGckyhlMnWvUsrqdeYwX3firixuv1YniQuQ
JivW2y7QgFOKAZwW6cF9pRBB650we1sgXeBNR/aRaKTQRV7i3hBE76J02R6IaZv9EFBA6jVLiEGp
hmCvlyQr1Jtk9grurFn8ViP7pwDaXkfpZ2aZrlTklKn71I1uNQdniOGSYYjBi2hiyqEnu/VZaMj/
3SXdCK6ZxmDrrTKVCun1pv9mD11OoY4+jLi/D93seFJNxZOur/BeJTlPz2N67lJnbiQzYDf9vdB3
jTSNrrAmsfX/ZuNtr/1/vR/R9hoLMGwAAAAASUVORK5CYII=')
	#endregion
	$button_GPupdate.ImageAlign = 'TopCenter'
	$button_GPupdate.Location = '447, 4'
	$button_GPupdate.Name = "button_GPupdate"
	$button_GPupdate.Size = '74, 77'
	$button_GPupdate.TabIndex = 0
	$button_GPupdate.Text = "GPupdate"
	$button_GPupdate.TextAlign = 'BottomCenter'
	$tooltipinfo.SetToolTip($button_GPupdate, "Group Policy update (via WMI)")
	$button_GPupdate.UseVisualStyleBackColor = $True
	$button_GPupdate.add_Click($button_GPupdate_Click)
	#
	# button_Applications
	#
	$button_Applications.Font = "Microsoft Sans Serif, 8.25pt"
	#region Binary Data
	$button_Applications.Image = [System.Convert]::FromBase64String('R0lGODlhMAAwAIcAAAAAAFpaW1RUZVlZdkN3YU1zc2NjY2FhbWpqamZmd3lhe3FxcXx8fABr0QB1
2x581gB/5F5ehV90qVt9tmJjimdomXBvmHh6hnFxnGxuomV1qmF/s3Z2qHx8tAGaAQ2TExqMJhWn
DhqqESWxGDGuNDK6ITOATT3BKEm1UEOvYEnKMVHFL1nUO2bdRHPlTACI7QWY/BKf/xui/iim/jeh
7zir/Fayj32Fr3iEtnO7v1KPz1Of30uy/VKx8VW1/1qy9Vq3/169/mST0XaRyWis5m2462S6/m63
8mm8/3m36nC+/XTGgHfD9nXA/3jE93vC/3zI+4ZpeaZWRrVuTqZtYN9pI9JtMM5+WqmQIIjzWqLq
W7PoXPqVNf+iPO6oXuy+T/+oQv+xS8zVVdvFT4SEhIODjY2NjYOAlpeXmIWFqYeHuo+dqpmZu5ml
spqouKOjo6Cir6urrKaqt6asv6ussKuruqq0vbOzs7u7u4eIxomL15OUxpKf0p+f0pyc2pmZ5Zub
/oOgxpiqyZOn2p2yzIy354e0/Jmm/5Ww45a945e57JS7/6WlyaSo26ys2a2zzKG52LO3xLKyzL+/
xb+/zLO00bq6076+2ays6aen/qW/5amy5a298LOp/7Oz5ru85be2/q7dv5/F34TF/4nH/4/L/JvL
65bC+ZbP9pTK/5jC9ZnF/5vM/5nR+7bEz7vO26bE7KTM/6zB9KvM/63S7KbT/bLN5rDP6L/C67PM
/7vM/7LQ57ba9bLZ/7vd/77h/NyvgdGzksS7/8LAudDOp+nnp8PDw8DAzcvLy8DA1sbG2c7O087O
3dTU1NHR3tXY2dra2sTE5cLC7MjI5sXF8sTE/sPM/83E/83P9svL/snc7NLM/dPT4dbX7tbd5Nbf
6Nrc5Njc6dHS8tPT/9vb/83g7cji+9Xg693j6dbp/OrF/+7X//3M//rY/+Pj4+Lk7eTo7Ovr6+Pj
8+Pj/uPt8+vt8+vr/+n0/v3o/vPz8/T0/PP4//7x//39/f///wAAACH/C05FVFNDQVBFMi4wAwEB
AAAh+QQBAAD+ACwAAAAAMAAwAAAI/wD9CRxIsKBBd9CeGWuWT6A+gxAjQkSo0NgdOpHkzHn06NMn
aXWMxXuGxxgePMieNZRIsJnFOHbauCFECJImTbNy6dTF05rPbJXIQKOzr59Rd80m3UG2EiIyaHGO
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
EAA7')
	#endregion
	$button_Applications.ImageAlign = 'TopCenter'
	$button_Applications.Location = '521, 4'
	$button_Applications.Name = "button_Applications"
	$button_Applications.Size = '74, 77'
	$button_Applications.TabIndex = 0
	$button_Applications.Text = "Apps"
	$button_Applications.TextAlign = 'BottomCenter'
	$tooltipinfo.SetToolTip($button_Applications, "List Applications installed")
	$button_Applications.UseVisualStyleBackColor = $True
	$button_Applications.add_Click($button_Applications_Click)
	#
	# button_ping
	#
	$button_ping.Font = "Microsoft Sans Serif, 8.25pt"
	#region Binary Data
	$button_ping.Image = [System.Convert]::FromBase64String('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
AAAAAElFTkSuQmCC')
	#endregion
	$button_ping.ImageAlign = 'TopCenter'
	$button_ping.Location = '3, 4'
	$button_ping.Name = "button_ping"
	$button_ping.Size = '74, 77'
	$button_ping.TabIndex = 0
	$button_ping.Text = "Ping"
	$button_ping.TextAlign = 'BottomCenter'
	$tooltipinfo.SetToolTip($button_ping, "Ping it")
	$button_ping.UseVisualStyleBackColor = $True
	$button_ping.add_Click($button_ping_Click)
	#
	# button_remot
	#
	$button_remot.Font = "Microsoft Sans Serif, 8.25pt"
	#region Binary Data
	$button_remot.Image = [System.Convert]::FromBase64String('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')
	#endregion
	$button_remot.ImageAlign = 'TopCenter'
	$button_remot.Location = '77, 4'
	$button_remot.Name = "button_remot"
	$button_remot.Size = '74, 77'
	$button_remot.TabIndex = 4
	$button_remot.Text = "Remote Desktop"
	$button_remot.TextAlign = 'BottomCenter'
	$tooltipinfo.SetToolTip($button_remot, "Open a Remote Desktop Connection")
	$button_remot.UseVisualStyleBackColor = $True
	$button_remot.add_Click($button_remot_Click)
	#
	# buttonRemoteAssistance
	#
	#region Binary Data
	$buttonRemoteAssistance.Image = [System.Convert]::FromBase64String('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
cwAAAABJRU5ErkJggg==')
	#endregion
	$buttonRemoteAssistance.ImageAlign = 'TopCenter'
	$buttonRemoteAssistance.Location = '225, 4'
	$buttonRemoteAssistance.Name = "buttonRemoteAssistance"
	$buttonRemoteAssistance.Size = '74, 77'
	$buttonRemoteAssistance.TabIndex = 44
	$buttonRemoteAssistance.Text = "Remote Assistance"
	$buttonRemoteAssistance.TextAlign = 'BottomCenter'
	$tooltipinfo.SetToolTip($buttonRemoteAssistance, "Offer a Remote Assistance")
	$buttonRemoteAssistance.UseVisualStyleBackColor = $True
	$buttonRemoteAssistance.add_Click($buttonRemoteAssistance_Click)
	#
	# button_PsRemoting
	#
	$button_PsRemoting.Font = "Microsoft Sans Serif, 8.25pt"
	#region Binary Data
	$button_PsRemoting.Image = [System.Convert]::FromBase64String('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
poU6kFQAAAAASUVORK5CYII=')
	#endregion
	$button_PsRemoting.ImageAlign = 'TopCenter'
	$button_PsRemoting.Location = '151, 4'
	$button_PsRemoting.Name = "button_PsRemoting"
	$button_PsRemoting.Size = '74, 77'
	$button_PsRemoting.TabIndex = 27
	$button_PsRemoting.Text = "PowerShell Remote"
	$button_PsRemoting.TextAlign = 'BottomCenter'
	$tooltipinfo.SetToolTip($button_PsRemoting, "Open a Powershell Remoting Session (PSRemoting)")
	$button_PsRemoting.UseVisualStyleBackColor = $True
	$button_PsRemoting.add_Click($button_PsRemoting_Click)
	#
	# buttonC
	#
	#region Binary Data
	$buttonC.Image = [System.Convert]::FromBase64String('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
jNa7tTOOdvEAAAAASUVORK5CYII=')
	#endregion
	$buttonC.ImageAlign = 'TopCenter'
	$buttonC.Location = '373, 4'
	$buttonC.Name = "buttonC"
	$buttonC.Size = '74, 77'
	$buttonC.TabIndex = 43
	$buttonC.Text = "C$"
	$buttonC.TextAlign = 'BottomCenter'
	$tooltipinfo.SetToolTip($buttonC, "Open Explorer.exe to the C: Drive")
	$buttonC.UseVisualStyleBackColor = $True
	$buttonC.add_Click($buttonC_Click)
	#
	# button_networkconfig
	#
	$button_networkconfig.Font = "Microsoft Sans Serif, 8.25pt"
	#region Binary Data
	$button_networkconfig.Image = [System.Convert]::FromBase64String('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')
	#endregion
	$button_networkconfig.ImageAlign = 'TopCenter'
	$button_networkconfig.Location = '299, 4'
	$button_networkconfig.Name = "button_networkconfig"
	$button_networkconfig.Size = '74, 77'
	$button_networkconfig.TabIndex = 42
	$button_networkconfig.Text = "IP Config"
	$button_networkconfig.TextAlign = 'BottomCenter'
	$tooltipinfo.SetToolTip($button_networkconfig, "Get the ip Configuration")
	$button_networkconfig.UseVisualStyleBackColor = $True
	$button_networkconfig.add_Click($button_networkIPConfig_Click)
	#
	# button_Restart
	#
	$button_Restart.Font = "Microsoft Sans Serif, 8.25pt"
	#region Binary Data
	$button_Restart.Image = [System.Convert]::FromBase64String('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
yulPgf4biUjLzYjxGOQAAAAASUVORK5CYII=')
	#endregion
	$button_Restart.ImageAlign = 'TopCenter'
	$button_Restart.Location = '661, 4'
	$button_Restart.Name = "button_Restart"
	$button_Restart.Size = '74, 77'
	$button_Restart.TabIndex = 0
	$button_Restart.Text = "Restart"
	$button_Restart.TextAlign = 'BottomCenter'
	$tooltipinfo.SetToolTip($button_Restart, "Restart Computer")
	$button_Restart.UseVisualStyleBackColor = $True
	$button_Restart.add_Click($button_Restart_Click)
	#
	# button_Shutdown
	#
	$button_Shutdown.Font = "Microsoft Sans Serif, 8.25pt"
	#region Binary Data
	$button_Shutdown.Image = [System.Convert]::FromBase64String('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
yOl5co93qgAAAABJRU5ErkJggg==')
	#endregion
	$button_Shutdown.ImageAlign = 'TopCenter'
	$button_Shutdown.Location = '735, 4'
	$button_Shutdown.Name = "button_Shutdown"
	$button_Shutdown.Size = '74, 77'
	$button_Shutdown.TabIndex = 1
	$button_Shutdown.Text = "Shutdown"
	$button_Shutdown.TextAlign = 'BottomCenter'
	$tooltipinfo.SetToolTip($button_Shutdown, "Shutdown Computer")
	$button_Shutdown.UseVisualStyleBackColor = $True
	$button_Shutdown.add_Click($button_Shutdown_Click)
	#
	# tabpage_ComputerOSSystem
	#
	$tabpage_ComputerOSSystem.Controls.Add($groupbox_UsersAndGroups)
	$tabpage_ComputerOSSystem.Controls.Add($groupbox_software)
	$tabpage_ComputerOSSystem.Controls.Add($groupbox_Hardware)
	$tabpage_ComputerOSSystem.Location = '4, 22'
	$tabpage_ComputerOSSystem.Name = "tabpage_ComputerOSSystem"
	$tabpage_ComputerOSSystem.Size = '1162, 111'
	$tabpage_ComputerOSSystem.TabIndex = 13
	$tabpage_ComputerOSSystem.Text = "Computer & Operating System"
	$tabpage_ComputerOSSystem.UseVisualStyleBackColor = $True
	#
	# groupbox_UsersAndGroups
	#
	$groupbox_UsersAndGroups.Controls.Add($button_UsersGroupLocalUsers)
	$groupbox_UsersAndGroups.Controls.Add($button_UsersGroupLocalGroups)
	$groupbox_UsersAndGroups.Location = '835, 1'
	$groupbox_UsersAndGroups.Name = "groupbox_UsersAndGroups"
	$groupbox_UsersAndGroups.Size = '123, 81'
	$groupbox_UsersAndGroups.TabIndex = 61
	$groupbox_UsersAndGroups.TabStop = $False
	$groupbox_UsersAndGroups.Text = "Users and Groups"
	#
	# button_UsersGroupLocalUsers
	#
	$button_UsersGroupLocalUsers.Location = '14, 21'
	$button_UsersGroupLocalUsers.Name = "button_UsersGroupLocalUsers"
	$button_UsersGroupLocalUsers.Size = '94, 23'
	$button_UsersGroupLocalUsers.TabIndex = 17
	$button_UsersGroupLocalUsers.Text = "Local Users"
	$button_UsersGroupLocalUsers.UseVisualStyleBackColor = $True
	$button_UsersGroupLocalUsers.add_Click($button_UsersGroupLocalUsers_Click)
	#
	# button_UsersGroupLocalGroups
	#
	$button_UsersGroupLocalGroups.Location = '14, 50'
	$button_UsersGroupLocalGroups.Name = "button_UsersGroupLocalGroups"
	$button_UsersGroupLocalGroups.Size = '94, 23'
	$button_UsersGroupLocalGroups.TabIndex = 18
	$button_UsersGroupLocalGroups.Text = "Local Groups"
	$button_UsersGroupLocalGroups.UseVisualStyleBackColor = $True
	$button_UsersGroupLocalGroups.add_Click($button_UsersGroupLocalGroups_Click)
	#
	# groupbox_software
	#
	$groupbox_software.Controls.Add($groupbox_ComputerDescription)
	$groupbox_software.Controls.Add($groupbox2)
	$groupbox_software.Controls.Add($groupbox_RemoteDesktop)
	$groupbox_software.Controls.Add($buttonApplications)
	$groupbox_software.Controls.Add($button_PageFile)
	$groupbox_software.Controls.Add($button_HostsFile)
	$groupbox_software.Controls.Add($button_StartupCommand)
	$groupbox_software.Location = '212, 1'
	$groupbox_software.Name = "groupbox_software"
	$groupbox_software.Size = '617, 102'
	$groupbox_software.TabIndex = 60
	$groupbox_software.TabStop = $False
	$groupbox_software.Text = "Operating System / Softwares"
	#
	# groupbox_ComputerDescription
	#
	$groupbox_ComputerDescription.Controls.Add($button_ComputerDescriptionChange)
	$groupbox_ComputerDescription.Controls.Add($button_ComputerDescriptionQuery)
	$groupbox_ComputerDescription.Location = '474, 52'
	$groupbox_ComputerDescription.Name = "groupbox_ComputerDescription"
	$groupbox_ComputerDescription.Size = '138, 48'
	$groupbox_ComputerDescription.TabIndex = 57
	$groupbox_ComputerDescription.TabStop = $False
	$groupbox_ComputerDescription.Text = "Computer Description"
	#
	# button_ComputerDescriptionChange
	#
	$button_ComputerDescriptionChange.Location = '71, 19'
	$button_ComputerDescriptionChange.Name = "button_ComputerDescriptionChange"
	$button_ComputerDescriptionChange.Size = '59, 23'
	$button_ComputerDescriptionChange.TabIndex = 57
	$button_ComputerDescriptionChange.Text = "Set"
	$button_ComputerDescriptionChange.UseVisualStyleBackColor = $True
	$button_ComputerDescriptionChange.add_Click($button_ComputerDescriptionChange_Click)
	#
	# button_ComputerDescriptionQuery
	#
	$button_ComputerDescriptionQuery.Location = '6, 19'
	$button_ComputerDescriptionQuery.Name = "button_ComputerDescriptionQuery"
	$button_ComputerDescriptionQuery.Size = '59, 23'
	$button_ComputerDescriptionQuery.TabIndex = 56
	$button_ComputerDescriptionQuery.Text = "Query"
	$button_ComputerDescriptionQuery.UseVisualStyleBackColor = $True
	$button_ComputerDescriptionQuery.add_Click($button_ComputerDescriptionQuery_Click)
	#
	# groupbox2
	#
	$groupbox2.Controls.Add($buttonReportingEventslog)
	$groupbox2.Controls.Add($button_HotFix)
	$groupbox2.Controls.Add($buttonWindowsUpdateLog)
	$groupbox2.Location = '217, 7'
	$groupbox2.Name = "groupbox2"
	$groupbox2.Size = '251, 92'
	$groupbox2.TabIndex = 59
	$groupbox2.TabStop = $False
	$groupbox2.Text = "Updates and Deployment"
	#
	# buttonReportingEventslog
	#
	$buttonReportingEventslog.Location = '119, 16'
	$buttonReportingEventslog.Name = "buttonReportingEventslog"
	$buttonReportingEventslog.Size = '123, 23'
	$buttonReportingEventslog.TabIndex = 46
	$buttonReportingEventslog.Text = "ReportingEvents.log"
	$tooltipinfo.SetToolTip($buttonReportingEventslog, "Get WSUS Report")
	$buttonReportingEventslog.UseVisualStyleBackColor = $True
	$buttonReportingEventslog.add_Click($buttonReportingEventslog_Click)
	#
	# button_HotFix
	#
	$button_HotFix.Location = '6, 16'
	$button_HotFix.Name = "button_HotFix"
	$button_HotFix.Size = '107, 23'
	$button_HotFix.TabIndex = 50
	$button_HotFix.Text = "Get-HotFix"
	$button_HotFix.UseVisualStyleBackColor = $True
	$button_HotFix.add_Click($button_HotFix_Click)
	#
	# buttonWindowsUpdateLog
	#
	$buttonWindowsUpdateLog.Location = '119, 41'
	$buttonWindowsUpdateLog.Name = "buttonWindowsUpdateLog"
	$buttonWindowsUpdateLog.Size = '123, 23'
	$buttonWindowsUpdateLog.TabIndex = 45
	$buttonWindowsUpdateLog.Text = "WindowsUpdate.log"
	$tooltipinfo.SetToolTip($buttonWindowsUpdateLog, "Open the WindowsUpdate.log")
	$buttonWindowsUpdateLog.UseVisualStyleBackColor = $True
	$buttonWindowsUpdateLog.add_Click($buttonWindowsUpdateLog_Click)
	#
	# groupbox_RemoteDesktop
	#
	$groupbox_RemoteDesktop.Controls.Add($button_RDPDisable)
	$groupbox_RemoteDesktop.Controls.Add($button_RDPEnable)
	$groupbox_RemoteDesktop.Location = '474, 7'
	$groupbox_RemoteDesktop.Name = "groupbox_RemoteDesktop"
	$groupbox_RemoteDesktop.Size = '138, 42'
	$groupbox_RemoteDesktop.TabIndex = 58
	$groupbox_RemoteDesktop.TabStop = $False
	$groupbox_RemoteDesktop.Text = "Remote Desktop"
	#
	# button_RDPDisable
	#
	$button_RDPDisable.Location = '71, 16'
	$button_RDPDisable.Name = "button_RDPDisable"
	$button_RDPDisable.Size = '59, 23'
	$button_RDPDisable.TabIndex = 49
	$button_RDPDisable.Text = "Disable"
	$button_RDPDisable.UseVisualStyleBackColor = $True
	$button_RDPDisable.add_Click($button_RDPDisable_Click)
	#
	# button_RDPEnable
	#
	$button_RDPEnable.Location = '6, 16'
	$button_RDPEnable.Name = "button_RDPEnable"
	$button_RDPEnable.Size = '59, 23'
	$button_RDPEnable.TabIndex = 48
	$button_RDPEnable.Text = "Enable"
	$button_RDPEnable.UseVisualStyleBackColor = $True
	$button_RDPEnable.add_Click($button_RDPEnable_Click)
	#
	# buttonApplications
	#
	$buttonApplications.Location = '6, 19'
	$buttonApplications.Name = "buttonApplications"
	$buttonApplications.Size = '114, 23'
	$buttonApplications.TabIndex = 56
	$buttonApplications.Text = "Applications"
	$buttonApplications.UseVisualStyleBackColor = $True
	$buttonApplications.add_Click($button_Applications_Click)
	#
	# button_PageFile
	#
	$button_PageFile.Location = '6, 48'
	$button_PageFile.Name = "button_PageFile"
	$button_PageFile.Size = '114, 23'
	$button_PageFile.TabIndex = 52
	$button_PageFile.Text = "PageFile"
	$button_PageFile.UseVisualStyleBackColor = $True
	$button_PageFile.add_Click($button_PageFile_Click)
	#
	# button_HostsFile
	#
	$button_HostsFile.Location = '126, 19'
	$button_HostsFile.Name = "button_HostsFile"
	$button_HostsFile.Size = '85, 23'
	$button_HostsFile.TabIndex = 26
	$button_HostsFile.Text = "Hosts File"
	$button_HostsFile.UseVisualStyleBackColor = $True
	$button_HostsFile.add_Click($button_HostsFile_Click)
	#
	# button_StartupCommand
	#
	$button_StartupCommand.Location = '6, 76'
	$button_StartupCommand.Name = "button_StartupCommand"
	$button_StartupCommand.Size = '114, 23'
	$button_StartupCommand.TabIndex = 27
	$button_StartupCommand.Text = "Startup Commands"
	$button_StartupCommand.UseVisualStyleBackColor = $True
	$button_StartupCommand.add_Click($button_StartupCommand_Click)
	#
	# groupbox_Hardware
	#
	$groupbox_Hardware.Controls.Add($button_MotherBoard)
	$groupbox_Hardware.Controls.Add($button_Processor)
	$groupbox_Hardware.Controls.Add($button_Memory)
	$groupbox_Hardware.Controls.Add($button_SystemType)
	$groupbox_Hardware.Controls.Add($button_Printers)
	$groupbox_Hardware.Controls.Add($button_USBDevices)
	$groupbox_Hardware.Location = '2, 1'
	$groupbox_Hardware.Name = "groupbox_Hardware"
	$groupbox_Hardware.Size = '204, 102'
	$groupbox_Hardware.TabIndex = 59
	$groupbox_Hardware.TabStop = $False
	$groupbox_Hardware.Text = "Hardware"
	#
	# button_MotherBoard
	#
	$button_MotherBoard.Location = '6, 19'
	$button_MotherBoard.Name = "button_MotherBoard"
	$button_MotherBoard.Size = '93, 23'
	$button_MotherBoard.TabIndex = 54
	$button_MotherBoard.Text = "MotherBoard"
	$button_MotherBoard.UseVisualStyleBackColor = $True
	$button_MotherBoard.add_Click($button_MotherBoard_Click)
	#
	# button_Processor
	#
	$button_Processor.Location = '6, 48'
	$button_Processor.Name = "button_Processor"
	$button_Processor.Size = '93, 23'
	$button_Processor.TabIndex = 53
	$button_Processor.Text = "Processor"
	$button_Processor.UseVisualStyleBackColor = $True
	$button_Processor.add_Click($button_Processor_Click)
	#
	# button_Memory
	#
	$button_Memory.Font = "Trebuchet MS, 8.25pt"
	$button_Memory.Location = '6, 77'
	$button_Memory.Name = "button_Memory"
	$button_Memory.Size = '93, 23'
	$button_Memory.TabIndex = 22
	$button_Memory.Text = "Memory"
	$button_Memory.UseVisualStyleBackColor = $True
	$button_Memory.add_Click($button_Memory_Click)
	#
	# button_SystemType
	#
	$button_SystemType.Location = '105, 19'
	$button_SystemType.Name = "button_SystemType"
	$button_SystemType.Size = '93, 23'
	$button_SystemType.TabIndex = 55
	$button_SystemType.Text = "System Type"
	$button_SystemType.UseVisualStyleBackColor = $True
	$button_SystemType.add_Click($button_SystemType_Click)
	#
	# button_Printers
	#
	$button_Printers.Location = '105, 77'
	$button_Printers.Name = "button_Printers"
	$button_Printers.Size = '93, 23'
	$button_Printers.TabIndex = 51
	$button_Printers.Text = "Printers"
	$button_Printers.UseVisualStyleBackColor = $True
	$button_Printers.add_Click($button_Printers_Click)
	#
	# button_USBDevices
	#
	$button_USBDevices.Location = '105, 48'
	$button_USBDevices.Name = "button_USBDevices"
	$button_USBDevices.Size = '93, 23'
	$button_USBDevices.TabIndex = 47
	$button_USBDevices.Text = "USB Devices"
	$button_USBDevices.UseVisualStyleBackColor = $True
	$button_USBDevices.add_Click($button_USBDevices_Click)
	#
	# tabpage_network
	#
	$tabpage_network.Controls.Add($button_ConnectivityTesting)
	$tabpage_network.Controls.Add($button_NIC)
	$tabpage_network.Controls.Add($button_networkIPConfig)
	$tabpage_network.Controls.Add($button_networkTestPort)
	$tabpage_network.Controls.Add($button_networkRouteTable)
	$tabpage_network.Location = '4, 22'
	$tabpage_network.Name = "tabpage_network"
	$tabpage_network.Size = '1162, 111'
	$tabpage_network.TabIndex = 6
	$tabpage_network.Text = "Network"
	$tabpage_network.UseVisualStyleBackColor = $True
	#
	# button_ConnectivityTesting
	#
	$button_ConnectivityTesting.FlatStyle = 'System'
	$button_ConnectivityTesting.Location = '137, 3'
	$button_ConnectivityTesting.Name = "button_ConnectivityTesting"
	$button_ConnectivityTesting.Size = '145, 23'
	$button_ConnectivityTesting.TabIndex = 46
	$button_ConnectivityTesting.Text = "Connectivity Tests (slow)"
	$tooltipinfo.SetToolTip($button_ConnectivityTesting, "Connectivity Testing")
	$button_ConnectivityTesting.UseVisualStyleBackColor = $False
	$button_ConnectivityTesting.add_Click($button_ConnectivityTesting_Click)
	#
	# button_NIC
	#
	$button_NIC.Location = '137, 32'
	$button_NIC.Name = "button_NIC"
	$button_NIC.Size = '145, 23'
	$button_NIC.TabIndex = 11
	$button_NIC.Text = "Network Interface (slow)"
	$tooltipinfo.SetToolTip($button_NIC, "Get the network interface card(s) information")
	$button_NIC.UseVisualStyleBackColor = $True
	$button_NIC.add_Click($button_NIC_Click)
	#
	# button_networkIPConfig
	#
	$button_networkIPConfig.Location = '8, 3'
	$button_networkIPConfig.Name = "button_networkIPConfig"
	$button_networkIPConfig.Size = '123, 23'
	$button_networkIPConfig.TabIndex = 9
	$button_networkIPConfig.Text = "IPConfig"
	$tooltipinfo.SetToolTip($button_networkIPConfig, "Get the ip configuration")
	$button_networkIPConfig.UseVisualStyleBackColor = $True
	$button_networkIPConfig.add_Click($button_networkIPConfig_Click)
	#
	# button_networkTestPort
	#
	$button_networkTestPort.Location = '8, 61'
	$button_networkTestPort.Name = "button_networkTestPort"
	$button_networkTestPort.Size = '123, 23'
	$button_networkTestPort.TabIndex = 8
	$button_networkTestPort.Text = "Test a Port"
	$tooltipinfo.SetToolTip($button_networkTestPort, "Test a port (default = 80)")
	$button_networkTestPort.UseVisualStyleBackColor = $True
	$button_networkTestPort.add_Click($button_networkTestPort_Click)
	#
	# button_networkRouteTable
	#
	$button_networkRouteTable.Location = '8, 32'
	$button_networkRouteTable.Name = "button_networkRouteTable"
	$button_networkRouteTable.Size = '123, 23'
	$button_networkRouteTable.TabIndex = 10
	$button_networkRouteTable.Text = "Route Table"
	$tooltipinfo.SetToolTip($button_networkRouteTable, "Get the route table")
	$button_networkRouteTable.UseVisualStyleBackColor = $True
	$button_networkRouteTable.add_Click($button_networkRouteTable_Click)
	#
	# tabpage_processes
	#
	$tabpage_processes.Controls.Add($buttonCommandLineGridView)
	$tabpage_processes.Controls.Add($button_processAll)
	$tabpage_processes.Controls.Add($buttonCommandLine)
	$tabpage_processes.Controls.Add($groupbox1)
	$tabpage_processes.Controls.Add($button_process100MB)
	$tabpage_processes.Controls.Add($button_ProcessGrid)
	$tabpage_processes.Controls.Add($button_processOwners)
	$tabpage_processes.Controls.Add($button_processLastHour)
	$tabpage_processes.Location = '4, 22'
	$tabpage_processes.Name = "tabpage_processes"
	$tabpage_processes.Size = '1162, 111'
	$tabpage_processes.TabIndex = 3
	$tabpage_processes.Text = "Processes"
	$tabpage_processes.UseVisualStyleBackColor = $True
	#
	# buttonCommandLineGridView
	#
	$buttonCommandLineGridView.Location = '284, 61'
	$buttonCommandLineGridView.Name = "buttonCommandLineGridView"
	$buttonCommandLineGridView.Size = '159, 23'
	$buttonCommandLineGridView.TabIndex = 17
	$buttonCommandLineGridView.Text = "CommandLine - GridView"
	$buttonCommandLineGridView.UseVisualStyleBackColor = $True
	$buttonCommandLineGridView.add_Click($buttonCommandLineGridView_Click)
	#
	# button_processAll
	#
	$button_processAll.Location = '8, 3'
	$button_processAll.Name = "button_processAll"
	$button_processAll.Size = '132, 23'
	$button_processAll.TabIndex = 5
	$button_processAll.Text = "Processes"
	$tooltipinfo.SetToolTip($button_processAll, "Get all the processes")
	$button_processAll.UseVisualStyleBackColor = $True
	$button_processAll.add_Click($button_processAll_Click)
	#
	# buttonCommandLine
	#
	$buttonCommandLine.Location = '146, 61'
	$buttonCommandLine.Name = "buttonCommandLine"
	$buttonCommandLine.Size = '132, 23'
	$buttonCommandLine.TabIndex = 15
	$buttonCommandLine.Text = "CommandLine"
	$tooltipinfo.SetToolTip($buttonCommandLine, "Get the processes CommandLine")
	$buttonCommandLine.UseVisualStyleBackColor = $True
	$buttonCommandLine.add_Click($buttonCommandLine_Click)
	#
	# groupbox1
	#
	$groupbox1.Controls.Add($textbox_processName)
	$groupbox1.Controls.Add($label_processEnterAProcessName)
	$groupbox1.Controls.Add($button_processTerminate)
	$groupbox1.Location = '870, 17'
	$groupbox1.Name = "groupbox1"
	$groupbox1.Size = '231, 83'
	$groupbox1.TabIndex = 16
	$groupbox1.TabStop = $False
	$groupbox1.Text = "Terminate a Process"
	#
	# textbox_processName
	#
	[void]$textbox_processName.AutoCompleteCustomSource.Add("dhcp")
	[void]$textbox_processName.AutoCompleteCustomSource.Add("iisadmin")
	[void]$textbox_processName.AutoCompleteCustomSource.Add("msftpsvc")
	[void]$textbox_processName.AutoCompleteCustomSource.Add("nntpsvc")
	[void]$textbox_processName.AutoCompleteCustomSource.Add("omniinet")
	[void]$textbox_processName.AutoCompleteCustomSource.Add("smtpsvc")
	[void]$textbox_processName.AutoCompleteCustomSource.Add("spooler")
	[void]$textbox_processName.AutoCompleteCustomSource.Add("sql")
	[void]$textbox_processName.AutoCompleteCustomSource.Add("w3svc")
	$textbox_processName.AutoCompleteMode = 'Suggest'
	$textbox_processName.Location = '6, 19'
	$textbox_processName.Name = "textbox_processName"
	$textbox_processName.Size = '116, 20'
	$textbox_processName.TabIndex = 12
	$textbox_processName.Text = "<ProcessName>"
	$tooltipinfo.SetToolTip($textbox_processName, "Enter a process name, example ""notepad.exe""")
	#
	# label_processEnterAProcessName
	#
	$label_processEnterAProcessName.Font = "Trebuchet MS, 6.75pt, style=Italic"
	$label_processEnterAProcessName.Location = '6, 41'
	$label_processEnterAProcessName.Name = "label_processEnterAProcessName"
	$label_processEnterAProcessName.Size = '206, 23'
	$label_processEnterAProcessName.TabIndex = 14
	$label_processEnterAProcessName.Text = "Enter a Process Name (ex:notepad.exe)"
	$label_processEnterAProcessName.TextAlign = 'MiddleCenter'
	#
	# button_processTerminate
	#
	$button_processTerminate.Font = "Microsoft Sans Serif, 8.25pt, style=Bold"
	$button_processTerminate.ForeColor = 'Red'
	$button_processTerminate.Location = '128, 18'
	$button_processTerminate.Name = "button_processTerminate"
	$button_processTerminate.Size = '84, 23'
	$button_processTerminate.TabIndex = 13
	$button_processTerminate.Text = "Terminate"
	$tooltipinfo.SetToolTip($button_processTerminate, "Terminate the process specified")
	$button_processTerminate.UseVisualStyleBackColor = $True
	$button_processTerminate.add_Click($button_processTerminate_Click)
	#
	# button_process100MB
	#
	$button_process100MB.Location = '8, 32'
	$button_process100MB.Name = "button_process100MB"
	$button_process100MB.Size = '132, 23'
	$button_process100MB.TabIndex = 0
	$button_process100MB.Text = "+100MB Memory"
	$tooltipinfo.SetToolTip($button_process100MB, "Get all the processes using more than 100MB of memory")
	$button_process100MB.UseVisualStyleBackColor = $True
	$button_process100MB.add_Click($button_process100MB_Click)
	#
	# button_ProcessGrid
	#
	$button_ProcessGrid.Location = '146, 32'
	$button_ProcessGrid.Name = "button_ProcessGrid"
	$button_ProcessGrid.Size = '132, 23'
	$button_ProcessGrid.TabIndex = 6
	$button_ProcessGrid.Text = "Processes - Grid View"
	$tooltipinfo.SetToolTip($button_ProcessGrid, "Get all the processes in a Grid View form")
	$button_ProcessGrid.UseVisualStyleBackColor = $True
	$button_ProcessGrid.add_Click($button_ProcessGrid_Click)
	#
	# button_processOwners
	#
	$button_processOwners.Location = '8, 61'
	$button_processOwners.Name = "button_processOwners"
	$button_processOwners.Size = '132, 23'
	$button_processOwners.TabIndex = 4
	$button_processOwners.Text = "Owners"
	$tooltipinfo.SetToolTip($button_processOwners, "Get the owners of each processes")
	$button_processOwners.UseVisualStyleBackColor = $True
	$button_processOwners.add_Click($button_processOwners_Click)
	#
	# button_processLastHour
	#
	$button_processLastHour.Location = '146, 3'
	$button_processLastHour.Name = "button_processLastHour"
	$button_processLastHour.Size = '132, 23'
	$button_processLastHour.TabIndex = 7
	$button_processLastHour.Text = "Started in Last hour"
	$tooltipinfo.SetToolTip($button_processLastHour, "Get the processes started in the last hour")
	$button_processLastHour.UseVisualStyleBackColor = $True
	$button_processLastHour.add_Click($button_processLastHour_Click)
	#
	# tabpage_services
	#
	$tabpage_services.Controls.Add($button_servicesNonStandardUser)
	$tabpage_services.Controls.Add($button_mmcServices)
	$tabpage_services.Controls.Add($button_servicesAutoNotStarted)
	$tabpage_services.Controls.Add($groupbox_Service_QueryStartStop)
	$tabpage_services.Controls.Add($button_servicesRunning)
	$tabpage_services.Controls.Add($button_servicesAll)
	$tabpage_services.Controls.Add($button_servicesGridView)
	$tabpage_services.Controls.Add($button_servicesAutomatic)
	$tabpage_services.Location = '4, 22'
	$tabpage_services.Name = "tabpage_services"
	$tabpage_services.Size = '1162, 111'
	$tabpage_services.TabIndex = 2
	$tabpage_services.Text = "Services"
	$tooltipinfo.SetToolTip($tabpage_services, "Services")
	$tabpage_services.UseVisualStyleBackColor = $True
	#
	# button_servicesNonStandardUser
	#
	$button_servicesNonStandardUser.Location = '285, 3'
	$button_servicesNonStandardUser.Name = "button_servicesNonStandardUser"
	$button_servicesNonStandardUser.Size = '133, 23'
	$button_servicesNonStandardUser.TabIndex = 8
	$button_servicesNonStandardUser.Text = "Non Standard User"
	$tooltipinfo.SetToolTip($button_servicesNonStandardUser, "Services set with a Non-Standard user account")
	$button_servicesNonStandardUser.UseVisualStyleBackColor = $True
	$button_servicesNonStandardUser.add_Click($button_servicesNonStandardUser_Click)
	#
	# button_mmcServices
	#
	$button_mmcServices.ForeColor = 'ForestGreen'
	$button_mmcServices.Location = '8, 3'
	$button_mmcServices.Name = "button_mmcServices"
	$button_mmcServices.Size = '132, 23'
	$button_mmcServices.TabIndex = 0
	$button_mmcServices.Text = "MMC: Services.msc"
	$tooltipinfo.SetToolTip($button_mmcServices, "Launch Services.msc")
	$button_mmcServices.UseVisualStyleBackColor = $True
	$button_mmcServices.add_Click($button_mmcServices_Click)
	#
	# button_servicesAutoNotStarted
	#
	$button_servicesAutoNotStarted.Location = '146, 61'
	$button_servicesAutoNotStarted.Name = "button_servicesAutoNotStarted"
	$button_servicesAutoNotStarted.Size = '133, 23'
	$button_servicesAutoNotStarted.TabIndex = 9
	$button_servicesAutoNotStarted.Text = "Auto and NOT Running"
	$tooltipinfo.SetToolTip($button_servicesAutoNotStarted, "Services with StartupType ""Automatic"" and Status different of ""Running""")
	$button_servicesAutoNotStarted.UseVisualStyleBackColor = $True
	$button_servicesAutoNotStarted.add_Click($button_servicesAutoNotStarted_Click)
	#
	# groupbox_Service_QueryStartStop
	#
	$groupbox_Service_QueryStartStop.Controls.Add($textbox_servicesAction)
	$groupbox_Service_QueryStartStop.Controls.Add($button_servicesRestart)
	$groupbox_Service_QueryStartStop.Controls.Add($label_servicesEnterAServiceName)
	$groupbox_Service_QueryStartStop.Controls.Add($button_servicesQuery)
	$groupbox_Service_QueryStartStop.Controls.Add($button_servicesStart)
	$groupbox_Service_QueryStartStop.Controls.Add($button_servicesStop)
	$groupbox_Service_QueryStartStop.Location = '872, 10'
	$groupbox_Service_QueryStartStop.Name = "groupbox_Service_QueryStartStop"
	$groupbox_Service_QueryStartStop.Size = '274, 90'
	$groupbox_Service_QueryStartStop.TabIndex = 13
	$groupbox_Service_QueryStartStop.TabStop = $False
	$groupbox_Service_QueryStartStop.Text = "QueryStartStop"
	#
	# textbox_servicesAction
	#
	[void]$textbox_servicesAction.AutoCompleteCustomSource.Add("dhcp")
	[void]$textbox_servicesAction.AutoCompleteCustomSource.Add("iisadmin")
	[void]$textbox_servicesAction.AutoCompleteCustomSource.Add("msftpsvc")
	[void]$textbox_servicesAction.AutoCompleteCustomSource.Add("nntpsvc")
	[void]$textbox_servicesAction.AutoCompleteCustomSource.Add("omniinet")
	[void]$textbox_servicesAction.AutoCompleteCustomSource.Add("smtpsvc")
	[void]$textbox_servicesAction.AutoCompleteCustomSource.Add("spooler")
	[void]$textbox_servicesAction.AutoCompleteCustomSource.Add("sql")
	[void]$textbox_servicesAction.AutoCompleteCustomSource.Add("w3svc")
	$textbox_servicesAction.AutoCompleteMode = 'Suggest'
	$textbox_servicesAction.Location = '6, 19'
	$textbox_servicesAction.Name = "textbox_servicesAction"
	$textbox_servicesAction.Size = '116, 20'
	$textbox_servicesAction.TabIndex = 11
	$textbox_servicesAction.Text = "<ServiceName>"
	$tooltipinfo.SetToolTip($textbox_servicesAction, "Please Enter a Service Name")
	$textbox_servicesAction.add_Click($textbox_servicesAction_Click)
	#
	# button_servicesRestart
	#
	$button_servicesRestart.Font = "Microsoft Sans Serif, 8.25pt, style=Bold"
	$button_servicesRestart.Location = '200, 15'
	$button_servicesRestart.Name = "button_servicesRestart"
	$button_servicesRestart.Size = '68, 23'
	$button_servicesRestart.TabIndex = 10
	$button_servicesRestart.Text = "Restart"
	$tooltipinfo.SetToolTip($button_servicesRestart, "Restart the service specified")
	$button_servicesRestart.UseVisualStyleBackColor = $True
	$button_servicesRestart.add_Click($button_servicesRestart_Click)
	#
	# label_servicesEnterAServiceName
	#
	$label_servicesEnterAServiceName.Font = "Trebuchet MS, 6.75pt, style=Italic"
	$label_servicesEnterAServiceName.Location = '6, 37'
	$label_servicesEnterAServiceName.Name = "label_servicesEnterAServiceName"
	$label_servicesEnterAServiceName.Size = '116, 15'
	$label_servicesEnterAServiceName.TabIndex = 12
	$label_servicesEnterAServiceName.Text = "Enter a Service Name"
	$label_servicesEnterAServiceName.TextAlign = 'MiddleCenter'
	#
	# button_servicesQuery
	#
	$button_servicesQuery.Font = "Microsoft Sans Serif, 8.25pt, style=Bold"
	$button_servicesQuery.Location = '128, 19'
	$button_servicesQuery.Name = "button_servicesQuery"
	$button_servicesQuery.Size = '59, 23'
	$button_servicesQuery.TabIndex = 4
	$button_servicesQuery.Text = "Query"
	$tooltipinfo.SetToolTip($button_servicesQuery, "Get the service specified information")
	$button_servicesQuery.UseVisualStyleBackColor = $True
	$button_servicesQuery.add_Click($button_servicesQuery_Click)
	#
	# button_servicesStart
	#
	$button_servicesStart.Font = "Microsoft Sans Serif, 8.25pt, style=Bold"
	$button_servicesStart.ForeColor = 'DarkBlue'
	$button_servicesStart.Location = '200, 37'
	$button_servicesStart.Name = "button_servicesStart"
	$button_servicesStart.Size = '68, 23'
	$button_servicesStart.TabIndex = 6
	$button_servicesStart.Text = "Start"
	$tooltipinfo.SetToolTip($button_servicesStart, "Start the service specified")
	$button_servicesStart.UseVisualStyleBackColor = $True
	$button_servicesStart.add_Click($button_servicesStart_Click)
	#
	# button_servicesStop
	#
	$button_servicesStop.Font = "Microsoft Sans Serif, 8.25pt, style=Bold"
	$button_servicesStop.ForeColor = 'Red'
	$button_servicesStop.Location = '200, 59'
	$button_servicesStop.Name = "button_servicesStop"
	$button_servicesStop.Size = '68, 23'
	$button_servicesStop.TabIndex = 5
	$button_servicesStop.Text = "Stop"
	$tooltipinfo.SetToolTip($button_servicesStop, "Stop the service specified")
	$button_servicesStop.UseVisualStyleBackColor = $True
	$button_servicesStop.add_Click($button_servicesStop_Click)
	#
	# button_servicesRunning
	#
	$button_servicesRunning.Location = '146, 3'
	$button_servicesRunning.Name = "button_servicesRunning"
	$button_servicesRunning.Size = '133, 23'
	$button_servicesRunning.TabIndex = 1
	$button_servicesRunning.Text = "Running"
	$tooltipinfo.SetToolTip($button_servicesRunning, "Services with Status = Running")
	$button_servicesRunning.UseVisualStyleBackColor = $True
	$button_servicesRunning.add_Click($button_servicesRunning_Click)
	#
	# button_servicesAll
	#
	$button_servicesAll.Location = '8, 32'
	$button_servicesAll.Name = "button_servicesAll"
	$button_servicesAll.Size = '132, 23'
	$button_servicesAll.TabIndex = 3
	$button_servicesAll.Text = "Services"
	$tooltipinfo.SetToolTip($button_servicesAll, "Get all the services")
	$button_servicesAll.UseVisualStyleBackColor = $True
	$button_servicesAll.add_Click($button_servicesAll_Click)
	#
	# button_servicesGridView
	#
	$button_servicesGridView.Location = '8, 61'
	$button_servicesGridView.Name = "button_servicesGridView"
	$button_servicesGridView.Size = '132, 23'
	$button_servicesGridView.TabIndex = 7
	$button_servicesGridView.Text = "Services - GridView"
	$tooltipinfo.SetToolTip($button_servicesGridView, "Get all the services in a Grid View form")
	$button_servicesGridView.UseVisualStyleBackColor = $True
	$button_servicesGridView.add_Click($button_servicesGridView_Click)
	#
	# button_servicesAutomatic
	#
	$button_servicesAutomatic.Location = '146, 32'
	$button_servicesAutomatic.Name = "button_servicesAutomatic"
	$button_servicesAutomatic.Size = '133, 23'
	$button_servicesAutomatic.TabIndex = 2
	$button_servicesAutomatic.Text = "Automatic"
	$tooltipinfo.SetToolTip($button_servicesAutomatic, "Services with StartupType = Automatic")
	$button_servicesAutomatic.UseVisualStyleBackColor = $True
	$button_servicesAutomatic.add_Click($button_servicesAutomatic_Click)
	#
	# tabpage_diskdrives
	#
	$tabpage_diskdrives.Controls.Add($button_DiskUsage)
	$tabpage_diskdrives.Controls.Add($button_DiskPhysical)
	$tabpage_diskdrives.Controls.Add($button_DiskPartition)
	$tabpage_diskdrives.Controls.Add($button_DiskLogical)
	$tabpage_diskdrives.Controls.Add($button_DiskMountPoint)
	$tabpage_diskdrives.Controls.Add($button_DiskRelationship)
	$tabpage_diskdrives.Controls.Add($button_DiskMappedDrive)
	$tabpage_diskdrives.Location = '4, 22'
	$tabpage_diskdrives.Name = "tabpage_diskdrives"
	$tabpage_diskdrives.Size = '1162, 111'
	$tabpage_diskdrives.TabIndex = 10
	$tabpage_diskdrives.Text = "Disk Drives"
	$tabpage_diskdrives.UseVisualStyleBackColor = $True
	#
	# button_DiskUsage
	#
	$button_DiskUsage.Location = '8, 3'
	$button_DiskUsage.Name = "button_DiskUsage"
	$button_DiskUsage.Size = '112, 23'
	$button_DiskUsage.TabIndex = 22
	$button_DiskUsage.Text = "Disk Usage"
	$tooltipinfo.SetToolTip($button_DiskUsage, "Get the Disk(s) Usage")
	$button_DiskUsage.UseVisualStyleBackColor = $True
	$button_DiskUsage.add_Click($button_DiskUsage_Click)
	#
	# button_DiskPhysical
	#
	$button_DiskPhysical.Location = '126, 3'
	$button_DiskPhysical.Name = "button_DiskPhysical"
	$button_DiskPhysical.Size = '112, 23'
	$button_DiskPhysical.TabIndex = 12
	$button_DiskPhysical.Text = "Physical Disks"
	$tooltipinfo.SetToolTip($button_DiskPhysical, "Get the physical disk(s)")
	$button_DiskPhysical.UseVisualStyleBackColor = $True
	$button_DiskPhysical.add_Click($button_DiskPhysical_Click)
	#
	# button_DiskPartition
	#
	$button_DiskPartition.Location = '244, 3'
	$button_DiskPartition.Name = "button_DiskPartition"
	$button_DiskPartition.Size = '112, 23'
	$button_DiskPartition.TabIndex = 17
	$button_DiskPartition.Text = "Partition"
	$tooltipinfo.SetToolTip($button_DiskPartition, "Get the partition(s)")
	$button_DiskPartition.UseVisualStyleBackColor = $True
	$button_DiskPartition.add_Click($button_DiskPartition_Click)
	#
	# button_DiskLogical
	#
	$button_DiskLogical.Location = '126, 32'
	$button_DiskLogical.Name = "button_DiskLogical"
	$button_DiskLogical.Size = '112, 23'
	$button_DiskLogical.TabIndex = 13
	$button_DiskLogical.Text = "Logical Disk"
	$tooltipinfo.SetToolTip($button_DiskLogical, "Get the logical disk(s)")
	$button_DiskLogical.UseVisualStyleBackColor = $True
	$button_DiskLogical.add_Click($button_DiskLogical_Click)
	#
	# button_DiskMountPoint
	#
	$button_DiskMountPoint.Location = '126, 61'
	$button_DiskMountPoint.Name = "button_DiskMountPoint"
	$button_DiskMountPoint.Size = '112, 23'
	$button_DiskMountPoint.TabIndex = 20
	$button_DiskMountPoint.Text = "MountPoint"
	$tooltipinfo.SetToolTip($button_DiskMountPoint, "Get the mountpoint(s)")
	$button_DiskMountPoint.UseVisualStyleBackColor = $True
	$button_DiskMountPoint.add_Click($button_DiskMountPoint_Click)
	#
	# button_DiskRelationship
	#
	$button_DiskRelationship.Location = '8, 61'
	$button_DiskRelationship.Name = "button_DiskRelationship"
	$button_DiskRelationship.Size = '112, 23'
	$button_DiskRelationship.TabIndex = 19
	$button_DiskRelationship.Text = "Disk Relationship"
	$tooltipinfo.SetToolTip($button_DiskRelationship, "Get the disk(s) relationship")
	$button_DiskRelationship.UseVisualStyleBackColor = $True
	$button_DiskRelationship.add_Click($button_DiskRelationship_Click)
	#
	# button_DiskMappedDrive
	#
	$button_DiskMappedDrive.Location = '8, 32'
	$button_DiskMappedDrive.Name = "button_DiskMappedDrive"
	$button_DiskMappedDrive.Size = '112, 23'
	$button_DiskMappedDrive.TabIndex = 21
	$button_DiskMappedDrive.Text = "Mapped Drive"
	$tooltipinfo.SetToolTip($button_DiskMappedDrive, "Get the Active mapped drive(s)")
	$button_DiskMappedDrive.UseVisualStyleBackColor = $True
	$button_DiskMappedDrive.add_Click($button_DiskMappedDrive_Click)
	#
	# tabpage_shares
	#
	$tabpage_shares.Controls.Add($button_mmcShares)
	$tabpage_shares.Controls.Add($button_SharesGrid)
	$tabpage_shares.Controls.Add($button_Shares)
	$tabpage_shares.Location = '4, 22'
	$tabpage_shares.Name = "tabpage_shares"
	$tabpage_shares.Size = '1162, 111'
	$tabpage_shares.TabIndex = 7
	$tabpage_shares.Text = "Shares"
	$tabpage_shares.UseVisualStyleBackColor = $True
	#
	# button_mmcShares
	#
	$button_mmcShares.ForeColor = 'ForestGreen'
	$button_mmcShares.Location = '8, 3'
	$button_mmcShares.Name = "button_mmcShares"
	$button_mmcShares.Size = '140, 23'
	$button_mmcShares.TabIndex = 1
	$button_mmcShares.Text = "MMC: Shares"
	$tooltipinfo.SetToolTip($button_mmcShares, "Launch the shared folders console (fsmgmt.msc)")
	$button_mmcShares.UseVisualStyleBackColor = $True
	$button_mmcShares.add_Click($button_mmcShares_Click)
	#
	# button_SharesGrid
	#
	$button_SharesGrid.Location = '8, 61'
	$button_SharesGrid.Name = "button_SharesGrid"
	$button_SharesGrid.Size = '140, 23'
	$button_SharesGrid.TabIndex = 16
	$button_SharesGrid.Text = "Shares - GridView"
	$tooltipinfo.SetToolTip($button_SharesGrid, "Get a list of all the shares in a Grid View form")
	$button_SharesGrid.UseVisualStyleBackColor = $True
	$button_SharesGrid.add_Click($button_SharesGrid_Click)
	#
	# button_Shares
	#
	$button_Shares.Location = '8, 32'
	$button_Shares.Name = "button_Shares"
	$button_Shares.Size = '140, 23'
	$button_Shares.TabIndex = 0
	$button_Shares.Text = "Shares"
	$tooltipinfo.SetToolTip($button_Shares, "Get a list of all the shares with a local path")
	$button_Shares.UseVisualStyleBackColor = $True
	$button_Shares.add_Click($button_Shares_Click)
	#
	# tabpage_eventlog
	#
	$tabpage_eventlog.Controls.Add($button_RebootHistory)
	$tabpage_eventlog.Controls.Add($button_mmcEvents)
	$tabpage_eventlog.Controls.Add($button_EventsSearch)
	$tabpage_eventlog.Controls.Add($button_EventsLogNames)
	$tabpage_eventlog.Controls.Add($button_EventsLast20)
	$tabpage_eventlog.Location = '4, 22'
	$tabpage_eventlog.Name = "tabpage_eventlog"
	$tabpage_eventlog.Size = '1162, 111'
	$tabpage_eventlog.TabIndex = 4
	$tabpage_eventlog.Text = "Event Log"
	$tabpage_eventlog.UseVisualStyleBackColor = $True
	#
	# button_RebootHistory
	#
	$button_RebootHistory.Location = '163, 32'
	$button_RebootHistory.Name = "button_RebootHistory"
	$button_RebootHistory.Size = '149, 23'
	$button_RebootHistory.TabIndex = 5
	$button_RebootHistory.Text = "Reboot History (slow)"
	$button_RebootHistory.UseVisualStyleBackColor = $True
	$button_RebootHistory.add_Click($button_RebootHistory_Click)
	#
	# button_mmcEvents
	#
	$button_mmcEvents.ForeColor = 'ForestGreen'
	$button_mmcEvents.Location = '8, 3'
	$button_mmcEvents.Name = "button_mmcEvents"
	$button_mmcEvents.Size = '149, 23'
	$button_mmcEvents.TabIndex = 0
	$button_mmcEvents.Text = "MMC: Event Viewer"
	$button_mmcEvents.UseVisualStyleBackColor = $True
	$button_mmcEvents.add_Click($button_mmcEvents_Click)
	#
	# button_EventsSearch
	#
	$button_EventsSearch.Location = '163, 3'
	$button_EventsSearch.Name = "button_EventsSearch"
	$button_EventsSearch.Size = '149, 23'
	$button_EventsSearch.TabIndex = 3
	$button_EventsSearch.Text = "Search (slow)"
	$button_EventsSearch.UseVisualStyleBackColor = $True
	$button_EventsSearch.add_Click($button_EventsSearch_Click)
	#
	# button_EventsLogNames
	#
	$button_EventsLogNames.Location = '9, 61'
	$button_EventsLogNames.Name = "button_EventsLogNames"
	$button_EventsLogNames.Size = '148, 23'
	$button_EventsLogNames.TabIndex = 4
	$button_EventsLogNames.Text = "LogNames"
	$button_EventsLogNames.UseVisualStyleBackColor = $True
	$button_EventsLogNames.add_Click($button_EventsLogNames_Click)
	#
	# button_EventsLast20
	#
	$button_EventsLast20.Location = '8, 32'
	$button_EventsLast20.Name = "button_EventsLast20"
	$button_EventsLast20.Size = '149, 23'
	$button_EventsLast20.TabIndex = 1
	$button_EventsLast20.Text = "Last20"
	$button_EventsLast20.UseVisualStyleBackColor = $True
	$button_EventsLast20.add_Click($button_EventsLast20_Click)
	#
	# tabpage_ExternalTools
	#
	$tabpage_ExternalTools.Controls.Add($groupbox3)
	$tabpage_ExternalTools.Controls.Add($button_Rwinsta)
	$tabpage_ExternalTools.Controls.Add($button_Qwinsta)
	$tabpage_ExternalTools.Controls.Add($button_MsInfo32)
	$tabpage_ExternalTools.Controls.Add($button_Telnet)
	$tabpage_ExternalTools.Controls.Add($button_DriverQuery)
	$tabpage_ExternalTools.Controls.Add($button_SystemInfoexe)
	$tabpage_ExternalTools.Controls.Add($button_PAExec)
	$tabpage_ExternalTools.Controls.Add($button_psexec)
	$tabpage_ExternalTools.Controls.Add($textbox_networktracertparam)
	$tabpage_ExternalTools.Controls.Add($button_networkTracert)
	$tabpage_ExternalTools.Controls.Add($button_networkNsLookup)
	$tabpage_ExternalTools.Controls.Add($button_networkPing)
	$tabpage_ExternalTools.Controls.Add($textbox_networkpathpingparam)
	$tabpage_ExternalTools.Controls.Add($textbox_pingparam)
	$tabpage_ExternalTools.Controls.Add($button_networkPathPing)
	$tabpage_ExternalTools.Location = '4, 22'
	$tabpage_ExternalTools.Name = "tabpage_ExternalTools"
	$tabpage_ExternalTools.Size = '1162, 111'
	$tabpage_ExternalTools.TabIndex = 9
	$tabpage_ExternalTools.Text = "ExternalTools"
	$tabpage_ExternalTools.UseVisualStyleBackColor = $True
	#
	# groupbox3
	#
	$groupbox3.Controls.Add($label_SYDI)
	$groupbox3.Controls.Add($combobox_sydi_format)
	$groupbox3.Controls.Add($textbox_sydi_arguments)
	$groupbox3.Controls.Add($button_SYDIGo)
	$groupbox3.Location = '791, 3'
	$groupbox3.Name = "groupbox3"
	$groupbox3.Size = '268, 47'
	$groupbox3.TabIndex = 49
	$groupbox3.TabStop = $False
	$groupbox3.Text = "Script Your Documentation Instantly (.VBS)"
	#
	# label_SYDI
	#
	$label_SYDI.Location = '6, 25'
	$label_SYDI.Name = "label_SYDI"
	$label_SYDI.Size = '34, 19'
	$label_SYDI.TabIndex = 38
	$label_SYDI.Text = "SYDI"
	#
	# combobox_sydi_format
	#
	$combobox_sydi_format.BackColor = 'Info'
	$combobox_sydi_format.FormattingEnabled = $True
	[void]$combobox_sydi_format.Items.Add("DOC")
	[void]$combobox_sydi_format.Items.Add("XML")
	$combobox_sydi_format.Location = '46, 21'
	$combobox_sydi_format.Name = "combobox_sydi_format"
	$combobox_sydi_format.Size = '46, 21'
	$combobox_sydi_format.TabIndex = 37
	#
	# textbox_sydi_arguments
	#
	$textbox_sydi_arguments.BackColor = 'Info'
	$textbox_sydi_arguments.Font = "Microsoft Sans Serif, 8.25pt"
	$textbox_sydi_arguments.Location = '98, 21'
	$textbox_sydi_arguments.Name = "textbox_sydi_arguments"
	$textbox_sydi_arguments.Size = '106, 20'
	$textbox_sydi_arguments.TabIndex = 27
	$textbox_sydi_arguments.Text = "-wabefghipPqrsu -racdklp"
	#
	# button_SYDIGo
	#
	$button_SYDIGo.Location = '210, 20'
	$button_SYDIGo.Name = "button_SYDIGo"
	$button_SYDIGo.Size = '30, 23'
	$button_SYDIGo.TabIndex = 26
	$button_SYDIGo.Text = "Go"
	$button_SYDIGo.UseVisualStyleBackColor = $True
	$button_SYDIGo.add_Click($button_SYDIGo_Click)
	#
	# button_Rwinsta
	#
	$button_Rwinsta.Location = '289, 27'
	$button_Rwinsta.Name = "button_Rwinsta"
	$button_Rwinsta.Size = '75, 23'
	$button_Rwinsta.TabIndex = 48
	$button_Rwinsta.Text = "Rwinsta"
	$button_Rwinsta.UseVisualStyleBackColor = $True
	$button_Rwinsta.add_Click($button_Rwinsta_Click)
	#
	# button_Qwinsta
	#
	$button_Qwinsta.Location = '289, 3'
	$button_Qwinsta.Name = "button_Qwinsta"
	$button_Qwinsta.Size = '75, 23'
	$button_Qwinsta.TabIndex = 47
	$button_Qwinsta.Text = "Qwinsta"
	$button_Qwinsta.UseVisualStyleBackColor = $True
	$button_Qwinsta.add_Click($button_Qwinsta_Click)
	#
	# button_MsInfo32
	#
	$button_MsInfo32.Location = '122, 52'
	$button_MsInfo32.Name = "button_MsInfo32"
	$button_MsInfo32.Size = '75, 23'
	$button_MsInfo32.TabIndex = 46
	$button_MsInfo32.Text = "MsInfo32"
	$button_MsInfo32.UseVisualStyleBackColor = $True
	$button_MsInfo32.add_Click($button_MsInfo32_Click)
	#
	# button_Telnet
	#
	$button_Telnet.Location = '122, 76'
	$button_Telnet.Name = "button_Telnet"
	$button_Telnet.Size = '75, 23'
	$button_Telnet.TabIndex = 39
	$button_Telnet.Text = "Telnet"
	$button_Telnet.UseVisualStyleBackColor = $True
	$button_Telnet.add_Click($button_Telnet_Click)
	#
	# button_DriverQuery
	#
	$button_DriverQuery.Location = '122, 27'
	$button_DriverQuery.Name = "button_DriverQuery"
	$button_DriverQuery.Size = '75, 23'
	$button_DriverQuery.TabIndex = 45
	$button_DriverQuery.Text = "DriverQuery"
	$button_DriverQuery.UseVisualStyleBackColor = $True
	$button_DriverQuery.add_Click($button_DriverQuery_Click)
	#
	# button_SystemInfoexe
	#
	$button_SystemInfoexe.Location = '122, 3'
	$button_SystemInfoexe.Name = "button_SystemInfoexe"
	$button_SystemInfoexe.Size = '75, 23'
	$button_SystemInfoexe.TabIndex = 1
	$button_SystemInfoexe.Text = "SystemInfo"
	$button_SystemInfoexe.UseVisualStyleBackColor = $True
	$button_SystemInfoexe.add_Click($button_SystemInfoexe_Click)
	#
	# button_PAExec
	#
	$button_PAExec.Location = '203, 27'
	$button_PAExec.Name = "button_PAExec"
	$button_PAExec.Size = '75, 23'
	$button_PAExec.TabIndex = 44
	$button_PAExec.Text = "PAExec"
	$button_PAExec.UseVisualStyleBackColor = $True
	$button_PAExec.add_Click($button_PAExec_Click)
	#
	# button_psexec
	#
	$button_psexec.Location = '203, 3'
	$button_psexec.Name = "button_psexec"
	$button_psexec.Size = '75, 23'
	$button_psexec.TabIndex = 43
	$button_psexec.Text = "PsExec"
	$button_psexec.UseVisualStyleBackColor = $True
	$button_psexec.add_Click($button_psexec_Click)
	#
	# textbox_networktracertparam
	#
	$textbox_networktracertparam.Location = '84, 78'
	$textbox_networktracertparam.Name = "textbox_networktracertparam"
	$textbox_networktracertparam.Size = '34, 20'
	$textbox_networktracertparam.TabIndex = 7
	$textbox_networktracertparam.Text = "-d"
	#
	# button_networkTracert
	#
	$button_networkTracert.Location = '3, 76'
	$button_networkTracert.Name = "button_networkTracert"
	$button_networkTracert.Size = '75, 23'
	$button_networkTracert.TabIndex = 6
	$button_networkTracert.Text = "Tracert"
	$button_networkTracert.UseVisualStyleBackColor = $True
	$button_networkTracert.add_Click($button_networkTracert_Click)
	#
	# button_networkNsLookup
	#
	$button_networkNsLookup.Location = '3, 3'
	$button_networkNsLookup.Name = "button_networkNsLookup"
	$button_networkNsLookup.Size = '75, 23'
	$button_networkNsLookup.TabIndex = 5
	$button_networkNsLookup.Text = "NsLookup"
	$button_networkNsLookup.UseVisualStyleBackColor = $True
	$button_networkNsLookup.add_Click($button_networkNsLookup_Click)
	#
	# button_networkPing
	#
	$button_networkPing.Location = '3, 27'
	$button_networkPing.Name = "button_networkPing"
	$button_networkPing.Size = '75, 23'
	$button_networkPing.TabIndex = 0
	$button_networkPing.Text = "Ping"
	$button_networkPing.UseVisualStyleBackColor = $True
	$button_networkPing.add_Click($button_networkPing_Click)
	#
	# textbox_networkpathpingparam
	#
	$textbox_networkpathpingparam.Location = '84, 54'
	$textbox_networkpathpingparam.Name = "textbox_networkpathpingparam"
	$textbox_networkpathpingparam.Size = '34, 20'
	$textbox_networkpathpingparam.TabIndex = 3
	$textbox_networkpathpingparam.Text = "-n"
	#
	# textbox_pingparam
	#
	$textbox_pingparam.Location = '84, 29'
	$textbox_pingparam.Name = "textbox_pingparam"
	$textbox_pingparam.Size = '34, 20'
	$textbox_pingparam.TabIndex = 1
	$textbox_pingparam.Text = "-t"
	#
	# button_networkPathPing
	#
	$button_networkPathPing.Location = '3, 52'
	$button_networkPathPing.Name = "button_networkPathPing"
	$button_networkPathPing.Size = '75, 23'
	$button_networkPathPing.TabIndex = 2
	$button_networkPathPing.Text = "PathPing"
	$button_networkPathPing.UseVisualStyleBackColor = $True
	$button_networkPathPing.add_Click($button_networkPathPing_Click)
	#
	# groupbox_ComputerName
	#
	$groupbox_ComputerName.Controls.Add($label_UptimeStatus)
	$groupbox_ComputerName.Controls.Add($textbox_computername)
	$groupbox_ComputerName.Controls.Add($label_OSStatus)
	$groupbox_ComputerName.Controls.Add($button_Check)
	$groupbox_ComputerName.Controls.Add($label_PingStatus)
	$groupbox_ComputerName.Controls.Add($label_Ping)
	$groupbox_ComputerName.Controls.Add($label_PSRemotingStatus)
	$groupbox_ComputerName.Controls.Add($label_Uptime)
	$groupbox_ComputerName.Controls.Add($label_RDPStatus)
	$groupbox_ComputerName.Controls.Add($label_OS)
	$groupbox_ComputerName.Controls.Add($label_PermissionStatus)
	$groupbox_ComputerName.Controls.Add($label_Permission)
	$groupbox_ComputerName.Controls.Add($label_PSRemoting)
	$groupbox_ComputerName.Controls.Add($label_RDP)
	$groupbox_ComputerName.Dock = 'Top'
	$groupbox_ComputerName.Location = '0, 26'
	$groupbox_ComputerName.Name = "groupbox_ComputerName"
	$groupbox_ComputerName.Size = '1170, 61'
	$groupbox_ComputerName.TabIndex = 62
	$groupbox_ComputerName.TabStop = $False
	$groupbox_ComputerName.Text = "ComputerName"
	#
	# label_UptimeStatus
	#
	$label_UptimeStatus.Location = '614, 33'
	$label_UptimeStatus.Name = "label_UptimeStatus"
	$label_UptimeStatus.Size = '539, 19'
	$label_UptimeStatus.TabIndex = 61
	#
	# textbox_computername
	#
	$textbox_computername.AutoCompleteMode = 'SuggestAppend'
	$textbox_computername.AutoCompleteSource = 'CustomSource'
	$textbox_computername.BackColor = 'LemonChiffon'
	$textbox_computername.BorderStyle = 'FixedSingle'
	$textbox_computername.CharacterCasing = 'Upper'
	$textbox_computername.Font = "Consolas, 18pt"
	$textbox_computername.ForeColor = 'WindowText'
	$textbox_computername.Location = '6, 14'
	$textbox_computername.Name = "textbox_computername"
	$textbox_computername.Size = '209, 36'
	$textbox_computername.TabIndex = 2
	$textbox_computername.Text = "LOCALHOST"
	$textbox_computername.TextAlign = 'Center'
	$tooltipinfo.SetToolTip($textbox_computername, "Please enter a Computer name")
	$textbox_computername.add_TextChanged($textbox_computername_TextChanged)
	$textbox_computername.add_KeyPress($textbox_computername_KeyPress)
	#
	# label_OSStatus
	#
	$label_OSStatus.Location = '614, 16'
	$label_OSStatus.Name = "label_OSStatus"
	$label_OSStatus.Size = '539, 16'
	$label_OSStatus.TabIndex = 60
	#
	# button_Check
	#
	$button_Check.Font = "Microsoft Sans Serif, 8.25pt, style=Bold"
	#region Binary Data
	$button_Check.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0
U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKsSURBVDhPpZPrS5NRHMf9O/Zse0xBAhlR
iCAh1F4FicSm2VDMy7I03d0rbTOGzbQoI+dljJTSMkutNufMpk5tbk0pE5c9Soi5N12oNowu9u08
D7RpQS/qxRfOi/P5/M45v9+JAxD3P/kDLvIdSMyf2a/P9aQxWY/2hiUPRWGJK5mROJP1mfbdib8X
2yEo8KZLZZ7UkM4jw/WgBQMrPVy6l1pR5joCcT8dEvfR0u2SqIBUlWZPpEQuzxvhXBuE7cUVmOar
ubBrx9oAmmdrsM8miKTaBFEJJ8jzpCVku1M2WJjdWBeoQJW/DJrZU9CRVJLU+k7D/uoOzk9XQWTh
b4iu8hNYlhPI3CkG1XgOV5mFWVDlPQHFTDEU00VQTxfDvT4Mg1cJB5Hk9x1C0iW+ISrIeihiuoOt
sAZbUOUrhfKxnICFUE6ReAox8dpF9gKhyDo6njXDNt+M+EY+ExUctidt3lu9ifqABlpvCTnJEJbe
L0A1WYzx9REO/r71DR1PL8AwWYqBYDeERmozKhDfpTcHV3ph9KtQ79fi45cPHPTu85sobJlrhNqV
C737JAaDXRDWbRf00cy1hRZ0Ll6EbkoOs68Wka+fOHjrxxYsT86hwpkDDRG0BRrQ6TWDrqFiV0i/
ITTIhzJgX72N2kk51O7jaJipxPLbRXTMNaF8+CgUjmPQOfNgf9mLTOtB0NVU7BFTrYKEPaQ1Zo8G
95lbqB4rgHY0D6oRGZQONiyciwfLPTCOlEKo5m3QairWRvYxklv40vgmKmJyV8BBJO0BM/RjJTgz
Kkc7uYKdwHpnCQTlvAiBdw7Sr9Hc1cSX0iYqJOkSo9NvRv9zK/oXrLB4TchoS4dQwQvRqhgc7cL2
2abP8hNpA6Wn6yhGqOWFhSpemFRkSPR0OfX3z/Qv3/onZ9Cs5bE2LHMAAAAASUVORK5CYII=')
	#endregion
	$button_Check.ImageAlign = 'MiddleLeft'
	$button_Check.Location = '239, 15'
	$button_Check.Name = "button_Check"
	$button_Check.Size = '88, 35'
	$button_Check.TabIndex = 51
	$button_Check.Text = "Check"
	$tooltipinfo.SetToolTip($button_Check, "Check the connectivity and basic information")
	$button_Check.UseVisualStyleBackColor = $True
	$button_Check.add_Click($button_Check_Click)
	#
	# label_PingStatus
	#
	$label_PingStatus.Location = '399, 17'
	$label_PingStatus.Name = "label_PingStatus"
	$label_PingStatus.Size = '33, 16'
	$label_PingStatus.TabIndex = 50
	#
	# label_Ping
	#
	$label_Ping.Font = "Trebuchet MS, 8.25pt, style=Underline"
	$label_Ping.Location = '333, 16'
	$label_Ping.Name = "label_Ping"
	$label_Ping.Size = '33, 16'
	$label_Ping.TabIndex = 49
	$label_Ping.Text = "Ping:"
	#
	# label_PSRemotingStatus
	#
	$label_PSRemotingStatus.Location = '496, 33'
	$label_PSRemotingStatus.Name = "label_PSRemotingStatus"
	$label_PSRemotingStatus.Size = '69, 14'
	$label_PSRemotingStatus.TabIndex = 57
	#
	# label_Uptime
	#
	$label_Uptime.Font = "Trebuchet MS, 8.25pt, style=Underline"
	$label_Uptime.Location = '571, 32'
	$label_Uptime.Name = "label_Uptime"
	$label_Uptime.Size = '50, 20'
	$label_Uptime.TabIndex = 59
	$label_Uptime.Text = "Uptime:"
	#
	# label_RDPStatus
	#
	$label_RDPStatus.Location = '496, 16'
	$label_RDPStatus.Name = "label_RDPStatus"
	$label_RDPStatus.Size = '69, 19'
	$label_RDPStatus.TabIndex = 56
	#
	# label_OS
	#
	$label_OS.Font = "Trebuchet MS, 8.25pt, style=Underline"
	$label_OS.Location = '571, 16'
	$label_OS.Name = "label_OS"
	$label_OS.Size = '37, 20'
	$label_OS.TabIndex = 58
	$label_OS.Text = "OS:"
	#
	# label_PermissionStatus
	#
	$label_PermissionStatus.Location = '399, 33'
	$label_PermissionStatus.Name = "label_PermissionStatus"
	$label_PermissionStatus.Size = '33, 16'
	$label_PermissionStatus.TabIndex = 53
	#
	# label_Permission
	#
	$label_Permission.Font = "Trebuchet MS, 8.25pt, style=Underline"
	$label_Permission.Location = '333, 32'
	$label_Permission.Name = "label_Permission"
	$label_Permission.Size = '72, 20'
	$label_Permission.TabIndex = 52
	$label_Permission.Text = "Permission:"
	#
	# label_PSRemoting
	#
	$label_PSRemoting.Font = "Trebuchet MS, 8.25pt, style=Underline"
	$label_PSRemoting.Location = '431, 32'
	$label_PSRemoting.Name = "label_PSRemoting"
	$label_PSRemoting.Size = '75, 20'
	$label_PSRemoting.TabIndex = 55
	$label_PSRemoting.Text = "PSRemoting:"
	#
	# label_RDP
	#
	$label_RDP.Font = "Trebuchet MS, 8.25pt, style=Underline"
	$label_RDP.Location = '431, 16'
	$label_RDP.Name = "label_RDP"
	$label_RDP.Size = '37, 20'
	$label_RDP.TabIndex = 54
	$label_RDP.Text = "RDP:"
	#
	# richtextbox_Logs
	#
	$richtextbox_Logs.BackColor = 'InactiveBorder'
	$richtextbox_Logs.Dock = 'Bottom'
	$richtextbox_Logs.Font = "Consolas, 8.25pt"
	$richtextbox_Logs.ForeColor = 'Green'
	$richtextbox_Logs.Location = '0, 623'
	$richtextbox_Logs.Name = "richtextbox_Logs"
	$richtextbox_Logs.ReadOnly = $True
	$richtextbox_Logs.Size = '1170, 70'
	$richtextbox_Logs.TabIndex = 35
	$richtextbox_Logs.Text = ""
	$richtextbox_Logs.add_TextChanged($richtextbox_Logs_TextChanged)
	#
	# statusbar1
	#
	$statusbar1.Location = '0, 693'
	$statusbar1.Name = "statusbar1"
	$statusbar1.Size = '1170, 26'
	$statusbar1.TabIndex = 16
	#
	# menustrip_principal
	#
	$menustrip_principal.Font = "Trebuchet MS, 9pt"
	[void]$menustrip_principal.Items.Add($ToolStripMenuItem_AdminArsenal)
	[void]$menustrip_principal.Items.Add($ToolStripMenuItem_localhost)
	[void]$menustrip_principal.Items.Add($ToolStripMenuItem_scripts)
	[void]$menustrip_principal.Items.Add($ToolStripMenuItem_about)
	$menustrip_principal.Location = '0, 0'
	$menustrip_principal.Name = "menustrip_principal"
	$menustrip_principal.Size = '1170, 26'
	$menustrip_principal.TabIndex = 1
	$menustrip_principal.Text = "menustrip1"
	#
	# ToolStripMenuItem_AdminArsenal
	#
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($ToolStripMenuItem_ADSearchDialog)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($ToolStripMenuItem_ADPrinters)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($toolstripseparator4)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($ToolStripMenuItem_CommandPrompt)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($ToolStripMenuItem_Powershell)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($ToolStripMenuItem_PowershellISE)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($toolstripseparator5)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($ToolStripMenuItem_RemoteDesktopConnection)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($ToolStripMenuItem_shutdownGui)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($ToolStripMenuItem_InternetExplorer)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($ToolStripMenuItem_TerminalAdmin)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($ToolStripMenuItem_Notepad)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($ToolStripMenuItem_Wordpad)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($ToolStripMenuItem_sysInternals)
	[void]$ToolStripMenuItem_AdminArsenal.DropDownItems.Add($ToolStripMenuItem_GeneratePassword)
	#region Binary Data
	$ToolStripMenuItem_AdminArsenal.Image = [System.Convert]::FromBase64String('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
AAAASUVORK5CYII=')
	#endregion
	$ToolStripMenuItem_AdminArsenal.Name = "ToolStripMenuItem_AdminArsenal"
	$ToolStripMenuItem_AdminArsenal.Size = '109, 22'
	$ToolStripMenuItem_AdminArsenal.Text = "AdminArsenal"
	#
	# ToolStripMenuItem_CommandPrompt
	#
	#region Binary Data
	$ToolStripMenuItem_CommandPrompt.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAa5JREFU
OE+tk8tLAlEUxp2oCFpFtNBV+xw3hjkmFfQuDWpyfGfRUyRa9CKT/oGKXvQUalMtsn+gFrUrCqlF
7QoUF+6avRu/5txwyEXQUBc+5tx7zu87h8tcne4fFldSUXlSbmz8KK1vlUuELpmz98q6Jqesa+77
khJzdgfLUQ3VEqP05qg/Xz0QRvfFHRyJ+1+JaqvFMBTWSAaWyp4xVM3saRIxCmtmBjWmFtS2D2sS
MaoBz5vQ1tquScSoBg1WAeKgpEnEqAaCrRGS24vRsXFsbm1jZ2cXC4tL7Iy+s7PzLP4uYlQDm80O
t8eHTCaDZDKJq6trrK6ts7O5uQWk02l4fQG2L4iYogl8/iDy+TxCoRG103JsRQH9uLm5xf7B4c8T
WAUbK6TlDwxh0OVmenh4RCAYwsRkGNlstihHjDqBxdLALjCXyyEajWEqHEFwaBiRyDRE0YX+ARGJ
y0ucnp2zmESMamA218Ph7MPGxibe3t6RSqVwFI/j5eUVkuRhOcntwdPTMzOkPTEFA77OaERHR6cm
EVP4lbmysvJjvd7wYTAY5N+IaokpPKY/PehPwtGRPXo66K0AAAAASUVORK5CYII=')
	#endregion
	$ToolStripMenuItem_CommandPrompt.Name = "ToolStripMenuItem_CommandPrompt"
	$ToolStripMenuItem_CommandPrompt.Size = '290, 22'
	$ToolStripMenuItem_CommandPrompt.Text = "Command Prompt"
	$ToolStripMenuItem_CommandPrompt.add_Click($ToolStripMenuItem_CommandPrompt_Click)
	#
	# ToolStripMenuItem_Powershell
	#
	#region Binary Data
	$ToolStripMenuItem_Powershell.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAA/45JREFU
eF7s/QdUFmfX9o2/gF2jxmhMjDHFxN5777333nvvvfcGKiBdBLGLqIAgvcNH72AHFXt67vo8z/uu
Nd9vzzVzcYFoNOV+/99/kbWOdZ4zV4GMHMc+9j73nPO//lfpf6VXoPQKlF6B0itQegVKr0DpFSi9
AqVXoPQKlF6B0itQegVKr0DpFSi9AqVXoPQKlF6B0itQegVKr0DpFSi9AqVXoPQKlF6B0itQegVK
r0DpFSi9AqVXoPQKlF6B0itQegVKr0DpFSi9AqVXoPQKlF6B0itQegVKr0DpFSi9AqVXoPQKlF6B
0itQegVKr0DpFSi9AqVXoPQKlF6B0itQegVKr0DpFSi9AqVXoPQKlF6B0itQegVKr0DpFSi9AqVX
oPQKlF6B0itQegVKr0DpFSi9AqVXoPQKlF6B0itQegVKr0DpFSi9AqVXoPQKlF6B0itQegVKr0Dp
FSi9AqVXoPQKlF6B0itQegVKr0DpFSi9AqVXoPQKlF6B0itQegVKr0DpFSi9AqVXoPQKlF6B0itQ
egVKr0DpFSi9AqVXoPQKlF6B0itQegVKr0DpFSi9AqVXoPQKlF6B0itQegVKr0DpFSi9AqVXoPQK
lF6B0itQegVKr0DpFSi9AqVXoPQKlF6B0itQegVKr0DpFSi9AqVXoPQKlF6B0itQegVKr0DpFSi9
AqVXoPQKlF6B0itQegVKr0DpFSi9AqVXoPQKlF6B0itQegVKr0DpFXi3K2DG20pReg3+yr+Bd/tL
LH3XX3oFSvoHNucnvg0WvF6K0mvwLn8Dv/W3VNLf31/6B1/65UWjmuk/kP4PWoaLZIqyHJei9Br8
GX8Dpn9XpgKi/x0WF4T/LF8brr9uNvdylvk2zxSL44G5Fm5ReWXOpj0ucyntUZmrmU/K+mQ9K+t/
6yV4Xtbv1quyQXe+Lxd89/tygfdk/K5c6L0fyoXn/Vgu7MGP5SLuf182Mu/HslGPfi4b/fCnstH5
P5WJefSTRdyjn8tE5v9oEZn3k3n0w5/No/J/Nlfn+T+axzz6WUUs5+Me/aIiQcbHP5slFPxilvD4
F7N4GQt+lgv1Pv+ZXlj9YpsSXv/HLceXCsqDCsVQkeNSlF6D3/M3YPq3JH9bAvk70//uRBj0v8eS
xOB9/tbf/719PYPMtt/IMLeKvm9xJjrP4lxKflmv7O/KeWU+Le+Z/qTC1axnFX1vfV/JJ+dllevZ
Tz/wvvXiA7/b31e7cetVdVDD7873H/rd/f4j/zvf1Qy8+13NoLs/1EIUagfd/f6ToHs/fhp8/8c6
Ifd//Cz0/g91w/J+qodI1At/8NPnkfk/14vM+/nziLyfPo/K+/FzBOHz6Ec/143J/7lu7MNfPgOf
xoPYRz9/Ev/4l4/jH/1SO+7xL7XiC36umVjw64cJBb9WSyz4pSqvVYl99EsVBKMK88oCzldKfPJr
Je/E3IrXE3IqOnoFqDjscq7S+v1HK81esa5Sk41nBjbYdH7fN5svRX6z+WL6N1su/x+glKL0Gvy5
fwOXfuJvLK3+xvPXv153ek2dyVu/haWVtIAi4mAqCLoYFBeC9yf2b32is4On2VrPeHObgHTzc4kF
Fl6Zz8tcIcpfySoo55X1vPzVnFcVr2Y9r3Q1+3nlazmvqlzJeVn1Ss6Lal7ZL6tfy35V42ruyxpe
OS8/8sp5Vetazne1r+W8rM35T67mvvr06q3v6vCZutdyX9a7nvvqi+u53391Pee7b7xzv//W5/b3
Dbxv/dDA59b3DX3vfN/4BvC7/UMTvzvfNfW790Mz/zs/trp55/s2N+/+0Dbg3o/tQceAe993Cbz3
Q4+g+z/0DnrwQx9EpX/Igx8Hhj74cRCOY3B43s9DwNCI/J+GRT78aXjY/e9GRTz4fkSkhtA7z0cG
ZhcMPxqYMavfcf/LjXZ4/TLaOULZ6ZelXMl8qvjffqnkfvdP5fb3/yqKHzg2wS1tfoexOO5yrij+
rdz98S/GD3y/DvlZ2vwOYyH4Xb//N/8fb4P+//lb7/sTX5ff6U0w/V3198g50/lb/3/+rdzi9fcC
333LBLnMjfiO+Tsg57t/KcWRUPA3heCpnIzPV1ZdSVY6HPRVvtl0/toXi20Hw9EqxcRAdwamQqA7
2N+i9Lu/PuWgn9m+0CzzU2mPLDzjHpc5n/Co7MXMF2Uv5LwofyHlaYVLmU8rema8qHw+40UVUPVC
xrNq57NeVD+X9eLD85nPa1zIfF7zfOarj89nvvzkXMbzOucyX9Q9n/WyHu/54lzGi6/OZ7ysfyH7
1Te8rwHnGl7IetX4YuarphezXjW/kPmixcXs71ozb3sh62W7izkv21/O/q7D5exXnS5lv+x8OfdV
V8/s77p55rzqfinnZQ/P7O97ctz3cs6rAVdyXw3m/BAw/Eru96O9cr4bezX3u/HXcr6feC33+6nX
b3033SvrxRyv7Ofzr+W8WHQl4+myKxkFq/b6Zx4aYB0Q156LvycgRyGl4B/3XyrSXvxDSXj6NyX6
ya9KJP9YgijBEwNiNEQ/+TvvMSBW8PTtiON1U8Rrx/HP/q68L+L4TPHvk2P9d4hh/iZE85oKk99f
n0dx7v8u/sHPfwOecl5g/B1N5+/7exf+e0by71kEBf/g31wg//b6/PUxgtfeiMe8VgIiORfN5+Kf
/VNJe4k4ICoC57h8pZ91oPL1Og/HGl1GfQpzPwCVNVcgjkDSg79GBGacSTWzCso2PxOXZ34156nF
lcxnZT1TnpS7lPW0/IXslxUuZr2odDHjWeULaZA/88UHZzOfVzuT/uzDs1nPa5zNePmRR/rzWmcy
ntU+m/7iU4/Ml3U9Ml/UO532/MvTmS/qe2S8+JZ5o9Ppz5twvplHxvPm7hnPW3ukv2h7OuNl+9MZ
Lzq5pz3vyrwHr/fifX3dM17098h4OZDPDj6d/mIo47Azma+Gn0l/MYLPjeS10WczX447k/FyPJgI
JnM81SPzuxlnMl/OOJv1ata5zFdzwLyzac8Wnkt7seRs6rNlHqmPVp5OebxyuF2wX7Pd15TDIbeV
rO/+wT/APyHwr0pw/s+K/4OfFZ97PynXgNedH5Ur4KqOu8xNcJ15ieCz14vBm2Pv+4XwYe7zQAc/
U36uBl9GU5i+9tr8/s98byGu3fuZ370Q8ntc5bgQcgzuvj+8+My7oOjPM/3Z/z80v8vvArx+E/L/
LO8r9v9+5yflyq3fBy8+d+02/953f1Fu3v9ViXj0NyXz1b+UdALPumtpSv0NZ9w/m76rK4SvZuII
JDUQN/DnisDEc9FmJ25mmF9MeWhxGct/mah/LvVJuYuZz8oT5SteSH9W6Vz28yrn0iF++qsPiOzV
z6Q9q+GR9rzm2YwXtSB3bY+0Z3XOZDz/DKJ+DkG/hMRfQ9xvIGoj99TnTU6nPof4L1pyro176ov2
7unPO0L8Lu7pL7ox73U69UU/5gMg/iC3tOfDEITh7hkvR3B+FK+P4bVxp9NeTGCcyGuTGKfw3mlu
6S9nMJ8FZrunv5rDZ+a7p71Y4J72ciGCsuhUyrOlrqlPV5xKebryZPLjNcci7m3pddT//5l0KlqJ
yP9RyYb4UQW/Kn4QzgsyX7n9gwnkuCiu8rpAhKEI+Kx8/loxXOePRhUCjfiFpC9K+CLkz4P8vwVN
IN4kBtcQBF0E5I/cAJ3whnmRP2j+mL2K4Yr8gf8h/MLn/78Lzzs/K28E5PX8HbjMZ1TcKoornPO7
96sSU/B3JZuUwTL0jlJ//ZnTH/Wd3gDCVzdxA3+eCFTslmo23DLYzCYw29wt+YGFe+qjMufSn4jl
L3cu/Vn5c2lPK55OK6h8NvVJZQj9AYSvejrlWXVI/BGo5Zb6/GP31GefuKU/q8P8c4Tgi1Npz77i
XH23tGcNTqU/b+SW/qIpr7U4lfaitVvay7an0p63d0t53onjrqfSX/RAHHq5pr3oy/sGQvwhrkL+
1OcjIfFo3j+az45lPoH3TnRLezEJ8k9hPo1xOiSfyTmI/3wux/MQg/l8zyLev0TglvJ0+ankpytP
JT9ZczLp0bpN3hlWvY4GJKy/nk7U/6eSiIW+CZEkwl++9YNyCXje+l6DzA24ItCFwXSuicHVO4gC
MBWEa3yniIHqDu6B+wITB8DP9TbBWyO8SvZfcAeCws+ZztXvMnUBpgKgR3+JYjrJTeclkfw25C8C
XQgN59/1j/93CcBtREMg4qHPix//BcLiyXe+Dk0EhOwiCKakh8Se74DiZJfjS4LcorjMsRf/nyH5
f1NFYItvpvLV6lNukL8W+BBU1VKC4iLw++sBe/xjzdzjH5ljjS3OZsry3vOy5zKfl8emVzif+qyi
R/rTyu4Zz6p4pD6v6p76tPrptCcfQbZaELi2e9rTTyFzHUhX91Ta0y+Itl8hAPUheYNTqc8buaY9
awqhm3OulWvqs7auqc/b8znI/7wLx915rRfzPpzvfzLl+WAEYCjzEZwbxefHuKa+GMc43i31xaST
qS8m89kpp1JfTEMwpnN+OudncW42mAv55zEu5PXFzJe4pjxb7prydIVr0pPVLkmP1x4Ovb1DyH8w
+JaS9eqfSsTDXxVv/vAv50L83O9VXC6CH9TXjBAxgPBvgu4URAR08qtuQMivoqgT0FOBN6UAPjiA
IjBJD0yFQ+bXdUB6ERkjtJ+p2n3N8utR/woOQAXXwBMxeBuhL/OHbwDXS4V+/P+f4yXt/0/G1/ET
5zQghJfeERd5n4rcYsjhuBiuIA5Rj/+mZLz8p8LfrFJnyvbhEP9jUKOYCEhNQJYKZXXgfZfB/9f/
mn0p3Mwz57E51XqL88l5ZTwyn5a9lGuI/kTNitj7SuTklYmmH3ikPqtG1K+BE/iIqFzrVMrz2ljy
T0+lvPgMe10P4n7J/OtTqc++hdwNOW4KIZsztoCMbSA75H/e0S3lGeR/3g0C93RNed4bkveDtAOZ
D+HcMBEAMJrvGHsy9fkEvmMin5uMQEzm/DSOpzPORARm8f45jPM4nsd3LMANLEJEFjNfdhLyn0wq
WOVM5HdKeLiu19Gb8Ru8M5RMIn/wQ4kuPyoXIfUFQc4P/CMgBNkIgQ4RBdzA5TfA4BRMXII4BFyA
fK/qBLSUQEYjAU1rAipRtaitRXWjCyhOfv1YEwEhvWn0LyoA2Hs1+mPpTaFZfp30urVXya9DrKn8
8Rezp0WPEQCT19VI9ht4+/f91s/7C15/gw03Rua3/v9AevJ3IyD0pWIoTvILvP5GQP4LJcDn3i9q
TcA28r64gGsQ/DNNBMQJSHFQlgylMKjXA97PBXyy4orZphuJZt5pj8x9cp5bXE5+XOYMjT0Xsp+X
O5fytPzpxKcVz6Q/F/JXwfZ/cDrtWTXIVcM95flHkLAWRK/tloIApL6oS6StdzL56VcIQ303EYCU
p43Ju5tB0BYIRWtea3cy5VlHSN0ZMegG2Q3kT3veF2JD/meD+b6hvHcE7xvNa0L+8WAS5BbiTxHy
gxkq+VOfz0Y45grxwUI18qc9X8Lvt5RxGT9v1cnkJ6udEx+tc054uGHIieDgyW4xXNB/KmEa+YX0
OoT8ugBcFAHQHIEIQHEUFwRVCDRnoKYJWjqgpgSaAyjiAjTiC2mLR/KiUR+7n/dmeCMKKkgL9O/R
hUAEQEcRIdAjPgLlKWmPgBqHOhrnWpSXP/J3jG7/kfcJKf8Dv48xUusRu/jI73GRa2OEaUS/JUHl
dVzg3BuRy2sl4DI/N5LCID0uCsvTSrmadb+B7HVATa0mIEuF0oAkRcH3dwH9bf3NDoRnmXtlvjSn
yGdxNoVlv6yCsmcznpU/nfKkwunUgkpE+0qnU55XcUt+WtUN+w9JEYBnNU+mPvsY0n5CxK8DgRGA
Z19AbtX+M34LiRtD/makAC2Yt3ZJed6O93QEXVySn/XgXG+XlGd9OR5wMvn5EKL1MKCSH4xzTX42
gdeF9FN5zzR+nhr1EYjZiMIc3kPEf75AyM/Po8j3fBnHyxGCVS5Jku8/XUf03+Cc8Gjzdr9MS6n2
S8Ev/tnf1Ar+BQh+3gRy/Bog9sXc7wy4VYhLzC+r0N0BaYJJeqCLwBUTB+BlmgaYWHRvVgCMIqAR
2icf0v8GvBExFQiEqYioAqClAdf4OQIvcAUnoFt+T0TAU2w8UV8lPzBaWt3aMupEuMAfogr+6FUU
P9bPv23UP/Om8V2+403v+a3vLuH110iuEfqtkRriXzDC5Hrw2fMQ+G04x+tvRA6vvQEBeb8qGQSt
QbbBSu1RK8dA9HrgE5NUwNQFvF8asOJmpJltaK75ORGAjO8szqQ/KeOR9LicBwIg+b87AnAqqaAy
BbkPKLZVc01+Wp3I+hGEqwXpa7skPf0UIn4GIesxfumc8vQrl9Rn34CGkLwJBG4OcVtC/rbOqc/a
855OfK6bc8qzni5Jz/rwOnn/s8Euyc+Hu6jkfz6Kz45zTn46idem8r3TeX0mMJA+9flcMJ/jhYyL
If1S5sv4GauI+mtOClJfrHdJfrLpZGLBZufEh9scYvN29T8eEL/rZrZ6IW9ABCH+uZxCnGeu4wLR
/wLHFyC3KYxCYBQDHINaNCx0CEYRUNMADXeLugDVCZjm6OICdOKLzX8H8hd/jy4E11m+FDdgEACD
AxDySxqgCoAmAp4IkzH6E/WF/K9HPUQSYVBRLHqd5/j9wXUXovwmTL9bf7+ce5fPvt97jIJmIiy/
++cUFwAIfV7Dm8htPJ+tCYCMxXCDNED+bqewYvXZ1B3LIP7XWiogRUFZGRAXIAVBvRbwbnWAcvO3
my04HW/mGnvb/EL2C4szmU/LnE5+UpYqfjmP9JflsfEVXVOeVHJPeVoZkn1AJR0BePIhIoAAPP2Y
c58QZetANrH/XxB1v0YA6kPeBohEY5fkp82ck542RyTaQO72nO/olPRUjf4Qvjev9ePcIEg/DLKP
dE5+NppxHGIxifk0Xpvpkvp8Fu+dy/l5nFvA8SKwRCV9yvMViMAqyL+G+Trm64X8iMAm5+QnW12S
CrZh/XcdCL5l2WqfN9X+X5VwrNRFCHs257siOMexjvPMz0PyEqGJQlFHICLwHTCsIly+jSsw1gIQ
ARMXIOQ3CkAe+b9Ef5X8JjZfEwBfRiOI9L46tPNGEdA+qzoBcA1cRQSuAYMAACP5qeIL+U0EQI/8
FzURMEZ3NeIbyK+T/RzzP4qzkE0Ftrk45Lv1c6Y/p6T3Fjmnf+fbxhJ+nnzHOe28Pp4lF/994HeH
vMVxhnNGZDF/GzJ53QRns36gR+BnJZ1C4ILzCUrdmft2QHRpFzZ1AVILKJ4GcOod/ptzMsHMKfqR
uXtKnoV7Rn4Z9+SnZVm+KwfZK0D2iuTQlbDwlSFtVZfEp9Ww6DUgX03I/TEE/gSi1SGy14XkXzip
AvAMAXjWkNeaOCU+aeaU9Kwlx20gfnvQyTH5WVde6+GY9LSPU/Kz/rw2xDnp+VBeG8V8LN87HhGZ
7JT8dLpz0rNZEH82AjCPn7/AOfn5Qo4XQ/ilHC9HKFYhBmtwI+v5nSD/s40UAzfzu2xzSSzYTtFv
l2Nc/t6JJ8P95p+P5yL+Q/GFCGezIX8RvEJ1EQAVzHN0FIqCiMN5Xi8UBRyDiUO4hGPQnYCkBZ6I
gArNBei1ACkEqtFfyK8LgOYAfIjeAt+HPxWS3ZT4b5j7PNLSBU0A9BWBq3yvCk0EdAcg9v8yAqDn
/EYBUPNcifhEUUYdbyP8GQj7ziAavvN73+d73+W9ROczJeCsCI4qOoUo6X2F534q/B4htv6dKsl/
KATEPaPBg/Gdkcl7i0EEIO3FP5Vp1K/qTNqyDlo3Al+a1AJkWVDSAL05SNKA3/6vppeX2YqbaWZO
CXnm7qkPLTySH5WhuFeWqF8OVCC6VzyZ9KQSqEwErwr5qkPQGpCvlkviMwTg2SeOyU/rOKY8/Rwy
f8n8a4j8DSRvCJo4Jj1r7pj0pJVT8pO2HHdwSnnahbE77+uFAPRzTHw2kM8NBsPBKEg/hnEC3zGZ
z06H8LOckp7P5Xg+bmCBcwoCkPx8MQKxFLFY7oTt59yak8nP1vE7IQLPNyEKW/h5250SH+90SHi4
xy46b1+nQ74PTiU+pF32V5WkHlmviuAMxwIPyH+2JBQTBFNnYJoqSI1ArQ2oDsAAtTCoiYC+HHjt
gSEFkCYdtQio2n7N+kNmY6SH8Dc4f4Olytfw6FfeJ5D3/6oYRQB3UOgCigqAF30AV4BEf10ALiEG
l/gdBQbyF7X2RvJr+av6By9ENoEH5/6/Cvn/ee135//N470BcSkieyACRkDk0xyflvFdkcF7i8GP
FCAVAehh6a/U6DJ6NMxuUkIaIK3C+mrAuwnA5x6ZZtvDcsxOZbD+n/zcwi2hoAy5flkKaQjA0won
E4n+yc8qQfTKELAqxKpOlK8B+WoRxWsT3T+FyJ9B6HpOic++Yl6feQPGxqApaAlaOyQ9bcd5ov/T
rhz34HN9IHh/h8QngxCIocxHcH403z2O90yG8FMdkp7N5NwcXpvPuJBzixGQJfzsZbiMFQDyP1sN
4dciTOtxAhuZb+LcZr5nm1NSwU6H+Id7rCPv72+w7YoSR39/CGSiNbioAGS+xHK9RHVBFnMdCMEZ
I8QxIA5a2lAkXZDCoVYv0IuElyC+wCAAmgvQOwRJAYwuAPt/Pd+QAqiRH0egE9r3MaSH5Dr8SF10
mJ6X9xkhQpBPXwOiILUAge4CvKTDUSsEqgVAcQGS+zNeFGD/9XzfYPd/MFh9eiDOFoMHx0bIHzzH
p00BEU7/p1H8d5Dj9/kdhKjyfhl/D4jy6ueyvlfcfw8y+VwGSC8KD84FkcpFExjk79i8fMUOEL0Z
kNWAz4H0BZjWAWQ58N0EoM2uZLM9vvFm7ql55mdSXlqcSiwog+0vS8QvTwGtAjm0Gv0dE59UcUx4
WhWyfuiYVPCRY8KTWpyrbZ/85FP7xKd1Oa4Hyb9ySHpSn7EB5xrbJz1pClraJz5rY5f4tL194pNO
vNaV9/Rg3pv39LdLejqIcSjHI8AYXp/A8STeMw0hmOmQ/GQeWOCQ/GwRWIIILEMEVuAUVvL6asRg
DVjvlPp0I25gs5DfOenJVrDDMeHhboe4vL0rPRNP9bUOQkH/rvb1u0P04jjNudMQXyAiYEAxl6CK
QdHUwVgz0FKDC6YrBWpUNRUAQy3AkP+DvB8p1kF+Ib4KQ75/49HPSuLLvyt3fv6XUvDrfys//Ot/
lF//+/+o+P5f/1u598t/KfH8v/jRIHKDG1RusEQkgqCKAMRXnYCWEkgtQBcBtQ4AroDXBAAhuCAC
IKOW7xcnv0p4iXDFopwpWdwhwDuD73H/LbzP9/3e98rvIJ/Vx5K+B3K7/wbctNfdIPLvBmR3K4Zz
/D5y85l70mPlq1WuSZC7PWiu1QFEAGoD6QkwLQS+mwC023PdbO+1SDOPpHxzj5SnFh4pCEDik7Iu
CU/Kk0NXYKzonFBQ2TGhoIpTwpNqkP5DyF7DPv5pTYeEpx9D1E8Z69rHP/kcsn8Jib92SHjyrV3C
k0aQvql9wtPmHLe2i3/SjuOO9gkFXXitu11iQU/I34/XB4IhHA/jeBTzsYwT+a4p/Kzp9slPZ/Mz
5iAM8xEbXMCzJRB/GVgOVjnhAMA6iL+BEfv/TOz/NkRql3183h7b6Ly9ox1DgpddTlIFwAtCco9A
Eajkz3xhQLqMcix4ZUARYTCIggiBwR0gCFlanUCKhth/gZ4KXLpNOnDH4ADUNEBcgCYABvJzA5BE
fSE+5E2G+N/9838rf/vvQvzK3ACDCOh48rf/VsKeixDwWe5hUKEJgQ+jiIA4AREBQ1HQQH5VABBC
gdEBSPFPyK/l/gbyG/JbNfprxDdE1O9VuAtUssj423DjPcVR9PPv/l3vLDLvIAqv/V5Eb7e3gVzf
TSDvoVinguNTCMAprHshvtPmMr4j0nlfMVzm3yDl+T+UTdczlM/nHDoF0cUB6AIghcDfLwD1tziY
Hbqaa3Y27rH5qZRHCMBjBOBxWeeEx+WJ/BWc459UdIp/UgkyighUhfzVIfSHDggARP6Y+SfM6yAI
de0TnnzB/GuH+Cf1IXQDu/iCJvbxBc0cEgpa2iUUtGHe3j6uoOOJeEQgvqA753oz9mMcyHcNZRzO
8Ug+O47jCYjBFPukp9NwBDNIFWY5JD6dS1ow3xFH4Jj4dBGigCN4Jo5gJXUDSQfWihA4Jj/e7Jj0
eJtDfN5Om+g7e7of8c3mxh/1Dr8L5PJuGS9UcAMRo4gBc8ivjkCEQD2G/AJdEGSukt8EaiFRWz3Q
6wIXVAGQgiD1AE0AVBFgKfDKPZYDjQ5AF4CflRjuRXj5j/9R/vZfEP8d8Ot/IQTgp3//byUaEfDn
FlaBn6QMkjoIpD7A8XUchWkqUEQAqAeoKYAe/bXCX5HoX4T8uq3WyV9IWlMinYJ47w7IIwT6XZ/R
P/t7xjf8jkLk34SB8K5U8wXqnBzflej/GrD0xnPF53JsijSOi+Eq3YrJCMBop3Dl4yELVxdzAH9M
AFpscTQ7GPrIzE0VgIcWJykCOiXml3WOf1TeGRfgkPC4okP8o0oOiQWVifIfQOJq9gmPP4TsH0HS
WhC2NoT+FLJ+xnE9+zhcQPyTr5l/Yxf3uJF9/OMmRP1mvK8FxziBx+0geiccQWcRAdv4xz1PJDwR
IRjAa4MZh/F9IxhH8zPG8b0T7BKfTMI9TMVdTAczwSxqArPBXIRhPkKwiDmFQbU2sNIp6fFqp8SH
ax1iHmyyjbi1vdnOqz+zG5ESTKSV6M8qgQFEex3cVITyFsfrqYJaJ0AIuB25UAhk1UBdOShcIVBF
AEeg1wGk4CYC4IUAXMX+C67J7b9Y/xRWJn5+B9K/SRhEBCJNRUDSAtIDX5yBr5YOXBcHQJ3BUAfA
AdznZhcKS5dFAHACev6vV/3VSr1EfxPyG6K8gfBvipqmJHblvSpUorwJ/MHr7/sjo/797/Md8hn9
9zP9XVUi/zZOau+R0Qjs+0lTQOaTb8R32msyakhlNIEr52/wb5TIfg0tdl1VKnxaf+A7pADvXgMY
cz3Q7FB0tplL8gPzc6wCuCUhAPH5ZU4mPi7nEF9Q3iHxcQX7+IeVTiQ8rgwpq9jFFlQ9Ef+4um18
QQ2I/NGJ2Ce1bGMLPuG4jm3c47on4h7XA19B4m84/tYm9nFDxqYQvRloxfva8Ho727iCDrynM8dd
mfcAvUE/MIjvH8JrIgSkBAWjEYixgNrAk4mIwWRSBJwBNYKkpzNwCLNIBebgAOgToDko9dki6hZL
XBIeLneOub96h0/y3nYHfFBQdl2BgPQJFCKNOTAKgokw6GKguwVuV6Y4owkCKYHUEAwFQ4MQSGFR
RED6By4I1FqAtiyI9b98TxzA9wYHIALAKoAIQOqrvyu/QP4/iu+oDYTLHY1yOzMCIJCUQOoCaj1A
LQr+ongJ1FRASwFUAaClFReg1gBwAOco/p3VoOf8kufrttuN6rgIwBvJ/lbSQ3iId1IF5FDxWyLx
x183/Lx3gE5mrLxKahlLgAvnXCC6YTQF51LfhO947TeQwusmcEc8QhBvTxzp12tP34f8si9AO5Mi
YF2TIuD7rwIM9QgyswxNNTtJEfBUcr66CuAS96iMc/KjsvZxD8s5JDyqYBf3qKJt3KNKRPDKtrGP
q0DkqpAeEXhc40RswUe2MQW1bOIe17aOfVTHJvZRXd5bj/EryP+1dcyjb4/HPGp0PK6gqU18QXPO
tbKOKWhjHVvQzgYRsIl53MUmtqA76AF6Wcc+FhHobxP3ZBDjUMRgJJ8bhRiMxlWIEIw/kWQQAlKD
qQjBdCkWUgiULsG5zkmPF1DIXOQSn7/MIfrOyikuYe6T6Z5KpvX3ClGZDsNCQH4XTQRECFQgENyX
gBsoCaQHarpQ6Az0VYOziIGsEuhOQBeAi/pKACnAFeCFCOjRP5JdhiTy/1Hy659/9e//UYKJFP58
r5+kA0YnIKsCpAKQX1IBL3AFN+CJAKkOgDXmi0AE4Dx1ALH/4gAk91cr+5LzG3P8H4qQ//UIr5O6
kNwukFwF9rhE6K//1qh/3vh9EA+SukBsFTLXoZ8r/p1v+h1Mz6vENsC52FyO3wisvLOAqP2bgOTO
b0Iyr2k4i7jE8u94MOi28sUi6xuQvQtoC5oWWwaUzULeXwCGH7tpZh16x8w1scCcop85BUAL8v4y
rJ+XtY9/VM4+7lH5E/GPKtrFPqx4IvZRZZv4x1Vs4h5VhcjVrGMef2gdV1CDeU3I/zFk/4RzdY4j
ApC+HmT+ktfq89q3x0kHOG5sHfe42fHYx81BK47bIgTtGbtwvhvz7oy9QF++dwDuYBAYhgAMRwxG
noh/Mso2oWAMIkCNoEAcwSTqAlO0hqGZRH8ahgrm8f+y0CUhf4l9eO6KPlY3Inb6ZynxrP8LSUkR
FJqWNCAAEL4k6IIgYlAoCFqKoNUQ3FBl49KhSe+A6gRwANJCLC7A2A+gCoCkAD+w7Pej8pwi3p9F
fv17nv7jv5UgxE5EQGoC6ioB6YC35gRUFyAOQBUAUgBGgwgQ/TUXcA4XoKcAugAYCn4G669Gfi1H
LozmhuhqIKAp0Us6hxDzHudM/tC18Y3i8EbCFiO8KflN5obvfw/oBIfITkZ8x/wNIEI7FQdR3knF
q3dDsva+JEaZy6jhItdU7P8sjzjl0/Eb9kPyzqA1aAy+AvpNQaaNQHJD0Lu1Ak92CDNzjHhkdjb5
iblb4mMLZ1YBWO4r4xRXgAA8KW8XiwNIQABwALYIAHYeAXhcFdJWh7A1iOAfWZMGIAq1RQAgfh0I
XxchqHc85vGXHNdn/Ib3fsvrjY7FPmrCuaYGEXjU8ljs4za83o7v68DYifNdEIvux+Me9UYI+vGz
BiIAg3ALQ2zjngxHAEbYJjwZdYLUAPs/lhWCCfQnTIDY3CnIfQNJj2e4JD6c7RR7b759eM7iVnuu
PTyX9kQJJeqJrXdKec4/SiFwDqhtMSASLqQDKviMwCgIOANX4CYQIdBXDCQdyAYUGQuLgob7CMQF
XFJXAnABWh0ghpTkF3L3d8J7uoTHf/8vJUAEgD8cgxMgFQAiAtdwAldJByQVUB0AAiApgJ4GqA5A
EwBpjhEBMCzVSWWcCjVwJaoKxL6XFNlfIxykcoRMOnQyOUIcB6KlDtP3qHNeV2E618+VcN7B5DUH
fmYRqD/rHYGFd1DB76bBnvHN+J7XTEBkt1fxSrGH0O8MSG9fDJ60KCfw79j1iJ9SrXW/yRC7I2gF
9E5A2S/wIyACYNoK/G4CMNUl0cwx4K7ZyaSH7ARUYOGaUmDhmPC4jCMCYBf3pDxFv/J28XkVT1AH
wNZLCvCBddyjapC4OkQl+hd8xLzW8ZiHtSH0p8fiHtU5FvtQHMDnx6Iff3Es5tHXkP4biN6A1xsd
jX7Y5Fj0w2aca85rrXhfW8a2jO0ZO4oA8FpXRkTgcU+EoY+kBYC0oGCgTULBYFwBqUHBMOkdoAA4
ioak0XQCjjuZ+nQ8G35Mco7Pn+YQfmuW1c20hY22eyk8e0DN/1kmVByMeM78ueJYApwRCB16ynAy
7RlOQKA5AkkTMgwiICsG7JWAAAi0VAAhMLoArSlIBMCTFQApBD745d/vRn5TkXgPIcjDXdyUdEBc
gOoEDPWA6+AqKwMiAHoacImi4EUpBOIAzpMGnKNgKQ7AQ0C+LwLgRrOTRH9XBEDP24X8OtmdiLIq
IJ7AQUjL0pcp7Dk2AuLbm6L4a3Jc/D2vHUM6SF0U2uf073vLd6jCoxFbH4uQ3EhkndDvMP4W4Usg
uV3SS8WIROaChJeKI9/ly54M7HSt1N904RcI3l1bAmzBKNuDlXQvwPvdDDTLOtnM0j/HzCUxnxrA
Qwun2PwydhQBWboreyKmoDykr2Adk1eRqC4CUOV49MMPIHBVSF79WMzjGpD8o6NRD2sdjc6vfTTm
4adWMfl1GOtaRT/+3DLq8RdWCADnvrGKzW/A+UZWUQ+bIALNjsY+agHRWx+NftSW43bHYh52PBrz
qBPf3YV5dwSjB4LRCxHoC1QBQHgGWLNagAgMwgEMpkBIB+ETWoifjnBJfTqS6v8Yl8RH4xxi7k62
C82eNss1dO+gEyEoKO2/WHJ7Ij19BRoQA46LgzZlHEIhaDkmbXhKYQaodYJnBsgKgogAcEMITmc+
V4VAugjPigiIAGirAmoxUGoBiNBl/jGvUAf4jiW/d4r+JbmEdxSCu4jMTf7f/XADkgr4CFgZuE5R
0Ev2QuAWU0+E4LImAJICiACcBWdwAR4UAsUBuCEApxACV0YRANOcXie+EF6HSnIhHqND+ivFDvts
B9FeB69hkwvxpvf9h88Tue1MARHtXgO/E3n6a+cTea8KjchvGE9wvkRA/BMapBgYSlfniagHypfL
HWNKKAC+rQvw3RzAMq9Es2Oxt8yc4+6YOyc+sHBGABxiH5ah8l/ONuZheZsoBCAWAYjJr3w8Or8K
pP2AaF8Non4IcWtA/JrgY8j9CULwKQT/zCo6/3PGLyyjHn5tGf3wG+YNLaPyG4GmR6IeNbeKfNjK
Mjq/zRGIz2sdeV9nvqurVfTDbqA7otCHsS/i0h9RGIgzGIQgDEEIhuIMhiECkgqMxJ2MogYwmsaf
sRB0rFPCowkuSQ8nOsbenWoblj1zwDG/S8s9k1UBkFZfUoZ3EgBHXIIpxDnotQMRAR3UHIz1ARGB
QidgEICzuZoLIHqqxUC1F4A6AA7g7eT/P7z+Jrxf0TD3538bUgERAZyApAHXEYFruIArwBMhkFqA
wQVQCEQExAF4iAAAd10AJPojACfJ/wV69NejvpDfnshvAMTQSa+Or5QTCMKJNBmLAaIZz8n8PWHL
d78GfoatoKTX3uUcv4Pt+4CobqsD8tuqeGkAZH4vxPN+YANkBSAO0V7hmaJ8NmOPk1YAbMNY/D6A
kgqA7ygAV9gFOC7b3DXhvrlL7AMLp7j7CEC+ugJwIu5hedtoVgCi8yohAgYBiMmvSoSufjQqn+j/
8KOjkZA/Kv8TK4n+UfmfgXqW0XlfWkbmf20ZmfcNaADBm0D0ZghAc0jfitfagfYIQUfOd7GMftSN
93S3jHzYm8/3tYzJH4AgDLSKfjQYBzEMcRmOYxiJIxh9PPbhGGoDY1kdGM9KwAT6EybR9z+Z25Cn
IADTnOIfzHCIvjfLNjRnXvv911Jtou6hoj9R3X+G4j4BT42gtwClNoEIBCCtKASOwQFwsxMphLgB
EzFINbgCSQ3YAEV1AgKPLFYLpJVYbiDCeQikFiB1ABEBKQT+xLLdr0T3PwScwK9vgGlxMe2nf6ki
IAKg1wKuSxpAC/EVaiOXcQGX6AuQNEB1AYziAE6TArjhAgSqA9DJjxjoxTsnCnk6+e0QAdMoX0h6
A/lNSWmDIBgB2WyEcJCzyHnT9xSfy3vf5/3654mqNkYYfq7hGNIJsOMqIO/vAoS3MeIF87cgnteK
wTr2haLjHCsAcRRwh+Bia/adIXsAdCqhAKjn//qdgO9eAOTL/tcW7zii/0Nzl4RH5s6xBRbOiY/L
2MU9KGsblV/ONvZhBQp/FW2i8itB/srHYvI+OBaVX+1YZP6HRyPzsP75Na2i8j62isz/BHLXYV7X
MuJBPcuIvC+PROXV59y3EL0h8yaMTa0i8loeiSTyR+S3OxL+oAPi0OVIVH430JPXe4O+OIP+iMFA
vnMI7mEoTmAEGInAjMYNjMWBjLeOezjeNv7RRHoTWAosoGW4YBoiMJ3mn5mO8fmz7SJuL7AOyljc
eMeVX2/e/U7xhXD0DqDEBajyEyMMgqAhwTAiKry3ECwzIgZPyMcEIgKkBxpkNYHUA3F5aqgPpGsi
IDUBRECtB2giUKQYyO/z+Nd/Kz8jAH8IkF+WEd8FSTzgxOgCqAeIC5BioOoCJA0AF1kduEB/gAiA
pAEiAO66AFAQdEUEjNFfy/8lx9etvyoARHzTaF88Er9GcJ2MRNBCYpqStOjcGtIXxXccmwBbbi0w
PafP9deMI9+FtS8Cfg/rN4HIbv1bSOA9CIApjiMCRkD44+BYsVE9F1cIa46vcM0jSdea7LyqlK1e
q79WAGzJ2BB8AfQdgfS9AN4v/xcBWH421exUTIGZS8oTc+e4AguW/craJajkL28d9RD7n1+JiF/p
aNSjykcRAOx9NaL0h1aRjz46EvmwFuStDT49EvPwMwhfD4J/Ab7mtfqHI/K+PRyZ1+hI1EOs/8Pm
nG/NubaHiP4Ho/I7HYrK68rrPTjXk9f78D39OR6IQAzmu4ZxPBxXMAqMwSWMsYx5OJ6fPxERmIQL
mGwT/2gqvQnTHOIfz7CLfzgL8s9xjM2bdyL81uL1l2J3dj58gzVUohskJG1AjZ+8BlYUDMKgikMB
IlCACAg0MdBGEQHVCZiAG5DU5URVBDQBUFcItHRAXIAqApIK0IOgigApgDQFSc//HyK/iMc7kl/e
9yPvj+WhJ748RcdHUgFE4JpeC2BlQHUBrAiICJyjJ+AsIiApwGn+CFUHwFxNAQQsTckSnkR/vchn
L1ZfgwiASnwNNowq8bVI/zqJNRK+Ru7iZH+lHOc9bwTff1xH8feZvlZ8DuGP64Dgx38PIP7xeB0v
mQs0spsQ+7jJ3JTw6pzor0OKgP78O5zBdX69xu02VO0G3vUmoHez/+aH/M2WuWWbuUY9NHdMyLM4
Ef3AgjX/sraJj8pZRz8sfyzyfoVj0QYBICpXsYzIr0o0rk5krnE4Mr/m4Yj8j8npP2FehyhfFyJ/
cTji4ZdHIh5+fSj8wTeHIh80OhSV3+QwAnAoIr/FwYi8Nnym/aHw/A7MuxyKzOsO4Xsy9jkUkTeA
7xnE+4eC4YjASI7HkDKMRxwmIAYTj0TnT+ZnT8YJTKUoOZ2i4ExWA2bREzDHLi5/vn1c3gL76PuL
T4TdWj7OPujsdPcYJZZIx2amqGuBcjz2iQp6DIxgZQEbVghWGIyCYBNf6BB0QRBHwE1JRjFQ6wMi
AmphUEsHdBHABbgjAIZUQBMBUgBJBa4++EF5RqX+D4vAe7iIH0k7InnajIiANyIgKwJeiMCVh1oa
gAhc0FyAKgCkA6eLOIDC/N+JNMCJdmi14KcSn/xdYCS9icWH/NbgOJFYJa9OQI10x4jC6jlTIjKX
8/85vORnAex/iYCQx94EyH4MHI0rjhecM8BKAMGPAhkNeF4UMRxHG+CECMl29dt8s5R68608tQKg
3gBUn2PpANS3AyveAPRuAiAOYI1rmplj+B1zh8R8C8d4in9R+WWPRz0sZx3zoPxxqv9HI/IqHY18
UNkyKu8DonLVI5EPPoS0NSByLQj/8eHw/E8OheXVORKeV/cIAgCxvzoYkV8fQjcAjThuCuGbg5YH
I4n+EXntONeR93Q+GJ7f/WB4Xo8DEXm9ea0fQjCQcSivDYP8ww9FPRyDWxh3OCp/AiIiAjDlMEAE
piEC0ykIzsIFzEEE5lGvWGgXm7/QJvLu0uOh2Su7H/aJkf3/wvnjZpWAf4DHKo4WwzGOVcSC+McI
xGME4XWIQ2DlQXMHBoeg1gs0R2AqAiIE0kmoLhGKAEh/QC5O4BYiwM1BakEQFxDArj/f07gjvfz/
KUjLcDB3RYoAeFNguoZA6sVANQ3ABVygIKjWASgGnqYvQAqBp3ACavSXAqBKfpb5WBEwFvxMyY8g
WCMEKkwi8THmxyB6SaS2egPZ5bzl24BQWP5eELUtjXjJXANktnxHWGHvdVgKqYn6MlqakNsSYr8T
IL6lhlNcq2jSs0muUcono1fthKpvagCSAmDxnYDeXQC2B6eZ2UXdNXeKvGdhF/uA/P9RWWvyf/L7
ClaRDypSjKtEbl/5cMSDD46EPagO6Yn+eTUPh+fVOhh+v/bBiAefQuq6kLreoXDIH/6gPqT+9kB4
XsMD4Q+aHoh40Jz3tILsbXlPe8514rXOjN0gfg/mvXlPPzCQ9w1GKIYdiMgfjgiMPgj5cQ4TGCch
CFMORz6chhBMxxHMwInMIhWYQyowl5bk+TYxeYso+C21ibi7/FhI1uoWu68+OZtaoPgQbSXCW0Js
HVbMTXGUY1NhEBHQUVwMRARUISB1MIiAuAFDfUAtEKrLhDgByH+KlQc3cQFSEBQhQADOmaYCLAmG
sULxI7f//qcEQH7OSxDIfQOqC0AEvICIwGVqApfoOxcXcA4ROCN1AETAHftvSAEMIuCCCDhDflMB
OAHpbakBiO0Xuy8RXwRAIr5KfHAU8guE0ELsIzog8BFB8WP9fEkjxD3yO1BI+KLkPwL5j0B6FURy
SyDj23CYqH4YshvHGOZGPGf+G4DshzUciX6mHIkywBKcZTUlin+T9gd8lSqNOsouwH9uA5BEf/lv
h0+imXPkbfNTcfctnKPyyhyPeVDWJuYhAvC4AkW7ilZRDyph76tAuqqQvzoErwHhRQA+JvJ/ejDs
/mf7Qx98fiAs/wvmXyMK3+wPe9BgX8SDJvvD7zfbH3q/JWRvDdHbHQjN68h7u+wLzeu2Pyyv1/6I
B332hz8YsC/swSDGoXxu+IHQB6N577j9EXkT+NxkxGQqwjEdQZgJZuEQ5uAK5h6OfjiPmsACVggW
sTqwBLey7GjUvRVWYbdX7/FJ2tqE/dMjHrIvO8SzjHmkHDGBHBeHVewjRKEQrDpg1wzuQMRBFwRr
3IHUEwQiBFJULCwUFq4UqKsDIgLiBFQRoDAoS4O6CCBMF7W+gEg2KpVVgT+E93QRT//+P8pNROA6
tYCr3CZ9hWqzKgCsClxkWfA8XYKGOgB3UOICRAAMLuBHxZllTUkBHHABBgdgsP86+UUAjgmw/Drx
9SiuE/8wpC4CLO9rx3KOavyh38Qr3gPIwY1402cg+iFwWBtlfogorgJCq4DUb8JBXjMCsh80RTTH
RjxnLnj2OiD4weKI5JwGcQFXuM5e3GDGMwFfQNM3NQDpDwZ5/92AjQJwJdfsVOpTc6e4hxYnwu6X
sY66V46lNvL//AqHw+9VtAy/Xxl7X4WcvOrBiPsfktt/RKSvtT8kr/a+0Ad1DkTcr3swLK/egbAH
X0HgbyB9A0jeaF/wg6b7Qu63QABac9xuX+j9jvtC73XhPZD/Qc+9Yff77gu7N4DzgxCAoXzXCOaj
eW08YjCBcQrnp/G9M3AKsxGFuWAeArAAQVhIurCY1GAJacEyy8gHy0lTVllF3l1zJCh7w4yTYa7D
7ENQ0J/U5blDUY+UQ9EPUdtCUFtQdByO4TwQkTAVBpYgEQETaOmCQQSACAB1Aikkmq4WqMuF1AXU
moDuBKRRSFwAqcAZ2TQEAbhAQfCS3CVIPUB2APpDAiAC8p4i8Phv/8PS4N+Va5oL8CTiXJJiIDiP
EzjLioAHLkAEwI3djVwRgZOsDIgDcKI12JG9EMQFSPHPFgGQYp9u+fWob6lFfBEA0whvJLspUYWM
xY4Pcu4vBVH+IKQ3Qid4cXK/7VhIHwXZS4IJsQ9GPoXkb0AE5zXYkD4E0JNhGXpX+XKpXcRf0gAk
AtDN3sds/7Vcc8fwPHOHqIdlbKNB+L1yRyPvlyfnr0C+XwkRqHwo7P4HRPZqB8Lvf7g/9N5H+8Pu
fbw/7P4n+0Pu14Hkn4MvwNd7Q+99uzf0fkPQZE/I/eYct4LobTjusCfkXmfQfU/og167Qx/0Zt5/
D+TfHXJ/KPORvH8Mr43j/RP3hd2fvDf0wXREYRYiMIfPz2Ocvz88bwHisAQsRRSWIQQrEIJV/H5r
WVZcdyT87saDgZlb+x/zC13plcJjln9SiXkAATgQ/Qglfh2HOHcoOt+AKIRAoAsF5DcVBREEcQni
CMQZ0JhEpRc3IEKQZFhBsGeUlEBdKpTiICJwEvK7ai5ALwrqIqCuCkh3IDcHpfwZIvCeTiLvb/+l
pgJePIn2CkVBTwpPF9VawC/KOVKBM9pqgJ4GnKQo6EJNwBkBcGAp0J6VACG/RH+10Kei0PJbIQAq
8bWIf4hRhURsHRrJ9SguhD9gxAvlAHl1iYCsB1TwfuNcOyefKX7ut46x7AeKYT9kNILIvF8HZN9v
ikiOX8MzzgmeFgKS7y+OMM6FAxlD6UXhdw/n32D++UR5BoANVJU7AIs3AMlTgX5/A5DuAI7c4D6A
yHxzx5h8C5voPNUBWIc/KH84NK/i4dD7lQ5G3q9CNf+DA2EIQMi9D/eF3Kt5IOT+x4yf7gu+9xn4
HNJ+sSfsfv09CABjYwjbFPI33xtyr9Xu0HttIXeHPcH3u+wOvt+dsRfotyf43kCORQCG8blRu0Pv
j9sV+mAS4xSOp/GZWWAu3z0fYViIICxGBJbsC89bzrhiX/iDVYjA6gOR+WsRjA37Q+9s3B+cu3WP
f9rOdnuv3beJus/6//cQ9REX/6EBkPtACTjIORUQn+VJhECDKg6PVEEQt1DoDgxzPUUQETiOCIgQ
qMuIyQhBCnUBzQk4syworcOnEAK3HNIBXIDUA85SDBQnoIuApzyi/Md/4gT+50/G29OLOz//F2kA
26WRBngiApdIBXQBUF2A7KPIngaSBpwEugBIGmCHAJwgDbAhZ7Wmc00EwDTf1wXgMNV1A/GJuDo0
4qtkJ/c2kp75fuy8ijjBizcA0r3xtTd9hvNE8yIggu+H+Cq5NVLvw6K/FyD6PkGEKZ5yDMKfvBV7
eX1vWCFOcp3CEeC+PAz0o+7j58NVaQBqBUy3Av9jDUAiAIPPZZgdDskysw+/a+EQnWdhxy3AR6Py
ylmF3ytvGf6gIta/Epa+yoGwe1XJ36uTn38EuWtCxo8ZPyVyfwaB6zF+tTvk3jfMG+wKutsYNIO8
LTluvSv4Xvvdwfc6MXbdHXS35+6ge713hdzrtzvkLuS/N5Tzw3cG3xuzK+T+eOYTwZRdwfdngNmI
wTywkO9ajFtYCpYjMCv4+av2hj9Yszc8b93eiLz1e0PvbtwTcnvrnsCcbbt803Y33H7lXzfuvFIu
UHyTyL8P8u+LzOcftBD7OTbFAV4zigNkPyBioEEXhMOQXsAqhCoARRyBXhsw9hNQJNQ7CGkQEidg
SAdEBNhqTC0Ksp0YInBOSwUukwpcoWvx9k//eRHI/unfhmKg1AK0VEBNAzQXcBpLKk1Bkga4MDrj
AiQNsMcFiADYkgbYUAQ8jghI7q8X/I6wtCZQBcCE/AeYC/YLVMILIKKMQmrm+7DnRhDl92nYy/m9
RHMVMjdFTLFj/TU5XyL4DgRhLyKwFxHYiwioQAhKBNF8b3FA8r0CovjrgNhCcB0mRN/D+1UQ+VUQ
/feFUQDkOgZyvRtsZQfgchV6QlXZA1BuAPrzGoBEAKa4RZrtZ0twx5j7FvYR5P8ReWWtYx+WOxL1
QM3/sdyVyMWrYPerYfGr7wu+X4PIXmsv1f/dYffr7Am9+xnErUfE/npn8N1vdgXfbQTpm0De5hC5
Jcdtd4bc7bgT+78j6G530Avy9+W9A3YG3RmMUAyD/KM4HrMz6O54xsk7Au9NZT6d+Wwwj88u5PsW
876lfHbFrtB7K/kZq3aH3VuDOKzbHXp3w+6QO5t2BtzauuNm1o75Z2JOdLX0U8K09t/d4fmKjj0R
+YopEA/+4TSIQGgoFAaDczCIQ76aQhgcgUEIBDRAqUJwFKehLiNqtQEbtalIqw3QKOSICDjLzUSk
Aq6Q/5SIAL0BqhPQ6gEX75MOsFPQVZYu8+gU/BEn8OeBZiDSg7chFfdxBRFQawHiArCh51gWPMOK
wGngRl+AKzWBk9QDnBEBR2oBqgAAW5yATYZU/Q3FPys6/Ax5v4H8pgJwgOq9RHwh+z6i/95i2MPx
Hogr2F0ELzgGEL9EQOLdOkzfo53bw/g6nqvndkN6I7Dyu4vgGcclgGi/WxAueGoARC6KJxz/BkJ5
XcNhfs41xNWelPSrVSfTJFMHf24DkG7/hzj7mh0NzDQ/EZplcYIlQFp+y1qG3Sl/IPR2Bdb0Kx4K
e1D5QOjdDyjeVdsfcq86lr4m1v1jIvonRO/PmH++O/juF7uC79SH0ET/e40hbVPmLXcE3mkDkdtB
+o7bA+92Bd1BL873B4OYD4XsIxjH7Ai8O473Td4RfG8a81nM5/Ad8yH9Yr5jGVjBfCUCsBpBWMMc
4t9bjwBs2hl8Z8vO4NvbdgTk7tzml757yIlAv5ln4uj//5Fe7gJlV3heISD7bo5NsYdjFbwmKBQE
5giCoIhT4FhNE3ABhsKiiIBhidEKEdCF4JikBPx8tbtQ+gXSEAGg1gSycAOIgBtQRYDeAFUEKAhe
pB5wmXqAiMCjX/+LJUJE4H3wRtH4bQEQcUjkkemSBogLuMCdaCIAZ1kRkDTAjahkEACDC3BiNUDq
AKoAyNq/mgYUrfxL/l+c/BL190F+Ib5KdqK9ARrxhbxCdA27GFVwfhdR+vdiN581ggi/W8MuyL8L
y78LMhcBxN71m3iq7IL0b8YTZRfk3hla8DpCOCcILsQxfpcQ7stYezVd+Xzu4bNa/v/nNwCJCPTe
ed3MJoybgJIfWdhF3y1zPOxO2cNhFADD7lc4GHKv0sGgO1X2Bd/5YH/wvWp7g+5+uCfwds29gXc/
3hV499M9gXfq7gy4XW9XwK2vdgbe/WZn4L0GOwPuNNkRcKc5Y6sdAbfbbr95p+P2gLuddwRA/pt3
em2/ebvftoA7Azk3ZNvNOyO2B9wZw/H47UF3J20PvDMNzEQQ5m4LurOAcfG2wLvLeW0VgrEWYVi/
I/juBsi/cWfQvS1gG2KwfUfQnV07gm7v3uafvX+zd+rBzgd9snYF5Ch+LLFJ7r49NM+AMMEDI3Yw
N8VORMAUIhK6OOiiQP2BnA6nAKg9GFyBvsKgLTOqS4mydIgTEEegioB0D1ITsBMRECdATcBFdwII
gMEJGERA0gFdBLzZx+DJ+4rAOwuAuIvXReEH6RZ89Q/lklYLOG90AdQBNBdwEhHQ0wAH+gLsWA0Q
B2CtpgCGJUBJAax0648D0C3/Psi/FxiIbyD/bkFxwkP2HQKisyl2QuKdLK3p2A6JTbGD1wTFz6vH
RHUdOyC8ERB/hwCyG/BUxU6TUeYqIHsRYNt36ghhbsQTZUeIoKAoIPsOIx4zB0GFsIsTAfhZGekQ
ptQetngDNH3XHYDe7TkAevSXcZJrhNmxwHxz24iHFrYxeWWsou6VJfcvfyj0bsUDofcqUfGvsgcB
2BN0tzqWvgaRvuauoDu1IXSdXQgApKzH8Vc7Am9/A0kbMjaB1M23B95uxbwt5zpuC7jdBZL32Bpw
uzfz/lsD7gzedvP2MI5HcTwOTNwWcGvq9oDbM/jsbI7nbb15axHjsm2Bd1by2TWcX48YbEQMNuMO
tvFzdzLuRBD2IAD7tt3MObjFL/vIpuspR5vtuvrjGRqALnBDzl6Iuj0E0usIZW6CHcwFOxEDwS5T
hHOsAgeBeOhOQheD/SYiILUDqRcckqVEreFI3ICViICJE7AVEaAw+LoIfFfECZwTJ5DHcwRwAr6P
f1Ze0C34x12AKdlLJr8uCPLwkRC6BUUELtIqfA43coZagAcFQdUFkAq44AKkDuAITlAMNBYCEQER
ACvSgCM0/xxGBA6CA0CN/BpEAHYjACr06K6TvvgYhQiA7YiBENmUvELobZxTgX0uca6/zrgV4hvB
+7cKIP9WiL8VchfiCfO3gKi+DWyVEaKrCC4BgQXKtmLYDuGNCGSuQYTgJNdHBKAlj7GvWLfhMGgq
DUCmNwDJDkA1wO+/AUgXgdFuqWaWgXfNHSLzLWxpAjoSca/ckYj75WnAqXgg5E4lintVyO8/INev
DtlUAYB4tbcF3f0M4n1OpP4SUn69PejOt5C10bbA200hbovtN2+13nrzTnuifKctN293Zd6Lsd/W
m7cHQO7Bm2/eGr7l5q3Rm2/eHsc4mdemcW4G4xyOF27xv72E+QqwekvA7XWIxUbGLVsD72zbGnh7
Bz9jF8Kwm99jPz/zwFb/7MObfdKPLbsU59Jyz3UlmGIaTwbiH+W+sjVYg8yNuMdcYDgn79sWWojt
zHdqeE0kTFIIoxhImqDWCBACtaeAtAAnYCntx4jAUUTgOE5AUhJdBBxwAk6aEziZQ01AdQJaYVCc
AHsGiAhcZitzfxp1XtG4804i8Na6gYjA28mvi8Ar0g5pFLrAsuB5ROAsDUIiAOICTiECJ+kNcKIn
wJHmIHtqAbb0A6hpgCYARyH/EVzAIW6xVcmPC9iXSGEP6NZfyL9TQHFO7L0a8cF2gUZ2Ifw2bLFK
biGrTmCdvDIKeYujhPNbeE+JoPC2BfJvIZJvgdAlo4DzgIhuiq1E861Bb8Y2SL0VyLgt8NHruMk5
gf8jZQ9CcB7x9CBl/Hqdx6Ni+b++A9CbHgLy7u2/ugBMuJJudij0FgJw38I2/GGZ4yH55Q4E3yt/
IPB+xf1BdyvtJgUg+lfdGXinOlG3Bla/Jva9NvPPIF9dSPgF+BpCfrv15t1GWwPuNt0ScKcFZG0D
odszdgbdmfdi7A8Gbfa/PWyT/+2RmwJuj90ccHsCr01FCGZuunl7NuP8Tf63FnFuGfPVvHfdpoBb
m5hvQQy28907N0N85nsQhX1834FNN7OPbPTJstp4Pd16rGOI7wiHUJ6j9oNajNsE+QtxT9kM6TcH
a6M6v2/EFuZbEAIdW42C8ABxMDgHXQz01MFYS5DagV4vECFABAQiAkcQAUsRAXEDFAWt6ROwoU9A
nIADTUqqCOBWTlIPcEUE3EgFpCZwhlRAnMAFioKXKWgG0jL83bvUAt6aAujk14uLb68LvPzH/1bv
HDxPPeAcRcEz/B7uOAFTFyAOQNIAcQE2dAZKHUBWAlQHgACoDgDyGwQAy8+4R0bN9uu5vU78bZB/
GzZfJb1Ajdpa5NZIbSQxlfctJtjMvBDPmOswOQ/RN5sC0m/WgX3fTCQvigKOAUQvCZsgdhFA4k1g
s44A5kY8Yl4MNx9yDjDuD6N1HUHd6ZerfLHY5iY8/a0twKUDUH8GwPsLwNzTwWbHw7PMHeO4CzDy
XpnDIffKUfArT+dehT1BtyuR81ehyPfB9qDbCMCdGuTwNcnNa2PJ60DeupAQAbj91eabd77d6ne7
0Wb/W81ASwjaBvK2B503+d/pttn/Tu9Nfrf6AxGA4ZB9FCIwbpPf7YnMp0L6mczn8doijoX8K5iv
2Xjz1ka+ewvz7bxnB+d3gz2IwH5wCKE4vNE/x2qDd5b1Oq8k216WfinSABRINV0KdRsD7xYiiLmG
TYwG3CsKEQcNWxh16C5CnMJ2gVEQqBuQHkjtQFIEEYR9kXm4gTyWEakRIAKHZLVAhAABsKJfQE0J
WB4UETghQkBdwIGlQScRAZzASXlyESJwGhfgoToBgwhcoqgZQsvw7xIBEQ413zcl/rs5gSd0C15D
BM4hAmdZFvQApygKShogtQAnWoUdJA2QQiC3CVuzicVxXIClJgAHUw0pgCoAjEL+3QIEQMi/QyAR
H9JL1BfSbzXBZiL+Zoi/CTKXCMi7yQQbIbcBz03Aezj3GiD8JgivAvteFAUcayDCbyqGjRC8CCD5
RiMeKRuJ6qbYxPEmSL7pZn5R3OBYg2XEEyWQ6zrdPVapM3HzES3/f1MD0O+/AUh3AMsvRZnZxmaZ
20blWhyNuFuWPv9yB0PvlN8TcrfiXhEAHAD2vuqOoNzqO27errHV/3YtRKD2Fv9bn0LIupD+Cwj/
FfNvGRtCzqabb+a2YN4GgrffdPMWAnC7+0a/270gfz8wcJNf7rCNfrmjNvjdGgsmbrhxa+pGv1uz
Nt64NW+j/62FzJfx/pUb/W+v5ngj41Y+t4Pv2cl8D9gHDoBDvH5kw41sq/XXM21WX0m0a73n2jOb
6Pv0//NHBUk3BNwtBGKwwYg76rxQIO4ZxcEgEiIEd00gYlDUIWyjriBQ6wviDqSOQM1gt7aasA8R
2C8iIGlBLGmB5gZEBI7iBI6ToliLCLBEaEc6YI8TcKIw6KI5gVPsInRa3AACcO4BDUPUA0QEIukW
/AFCvzMgvfG9MqddWB42qkLm74BHpB+e9AecY1XAAyfgzr0Cp1gVOMkfq7MIAKmAuAARABu25D6O
EziKCzhMR+AhcIA0YL8mAns1B6BX9lUBYB1+O9gmQAS2QPotRH0ZRQA2qQIAqXVQjNtoCiPpnyob
Qp8pG7D0gvVYfhVyTsP6EI4h/gYdwcyL4AnHBRoeM2qA8BuKA8JvuGkCv0fKhpLg/1DZ6Af8CUoC
CK9jw408ZaOvHOcpttFPlQBEtcthP6V624HT4GnxBiDTHYB/3w5ApkXAJR5JZrYheea2pABWUXfL
HA69U25fyC2i/92K+wJuV9rhn1uFCF91d8Dt6kT1Gpv9cmtu879dm+j/GaT/fKtv7pcQ9msI+w0k
bci8GWNLxjYbb+S233AjtxPE7gbhe0L2fmAgxB3KOHK9/62x6/1yJ2z0vTUVEZgJZnN+/robt5Yw
X77+Ru7qDX656zm3ef2N29s4t4P5LrB7g/+t/eAg88Prb2Rarmbnr5WX4+3k0cnXyaPZJVjZFHBf
WX/zHrhjGAMYX8NdzhWiUCAMYiFiUNwpbBZxACII4gzU+oFWQ1BTBFUIcAMiBLiBvTgREYL9khZQ
IDSkBAXcQoobkJSArkERgROkA6oI4AScxQmQDogIuNMo5MGKxhlczXlqAhcQgdj3FYE3CQauQKr+
74L77F0gRcEzIgLiAqgFuCICLtQCHCkIqi4A+yoiIAJgRSpwhHz2ELUAcQH7GVUHoFX/d3HzzXaV
/AarL1F/C9gM8QWbhPiCYqTfAKFVaCQ3juTuG8B63MA6BMEIiL7ubQjidbA+iM+CdYGMFO2KANu+
3hRE8/U6yN3XmwIBWK/jxkNlvRH5ynqIrmOdb56y3rsQm3nNFVd0lT0W6m+++Dd4WvwGoD9nByBT
AVjtkWZ2IqzA3DrsvoVN+N2ykgJg+csT/SvuDsittM3/VhXW16tu979VfcuNWzW23situdXvVm3I
X4fo+/mmGzlfQsKvN/rnfgvhG6/3y2kKMVtA3NbrfXPar/e91WmDb263Db45vdbfyO674UbOwPW+
uUMh90gwBkzgeCrjdDBr/Y2c+et8cxeDZetu5K5cdyNnDcTfiChsWX/j1tYNfrd3IBq7mO/mu/ev
8806vPpautWqqynWk1zDL/ayClBukjtzd6Cyzv+uhtuMGm4yGnGH+et4TSQCxS0ASC/YhDAYodUY
1BRBLzBqy40iBLKKsDvigbIHEdiLAOyXDkNSgkOIwCG5RZl6wDEKg8clJaAmcIJ0wI4+AXtEwImH
i7ggAq6aCJzm/0utCyAC58nFU77/57u7AF0AhOymYvCO5NcF4tYv/21wAewm7CYuABFQXQBRS1yA
LgDWiMAxlgWPUBQUF3AQ8u+nMWgfPQHiAHaRAuyiwUfN9+m1NwiAIeqrER9spLq/QYdG+vWkAesh
t5BchynR1yIAJQJ7v7YkQPi1EF4gxF8XoKOAuQFrifJGEO3X6oD0ayF6iSDCrxVA6kLkMTeBD3MN
667nKTtwCZcQTEtqU1+tcI7XCoD6I8C+5VjfAdj0MeC/P/8XIVh9KdvMOvy+uU14vsXRwLtlKfyV
2x90rzz5f0Wq+pV2UgOgw67qlps51TfdyK2x1S+31ma/27WJ8J9u9rtVl8j+BcT/auONnG8heSNI
35So3wIyt1rnm9N2nW92R851Zd6DeS/Qf51P9mCOh63zyRm11jdnLGSfuBYRWOObM2utb/a8tTdy
53N+CVgOVoF1vGcjr2/mtW0Iw451Prk7+fyeNd6ZB1ZdTT+8/HLCsb5H/SPn0ADkD0m4lVhZ438H
3C4KyL/GCF5HAN4Go1gE3EbxNeAK1oMNWqog6cJGk2LiZn1lgSLi9rD7OIL7NJcgBBQJd+ME9okQ
IFDiBg5TF7BEAKxIB45JSsAyoQ3PJDihiYAD6YATNQEpDp7i/8uddMCDAqc05pzHCWT88E/le/YS
KBGQu8h5Of4TkPXjv0kDDC7AjYYVF1YERAAcSQXsb/2k2OICRACOUxOwpEX4MDcKiQs4wD58+ygK
7uUGoN24ALH+Uu2Xgp+B/BTgNLuvW32J9EYbL5YeG79OxVOIDojsgtVY+DUQXAW5uj5fBcEFqzlX
BET41ZB7tT7K3ARrILkBjwoB4dcUBwKwxhcQ5YvAh2MTrEYIVkP+1UT8IoD4q8EasI9ioj/Xb8mF
ZKXurP2uWgOQ5P/yCDDZAegzIDsA/fEbgHQXsCog3cyGVYDjoXctWPYrezD0brl9OACW8SpS4KtE
Q0+VLf65VTf4ZX9IVK+xyT+3FhG5NlH7042+OXUhfT2i9lfrfbO/YWwEOZtA/hZrb+S0WuuT03aN
T3ZHiNsFYvfguDfzfswHrvHNHsp8BEIwBiJPWO2bPZnj6cxnrfHJmbfGJ3cR49I1vrnLeW0Nr61b
7ZuzYbVv7mbEYivftR3y71rlnbF3xZXU/csuJRxpv+/6rR03c5TLkEai8Sq/28pKoI/GOaKwEqwy
jnfU+ZtQKBgiHneIBjgLExjSBqkhiBDgENRVBlYXRAhICbZqzUdSH9hFXWCXuAH6BkQIDuAEDuIE
DpMOiBCICBzDCdggALbcNyBOwJ66gJoSsDLgSlHQTUSAh4ucoSZwDhG4xbbfbxQBU3H4E8gvAiI7
CiWywehpagHiAlxZFXBh7zpHNg4RF2BLOmDNsqBRABABcQBSBxAHIKsAsvRXVAAM+b7B8hP9w4n+
Eu0RAGOE10lvJL5GeEi/iiKeKdn1+Sqi+koVBQZAcsEqovoqCK7C/3Ws4NwKyL7ixiNlpYZV5PCv
wZdzpvDmGKz0yVdHfb6SSG8EZF95/YEBVx8oq4CMh1li9EM8B9uGKLUGzpFHgP/5OwCb2n+Zb/Cm
CBicZX484p4F3X9lDobcLkcHX3msfwXy/0rb/HKrkMN/gHVXHcBGv5xakLY2JKyDta+7zjun3lqf
7K/Weud8w/mGq72zm6z2yWlB1G4Faduu8s3puMonuwvnu6/xzu692junH/NBCMNQzo/kvWNW+2RP
AJNX+2RN5fWZq69nz13lnTN/1fWcxbxn+UqfnFV8z5qV3jnrmG/g3CaEYOuq65k7Vnil7152JWXf
kgvxBxtvv/LLaSLoSQpr62/e5R8OohfBLcOxJgzFx+JCIccqEIfVRtxhLiJQiHUIwHoNIgS6M5Dl
x80UCHUR2EZdYDtOYCd1gV1yTwLpwD7aiPdrIqCmBIjAUX5/EQFr7hsQEbAD4gQccQIu3DfgymPO
RQROUxfwoEfgAumAPADkPy0CMbQMiwic0lyAk+oCflTsiGI2/CEfQwT0NEAKgXoasAcHsFMcAPmu
VP+l8LcVF6Dm/1LsAyIAhsiv5fKqtZdoD+kFxmhPdKdgp4IobyS6TnjGFRC+EBAb8q+A+AaSF2I5
0dwIovpyiC1YYTKuIKrrWElUF6KXiOucN8U1SG8EhL9mIL2O1RyfwAX5cnMVf8d/3Q7AxQVgu0+6
mV3YHXObqDtlLCPuldkbfLvcTv/c8jtvIgA3cyttuplTZaNv7gebfHOqY/NrYOdrYuFrE6k/xc5/
RiT+nEj9JYT+BiFoAHkbr/LObs5xS4jeZqVPdofVPpmdV13P6r7aO6s3Yz8waPX1rKGrrmePWOmd
NWald/Z45pNWXMucuvJa9sxV1zLnrriWPX/F9axFK7yzlvP6ipU+WatXXs9es/J61gawcYV39ubl
V9O2LvNM27nkYuKeaSfDbVrv81Z8b9N+SmRd7ndLWXajKJb75hrO8dpydbytjm/DCl4XrPQ3YJUK
E1EgLVgtKYUmCOuCKDTqYiBpAm5A0oNN0l8QjiPADYgQ7EAAVCGgjXgvNYH93EtwgHRAdwOSEhxF
BI4jAuIGTnBXoz0iIEIgdQFxA2pKwH0D0pwjIpBHy/BvisCf6AIMewv+Q3GjJiAuwElcACJgTypg
iwhYsypwlN4AKzUNMLgAKQTuxQXs4mYgEYCdpAFSB5B1frXwZxQAKvNY/nUCLfKvwuobQLRHAFZi
7VdC+hVCcrAcLIPsKiC4juUyh/TGc5B+mV8xEOWXFQdkXwbBjfBmDpYTzVcIsPMrILWOZcxfw1XO
geWQ3YD7BngVxTq+y52iqAN/DzwC/G6xBiDJ/+URYH9eA5AuBHtvPDazC39obh1zx2I/RcA9/jnl
9gXeLk+Pf0XsfiWKcFUo9FXd7JdTfb1Pbo013jk1sfAfr/fJ/hSSfwbJP+fcl2u9s78hwjeAyKoA
EM1brrqW1Wbl1az2ELozhO9OxO614lpGPwg8ADIPWXk1c/jKa5ljIP74ldczNQHImsk5BCBzwYqr
WYsRguXMVy2/ngn5M9etuAb5wfKr6VuWeqVtWXIpeeeic/F7+h/19xrlFK743KbKTM691Du7RCzz
yeEf9P2w3CeXKABuGLDSFCIING2IMOguQVKGtWqqYIAIgkEISA8o8EijkSoEuAFVCHACqhugLiBu
4ABO4JCWElgiAsfYVMRaTQl4ZBSpgFoXQARkWy4RATc6Bj3oE7hIp97jX//77TWBP0kA9FTgFSmG
P92CJ6kHSC3AiVUBe4qCqgtgS6ujuAAragFHWBE4qC0HSh1gN2mACIC+CqCuAOj5vxT+uHVWj/5q
5Acq+YX0YumF+EBIv5yluaWQ3IBHylIi+VIIvhQLL/NlMsp5GSG5+rqMRjxUlhLliwD7vlRFvgFE
86VYdx3LmJuSfSkRfCkEN8LrgbIMkhtxhfmVe4XwZG6CrRQMr3KNNlzNUOotOHZdawD6a24AMnUB
Vj73zY6H3jc/FHq7zOGw22X238wuR+Qvv8kvu+IG7+xKG7wRAN+sDzb4ZlcjwtdY5ZNVi0hee821
zE/XXM/6jOhcj0j9FST/ZvW1rAYrr2U1hqDNVlzPbAnhEYDM9suvZXVefi2zO0QWAegLmQdwbgjn
RvDe0cuvZo3jtYkcTwUzwZxl17Lmc34xWA5WLbuatYbz6zi/gXHjsqvpm5deTduy6GLizoXnYnZ3
3H89YfXVVMUrm0gSkKssvpZZArI4B64XgzfHGhYhHCVhsQiKD/A1YJlvDvbQgBU3coyisAJ3IVCL
j6ozQAxECBCBdaQHAhEDtUaAUG2hWLmd25V3UBPYQ4HQIASPtbSAIiEpwRFxA6wSHKc4aE06IG7A
gT4HR1UEeFAny4QiAu6IwBV2+JWbh2Sn4dfwTxEHDX+CEIgDELygW1C2FHOhHuDMqoAj9Qk7nIDU
Ao4jAlYUBEUADuECDlDl3kctQOoAO2gJljrAVkkBNPu/ERewARcg1X6J/Guo+K9iXEnUX8FS3XJI
v0yHFu2X+heo5F8C6ZdAcsFizhnAMbm7ERTrlgiI7otfQz7nNED6xUWQxzEgyi+G/DIukTnEXwzx
jbjCXMX9EnBPWex5V1l82QQXmYNdrAB4I5bjnCOVT8as2a01AMkjwE0fAabvAPTHG4BEBPp6h5vt
u55ubhV6x9wq6JbFkZCcsrsCc8pxU035zb6ZFbd4Z1ba7J1RZYN3WtW11zOqr76eUWO1d1qtNdcy
Pl59Nf1Tqu91V1zNrLfiahoCkPbNqmsZDYjMTZZ5pTcDLVdcS28D4Tssu5rRGcJ2X+qV0Wu5V2a/
5dcyBnJuCBix9GrGaMZxYCKYyvFMMGeZV+Z83r946dX05UuvZiIAGWs4t26JV+YGXt+49Era5sWX
krcvvJiwc65H1J5mO688tY68p7gmPaIoA4lRUgPStTGT0QTXmZeAhYiDQF7T56bjEu9MZQliIWKw
BCexVNwEjkDHcuYGiBBIvUFSB4qMOILVWgFRxGBDCEuJoQgBRcLNFAe3iRCwSqC7gb24gX26G9BE
QNzAUVKCY+wsZIsA2LFM6EBdwIlmIRe1OIgI3P+Rbb5/VV7QuPObIiBi8AeFQBeB5ywtevKYMWdS
AUdqAuICTtAfcJxagLgAS5qDDgFJA/aB3fQD7NYEQFKALQjBZoRgA7UAlfys/a+F/KvJ/VdD/pVY
/hVgGQ5ALP5SgZAe6ERfTETXsejGY0UFkX0RhFdHCG9AvrIQLILghchjDiC3CshdFA/4+wEQfiEW
XgURflFJ8OR8EdxTFl0W3DXgEoD0Cy/eUbEIHKTZyBun1IEdgKu26DURev41OwCbRv8uDjfNtvmn
mR+LvGt+LOJWGXbTKcNNNeW2+WWV3+aTUXGLT3qlDT6pVdZ4p1dddT29+iqvtBprrqbVZN3945UI
wMqraXUpwtVb4ZX21Yqrqd+svJracPnV1CbLrqQ2B62WeaW1Ax0ga+dlnqndl3im9mbej3MDeX0I
8xGcG8M4fqlX6mTGaUuupM1c6pk6d4ln+sIlnmmLOV625Er6Kl5fw7iOcxs4t3HJ5dQtCy8kbF9w
PnbnrFPhB9gBSPHMxC6zDdhiSL/Q623I4B8wQ1kguGbAQnXMfAuyeA1oArEQIViIECzUHMMSVRAM
orBMag0aDEJggL7yoC470lewllWDddJXgBvYhBsQIdiKEIgb2EVdYA9OYC8PLVGLhIjAIZqbjiAC
VqQEx3ACNmw5foJdY0UEHBEAEQFJCU4hAvIA0JeIgLQNvxlEcCz8H4GkADoe4QTOIQKOOAEHnIC4
ABtcwLFsgws4RIvwQVqEpQ6whzRgp54GIACbuQV2Ey5goxr9nyvrKABK9BcBkOgvWIb1N5Kf6C7k
N0T7R8oior+QfCEiYASFvIUmWAD554MFWPtC5DMHWPwigOgLBJB+AWTXx/le95T5WPkFAkj9Gi5x
rgjucmyCC3eUBcWwFFGwZYeh0zyjsv6G89+X0AD0xx8BXrz4px8fCkkjBbhtfiDktsXegFtldiIA
233Ty2/xTq+wwSej0lrf9CqrrqV/QLSvtvpq2odE+pqrvNI/XuGZVme5V1pdyFyP8atlXinfLPdM
abD0SmrjJVdSm0HmVuTobSBze467QPRuS66k9Fp8JbUv84FLPVOGLPZMHQ7GcDyecTKYBmYuvpwy
b5Fn6gLmqgAwrgSrF3mmrVuMACy6lLRpwaXETfPOJ2yd4xG1a6i1v3vfYwHKtRx2dgnmAl9JA6n8
Q6WrWFAC5ntlKHPBPA3zEYO5GubhFATz34AFnF+IWBRChCAHi5htACKwhNRgqQoRA0MxUgqTqisg
NVgpjoClRDU1ICVYjxvYgAhsYt8CcQM7Ih5yh9wjdr1BBMQNUCBUawOkA0fkISekA0dxAscRAXEC
9qQCjjgBZ9KBk1IXoDh4k/79VzyC/K8UABEPUxF4+Ov/KKfzEAFxAdQEpBh4TKsFHKE70JAGfK/2
A0gdQFYDtlELEAegCgB1gPWIgC4AqyQF4Eac5VT5VetP5F9Cs06hxS9Qyb+QaL+QPNpUABb4PFIM
EOLnq5gH0Y24ytwUXhx75SnzjXjAHGDphfTzIfxrwNLPF0Dy10CUnw8WXADn7yqzz95WJrvlqhjt
kq0Mc8wEGcpY5pb8P671yla+XOYQpeX/egPQNyYNQNWZVwF/7AYgUzE4GpjEfgC55gdv3rU4FHir
7G7/rHJbfTLLb7ieWQGrXxHyVybqf7DWK7Xaaq/UGqu8Umqu9Eyttcwz5RPIXgeCf87jt79Y5plc
f+nllG9BQ8jaBBI3X+yZ3HLp5eS2Sy6ldFxyOaULAtB90eWUXosuJfdfdDl50CLPlKGLPVNGcW7M
okupExZeTpkKZnA8C8xdfCll0eLLqUsWeqYsX3g5dSVYw+trF15M3DD/UsLGuWfjt852j9rZ9aB3
8GyPOOVqNktI5OPzPNNKQDrnDJirYQ7CMIe5jHNxDOqxOs9Q5mgCIXNTodAFYx5iIZiPEMwXZ6BB
TR/0OgJCoIoBv5MIwVI1VRAhuM3yk4DUACegCgErBusoEG5g2XCjpAV0E27FCexgmVDcwG72FpCU
YD+twwfBYUTAMoVHSJESSF3AlvZRuxwe0smzB0UEXDQRCHr2t7/cBRQXgbu//BerAr8qDvd+UexI
BY6LC2BFQHUBdAceEBdAV6CsBogL2En1e6sIgOT/kgKIAJAGrGIJcCUOYIUJ+cX6C/kXUslfCPEX
QPwFRP0FRPr5Asg+D9IL5gqI9gbkK3Mh/xysvQpIPufKG+DJec8HKmZj5edc1nCJUcU9Zc7Fe8qE
M7eVCadvK8NccpShoK9thtLLOl3pYZOutDuSoqL1wRSl0Z6EQuxmXgTxSj/rNOUoAjDWMUb5bPpu
e/hZ0g7Af24DkIjAjEOJZkf8s8yOB2ebWwbeLrPHL6vMZt+McvTWl1/jnVFh3dW0imu90iqvvUoa
cCWl2sorKR+uuJLyEevuNSF87SWeyXUg/GeQu97SSylfQfRvmDegMt9o4cXkpgsvJrUkT2/Nufag
0+KLyd0hf0/I3WfBpeQBiy6lDOZ4+MJLyaMYxy28lDKJ+RRIPp3Pz1l4MWX+gkupixdcSlm28FLq
igWXU1aB1QsuJq2bdzZh01yPmC2z3SN3tNzllbvzZpbilsLarTfkvZyiIVWZfVmQpswyBQIxG8wq
Dsg/S6Cf98pUZoHZVzJUzCkGXRzEORiEwCAG8xEBSRUWXM82pAisIggW4wQW4wKWsGKwVJYgBVoz
0mr6FlaLCEhaQEqwgVWCjSwXbqFAqApB1GPul8cN4AL2sUJwgHRAUgJLth63QgAkJbAmHTihiYBs
1SUi4IoTiGJjD3ECRpAWyL3+v42i0b3w/cXPG45fmiCXXYadEQD7O7+oLkBqAXox8CD7Bu6nGKgL
wHZqAWoNAAewAaxjFWANNYBVbMaxAgFYhv1figgsoeK/mOi/EAFYAPnnQ/55kN5A9ofKnOuAcRbj
zGsPldnX8hkBUV7HLIj/GiD6LB2XHygTz91Txp27oww+eUsZ5JKr9LDLUjrbZCrtLDOUNpZpSqMD
kHqfCfYmKY32JhqwpxANhfhC9l1vwI44pREYhRMQAeh6yF/5qOfERVoDUCvGxuArUAf88R2Ai6cB
iz3izY763zU7FpJpvj8opwwPISyz2Tu9HEW/8muvkwJcEwFIrUzk/2ClZ1rV5VdSqi+7klwD4teE
0CIAny6+nPwZ5P0con8J6jNvALEbQeSmkLwlpG4N2oKOCy4md4XcuIDkXrzWj+OBCy6mDIHsI8Bo
jsdxfuL8iylT519Mnjn/UvJs5vOZL+a1pYjBcsRg1bwLSWvmnk1YT/TfON01bGvDrZ5/d6P4d5T8
fz72f9alFBUzL6UqMz1NIMcCxGAmwqACshvmMmqQczog/cwSMItzgtkIhmAODmLu1SwDrmVjM7MR
AgMWkB4IFpISqGKAE1iME1hCU9IyvzssU92hMYXGJS0tWBN0HyEAtBJvQAQ2s1S4hY1Jt0UjAvQL
7EEE9vIgkv3kjAeTnimHU3keHQJwlK5BtS5ATUCcgCNOwJmKvCs1gThuHlIF4J2Ir7/PlOglnSsq
BKYCIPO0H/5NLeAX5cTtnxGAnxQrioGSBhxkRWAfLmAvacAOtr/eTgqwmTrAJon+uIA1pAGrqQGs
oPq/jMKfgfgS+Yn6kH/+jQJlHuSfC/kluqvEJ7rPBkL8GZBex3RsvQF5ygzs/GQi+Fjs+GC320o/
11ylu2O20ulEltL2eKbS5HCq0uiQhoOMggMCyK7DSHwhvQ4T4u9OVBpC+oaQ3hSqCOyIL4Y4pdnu
eGXm6VzlUNAjpSE3sllUrtZHKwD+uY8AL6kGMIe9AI7ezDU/xINBdwdmWez0TSu7wy+z7JbrGeU3
XE2tAPkrcpddpZVXUj+A+FXJ26sv9Ur5UAQAe/4xkfyThZeT60D4zxddTP6C3PwriP8tpG5ElG68
4HJSM45bzbuY0mbepeQO8y4ldYLUXXm9B4Tuzbl+8y6lDITgQ8DweReTR3FuDOP4uReSp8y9mDx9
/sWkmZybO+9CygLEYOHc8wlL51yIXz77bOyqGW5Ra4fb+B/ucMBHLQDuDLqtzKSPejqYoY3TL6Rw
rOFSmmGuj6bzi7ymQ15HDIqAVGFGEWRwjDgAoxhQG5iDAOiYixsQzBNB0ERBFQKfW4iBBkRgyY07
OALAcuGKgHusc9PGDNaqIvCAm18e0B7LhhGIwFYaRXaSFuymOLiXJxLtU0XgOb32L7jxxlAXsKFP
wAYnYC8iQGHQCRFwQQTSuXmoiBMwdQVvnENyinuFn9OPi46ycUhJiHv1L8WaBqHjuICjuIDDVLoP
kgbspw6wh/0CdpIGSA1AioAbY7D+IgDY/xXk/ssRgKX0+C9GABbRyLOQtfz5RP55WH4h/2zB9UeQ
HdIzTkcIpkH2SVj2URfvKwNP31X6nLqjdHXKVdqeyFaaHctQGhPFGx0Bh9MNOCRIUxpCfBWQXgXE
FxijvWnUF+Lv0cgvo076NxLfhPzbEQEj4pT2+xOV1dQX1nnlKF+tds2Gp3/dDsAliYBlYKbZ4bB7
5gf9sy12+6aV2eKXUXaDT2Y5yF+efL8i3XaVll9OrbLkclJVcvpqi6+k1ID8H0H8j8nhay+6mFpn
0cWkzxdeSqpHdP8K4teHtA3mX0pqBKmbzLuY1IKIjQgkt0UIOs69kNQFMneH1L3mXkrqw3F/MIjj
oXMvJo2A+KM4HjfnYvLEOReSpsy9kDgNIZgJ5nB+7uxz8QtnnY9fNMMjeuk017CV3Q5ePzfWOVzx
zKBxhMcoT7+QpEw/D9TRIAbqqM+NwqC9VpJQXEQkdBiFIB1BQAReAyJw2SAE4hRUVyBpgw4TURBn
MOd6DnmquIJcilO5zEUIblPIYjkIB7CUOxiX4wZUIaCDcDUFwrUUBtdJSoAT2IwQbEEEduAEdiIC
uzQROJDMc+UoDIoI6OmAiICdKgLs3osInCQdyPrxX5D5v01gkhq8JgKmJJf3vR/5dUGIePkP5Tgr
AkdZDbCkDnAQF7AfByACsAMB2MqdgSIA64FRAMj/RQCW4AAWIQCS88/HBcxjTV/IPxVbP4Fcfdi5
+0pf9ztKt5O3lQ7OuUoziN7UJktpcqwQjY9mQnwBAlCE/EJ8LL0IgE58E/I3hPQNifgC1fLrEV9I
rxI/iWhfcsRXo/+OEqK+Sn6sv4pYpefhZOUQtxlPP5WgfD7vyCUt///rG4BEDOaeDTA7HJxrfjTo
lvneGxkWm/0zytD8U5aoX458v/xyz6SKRP1KLLlVxrZ/sOhyYlWI/yF2/aP5FxNrQXYEIKXOovOJ
ny24mPj5gktJX/Ioo6/nX0j8dt7FxIbzzic3mXsuqdm8CwktIW/reeeS2885n9gRYneZfSGpx5wL
ib047svxAMg/mPcMm3s+aSQYx7nxYBKYyntm8P5Zs88nzZ51Jm7ezLNx86e5RS2e4hy8vNWuKzGr
rqQoHuT/rDooU88lgEQNSYwmIOJPfStSef0NwBVMBdOKIJ1jA6YDozggAtMRgBkaZnplKYJZYPbV
bHLTbApSudjXW+SuBsxHBBbiBhbhBpYgBstZHViOCKxABFYEcbeYKgLcS05KsIl+gc2IwFZSAoMI
FLDLzlPqAjwDkcKgiIAV6cBxVgdEBE4gAg6aCLjSLHSHm4d+2wkUj/yvC8Cbon5J5/1pFDrKjUJH
KAYeQgSkBrAn9XtlJ2mACMAmXMD62GfKWtKA1TiA5TiAuSz7TSfijyeyD73wQOlHbt7T/ZbSHqK3
dcxVWtvnKi3tcpQWttlKc1sD+Zsdz1aaqMhSGh+D9FaZSiPIrwLyNz6iR3098puQX4v6KvE18hty
fZOILyIA8Y3kL2b1deI31O2+SbQ3En8r5N8aq2IIBUMregD6HwtRao9asc2kAcg0/y/eAGTB+2QH
4PffAszUBSw9k2B2JCDH7IBfhvn2gHSLDX7pZVZfzSi74mpKOSx/eax+hUVXkipB+MrY+Srk51Uh
c/V5FxJrzL2YWHPu+cSP551P/GTB+aTPIP7nLMt9Cb7m3DdzzyU2mHsuoQnvacZxS0jces75hLZz
ziZ2nH0+sQvoNvtsQq/Z5xL7MB8Ahsw5mzBszrnEEczHcH4c4wQwFeJPm3UucQaYPdMjbu7009Hz
p56KWjTJMXBp422eBUfD7ijW7AI0m+LfZMhvQPKbgRuY/EbwHecBQqFjEqIwRcdF5iaYTNqgY4qI
AU5gKqnCNERg2pVMZTrQhWCGJgQzEQHB7Gu5OAKAGxAxmIcQLNCEYCEisJjVARGBZaQCywMf0BDz
gOYYzQ1Esq8c2IoT2IYI7KQmIHUBEYGDkg6kvVRF4BiFQRsKgiIC9oiAI6nAaZp17lOkk01Gf1sI
TN9T6ABKJP/fS0gD5Bx4AeSxY5bUAQ6BffQE7E37QdnGLcLryP+XQPpZRPsJtOkOJ7r3pyjXGxvf
E9J3O3NP6UKU73SKKE9hrj2FORGANghAK1sE4ESO0gwRaGZTTAAgvyoARwrJ39ho+9OJ+m8gvxb1
G+5FCHS7r0d908i/i+ivCwDRXkhvRHHiq6Q3wZZYpfHWGGWiU5ZixW3AzXdeUyp92XxEsfz/S471
HYD0HYDLcU4E4I+RX4Rg/YUMdgTOMdsTmGW+xy/DYrsPDuBqSpk1V9LKrrySXG7ZpZQKSy4lVVx8
KbHSovNJVRaeT/pgwYXEavMvJnyICHwE2WuJCED2T+acS/hszvn4eoxfzT6XUB80mHU2oSFjE9Ac
sreGwG0hdruZZxM6zjyX0GXWuYTuvKcXY1/GgTPPJg6ZeS5x2IxzCSPBGI7HzTibMGnG2cQpHE9j
PmP66bg5U92i5010CV44ytZvTZOdV5XzqY+V3cG3lCkQf9LZBA0yT3odOIJJv4lk3pOsTCQNMAIB
ECFQgQAURRrHBkwhRRAhmMooQjDVMxNRQAgEV0hRwAwBa76CmVdzqFrnkMuKGOAGEIL5vvQy4ARE
BCQtWEZKsJTVgRVSG0AE1oSwyQRuYAMCsAkXsAUR2BqLCIgTSODhkmo6wHPqKQxaURQ8yp791vQJ
2IoIcAehtOrKtl75tAy/xPaXCMTh9fOFBJf239+ERnwh/3NQwN6CLqwMbGAJcAXr//O4+20qNn8i
xB9HU88orP0wCnmDyeMHYO/7XHqgCkCPM+Tx7reVzhTuOiIAYvXbkde3sUMAIL/BAWgCgAg0tcb+
G22/gfxq9If8AgPxdej5fqHdV22/kL8Y6QstvxBfx+vEbwj5G2LxG+qEF7uvz7dwHvI33BKjtNwZ
pyykN2C79115BPhTKFnSI8BLugHozxGA3V4ZZkeCb5kd4HbgvTeyLLb5ZFqsFwHwTC27yjOl3IrL
uICLSRW52w4XkFh54fnEKgvPJVZdcD6xOhG/xrxzCTXnn0v4mLE20f7TOefi6845E//FnDMJX845
G19/1tm4b2eeiW8I4ZuA5sxbQeLWjO1Axxln47tMPxPffcaZxJ6c7zP9bHz/6WcTBk0/kzCE+XBe
G8V8LOcmgEnT3OOmTnWPmTH5ZPicCU7B87ofvHp8gHUg2yizcwv5/8Rz8SZIYA7OJhbCeJzEuUJM
YG6K8WeTFSMQgvFgAq5goilwCBMRg0KkMTdgEgIw2YgMZbJnloqppAQGZOEORAyySRVyqFxnIwK5
qgjM9r6tzEEA5vrcVtMCcQSL/OgXxw0s4T4C1Q0E4wZICdayRLg+kh1oNRHYjgjsiOMRU6QDe5N5
yi0FwcPpL4m6PKhDFQGcAC7AAQGQm3Zkq+/Hf3+LCBQRh6LRvQj5hejFBOEpAvKEpqAC8OjX/608
/OV/VDz46b+VXRQA57EL0Cyq/dMQgMkU+sbfLFDGUNwbLgJA990gBKDvxQdKrwvY/rN3lW4IQJdT
twwCgANQBcA+xyAAkN4oAFTzm0r+f5QUoEjeL4U/Pd83Jb9m99Vor4kAxBfyqyhi902Ir0Z8E/Kr
pC8kvpH8Qnwj6YX4YLMgRum8LxHy03h0JlX5YsmJEATgr90BuHgRcPO5OHYDumu2PyTbfJN3usXa
6ykWq7zTy5AClF16KbncEs/E8hT/KnDDTaUFFxIqC+afj/9g/vmEaqzDfzj3XPxHjDXnnomvDeE/
gfyfMdadfSauHo05X804E18fkn870yO+wUyPhCYzziQ0m3kmocWMM3GtsfJtOe4AyTuBrtM84rsz
9oT4fRn7T/eIHzTNAyE4Ez8UERjJ66OnusWORwAmTnIKmzLuxM3prXd6XuNn4QDoC2f5b8LpOGWC
R7yGBEYdicwFhuPxzMef4ViDzE0x7kySYgTkH6eJwPhzKcoEUyAIE86nGgDxi2PSxXRcAUAMJuEA
BFNICQxAECD+NByAYMbVXCrZucpMMOv6bWU2AjCHlYJ5IgQ4gYU4gUU4gcX+91gtQARwAitD2WUm
gv3nxAnQJyBOYJuIAKnA7sRnqggcTBMn8IriGyJAPUDSATtycXsRAW4jvogtl5uHikT716K/wcYX
dwQq6Tn/lMguOwcL2eVuxEcq6QGEF+jk18dbLA9uJfefw5r/TIp9UxGAiRT6xpLvj2AdfyiNOoPp
vuvPmnzv8wjAmbtK99N3DGmAqyENMAoAKUBLSQPE/qspQKbSDNvfxAoRsCLiq3l/BsU+Q85vKPhp
1n+/RH+N+Dr5sfw68YX8hiKfKfGZG8mvCUAJ5FcFwJT4KulNEaP0s0pRrHhOwPATEUqdyVut3tAA
9Oc8ArykFYBNl6PMDt/IMmNPAPNtFAE3eadYrLmSWGbJlaSyizyTy1HUK7/gUkKF+efjKs4/l1gJ
218ZgleZczauKstw1SjGVSeS15h1Jr4WhK4940zspzM84uqAupC83vTT8V9O84j7erpH3DdY94bM
G08/Hdt02un45hC7Jcdtpp6ObT8VNzDVI74L6DbVI64Hx72Z9wcDOB401SNhGPMRU9yiR006GTF2
glPo+DE2vpObbLucsd0vU7GLJf+/AIlPx4I4EF8CIP5pA8bxumAsQjAOyFgUSRxrQAzG4gh0jGNu
ChEFIxCC8SYQQTC4gnRlIinBxMuZKiYjBLormIILmEIqMA0nIG5guggBtYGZpAIzIf9snzuqI5h3
g3ZSgYgAdQGDCHAvOk5gVTgbT2rpwOYYnkIjIoAL2E0qsBcBOMhtxIfpFLSiHnAcEbDmmX62snsP
LsCRDUWu0DL8nJUBleAlWX85p+E5G4M+BU8gesHP/608FpLrhDchvU7+N4lA9vf/pawmDZhF1980
Gn0mUfAbTxowhn7+4azjD0EABtJt1+c8dYCzpAEeWhogdQAcgFoIxAG0xgG0ovjXwhoXQOGv2TFE
wCoD8iMCFPzUqr9p4e8A5N8vgPx61NfsvmnUb1Cc+GL5TYm/HfKbEl+z/EL8hiVG/MLIL9G/0ZZo
ZfSJdMUSAeh04IZSo+uYuSYNQPojwP/cHYCLi8AGzzizvf4ZZnv8Ms13+qabb76abMHe+mVWeiaX
XXoxodyCi/HlifYVIH3F2efjKs0+G1cZW48AxH8w60xstVlnY6sT6WtA9o8gea1pp2Nrg08hdZ2p
p+PqErXrQfYvOf56mkfMt7zWcMrp2MaT3WOaTT4d23yKR2yrKe6xbaecjm8/+XRcR17rxLzbZPfY
nqD3lNNx/TgeOMU9fjDzIZNPxQyf4BwxaqxdwPhRx30mfrvl8t+d49lUIzhXjfpj3WKVseynPkbI
jRDokGMDEpTRRsSbzE3P6/NEXgcIwWhShDEIwetIVs8ZBeJcqjLWBOPOpyEIOAMBIjDhYoYy4ZLA
IAQTxRXgBASTPbOVqYjBVNyAYJoqBAYRmCVCQNfgPFYJxA0sYKlQRGAxNYFlwQYRWB2OE8AFbMQF
bKEouJ1UYCcFwd2sCuxLeUEPPo/oZmMOuTf/OC7Amqf7npDbdnEBDuwv6PP0b+odhHqUl7mQXSU6
Fr6AouFjifC0+T6WuQ4EQM4Xj/q/JQDiBpJe/lNZSiowg46/yTiACaQBY6kDjBABoGlnME07/S/c
V3pL9R8X0I0aQGdXQwrQXtb2HRAAVgFakf+raQC2vxmV/2Ys9zXB/osAqOSXwt9BDaoAFCN/sagv
5G8A4QVqrl8k4gvxdfIb8vxC0scpDbD4gkKrb0L8TTFKQxXRSjNqALNds5X9fnnKt68/AlyeAPTn
7wBcXAC2XskxOxSQabYnIMN8q28y+X+axarLiWVWXEwqu/R8UrnFiMCi8wnlsfoVZ5+Lq8QSXGWe
ulsFEfhglkdc1ZmnY3EAsTWI+B+BWtPcY2tD/E+J2nWmusfWxa7Xm3o65kvm9ae6x3871S2u4RT3
mMZTTsc0m+Ie13yyW3wrhKAt83aMHRGBzhC/G2Tvybz3ZHcRgNiBHA+e4BozbLxr1IhxTiFjxtgH
jut10GtNp4O+ypkUNm70yVRGn4pVRiEAo1XEGeD+Oka5xytFkcDxO4A0YTROwQBEQXAmpch8DOR/
HWnKWFyAYBwiMI6UYCxCMPZiJuvYGi5Tv7icrWIKQjD5Sg7IVabgBKZRGFRFAEcgbmAuAjCPLc7n
+3PLKS5gCfWAZQjAijA2oRQRoB6wCRewOfaJsj2BB2jiAkQEpB5wSFIBmnCkKHgcF2BDQdCeVQER
gOP07MttxAbCFyO5keycNxUAIb+G4oQv6bh4KiDHsc//oczFBUzlNl9JA8axCjCSNGAYdYDB9OEP
YPmvDw6glwdpgF4IJPqLA2iHA2hjl20QAN0BEPnFATSVNX/J+fWGnwMIAORvtJ9lPWCM/ia5vinx
SyS/SnyTyG9Cfp346liC3TcQ34BGG6OUDrvilPXcBbjqYpby1UqXlHdsAPpjOwC/JgBBOWZ7Q3LN
tgZkmW/wSTFnc02LZZeTyyy5GF920YWEstxrX45bbsvPPxdfAYtfCYtfGVSZ4R77wYzTsVWJ/NUZ
a0z3iKkB+WtC/o8h7KdE+DqT3aPrTnGLqUeE/4Ljrye7xdSH/A0nu8U2nnQqtukk9xgEIKbFJLeY
1pPcYtsxtp90OqbTJPforpzvDvl7TnSL7TPRLabvxNOxA8afjB487mTksLEOwSNH2fiNabPL02m8
S7hyJplbPukDGOkaDWKUkadilFEiBjoQBBGGkUUQx7EGBGHkW5GgjDydxHsYIX0hkpm/jlFnkpVR
pAWmGE1aMOZcmjIGJ6ACIRCMxQ2Mww2MBxMgv2AiAjCRVGCSp4gAKxtXASKgC4GIwGwRAT9EABew
MOiBsgQsC2PzSlIBqQmswwlsQAC24AK2IQIiAHtpEtrP0qDcjHMYAdgL9pAO7GLcSn1gC+e3MHqx
Xv9alDcVANPIbyIAairwDihJBEKe/EOZSTFwEt1+IgCjuWtvOK27Q6gBDGApsI/qAO6oAtAVB9AJ
B6CuBOAAdAFoif0XB9D0KOQHqv1Xc35t3V/IL9CaehruSTbm+irxTaK+Gv13CHTCFyc+xb6tAKtf
nPhCfoMAFBLeSP6NQv5oVQB6H0xULHkc2GTnOOXz2Qc93tIA9OftAFxcAA4G55gdDMww2+Wbar7N
O818rVeKxZKLCWUWnosvM/9CXNn5Z+PKzTsbV37u2ZgKWP2KMzxiK09zj64C4T+Y5h5TdbpbTDXW
5D+c6hZTA5LXnHw65uPJbtGfTD4VXQcS1+Xc55Pdor6Y6B711UT36PqQ+RuI3miiW3QTjptNcotu
znErxracazfBLaYT6ALxu/Le7hPdY3ox7zvBLbbfONeIgWNPhg8cZRcwfPgx71FNt18OW3UlWXGM
faBQaFRGnIwC0QYgBiMQA1MM59iAWA1xjBrcEpThvwUEYDgpgWCEiqTXAflHmIJ6wXBcwoizqYqI
wChEwIB0ZfS5DGX0hQxlDCIwBgEYeykLMQAQfwKpgI5JOIFJpAPiBqaSEkxnlWAWS4SzWRmYQ0Fw
Pi5AnMBilgWXqiLAFtWqAPA8OkRgKwKwiYLg+nh21wHLWCYUrKJAuA5B2ERaoJJfByJwk3TgjSLw
FgH43SLAd3qzh8BkBGA87b5jcADD2UdvCLvqqAIgDoAUoIcmAJ2x/x1AexxAWxxAa+y/CEALXQCI
/k3VJT/yfxEA6enfJ+TXBGAv5N8tSIL4gkLLbyB/QjHyaxV+Ib2GIsTXon4DSC94jfxG4hvILxh+
LFU5SgdgL8tApdbg+Wvf0gBUlddMnwD0/o8AL6kAKOf2Xksxs/Qn//fJMN94NdVi7eUEixUX48os
OJ9QdvbZ+HJzPGLKzz0dB/ljK85xj6k00yOq8lTIj7WvOtUtqtqUU9HVWZOvAT6afCqqFmSuPelU
zCeTTkV9BupOOhX9OeT+YsKp6K9A/Qmu0d9MOBXVELI3nuQa3XTCqZjmnG85/lR0m/GnYttx3J7j
jqDL+FMxXTnugSD04vU+41wiBoxxCh043MZv6FBLrxENtl5+Yhl6W9lL/j+OqD/MOQpEK8MQABUu
0crwk5x3gfQyQv7XEcs5DW7xyrASkcB5IAJQBIiBu44k5knKsNPJxZCiDPdIVTGC9GAE0X+kDhzA
SDCKdGC0APKPuZStjLmco4zDCYzXgQBM8LqlTAJTVAEANAxNpyA45wa3pd5kw4pAdq8JRgBCuRsS
EVhMOjCP41lgetBDZTrnZ4fTQ48wLMQVLEUAViAAa3laz0ZqA5shf3GEPf+7SZ5fQkpQLPr/7lQA
8j/UYMNNQhNo+RUBGMFmHJICDEQApANQFQBuvRUHIALQkUagDjgAVQCw/wYHwBKgkF8XAHEAkL8x
HX6NyfsbUexrBPkbSfRHAFTya7m+adQvjPwlEV+ivhb5tWivE78B9l7wesQX4mvYEKU0pQYwzSlT
seI5gU12eCkVPvl6cLEGIMn//7xHgL9JAA75pJjt88ky3+iTZk77rwXr/hbLLsSVWXIurix325XD
9pefeTq6Irl+pZnu2H+P6MoQ/4MpkH/yqcgPsfQ1sPk1EYKPJ7lGfTLxVNSnE92iPpvoCvldo+sh
AF9MOAn5T0YJ+RuMd41uyLwJYzNI3px5y3Eno1qPd41pC8nbcr49eX4nCN2Zc13GuUZ3x/p3Rwx6
jnWO6DvaIWQAAjC4z4HLU5rvuqq4Jz1U1nqnQ/xIZaiTBoRgqIsBIgJDBQjC64jhnAlOxSlDS0Q8
5wHkV0ERUccQBEAFbqBEkCIMAUNxAcN0IATDcADDcQAjzmUiCIUYTT44WhWBQogjGO+Va0gLcAKT
EYGpLBNO872LENxVZpIKzPS7r0wEYxCE4dfvKiN5bSzHE27mKZMRgGkIwCwRgEh66mM0AeAGotUI
wHoe2mEkP9Ffn0taEM8dhEUKfsWLf39UBEzILyJwi2cNzKDffyzbbY9EAIZwU48IQF/6/XuRAqgO
wEUEIEfpKC4AAWjHCoCpAEgBsCmV/6bk/41Z7tPJ31hyfxEAyG8QACG/iQBoUb+BaZ5fJOLrxC8u
AAbSm6KhTnYj6SH/Bh1RSuttscrSs7eUzYg6OwDnl5D//zU7AJsKwTC3WLPd3klm+25mm++8kWK+
zivZgs07LBZfIAU4i/0/E1uOAl/5aWdiK053j6403S2qMpa/CoSvCvmrE+E/JOp/xNJczUmnIj+e
gAAQ3T+F/CIA9Tj+cvypqK8gcX1IrpJ/nGtko3GuUU3HnoxsMdY1qtVY1+g2jG15vf24k9EdeW/n
sSeju449GdWN8915vQfoOdYpvM9o59B+I04EDhx21GdIu52Xdg+0CVTcE9kB5jLkc4xQhjiZIlIZ
gigM1jAEURjiaopojunDLoI4jkvGYG7U0DEEETDFYLdEbi0FiIAR7hDfFDgAEYGhZ9IMQACGIQCC
Eec1XMhSRuICBGMoEOpuYCyOYCwCMIF6wETcwMSrbELBH85I5oMv5Sp9LrARBWP/K7eVQVfvKEOv
36GIdlcZgwCM9+f2VwRgagh3y+EM5uIAFiAAi0kJViAAq9icc4MIAMXBzUJ+EwEQIdhOfSD51T9e
FwEhvojBHxGAYuTXXcD2+OfKWGoAo0gBhtIOPJilQHEAfVgGFAHoRg9AZ2oAqgCQArTjxp9WtllK
S6K/OIBmQn4B0b8xOb8qAOT9Al0AZLnPEPkZtVxftf2QXwXEF+h2v+EWjtWoDzbrkFy/GPmx+kXI
byS9gfwNif4NN0QqXffEK7u92XAE1/jFIusbxRqA5AlAdYFsAFIdVAblwZ9bABx1JYsGoFtmBwMy
zLZ6JZtvvJJosepiYhkKfmXnQv55Z2PLzTkTVX6ae1TFqQgAuX/lqaeiq0w5FVWVKI8ARH8I8T+a
dDKq1gTXyI8h+ydE78/Gn4ysO+FkZD0i+pcQuT74ZrwqAFGNKeI1HeMS1ZxzrUBbSN4OMegwxjWq
8xhID7qDXqDPaNfofmNORg9gHDTaKXwIW34PG3EiYORgy+tjm22/fHXu2TjFNSFPmU4j0GCHiGKA
/I6RyiANgx2jlMFOACEwIFoZTGpQBCdj2QCiKAZxrGOga7yiAjdQiETmGiD8wDdgMC5gMCIwxAgR
gnRVCIaeRwzAcJzAcERgxHlEQMB81MUcZTQCMOJSjjKYc33PZNARl650dk9TOp/JpEc+k0YZTQAu
31IGIgBDgC4A43AAkxCAKSHcMhvG/fMIwHzqAqoAJBgEQHUAIgAlpAFybi+Fwqwf/lWyE3gXAYDo
rxUH5dwbBOAk9wkUFYC7RgHoSQ+ACECXk1oKIDUAyN+K1t+WdP81lxWAI2lq/l8oAAbyN1ajv6G9
V43+OzQR0AVAJb+B+KYC8DrxRQBMyA/pG2jEF/I3VIleGPENpAfrdUQqAw4nKZbY/6E24cqnEzYe
0vL/v+4R4CWlALPPhpvtCk43I4c2W38t3XzlJfL/c3FlFp+LKTP7THS5WR6x5Wedjq4w43RURSr6
lSjmVSbiqwIwwTWi+vhTkTVATeYfj3eNrD3WNfJTCF6XaF6P8csxJyPqj3GJ/GasS1QDSN6YebPR
RP4xLhEtR7tEtEYI2kH0DqNdojqNdo7qyms9OO45WsjvEtmf84NHu0YN5Xg45B8z3C543LATNycO
tro2rdHWy7doXFIOhOQqY1wjlYH2YSDcMDoyQvyBpAQDGAUDIf9AiG9AdLF5DMfAKUYZ4BxbBP05
7n8yTsUAFxPIMWKg4mSCAa5JyoBTOpKZG6CLwqDTKYoBaSoGn01ThiACKnABQy9kIgYGAZCxP2Tv
cSqN1tdUpa0z20u5pCodXFOVjm6Q/3SG0gXydz+bpfQ6l6P0wwX092T3GlyACMBw33s4gAfK+AAE
IFAcwCNlpqkAUBhcjgCsfgcBEBHYR9/ALW4jLjEdKEEEihD+PQXAgz0DCgXgvjKY/fT6UwTsQydg
L7dbBgGQGoB9ttKe/L+tdSYpQKbSEvI3Z/mvGdX/QgFIVZpg/YX8ArXyr3b3afbfNOoXI3+DEqO+
Rv5NCIDY/hKIbxAAU8IXJX+jdZHKGJtUVQDa7vFRqrXuN/k3GoAq8vqfdwOQqRgc5Eag7TeSzTdf
STJffokVAOz/orPROICoclT8y89wi6kw41RUxSnuUZXI2atg+z+Y5BpRbdKpiA/Hu0bUwM4bBMAl
4hP2M68D0etSrPtirAsC4ByJAER8y9iIselo58gWo1wiW412jmjL2H7UyciOjF1Bd8jec5RLVJ9R
zlH9OR4Mho5yjhzOe8ZwfvxIx/Apw+yCpw057jdrgNW1hd9u9VQcY9hEwQfyOIQpA+xMgBsYoCJS
6a9DFYIoZQBCYIQcg/7swyboJ0AEisAlVumnoT/LNSo0QejvEq8UgWui0l8HQtBfxMDNgIEUBwd6
pIA05qnqOAgM9tAEgFRgAPOebhAcsrdyTFRa2icpreyTldaOKUpbFwQAIejgCvkRBRGAbh6ZSo9z
CIDuADzvKIO87tJGKw7gnjJaBEBqAIH5r6cACICeAqznYR0GB/B2yK28d37695vTgbcQ/X0cgA23
CYsAjKQRaCg1gEGaAPSmANiDewG6OpMCOOZg/7MMqwAiAGz0oQqAZbomALgArfBnsP6Fhb+GOxGA
ndoyn27530R+o93XbL9KfKBF/TdF/iICsBYBMCJSab4pSpnrmqXs9bmv1N944Rf4WNINQJ9wvgbQ
7wAsy/zPuQHIVAD28FiwvXQB7vDG/l+Is1hwNr7sPAqA8zyiy884HVmB5b2K01yjK005GVUZW/8B
Vr/aRNfI6hNdiP4uETUhe20s/6eQ/7OxTpGfj3GO+oJi3VdjnCO+Ge0U2WC0U0Rj5k2x8C0QgNaQ
uu0o54iORPTOI53Cu41yiuwF+o50iuw/0jly0EiniKGjnCJGMB89wjlqHOOE4fah04Y5hM4YeiJ4
zpBjfvO77PPa3+XwDZ6jzh7tlxKVAScgvylEDOwjlP46TIVA5oiBoJ+Gvo7RihE4gb4loB/nVJgI
Qj/EQIVLgtLvZOJr6I8jUEGe198NNwDxjeDmj4HUAnqfSlU6OycrbRwSuZ01QWl5AuLbJSktOW6F
ALR24DUEoS3Rvz3Rv4OQ340UAPJ3O40AnMlWU4B+l26pNYDBXkR/TQCkBjAhIJ8bbQwOYDY1ACkC
Sg1gCcuByxPZeUdzAJsQgE0IwNvg+ehXtVr/Whegdk4svQq9F+BtgvCWFGA1NwiN4f5/EQApAg46
fwc3dFdRBYAVgK6s/3ei+NeBbbzas0+fKgCs+7ci+hsEAPKT/6sCsE8A+YsIAJ19IgC65dfJr0Z8
k1zfmO8b1vVV4qvkZ41frL4OzfI3IOoLXov+Qn6ivgERSscdscpGdhBedjZd+XK5U1yx/P+v3QHY
lPyLzyeYHfbNMtvhm2G+3jvJYvWFeAvW/8vS7VeOPn/sf1SFyW4RFSe7RlSa4hpRZaJrRNXxJ7H+
LkR/l/CPxjmH1xp7MqI2IlBnjHN43dHO4fUg/JejHSO+gcQNIHojiN8EorcY6RzeapRzeNtRjmEd
IXmXEY6R3Rh7jnAM7zPCKbz/cMfwgcyHjID8w50ixwx3jhw3wjl8AvPJQ+3DZgy1C5095ETQvAFW
3ota7fT0nEgD0Mm4+8q005CSJ6n2QwCMI/O+iEBfu/Ai6GcXoahAGPrhEPqaoI9DlPIanKKVPjpE
FJxiEYf4QuAA+upwTVD6auhHOmAAooAA9CMNUIEI9HVLUbqfTFLaE+Gbn4iH9OBEAohXWtglKC3s
JfJDfkSgtUR/lfwS/VMQgDSlk9h/agBdVfKL/c9W+p7PVgVgoKdBAEZwa+lIUoCx/nl01rE9lnEV
AAGIZhUglm224gwCoNcA3iYAe3J/UPcTfJP9NxLfVAD0eUmiYPKaXvjTx/inf1fGc0fgGFqBR3Iv
wBB23x3E5pz9KAD2pgD4ugBksJdfuioALbnxp4WQn8p/U4p/Yv2l6UcVAKn878L+a9FfWnuNAqDn
/MUFQKK/Tvoi5DcU+vRcX0aV/OT4gsJc3yTyC/nXCCKUPvsSFEueAjTOPlr5bMYeJzj5n9kBuHgd
YO6pZLM9vmm0AWebr72WjP2PsVh0NqYMxbWy00/HlKfyX2GaayQCEFVp4smIKhNOhlcd5xJWTQQA
8n80xjmsFoSvPRbrP9op7PORTmFfENm/4tw3Ix3CG2LbG3HcdIRjWIsRTmFtIHj74U4RnYY7RnQZ
7hTeY5hjeC/Qd7hj2AAEYDDnhzGOHOYUMYbzQv5Jw5wipw61D505xC5kzmBr/wUDLH2XNNl+OWml
Z5JiFXaL/B8inwjWEKr0OaHBnlGAEPShNqCjLwIgxO/D2Iext32kCejOsgcO0a8D8vcugjilNzUB
IyB8b9AHN9AH4uvoDdl7OicSseK5YSWOrapilSagqQ2bQQr5QXMEwEB+A1raJSutHCT6Q37J/bH+
Kvkl+ksBEPJ388jiBplsOuS0/P9yLrfPsj21if0fdxPy0x8gDkD6AOZEUABEABYR/ZeqKcALlgFf
KRvUZqCSo78jD/e482MJtt/ECRQRAIn+xcmvO4ESzhcVgH8rVmwPNo6bgUazIcgIegCGsAIw8CwC
wF2AIgDd1fw/R+kk+b8tu/Ta6AIA+Vn+ay7FP8ivQo3+2rIf5G9ExV8VAIp+RgEwKfh9S8QXFKny
mwhAQzXfBxsEbxEAU8uvR36N/CIAw7kD0NI/X+l+OECp2X/WCi3/l0eA/bU7ABcXgGU3UswOBHEj
kE8SNYBEi6Xn4y3mnokpM88jstw098jyRH4EILwid99VmnAyovLEk2EfTHAOqzbGKfxDbP1HLM3V
GuUYXpuo/ulox7DPRjmGfj7SMezLkU6h9SF9gxEOYY0gfRMRgOEOYa1BW6x8x2GOoV2YGwTAIaIv
44BhDmGDwXAwaphjxNihjhEThzqGT+a1qUPtQmYPPhE8b5D1zYX9Lb2X0AD0w+GQHGWjb4YyCJL3
tgkGIUovFaGFQAx6gZ62YRrCGcOVXqDnCQ24hJ44AiPsIpWeAkSgCKgN9KJG0MsxFsQpvZw04AB6
OhvIr6OXS6LSlfe0s41VmtvQ+nksSml8PFppYh0DEADQ1BYBsIb8CEALEQCV/Ab7X4T8RP8ORH+d
/J3I/Q3R32D9+14g+kv1/zLFP5PoP4blvwlSADSx/8YlQCkAqsuAL2gEeqVsFAEolv9LD4CftAQX
t/ymXYDFXlOtf0nkf8O54tE/iBRjIjv9jqMJaBT2fxj2XwqAA1n/lwJgT+x/N+kBIP/vyNq/qQCI
/W/B0p8uAE2w/020wp8QXyU/VX8DDPfx65V+nfjqqOf8ppFftfyvk9806hujfxG7r0f9wujfhBRg
un2GcoQbgBpt8/rPPQK8pFWAdd7cCRiSYbbFN8l87dVEi2V0ALLPftnZHjHlKPwhAJEVJiEAFPkq
E/mrjHMOqzrWKaw66/E1RjuF1hzjGPoxZP9kpGNonVGOIXVHOITWg/RfjbAPqw/BG4BGoOkwx5AW
oPVQx5B2w0gBIHkXbH0Pine9hjqG9hnqEDpgiH3Y4KEOYcOGOoSPZBzLaxOHOIRPZpw2SKK/bdD8
/kdvLO5+wGtry91XFWfs/+JLSUoflfwG9FKhCwEjqYEKTQhUMZC5CIIuACUJQUkCoApCDGATR4c4
A8j/e5oIQVdea2cbzWYUtHoeNaDxcR0GAZDIrwIBaGED+UUAdPKL9QetHZO0yK/Zfi3yd5LIr1n/
nrr1Z5lwAAIwlL6AYdew/lL84yYhKf4Vif60B+v2fwldgLICsIpn80kBcJPaCVhYADyC5U/97p/v
RX5dKH6fAPxbyeSuwHkhtAGL/ee5fGL/h/IUnsHnWAGQ/J/o35MCYDfy/87k/x0l/xcHwEM42hxL
I/9PV1oS/Ztxx59Kfrr+1KU/uv1KFIBthqW+IuTXo79GfiPpi5DfEP11wjeA8EYY8/zixOd4dQQI
V9pQAFx5JlfZQLPX12vcbv9faQDSxWArtwLv98s12+ydbL7SM8ZiyfnIMos9IsvOPi0CEF1+6smo
ihNdIipNcgqvMs4p7AMsf7WxTqEfjnII+QjSY//DiP6hn0L6z0bYh34+wiHky+EOofWH2Yd8S87e
aJhdaNNhdiHNsfCthtkT/e3D2mPlOxPRuw6xD+0xxD6kz2C7kH6D7cMGDbYLGzrELnTEYPvQMYPt
QsczTkAUpgw6ETxzoG3InIE2Nxf2tfReyg1ApxAD+v/vKdxirPQ8HqSiB+Q3RXfrEKUoQjk2oJs6
hindcQIqWItVxxORhbCLUroLyNMEPYyIYS6IVXrgBrrYRWNDI7n5JJK95yLYeDLSACuIrwpAtBGm
AqCS3xj54w15P7a/jWOySv72J5PVop9p5C8kfxb3yBP5ZekP6z+Y4p9a+PO+p4yiE3CcRH/J/Yn+
07Tin7r+Lw1A7CC8DAewUtqApQmIvQI2G/sAXikePOI776c33An4JjfwpnTgN9yAwQH8W0mk5XiJ
3AjETUAG+59nsP/sBDSQ7bLE/vdi/b870V+29xb734G1//Y8hceQ/6crrQ7hAKTwR9uvkL/JXgSA
vL+x7OYjDkC1/pr9h/zS4CMFPz3qS+T/1qTQ9ybyNzAlv+T8ugBA/gbGPL8w4ovlN5DfIAA92AJs
//UHykwcY70FR720AuB/Zgfg4i5gg0eE2R6vdPPd19Ms1l9iBeBcVJn5HtHlZrpHlmPLrQpTnEMr
YvkrjXcKrTLOMbTqaKeQamMcQj4cZR/6EdG+1kiHkNqQvs5w+5C6rNHXG2Yf+tVwu9BvhtoHNxhy
Irjx0BOhzSB/C4jeGtK3H3IipOMQu+Au2PmeEL/34BOh/QadCB04yC50yKATISOI9KOx9OM4PxER
gPxhMwbaBM3pbxO0oP9Rv6V9j3ivpAEoau7ZWMUm8o7CqoLS42ig0v14sNLtTbDmNQHOoKsGEQAV
NmGFoHDYDQEwgtpAN1NQJOwuQAi6Igztjkdyz3k4pDegCPGF/CYCYLD+BjQj8kvxTyW/lverFX+i
fhsEoK0TxHfRyI8ASM7fxZ0lP5PIL+TvK+Sn+28wa//D6AwcSfvvKCn8qZV/Q/PPNOn+k9yfjUIk
+i+KIfenALgC+79abgSS+wCw/7IEuBPLH/7sLW2/70D+93EBOvlD2I1ofmiBMpn+/4mQfxzbgan2
n30ABvPwjgEet7H/huU/if5dsP+deEqPHv3bEv1bU/lXo79W+RfyN5WiH9FfFQDIbxAAcv9tYGsC
xC9GfqL+t8YKv2b3jfm+Ie83kP/N0b+Bmue/ifwGARgkdwD6sd/h0RDlk9GrdmoNQMXz/z/3EeAl
2X85t/1qOvcBpJmvpwV49cV4QwOQe1TZWacisP/hFSadDEMAQiuPcQzBAYRUHe0YUn2UfXCNUQ7B
NSF9Lcj/CdH+M9bnPwdfEN2/Zqnu2yG2wQ2H2AU1RgSaDz0R0pKxNaRvP9g2uBNjVwjfA7L3HmQb
3H+QbQgCEDJ0IAIAxgw8ETp+oF3IJObTBtmGzupvHTSvn3XAor5WN5b3OnR1dcOtlx9vvZGubPVj
3ZziX3erAKXbsUADjgYoXY8FIQaB6mhAsNIVARB0MUHX4wjC8VDOA1sd4cwFEQYgCDq6kBa0sQ6n
xTSUO8zCCqEKQGHkF+I3ETcg0Z9UoIm1nvtDfrXwZxCA5nZEfZb8WjskYPmT2d4qSUUHIn9HPfJT
8Tclv1T8VfJj+/vTHaiS/9ptZYS0/gr5if7juTFIGn+mBLPPvHoDkCz90f4bzdIfNwHJXYAS/dew
Qch6yf2BbAyS86Ymn/cgvgjAm1OAfxtfE/I/wGW48MDQWTzuazp3xE3C+o+j/1+1/3ruL8U/cv/e
RP+edP51d85ROhP9VftP8a8d0b8tj+lqSeOP5P7NqP4bon+KKgBi/xur0Z+n9gAhfwPIb7D+QI36
hsgv5P+WXN+wrl9UAAqJr5Ffor4W8Y1jcfIbo74W/Vfxd8K5cccpACIALXddV6o06jgGGv71jwB/
kwDw2C+zbewCtIE9AJZeTLRYTAFwlnt0uenuUeWnuIRXYKkPAQivzB14VcY4hFYlz68O6WuMtA/+
aJh98MfD7YI+GWoX/NlQu6DPGb+E3F8T4b+F6A2x6U0G2wU3H2QX3BKStx1oG9wBO99l4IngbqAX
874QfcBA29DBkH34ANvgUVj9cQNOhEyE2FP7nwiZwXxOP6J/n2P+S3pZ+a7stu/KlkY8Atwm4ray
lP7/HkdvKt0sbypdTYEIdMEVdEEQ1JH0QAXk72yCLghAF/Zh70Kq0IV0oAvk7oIj6EJNoAvk7wL5
OzO2PRZKpA9hD7kgbisNhviCEA0IgbgA1QlEGIivCYDMmxwT8lMToBDYjMKfCgqDkver5Cf3l/V/
IX57Z538yYZGH8jflYJfd2n2YbmvNw0/xp5/1fYXkl+P/OO5KUjy/ilyB6CQX3r/qfwvIPovJvIv
Y+mvSPTHAVyh8PZIbe7R8fvt/1sFgJ+ht/6mvfqnspV+/1nsAjQj8DHR/5EyAfKPo/I/it7/oUT/
QUT//hL92QGoF8W/HvT+d5XoT/NPB9b+RQDaHsP+S+6PALTQKv8S/Y0CQOW/iZB/uwE6+VUBEOJr
UV8fZX3fKABqpd806kP+tYJi5If4EvkbiNUvYvd14jOuEoQrLdZHKPNPZim76NSsv+Hsq7c0AH2o
NQDJE4D/mgYgEYX1N9PNdvM8gG2X4i2WXogpM/9sVJmZbpHlKPyVnyoC4BxWcZxTaOWxDiFVyPur
gupE/hoj7IJqDrMP+njYiaBPifyfsT7/+RDboC8Gnwj6GjQYdCKoEWg6yDao+cATga0G2ga1Ax0g
ftf+tsE9IHtv0A8M7H8ieBjnRmLzx/S3CR7f3zZkMuv50/vaBM/ucyxgXu/jQQt7Wd1Y2uPQ9dVt
d122737ET7GLvsv6P1b8iL/S5chNpbOlvwrDPKAQVkHMA5XOVuBokNIJwneSEftlhJwzIlTphCNo
YxlsJL0Q30B+AwoFoJD8TRCAJkdNBQDSU/wTAXiN/GL/7VkSVPN9nfyJauTvRLW/M52A6jo/zT5C
/p60+urk76cW/AzkHy62n41BDOQn8oOJAQ+UKUGm5OeJuVFYf7n9l/5/Ib+e+++h6BfPA0MLif8+
AvD6ew2RX0iuw+TYhPy++b8oS9j9Zw7kn8mjvqfRDqtb/9FY/xFq59+dwqU/rL8a/Vn66+wg0d9A
fon+baxSlVaQvyWFP1UAWPYT8jeh378J1r8xN/vo5G+4TSK/VvnfLAKgRX1dBDTyN9CIr5Jftfsa
VPID08ivk5/I3uC1iK8Tn9cgf4NVYUqnbdHKlsts7EpD2JdL7SL+rzUA6Y5gD/cB7PbOMN/glWCx
8kKUxbyzkWVmuYWXm3IyrPwk59AK4x1DK45xDK482j6oClG/6giH4GpD7YM+HGYXWHOoXeDHQ04E
fgr5PxtsG/j5INuALyD81+DbgbaBDUFT8vfmA2wDWw2wCWoLwTsOsA3qCsl7MO/V3zaoL/MBRPgh
fW2Chve1DRrZ1zp4XJ/jwRP6WAdP7W0dNLOX1c25Pa0C5vdg7b/Lviuryf99cSTKiai7Cg1GSufD
fkpHnqba8bABnUEnRKAQAcwBaYKgI2Kg4miwikLih/DU1yCKSJB8XyCPgQpQSV+c/KoIGB0AUf+w
IfqbCoCsADQ5SuSH/M3J+WUZUKK+2P/moBXWX2x/O8jfnv6ADuT7Hekb6ETDkJC/Czf5dCPy9yDn
78m9AEJ+damPm4EGQv4h3BUo5B+F7R+N5VfJj+2fDKbw9CCJ/LOk4w/rP5+uv0XS9cf+gMvl/n/1
7r8Xij2P6r7Drry/j/yvO4RC228qACZzBOA+vQQ2PA5sATsAzwEzdetP3j+ebbHHUPgbSeFvKMt+
g8/dNon+PJmX3L+rPMCT3F+ifztrov/Rwty/ORt+qPZfI7+a/2P9G2vRv5D8CIC6Wadm+yH9txu0
tl6V8BLx30R8ifxASL9aj/qGyC/kNwqAGu010q8U4mtYSWPa3njF8gYuxzZS+WzqDpv/aw1AugAc
DMk223wt1Xy5V7zF8vNxFvPORJeZfipcCoDlx+EAxjqGVYT4lUfaBVUZbh/8AZa/+hDbwBqg5uAT
gR8Psg38ZJBN4GcDbQM+H3Qi8Av25/96wPHAb7hNt+EAm8Am/a0Dm5O/t2Tepr9NYAfQiZy+az/r
oB4Qv3df66D+fayDBkH2IUT6Eb2OB43peTxwfK9jQZN6Hguc0uOI38xuh33ndTl0fVHnvZ7LG269
lLmc1t9dAZkKwqJ0POKrdDjkp3TAFXRADIwgJeiAO1Ahcw3tGdsjAIIOVsFKe9DqUAC3i96E+P60
i95knzjIL9gfQMQPNEZ+gwMIRgD0GgDkP6KRXxMBIb9E/mbWUUbyqwKA9W9xwmD9WxP92zoiAE4J
bGmVRNSH+K7Yfsjflbbg7ghAD+4J6MWNPn2E/OT8/YX87AkwVMhPzj9SyK/e71+M/BT91HbfIuQn
79es/3q2BfPB8r9O/JKiv9788y5NQG+I/OIGIH/8s38oGxNevEb+yTzjb4J3vjJWuv687ivDaPqR
tt8BZ27zrL/b5P5Ef6x/d6dscn/Iry77Gax/GyuW/vTozw6/avSXyA+acrdfYyr+jdWiH2v+Ev23
gM0yygqAId9Xc34hvPT1C/lVSJQHa0xGsf1rNPJrdl8n/RvJL8QXATAiTBlxJFmxQgA67fdTPuo+
fr7WANSKUd8B+K95BHhJNYCpByLMdl7HAVxLMF97JYF7AOIs5rpHlpl2KrTcRJfQ8uOcQ8uPdQwx
CsCwE4EfDLUNqAb5PxxiE/jRQOuAWjTm1B5oE1Cnv/XNugOtA+tB+K/6Hw+qjxA0YN64n3Vgk37H
ApqD1n2PBbbtezywQx/rgM59jgV2A716Hw/o2+tYQH/IPqjn0YAhYHiPYwGjulsFjutmFTCh6xG/
KV0O+czsvN9rbsddFxexA/CvB4OyleWeiUo3Kwh/SATAV2l/6IYqBDK2PwgQAyNEBA4L8XUEKm3o
wGqy3587wwDE1yECoIoADqDRQSG/jkLyqwIghUDQRAQANCX/V1GM/Crxif4t6QBsZRfH3nWA/gED
+RMM5OeGoc60CHdFAHpA/p6Qv/fZDJX8/dgcZADrxYMp+BnJj+0fzU5A48BEBGAyjwubwq7AM3hS
0BzZBYj9AA2R/7Gh6Af5VxL997LWn/ad3NdfUuQvLgBvSwcKP/+67dcLfQbiCy7yFKAlPP1nPpZ/
tth+LfIL+SdS8R8rVX/W/IfLmr80/RgLfzr5sf5E/o52Yv0RAK3wp1f+Jfo3p/CnC4BE/yYS/REA
sf9GARDyA32nXjXyqzm+SdQX4usQAVBFQFvq0wVAi/ZGAVCjfWHUN0b/IgIQpjTheIZdhnKIPQBK
2AG4IRz963cANhWCKe7hZvuuZ5jtuB5rts4z1nzJuWiLuW4RZaaeDC7LE3fKjXcMLj/aPrjCKPug
SiPsAioPPxHwwRDbgKqIQPXBNgEfIgA1B1gHfMz4Sf/jN+sMOOZfFyGox7kv+x2/WR80AA37Hgto
0vtYQIvex262Aq17Hb3ZHmvfkQJetx5WAT16WAb06W51s383K/8B3S39h3Szujmsq9XNUZ0P3hjb
6bDvxE4HvKd02OM5s9X2Cxvb7PVWC4DsQajI48DbCw76KO3YU90IRKDdQT8DhPikCDK2PXSTPxQ/
CO4H8W8Q5WU0EQE1+hscQKMDIgCmDoDIL9H/kET/EEgPmKvkt4T45P9Nj3GXFwW/5jYCLepr5G+t
kb8tvQPtEIBC8ifzpJtkpTv3B/Tg9mCV/Nj+fuwS1O9itjII8g8h8g9jL8AR7AI0CvKPEfKzF+BE
dgUW8k+l4Cfk1yP/Atb7i5CfZwOcuvcDa/tvI37xIuCbBMCU/CZkLyHvz/7u3zyL4DtlYdRTI/ln
qOSn6GdCfsn7hfxi/QfJmr/HLR7nTdVfIr9zttKVvL8Tkb/9cfJ+In9b1vzbHNFz/zSlhZBfW/YT
8jeVW321op8s96nQoz+FP/XBHBLxTcj/rR71iwuARP7VpsDya4Q3CsBKBECgE7545F+OC1georTl
XoE1HrnKau76/GrVybQSGoA+51xJjwD74w8ALckBjHYJMNtxI91svU+S2bLLUeaLPUItyP/LTD4Z
Vna8c0g5Cn/lR9iHVBhpF1hxmO3NysNtA6oMtrlZdbB1QLVB1v4IgP9HEL8WhK/d/7g/IuBfh0hf
l/GLvkf9vupzzK8++Kb3Ub+Gvaz8G/c46tesh5V/8x6W/q16WPq17Wbp16GrlX9nKvhdux7269nV
0r9PF0v//p2P+A/uZOk3tPNB35Fs+T2m3R6vSW13nZ/WZMt5JwqNinU4+a9jqNJun7fSbr8v8FHa
MhrBNuFtEQEdrXAEjbnnusEusMfXQH4dJtFfXIBK/CLQIr9U/w9qKwAa+ZuyFKjCMox96MOV5tj/
5jgAVQTI/VvYxtD7H8ue9UR9GofaOsZzA1Cc0pF7BTpxy3AnIn/XU9wY5J7KLcBpSh/2BOhL5O/H
piADhfzsDDyUrcGF/CPZBHQ0DwYZCwrJf1+ZznbgM9kOfLYW+Rew3Gcgf4Ea+TekPFNCeeDH26P+
uzgCPe83vNdQ6NOX/F7P+0MLflXW8pjvhTzsc54W+VXyU/GfwhLYeLH9EvnZ9lsaflTyY/1V8rvm
Kr0o+kne303yfhp+OnK3XzsEQJp+ZNlPjf5a4a851r+ZLPux5KdC1vxZ7lOjv6kAbML6iwBsFJha
/hjlW1Pi6/a/JPJL9BcB0EeZQ/5vi1h9zfarxNcRovTYHqMc9sGt0Tz2+dzDZ7X8//9OA5AIwmS3
AJYAk8x2XGMr8EsxFvT/l5nujgA4BZcd7xBcbrRdcHly/goQvyLErzzUGgE4HlB1oPXNagOP+1cf
cNy/Rv9j/jX7H/Or1e+of+1+x/0/7WN1s24vK7/Pe1v6fdHTyv+rHlY36ne3vPEtlfuGoEn3w37N
uh7xbdHV0q9118M32nS19G3f5YhfJ4p5XUD3zkf8enY65Nev02G//h0Oeg8myg9ru8tzVOvt58Y3
2HwhaK5HtHIwmJzYJkBpu+868Ib43kobBMAUrQ/4Ee19KQRdVxrshPg7vQ3k311MAEwcQKP92H+p
Baj1AISAYmCjAwgAaExBUBUAVQRCDMQXHAljAwrIfzzCACH+cR74yM0+rYj+bexiDJYftKdluAN3
Enai4NeZqN9N7goEPdkTQMgvUb8/ln8gGMx+gEL+4cXIL5Z/Erv/TmYL8OmhkJ+nAs1lG/D55Pxq
5AdS7RfyH+EJQNnqLj7vGvl/+31vrPJropDH6EqBcRGWf0Ekj/am2DeLJp8ZPPl2Gmv9k+n0U8nP
Xn9qxR/yD7toIH//M7e4U1LIL0t+2Up3yN/VPlPpKEt+3Osveb9a+DtM9KfhpyVFvxaQv+keQ9OP
Sn6sfxPN+osISORXoz/kFzRUe/o1B2DM+YsJgNj+18iPC1hVNPp/S6QX4utj0Xy/KPkbLA9VBu+n
AOjLw06PBCkfD1+y8S0NQCXtAPzHnwJc3AXMOx1stu9qsroV2JrzsRY0AJWZfjKkzBTHwLLj7APL
sfV2+ZEngioMsw2oNNjGvzJ34n0wxPpm1QHW/tUg/4f9j/p/1A/y9z164+M+VjdqQ/w6PS1v1IX0
nxPhv4DwX3U/cqM+ZP+WCN+o62H/Jl0P+bVAAFp2PuzbuvMhn3ZdDvu073TIt1PnQ75dOx7y7Q56
gj7k9f3a778+qO1er6Ftdlwc2XLTmTHfbr6Ut8k7VVl1hRtt2Augzd5rkN5baS3Y58N4Q2m5z5c/
gmtYwKuQ/hoQAQBE/4a7IL9AdQG6EJASSOSnHmAkvyoAQn5DAbDxYU0A1Op/sMH+W0pvAOTH/jc/
poHo3wIBEPK3JvIL+XXLr5O/I+2fnan2dyPn787OQL1YDuor5Gc3ICH/IPYCHELkHwZGUPAbxcNA
xgA935/Eg0Gn8iSgGeT8c3gmoEr+iIfKQjr9FvMwkKWs969MfKJc4lFfRdf2f5vcvyUURcn/etRP
p5d/J30FOvllmc9Ifrb5nsTTftSCH5FfyK9W/CH/QCn6sd7f1z1X6c16f6H1z1I6C/ml6Mdav6AN
t/q2PpQC+VNV69+cyN9sN9FfXe+H/Fqzj0p+zfo3klt8VfJL5P895Bfia+RXrX5h1FcFwDT6GyN+
KNFfR4jSaEWoMpEGICufPKXpjqtKxboNh2kNQC0ZJf//Evz1OwCbisBitzizHZ6pZisuJZsvPRdv
Mcc9zGKGS7DqAMY4BJWj8l9+pF1AhaG2/pUG2fiBm1Uo+lUl16/W79iNDyH+R72t/Gr1srzxcU8E
oIfljU+J9nUhfT0q91+C+pC9fpcjvg0hfGM28GgK0VuAVpC+Hfa+A2QHNzp3PHije4eDvj1BL8jf
h2Je//b7rg9qs9traOvtF0c23+g+rTENQEfZ/muWRxTbKF1TWu8GuIBWoMXe6/zjQ/rtXkBGXQBE
BLwLyS8CoLoAgwCoxDdBQyH+XsDYmAJgY0TAIAAQ/5Dk/ZL/h1LwE/IT+SX6IwAtaAtuYR2pRn2V
/CaWX6K+2H6V/ER/IX8PiG+w/AbyD+SZAEL+oTwdaDiRfyTbfo9m2++xkH88Of8kyfeJ/NNCID8P
BJ3N/v/zgEr+6EfKEvb/Xyb7/9PhF//8j1j+koXit8jvy2PGV9DYo+b72H5Z5lPJj+WfBvkn0uRj
qPZL5KfP/wo5v5Cf9X6p+Pc7fctI/h5U/Ls5ZKl5fwfJ+8n521LxF/K3OUT0P4gAcLNPC270aaZF
fV0ADFV/7P9WQ/QX8jcyJT+FP8OtvIYUQKy/av/1gl/xyK8SX4Oe62uWXye/UQCKWP6iAtBybbiy
yCVL2cYy7tfrzxQUy//lEWB//Q7AxR3AGs90s41XEygAJlEAjLGYTw1gmktImQkOQWVHIwCjbYLK
D7e5WWGozc2K5PyVyPkr04//QT8r/2q9rW5UJ+LX6HHEt2aPIz61uh/xrd3tiE8dSF+36yHfel0O
+X7ZBQGA+N9A9oYdD/k07njQpylo0fGQd+tOB33adTjg2wGyd+pw6EZXKvfdKej1bHfAp3f7A759
2+29PqDd/utDWu28OKLl1jOjG208s6cXjT7Hwtj/zzlEacXdgK0QgOa7r1Pt9aLH+4pG/mICQArQ
UI3+mgMQ8psKgER/3QFICiBLf0AlPmgioyn5EQCJ/M2OhqtoTuW/hVUkUT8K8kcrbU5Es0d9DJY/
Vs33VfJDfLH9Xcj7u7MzUC92AurNXoD9yPf7swegkH+wkJ9nAw7neYCjsP2S74+j4DcR8k/mzr4p
Yvkl38fyzxHyi+Wn2r8oppD8trnfKffUdt4/Hu317/gt4t+jl8CWDTwXxz5TyT9PyK9Hfq3DbyK3
9uo5v0p+Ov2GaOQfpJFfzfux/T0o+nVzzKILU7f+WuSXvJ8tvlXyS/Qn8jfH9hsEwACJ/o3VvJ+R
6K+Tv9EmPe8vJL8IgEp+iC8w3tBjLPiZEL+YAJgS/9sVOABgiPamtl8TgKUyhiidt0QpO3kE2Fzc
3xeLbW6W0AAkOwB/DKoD2QFYOgD/3B2AiwvAyosJZjv80sw2XIs3X3EmymKOW1iZKS6hZcbbB5Yd
a3ez3KgTN8sPs/avOATyDzjmV7nfUd8qfa18q/ay9K3W87DPh5D/o26HfWp2O+TzcddD3p92Oej9
WeeD3p8zftH5kPdXnQ/61O900LtBxwOQ/4BPkw4HvJt32O/TmrEtZO/Q/oB3pw4HfbpA+u5thfz7
ffpQ1OvPOKjtnuvD2uy9PqLljstjm285M7Hh5vNXJrqEKcdC6YQ77q80h/DSEizEL5H82CxDCgB2
kf+bCkCRFAAXQB1Azf+B9AM0RgCa7NfJH0TUN0T/puT+zYj+zY6KAEjuD/mJ/kL+1ieisPwG8reH
/B24Tbgj+wToUb8rBT+J/D3ZE7AP5O/LTsD9eRDIILb+HoIADOPJwCOAkH8s0X88AjCRh39O4bFf
0yD/DKr9syj2zQnLU5f5FkRh+SH/Up7/t5olPh+66/5M4hcW+t7Q2IPIyNr+Fm4nXhSjkR/iq919
FPtmSKWf9t5C8hfm/Cr52eHHSH4176fop+b9WWre3xnbr1p/yfs1698K6///tveW0XGcWdvukjlM
DpOTGMTQLWbJlpkZYzsxxcwgZtkyM9tiRovM7GO2w4wD30wG3/f73nPOWudPnWs/VdVqteUkQ0l+
9Ky1V1W35Ixd3fe97w3P3ooAiPsVAQB+RQBIfzEl/wG/KzV/VyEAPL+A30YAtrKf3tlnIwDzNJ8C
v9HkY+/55X7JeT3eN80Avg5+kwDsvb4dASxgWhU7ADeSABy69Yz2woR1uUb8//NOAHYkgNkll1yS
W953WU4JcEH++Y5vHj7XcfJ+KgC7W7oM39bUlcx/t0HbGrvFbWl4sN+mYw/Hbqp/JDq3/rGo3LrH
I9fXPQnwdfDn1D2HvRCSXfsSJbtXAP1rQTm1bwRl1/YOzK5xDcyuBfz13gFZ9b6A3uKfXRsQkFUX
hIX6Z9VFWLPqoyGAviTz4vwzjw20ZNUP8UuvGeGbWjnGJ7FsvNfqvCm91pW+v6T8urayhlNy2cT4
DATtY0cArSRgyH97AjCTgEICaYQDVAR0M8CvFADAz2kG+AJ+nQA8SP6Zsr8t+HXp74Ps98UsCvyc
DkT23wN+w+tHMhA0mpg/Bu/fj01A/QX8AF95fVaAjcDzj6pju1E9s//Z/jsZ8E8B/NNOSryvg38W
4J99Xpf8CwD/IsCfzq6/O2pm/7/P6/8U8Jd+8V/aAiT/vIu/0z2/WeM/JeAn2SfgR/abCT853TcM
2a/AT8wvtX7p8zeTflEHPlTNPuE0+wQT9wcCflXvl4YfifvF+2cb4Ef6CwF4iucn4eeO7Bfwy1WA
3+r9dfC7Suy/Woy6v9noIwRgeP9e9mW+doDfBvx2wG/r/R3AL55fGWdIFp7SRm3gBCAEEJBxTHs8
cPB0sBiM+WI/zwrw9sqAiyouuKQ33HFZU3a1wxwIYCoJwPF7T3UeufN4Fzx/10GbAf+mhgf6bap/
KDb32MMxuXWPRm2oeyxifd0TYetrnwL03fH2z4Zk1z0fnF37YnAWBJBV92pQVu3rgVk1b2B9SOS5
IeU9AbsQgJ81q9YfoAfh5UPJ4EdYMuuiuMZCAnGWzNr+vB7sl1k3zDe9eoRvSuVY74TiCV5r8qb1
jC//n7Smu9qbR+m0E69vEoCQAKbH/qaZOQAjASgVAEigD0rANU0HvysqwDVDJwA3CEAZ3t8kAA+k
vweZf/H+XuL5VdLPSPwR/4vn9yXmt9LS6c+hoQAIIJBhIYFk+sXzBxPzhxvgj2JPQLR4fsDfl5Vg
A0qZBFzOCHBWgyuvD/hH136E12f1F+u/JzcD/uNs/DnBth/i/bfJ9s86+zWS/xsAh+Qn2SfgP/LJ
n/6B2v5PI4gfk/wf/Pn/ZcX4n8g56OCXTP+sczT4nBbP/5061WcP/tHE/AJ+VeoD/IPw/Dbw2yX9
zLg/jLhf9/46+PXY/zaJv9uaD/P9fJjt502nn/L+IvsF/GJ4fTcO+LiK0exjen6TAHrbwG/X6UeD
Txvwt+f9lefXy3zKTAJYyL0yQC5mS/iZwG8lAA8SgDN33dGyqj/T3lhb+r/BouME4J+3Acgkg/ji
83oXYPHVDrOOnsX7n+zE1t3Ow7Y1dxmyo7HrgM3HIIBjD/TNrX8oJrf+Ybz+o+Hr6x4H+E+G5tR2
x+M/HZJd8xzgfyEoq+Yl7JXAzLrXAHvPgKyaXgGZNa7+mTUe1qwab64+lO2sZO0DsGCAHu6XURsF
6KMhgH6WrNoBZPMH8v5Qv9SakcT4o72TSidCAFPc1uSvlXLfBjoAR+yhGScR7y8EcF8SgABEASiT
MEAHv3h/IQBXIQABfxoVAMwto0lzhwDcRQFAAh40AAkBeEIAXkIAm1oJQDy/LzV/X0p+Fk4K+gP8
AGYIBjEtKNiQ/aHE/AL+SEaBR+P5xeuL7I9jIaiAfzCLQIfi+YfXfKCNqmEHIOAfD/gnNQH+Fg45
Afw3T3zBMdkvdPCfY/PRhW+0d5D9C0n2rbzxG+3Mb39myU8TkdT2VzJEdD7xvg384vkB/5sG+Keo
gz14fkZ628BPi+8QBnua4NfbfNlmZNb7RfqT9BPpr7w/nt+W+Nuog195/6ybbQhAyX6TAFjRrRMA
4KfWr8zw/qIA9P5++1Zfs7XXscnHTPjpsl/3/hCAvec3gC/gb0MANq9vTwKntABOAK5iAtBiyr2v
Ld5/w0gA+nP1xHph7TUA/WfjfyGB+NKbLmtqrrgsKrnYQSoAE0kAjtrV0pmkX5eBmxu6Iv279UMB
xObWPcRJvIcjNtQ+FpZTowgA8HcPzqp5RsDP9cXAzOqXIYAegVm1b/hn1vbyz6zuY82odrdm1Hha
BPwZ1X6APcCaURtkyaoJ9cuoifBLr43h2hciEO8/iIz+UO6R/tVjfNOqxnkllUz2XFfwZp+1RXlD
aQBaf4K++M1NnOgq18EvRGAogLYqoBX8faQkKOCnFKiuEv8jw/pAAG7cu2UKATQqAvBA+iszwU/J
zwS/N97fZ8sZgH+GmQAYE4T88f46+C8BfrEr7Ky7qkWwJSiKeF/AH4vnF68fx6rwgWV3lecfZgd+
8fzjyfRPahbws+vvBHv+IIC3yPbPAvyz8fwC/gWAfxENPhvf+wO1fRnV9dM8+k/9vR/y/F8C/iOf
/lVbhOQXzz/X9Pxnf8Pfs9XzC/gnSZMPpa7RUuqTwz1s9h1Cf/9gxnr1F9nPYA9V7jvyoar3R3HC
T0l/CEASf8Hb71Lz1+N+afixbLil+RH3+2YzJh3v70PizzsVBZCix/7uJP2UCQGo2F8UgGEAX8Dv
al/6WwEJqKYfOwKQFl8z/jfifRvwlfe3IwAH8NsIQFSAnewX6d97PrbgpBaVdFHJ//EMknlpeuZh
oGdOAPbgXlaAvYjJCrD/3ApwxxAgLvuES0ID68Aqr7gszD/TYdYR4v+DJzuN3N3UeejW5q4D8f79
AX/MhvoHo3PrHo7aUPtIxPqax8Kza58Iy659KjSnRgjg2ZDMmueDMqtfJNbH+9e8htcX6d87IKPa
zT8D759Z4w3o/cjq+6MCgngdCtDDsShLem0sgEf2U+7LAPyZtcMp6Y32Sa0e751SPdErsexNCOAt
4v/Lb1H6S6hnPNZ6ZH1imU4CQgD3JYEqBkBUK+uDCrARgNEI5Er87wYRuNEwJCQg5wI8yAMIAXiJ
56dZw0sIgJq/DfwCfMy6Hc+P91eyn30CQYA/hO1B4QdN8N9gfj3gZw9gX1aD92cl+EDx/IB/aAVL
QJH9o2tZ9km8PxHPP7n5UyT/p8TOn2ozTn2uvY3sn3X2K5vkl3h/8ZXvtLIv//qL1PYzGBqqg59k
n4AfyT8Lrz/TBP+Jb9WR3okG+MfQ6z6q+gtV6htG5nuw0d8fJ54/D89vgp9OP5H+jt4/wCj7WZH+
FhJ/fjkAPwsCAPw+SH9d/pP4k/hfwA/w3fH87qbn56Sfm9ybdX+j9NfbBn47ArB19LV6fl3ym8B3
9P7i9XXpr8A/384E9Mr02F/A33v+SW0oDUCbIIBIDp09PeCtZUb8394EIMcGoH9/849JBP45RS7x
tTQBVV/rsKTgfIeZB892nLj7eKfRu1q6DJP4f2sDBFD3ADP4HozdgPzfUIv8r308PKf2SQige2h2
9TPI/+dD8P7BmTUvB2ZV90D2v07tvqcu/avduXoBel+IwIoSCAT8IaiBCO6jAXxfiKE/18GogGEQ
wUhi/1Fcx/mmVE32Tq6Y5p1YNtNzTd68nvFlf1hTe0ubU0yTTRpxfnx5WxVgRwJmHsA1xYEAxPur
MIDYXyX/IADx/m3Az1kBDgDZwA8BeCP/fYj5/QzPb8XzBxDzBwJ+JfuZFBzKaHABfyTLQ6MxHfzs
AgD8A4pvsdiSHYCAfzieX+L9Mcj+VvDj9fH8bxLzzzj5OaOxvrB5/fnE+yL5E2/9Vrv2S9T2v/sv
bQWSfzFdhQuuIPtZ1qHAj+dXMT8Jv2kG+Ccx434CXW5jmeYzmnl3KumH7Bfwy0z/OLPH/+iH1Ps/
Us0+Av5Iuv0k8SexfxBn/HX5f0cT8Fvp+LMRAEs9vDnh553GLgUhAMBvIwABPzV/IQC3+MtK/rtR
ARCTxJ8y5L9YGxIQz29/kMcW7wvo2yEAR+/fBvwm6A0SEO8P+N1IAE6RCUB1X1CirNS6dH9pABiU
CUBmA9AvE/9Hbi1zWXXspsuKmhsd3im83HH6wbPU/092GrGjqcvgbcT/yP+4zXUP9JP4f0PdI5E5
JP821D0Rvr7mScKA7nj+Z4MhAFTASyiAV4Mzq18LzKp6IyCzujfmhnn6Z1Tj/ZH+GdUBdO0F0dUX
yutI7mMs6dVxfhnVAwH8UN8MYv70mjG+GbXjsUlk/6d5J1XM9EoomuexJn+1J3X+Dcff1xhJRukP
8IsCwPpwr5ueCBQ10EoAuvfXFYAh/yUJKCY5AFP60z0ont+T/n8vrl40/yjPL+DH+/tuPg34GRDC
pCAro8ICdp5jG81Z9tJfMMB/WYtgN6ACPzX+WLYD981nCxDgH1hyW4F/WMVdwP8uXpF/A55/Ap5/
UqN4/k+0Kc0fA/5PtZmA/+0zX2hzz36pvUOyT5f832o7P/wj5+h/htq+cXJPugell2Dnh3/Wlsre
gKu/18FPa+9cSfidpdQH8GeY4G9B9pvgV9JfwP+FfrhHJf106d9f2nzx/jGHkP5YlHh+Q/qHM94r
ZOe7uvzH+/sj/QX8ytazGIXY3zdTB38bApDMv533lzBAqQBifzcJA6T+bwM/M/zJ/CsSMJt+RPab
BKCafCTRZ4BfCMA0u4Sf6fnV1SQA8fhyb1MAhvyHAPyWn9UWsQJsDUteWQH+mRH/B3D1MuL/n78B
SFRA3AGWgkIASbW3O7xTdLXDDHIAE/bSALSzuQurt7oO2AQBbKp/MGZT3cPRuTUQQO1j2BMROTVP
hWfXPB2WVfNcSFb1C0GZZP4zqnsEZla9HphR3TMwo8Y1ILPKnRBAEn++1vRqizW9KhDgh0AEEYA/
Go/fjzIf4K8ZYkmvGe6XXj0KG8frST6pFdN8UitneCeVve0VX7igz5rCfTGbmkgA0iZL/d8Ev54H
MAjADAWMngDd++sKQMl/IQByAAr4kgSUBKB4/swGI/YH+CT/vOS0INLfm2lAAn4/xoBZmCdoYUKQ
v4CfRSKBrBVT4Gc/QCiyP4LNwVEQQMxRFoEI+PH8/Q3wDykH/Hj+EVXv2cA/sQHwN32sgD8Nzz/9
xKck+mgQOWuC/2sF/qWXv9WOffPXnyfWtwP/1T/8j5bMmPClAH8xwBfwv4Psn3cez3/mN4QngF/q
/DJtmIz/ZMA/kfPt45G4Iv1lnfcIpP/Q9rw/9X4hgCiafaThRxEAx3zDOOYbwnRfRQBk/U0C8Cf+
NwnAJwMCSDcIgCk/kgPwZK2XB11/AnplQgACfib8uIoR+6v4X3l/wM80HzGdAOySfwb4bQRgTwIL
IQJD7juC30YAKta38/xm/A8BhK+7oKVXktchN/TKnC21QC8M++UOAJkhwMDdDAMtveWythwFkEcL
8OFTncbtEwJo7DJkawMlwGMP9N9Y/2DsxpqHo5H/JAAfx/s/Afi7h2ZVPw34n+f6Ykhm9SvBmVU9
AD/yv6q3f0YVsX+1R0BGlQ+n+CxYAK+D8fhhgJ2SX01fiCCOFt/BlvSqYdyPBPhjsQmogCl4/+k+
qVVv+SSVz/Fcm7+w99riUxNpAMpmAAiNR60EIArATATaEYA0B7ULfjoGXTNawa+kPwTgIaAX8CsC
OK550/brAwH4If0F/FbmBvqzaCSAPQKBTAgOIuYPxsLYDxiBRR5hM9BRNgEB/rgCJD/JvsF4/qGA
f3jVu3jD95h08z71cOJ9wD8Zzz8Vzz/t+CcA6TNAhewX8F/4Snvn/NfaQmR/+q3fae9+b4zqkiO8
P/kY7w8nBm2JPjWeq619w3vljANfLhODxPMD/IXYfKYIq/ZePP/bEMBMsv2S8Z+K9DeTfhOOAX48
/yg8v+n9h7L3bpCq93+ivL+0+sYa3j/SrPnT9GPKf0UAJP+CkP+BZP7F+wsBWMj+iwLwk/JfJgQA
+MW8WOqhE8BVzYN2X0UAgN8MA9w47acIgOy/mD0BKBIwa/9LIQKHk3w2zy8KoD0CwNv3AvRtFIAN
9GbyT88B9E/TG4AGygTgMSszwF8IJvG/O/a6kQD8eSYA2ycCJ+0977K67LLL0tIL9ACc6Tj90OlO
Y/e0dB5OBYD4v+uAjfWU/2oeil1f83DMhppHIzeQ/Rf5n12tx/+Z1cj/6pcAP/K/6rWgjKqeqACS
f4oAvCACvH+VFQvCQgF7BGogBiUQBxkMhAyGSrMP1zFcJxAKTCYUmOabWjHTG/D7JJbM91pXsIQE
4BeLy65oSzD+fKv8b08BQAT3xP54f1cBv5iq/+vJPwV+ZgN4yqlBIQEl/Y9rvgJ+VICF8WCt4D/N
MApd9ocS8yvwE/Mrz38E8BdcQ/Kz/VfAX3a7jeQfQ6lvvID/2IcG+D/WpiP5TfDPOcdy03NfMSPv
S8D/tZb/8fd6bd/R/sWsfxvwmx7fIIGPWACyhdXfAv5lsi0I779IdgfS4TcP8M81vP9bp79DsTBp
WOJ+pP9kVltNJO4fh+cfTcwv4B9O1l/kvzT86GW/jzno8xHLUaXsJ5l/8f5G5t/o+pP4P5Sef3sC
CJAcAC2//iQBLVQAJARQKkDCAEUAGPLfk6y/PQGI9xdzVyrAjgRWQgKGAlBju6XmL+BXJuW+1sk9
bQhAkYCe8DNlvwBfB78p9du7ntT6QABjcm8oAvCjBP2od/QEIwHoy7W9BqD/3ApwxyrAtLwTLknV
t13WlZzvsIAegBmHyAHQAjyS+v/gLVQAttQ92De3lvp/3SNR66uR/zWPR2RXPxWeU/U0JPAc3v/5
4MzKlyn/vRoEAZAERP5Xi/z3wLwhADL/1QEogGD/tKowSCCS5B/ev6Y/sf8gv7TqYX7pVaMgg3HY
JGwqYcB0n5SKWbT/vuMVX7TYc82RVb0AembTHW3qQSaqJLbG/7Y8gBkGiOc3zZb517P/ciTYVXoA
IAA3TguKuRP7e4rlNGHE/4DfB9D7MirMj9mBVnYMKM/PrgABfzCrw0KR/2H7WRICAUQdEs/PYtD8
a3i46yS6birwDyfeH4HnH4XnHwv4J9R9gOcX8H9Elv8TbaYh+WcT78/B8yvwX/iS+vq32pnf/B3g
E+8r+xES+AdUQRtvbyf35f3Tv/tvLZ5JQW3AL9IfAlBdfoBfvL+AfwbAf5Nx41Mx8f6S9RfpP7bm
C5v3H47nN+W/zPUT79+f2D+O5F/fQx8oAlDx/142HBm1f0UANP+EkAAUEhAFEJiL/EcB+BsKwAIB
+EIAPpIITGWfQso1CMAgATb7ehDzSwJQTMDvhvd3VwrgoubK8g5XtauPEMAAvxBAKwkYBCBtvYYp
EvhR+W8H/He4F7ORAnmkJae1WXvuaulVn7ACvPivYPCXWwHuSADDdh2jDPiey8rKKx0YBd5x8t5T
ncbsbO48cntj1yFbpQRY92DcpjqVAIzKqXksIqsa+V/dnRDgmbCsauL/qhcJA5D/1T2CMirfIBGo
Sn8B6VWe/plVvtwj/yshgMoQ/3Ri//TqaKyf7v054ZdWPRLvP5brRE71TYEU3vRJqZzlm1Y51yep
bKFPQskyt3UF24Ozj6kE4PCdx/H+pQ4hQNs8gCKAZFEBZumvRge/QQAyFEQZcwI8bATQwiDQZsDf
osCvPD+7BPwZH66D/wyz6HTwh+9jKQgEEHWIJaEm+IsAf8kNPN4tPP8d4l/AX2OC/31tEuCfguyf
Rswv4J9FmU9kv57s+4J4/0tt493faR/JqC4b+B0JwHgtKsCeGNpTBQ7EcD/wS20/74u/sReQ/QB4
/uUyLVj2BaqMP9uDkP5zDOn/lkh/O+8/RRJ/7LUT7z8e7z+2VieAEVVS9iP+x/sPLmZLsRAAAz7s
CSB2PwtNJfsP+CNo/AlnR14YScAwKgChQgAkAYOY9BuIAgig/i8KwEoZUMIAIQE/8gA+qAAfIQFK
gKIClBIwwgDl/Q3wy9VNwE/8r0IB4n4T+Orq2PZrEgC9/Tr4z9zX+0sI0EYBtAG/XgEIWn1OW1v0
sfbO0Vtaj4V7Lhjxv9kA9POtAHcEv7yedOSES2LjXQaBXO0wO482YI4Bj0EBDKcCMHBzfbf+G2sf
pARICFD7SDT1/8hsif+ru4dlVT0D+J9D/usEkFH5OgqgJ9YnMLNSYn8vSADvX+mPZA/GwiwZVVFc
+wL8/oQAgyCBYRY6/QA+3r9mIjYNIpjJyu/ZfmmV8+kAXOwZX7CSBqBjHEnW1kMAsRuJ/9dBAPFU
AOxMJQJF+osJ+OWQEFUD19RqlkKYBFCH7McE/OQBPCAV8f5eeH8vZgN65yL9mRzsBwHYwM8+QQV+
vL8J/sgD7AUE/LHE/crzG+AfYoIf7y+ef1zte3h+A/xNHynwvwX4Z5/6TJtjZPrnn/8Cyf+VVv75
n6jtm17f/mqC3Q787RGAPeDtyEHN4zMGcjrev8vZgWy2AK24/QeWg7SCXyX98PwC/nkXfss0Hz3u
t/f+U2ThiEh/En8T8P7jAP9owD+q+nOV/HMkgAEmAVD7FwUQQ9dfNCQQifyP2AMBkAQM38kIdDoA
w0QFsOUnmDxAECogQBQABCAqwCp5ADEIQJGAUgGMVzcIQEjArAKIAnAnB6AMBeAmBLCKVW0QgI0E
7Id7mM0/toM9AnzTdLmvmx7361c7AjDjf3sSeIddlUwAEvk/mrLxi9PSdgO7X2YFeHsEMG3PaZes
uhsd1nAUeHbe6Y7TDrQQApAE3NHUdYhJABtqHoreWPtI5Hrkf44ogJqnWMz5TFhG5XMhGdUvQQTI
f0UAvQLTK/sAfI/AjCpvRQAk/wIyxPtXhlszKqMJAfpRBhwAGQwlATjCL61qjCWtcgJhwBSR/rx+
yy+1ci62wCeheDkEsBrA353FBKB1NTc0ugwBvhCAaToR9KEngEnBqjyowJ8iJGASAGVApQAMAgD8
7sh/T0aEeUnsj3lL3A/4fdkb4McSEeu2E4ydZk8Am4KCIYBQ1oeH2Xn+voC/H97fBP9QO/CPNsFf
L+D/AM/P7AIF/k/w/J9qcwH/PLy/gD8RyX/1d7Tztgt+UwG0RwjtqACHcMEcxtne9Ri1/XV3ZSOw
bAYS7697fqn1LwL4kvQz4/7Z5wA/BDCDpN/048T+LV8r6T+5gc1DJP7E+wsBqOQf4B9B04/U/oeW
sKXYUAAmAfSHAPodpgdACGCfqABIQKkAVp6RAAzfxhKUrRgEEAIBBIsKMEkAAtBJgD0KEgoQBvjS
COSbCgGQCPQiESgE4EEDkJ4M1MMAkwDcmcXnRgggYYCrhABtwC/lv9a2XxUCKAVwPwIwk392kt+U
/zYCoAEIAhiWdU01AIVlN2lPxUyebxf//7wrwNsjgAX5F13iIYBFRVc6zD5ySoUAozkCPGxbQ9fB
W+u7DaABKC6XBOD6mkejaQBSCiBHFEDNM6GZhACZlS9hKgGI9SQMEAJwB/AQQKVfQFpVICQQYhUC
SK+MsmRUigIYIBN+eD3SmlY1FiJA/ldJ7D8DVTCL+3m+SeWLIICVVADiaQD6W0LdTY1RZXzQxP/t
EoBUAyAApQIkD6CX/9yYF2AqADfifzfOEijw4/29MQV+FIAv04N9mRbsxzYhf7YH+QP+QLYHC/jD
drMibB+7B/dfUJ7fBn68/0C8/9CSm7rsx/Pr4H8Xr9jq+We0fKy9rcCP5z/7uZL8Av5d7/2e2j7t
vPbg/7vU+u3sB1VBO/kBgwTuB/7PGQ229+O/sAuQhaAm+A3Zv/iqAX7x/qwPm8NEYQG/yvobsf80
ifvFkP6TGpD/gF/Jf4n/SfzpBPC5pnIAgF8RAPH/QOJ/CQH6kwSMUyrgfRSA5AEgAfIAkaiACHoA
InbcNUiAkMAgAEUCEgqoXACr01AAVgjAQi5AVICFPIAv8b9XshDAVRUGeNgTAN5fFIAQgDvtv4oA
yP6LOTYA2UigjQqw9/6tnr+XCXR74DvE/9IANG37bW19zec0rVVoHR96LPZX0QBkksGCwksu66ou
d1hafLbjrCNnOk7dcwrvzyGgLfXSBvxAXC5JwA21D8dSAYjKqYYAqp+IyKrqHpZR9WxoVuXzoRlV
LwH6V4LSK6gAVCoCwFAAOgEAfkKAKkKAKsp/EgJUxSLv++PxOepbPQLwj+E18r96Cj+fznuz/FIr
3kH+L+EA0AqPtfnZ3qlV2vqWd7Uxe8moOoC/j/L+JvhLdQJIMry/PQGQ/XeXaUHpdQr8ujUA/kbW
STWR8W/WLKwXswD+AOL+IPH+EEAI4A/H+0eyfDTm4EXAfxnPf4Wk1lUD/NeRu7eQvXe0MQL+mlbw
T0P224N/Lsm+dyCARRe/pLb/l1bgO4K+vdf3EME/Dn7Z/pPCGQIFfuX17WS/gJ9JQgtkazA2ly1C
JviV9FfeX2r+eH/J/DeygAQCEPkvBDCGL/gowD+yQlcAw0s/1YYx5UeRAAdghAQGHCEPYBBAv8Ps
NZRkIAQQAwFEkQeIog8gEhUQQR+AKIHQLSxH2cx2JBqCgiGAQMIAlQ+ABKyAX8wiBEAuwI9yoLco
AKoBUhEwScDDpgAE/Lq5rZAwAIMATBXQh5q/mI0A1Nn+M8ruzfzr0t8m/9sjAPUevSM0AC058oG2
kgGvry07/FE7DUA/7wRgRxWwsOpdlxQSgKuKL3IO4DwK4GTnsTsau4zYfKzr4M0ND5AApAWYMwC5
lABzqqgAVD4ZngkBZFU+G5apE0BwesWrQRkVrwelV/YKyKhw9U+v8OSqKwAjAWgogGhrGgogrWKA
Jb1yCNJ/hCW1ajTAHw8RTMbzT/dNLocAKuf5Jpcu9Cb+d1tbWMSgUUUA/bc2Ev+XMNetWM8DYG0J
APkv4FdJQBQA5gZ5uCH/3dNrGRhZS8xfR6dfPXE/xihxH6YG+0EAAn7rFkaHQwCBEEAwsX8Iyb/Q
PRDAvnNkrQH/4YtaPwigf94VbVD+VW1I8Q2k7g2+8LcA/13Af1f3/Mc+0KY2fmgH/k+J+fH8gD/t
+jfae98zquuHvP6/oALa8/zfsImnnNmAq+/IFmAD/Dd/rxJ+SwH+YpJ9Av6FHC02wT8Hzz/r7HfK
889krfgMGn5s3r+JnYMi/7EJSP/2CYAwgBBgaPHH2mB6AGwqQAiASkAcpcC+jMbqSx5AEoJCAtGE
AVGoACEBIYDwrSxIQQWEogBCqAYEowAUCZgqwCABK2GAkICPkADg90IBeNIM5Eko4AkBeKg8AArA
IAB3MwQwKgAm+G0EsIhQwJEA2sT/P50AItdd1LLJi0zlePjLs3LLjPj/l28AMong7eIbjAO/1mFh
yaWOM4+c6jRhV3Pn0TQBDd96rOvATbUP9N9Q91A/DgDFZEsJ0CCAbEqAmZXPhmRUPh+cUfFSUHpV
D65vQARGDqDCwz+t0pswwOKfVhEA6EOY6BtuSa9AAQgBVA7gvSHYSEtqxViMEKBSFMCbfillEED5
PN/E4sVe6/JWMgHo0tRDZ7X0Br4MORwAsicAw/tLSNCHhiAV/ysCAPyYgN+dMwPuJAFlQKgHw0O9
SAIK8L1QAD7kAET6+zFizAoBBGxpUeAP2i4EcFoL3c2a8L3n6Fe/wGYa8f6X+PJe0QYK+AuvacNK
r2sjym5qoytua+Or72gTyPpPPva+Dn5i/rdp8pGYf84ZdsCd+Uw78tEftK/+amT5f4rXN3/nvvmB
e0uFjgTw4Z//R9vKiDAB/ipGg68wgC/Tg5ZeZUegHfjnI/vnMmNApP/bEvcb4J8O+N/E609j1+CU
5q+U/DcJYDy97ePw/o4KYETZp9pwGoCGUQEYSg+ATQWgBvqTAxACiEMBxFEOVCQgSgACMEnADAXC
JR8gJEAeIITjwMFUAgJRAQGEAf40BVk5G2Bl/r+FdmBRAT7kAnwAvxfg96IUqAhgrRECtCEAPP4K
WeIhcb/u/RUBtBnnhQJYgAKwgd8+CQgJ2Jf87lEB+gGggel6A1AcfSXPjlycaNcAZB//OzYAdeT3
/jM7ABwVQELDNaYBX+0wP59RYIdPdJq8v6Xz6O10AW4j/ucQUD+OAEsTUCwlwKjs6scjMqufjMiq
pAsQAsiqUgRABeBVFnbQAiwEUOEamFbhgef3Bvx+gDwAwIdg4ZbUyihTAfilVw7GUACVehKQHIAK
AVLKZ/sklb5D/L/Ye23eShqAvltWflVbWHJRIzSwEUAfVQmwM+J/IYE+9AjoCqDSAL9BAEICmRBA
dq0iAMn+e0MAfqwSs25q5uAJa8O2sjPQ9P67TiP9zyrpL94/Vrz/0UsK/IOR/8NKriNzb2ij8f5j
Af9E4v5J9e9pU0n6TW/+SJt5/GMb+FeQ5T/9He28JpD/EfD/AyTgCP4zv/9vLYEM/wqAvxzgr8Dj
r7gB8GUtOMBffJmdAXh9GScmw0XmMkpcRorPZouwDfxS85cloyL92TYsBCDgn0TpTxSASQBjKf2N
wdONpt11JCHACBZf6mEABCAkQAggKmBQPqvNJBdACKBIAALoZyiBvvtYgUYoEMPWnOhdLEQ1QgGd
BAgHFAmgBIQESAbaSIBkoAoDqAj4QQC+QgCKBCAAln94UvrzoAKg8gB4fwkBxPQSoE4CigCo+fex
xf5GCEB/f9vsv533dwS9Q/zvSpgwbqPeAORFH8pDPS0j7eJ/xwagR/jZz9cAZBLBGroAUzgHsLRQ
tgGd7DgJBTCGEGDY1vqug4QA5BzAhmqOAVc/SvxPCFDzZHiGUgDPhKIAUAEvhRACQASvA34hgD4B
aZUehAHeAWkVvgDe35pWQRNQRRhXjv6WkwQs78/7g7HhKIPRSH5CgEpCgMo3fZPLZvkmlc7ziS9Y
RAPQGonpM5vvaJMPcgBonUj/IpY6FKkwQOUDEnSTMqCrgF9MlQAhACkBYh6GAvAkB2B6f2+R/qwQ
s2wUAmji8Il4f3YM7mB1+M5T9KWfoUnlLP3qEvtfIF69gPS/pKT/ULy/gH8U4B9XeRvPj/eve0+b
gvef3vShAv9bJz/hRN8n2vqb32of/tmQ/P8M8H8iAUgJ0SSAL5H8R9gAtFJ5/N8pqb8c0IvXF+Db
wA/oBfjzZa4g48TnYAL+t0X6G7Jf9/4QQLPE/l9rU5vYQHQPAXyhegBEBYyuYllrxaeKAJQKEBKA
AIZQBx8iSoBuwEF5kAChgCKBg0ICrD6jKtCXkmBfkoGxKIEYSoLRJASjtt/RIugLCKcqEEYoYCMB
wgBFAhwN9kcBWJkJoKsAti2TCxAV4K1IgKWsdAJ6SAjgQACuxhZf159EAK3At8X/P0IA3mwBnrfv
XS2JCcBvrCr43X0agNrbACQK4D93BNheBazMu+yyQmYBFl3oOPMAB4F2NHUeua2xy9BNJAEhgP7r
ax6Mza1+ODqn6lHi/8fDMyufDCUJyIbeZ0PSIYB0CQEgAEkCplf0BPQQQIU7ZiiAcn/AHwzQIYDy
KOR+X4gAAigfwv1wvPooDAKomATw3/RLKpvpm1Q8x3td3kImAG1nsjD1/7vakO0cAFoD8IUAJAdg
RwB9FAFIBUC8fysBuHEQyEYAjA/3yoIA2Bsg2X9fEoAW5f1ZF0aOIUC8/3bWhUMAoRBAxC42uBw4
R7nqHLH/eS0OBTDg6GWb9x8BAYytuKWNr7qtvP9kCODNxg+0mc0fUu77WJtz6hOt7JM//mOx/g8R
xA+EATr4dbvD2YGsd/H6AF88/jJ2A4jU10FPrI+3XwjoxUzgi+eXfQKzGTIqU4Zlr+AMlotOx/Ob
3l91/Qn4Sf4JAUw+9gUlwC/IeWCEAeNrWU6KAhgLAYyGAIQERkEAIyCA4aiAYeQBJBQYAgEMhgBE
CQw6+gGJQYa7Egr0hwTiaAzqRzjQzyQBCQkggkiUgCIBDgiFoQJCOR8gSiAw5wYkwGxIGwmQEEQB
+EEAQgLehAE+63QCUCqACoA0BJkKQAhAmUkASgXYT/SVEMBB9hvJP5UA/BECCFlzXksqxREwCPbV
+TtPttMA9PNPAHYMAVYUXHFJLLvYYVHB6Y5v7TvRadLeFkUAQyCAAetruvUVAsjhIFBW1SORWZUM
Aql8Ijyrojsbep8JySh/DuC/EJhW/kpgankPrj0D08uFANz808q8/FPLfAG/FfAHAXjJA0RwjcU4
BFQxCBsKCYzCxkkeAO8/FdMJYO3RRTQA1Y1i9JckADmIpAigjzLx/pgCvpEINHsApP6PKfAzCkwI
QHIAYioBiPz3JgnoCwlYZG0YJBAgy0W3sE4cAgiBAMIAf8TeM5SozmmxEEA/8f7I/0EFV7RhxeL9
r+P9b2rjqm7h/W8D/ne1aXj/GU0QwPEPtZXnP9eu/PZv2m/+9n8ra1PW+2dUwE8E/7Fv/66tuf17
RoX9Fo//W23ZVZaDYItZD6bkvloYAvBlhLjh9QX4MmPQBP/bgH8m4J8hewaP4/mR/dO42sAPAUxu
YDy5EADSdiLgnwD4hQAUCdSwrxASGFPJ7kJUwKgyNhhDAGLDUQLDhQggAbHBHAwSMhgICQxQ+QBI
gHAgDiUgJKDUAKGAUgLMBoxABYRTERASCCEhGGTLB9zQ/CEBK2GAhTyAHyVBv0TAz+ZfH1EABgmo
MEBIQEIAqgBiEga4ShhgyH8bASyACIj/1VAPSnn2jT9KAbRXAmzTFXhS65tyWcn/EcyOeGFS4tb7
NACZ8b+MAO+K/edHgNmTQHzFOZc15RcZB36+44yDJzqOpw141Pb6LsO2kATcWNuN8t+DMTmEANko
ACGATAggo5wyYPkzoenlNAJVvKgIIF0IoOyNgLTy3v6p5W5cPSECH2tamcWaWh7kDwFYUssjLGnl
VALK+/E+yz7KhlpSKkagAMZIGID3n+qbWDLDN6FoNgSwkITf+/OKLmmrqtigm078b4JfroQDEgKY
VQBX7l2T8f5CACQC3Uj+Sf3fJABPI/kn4PcRBYCyUARACBCwuVEL5ohxCGvGxPuH7z5NXfq0FoP8
V96fAaQD8i8hYSEAwD+SzP+Yipsk/vD+dXeR/u9p0xveV95/y81vtM//8n9s4P+XCeAngP8zavu7
ODy08rqMBheP/xttKZODZHrQIlkUIoA3QQ8BzGOi8DwZLMo2oTlqndg32mLeT0cx7OA8wO73/qgV
cChILN+wvA//pOV9oNsRZgQc+QB778/a4fd123XrD9pG/vxGmolyqSzk0Esglk1JMZvkYhbnCbJo
Kc6kszCTcwXpzBRIJ9GYRpdhKoNFUjlenHLqOy2ZcmMyewSSaThKJP+QyFHjBNTHQiYLTZYpQpIX
gARCKQsGowKEBILoCQigIuAPAVgJAxQJQACSC/CFAJQKEAVgVAKkGcgkAFchADGagAT87RJAOyqg
Xe9v3wBEAnBEjj4BOIgDZ0+GjX7brgHol5sA7KgA4msvuCytZhowfQDT9h/vOI5RYCO2H2MWQB2z
AGq79cuFANYTAmSLAqiCACqeCM2s6A74nyEEeC4oreLFoPTyV4LSyl4LQgFICCAEgHkBel9rSrnF
klIeBPgVASD/Y7gSBpQP5Mrgz4rheP/RvD+e1V9TfBKLZ/isy5vjs+bwfBqA/ncK479YVEpZB7Db
vD8EYAf+1gqAUQUg/ndTPQAk/iACD4n9aQDyyq5T3l8IwMJKMfH+/hsbtCDx/luPM4X2hO79d5+i
Pn2GU2tn6Vo7p/U/chHpf5lk1lXk7HU82w28/03D+9/F+7+rzT7+kVb/xR/bAP83f0cBGPZPq4Af
IYAr/+u/tRSODS83QL8EwIstll0BzBJYcPEbvL0MEgXwHDMWmwv4lddnzuAqlMFRQN709d+VNX71
d63B3r7kNXaM8wI2+5x7w+o+/ZtWa9pnf9PqPv+rVsPcwBr2Air7+K9atbK/aFUf/UWrNO1D7iGS
CtMglHKx9/7UamwULr37vVZ6509aCePIxPKu/1FbChlEkxgMRQUEMygkWPIBHBFWuQBOCFqTWMJK
LsBPCIAqgCIArD0CcMP7iwJwNeS/IgEGf/S2VwCOBHC/ur/dASAPpgNP33FHyyEv8qtYAd5eF6C8
l1pz1SW+8kaHeVQBph863nHC7kYagRq7DN5a1zVuQ223mNxqFEDNw1HrIYAMQwFAAJIEDE6rfBbP
/ALe/2W8fw+8/huBqRW9A9LKIIBSj4BUCCC13GJNKQskHGirAFIqIIAKFn6WD4ckxliSSif4JZdO
Rv5P91l3dLbHmqPJDAvVNrTQV7+bZR1rTfnv4P1V9t+I/VUZ0L4CYBCAEf97CwFgvmwNVgQg3n+T
TgAh2/D+249zIOUEDSmn8P5nSPydpWvtPLH/JZJXuvyX2H9M5Q1ifwig9rY2pfaOtvrcp9rd3/8d
8P+Pg7USwI8RwW8IDUz7KWQh8X4Z5wdWXmU6MLYcb78MwC8F+EtkdiD3iwD/QoC/EI8vw0UWAP75
3M8H/KsZLHr0o++144D+OIBXxn0L12bTAH4z1vTl39oaZNBkZw0Av8EkBe6PyWtIoN40iKBW2V+0
WohArAYiqIEEqiGAKoAvVomS0O1PWoUYZCBW/u73ykoZUFIqRHDrj9oejigPI0QIlf4ApQKukwtA
CaRd1awoACsEYEEF+FEJsOUBUAAeRjuwqQDcjBDgxwmgbRJQHQC6p/W3dQKQlRVgK8hzLGHt22tL
Dtz61TUACfj7ba7mJOCHLivKhADOd5y2r0VXADtQAJtru3IQqFu/9bWSA3iIEOCRiKyKx+j/f4Im
oKdC08qfJgH4bHB6+QuA/mVUwKuEAq8D+l7+KeWuXIUAvFECigCI/0MAeoQlpSwa0PfDBqIMhvLe
SH42Bu8/kd1/U3wTCmf6QgBuawvy2T6sEoBxm9nqu66Q5J8kAPUkoNn9J8k/kwDcIAA38f5SASAH
4J4u3p8qgCgAEoDekgDMgQA2CAGwOjy3Afnf0Cr/if8jdzK9dc8pmlMMAjh8gWQV8l9KfxDAKOT/
WMA/vvoWyb872t7b32pf/1UkvyP4eW2nAO69/3+036qftwL/p95/+Kf/o219n7r+te9Yvf2tthyw
6+D/RtkS5gksufC1thjALzr/lbaIo8YLuV/AWPH5yP0NlAKPf/037SSAFzuh7G92V7nHaB467miQ
wXHDWrjaWxMkoNtflQkJ2AwCOIbVi0EAYiYZ1EICNWIGEShCgACqAL9YBeAXK4cAxEpZPFoKCRxk
OGl/qgSh629oISQEg+gLEBLwT7MnAFQA3t9HEoFCABIGmCEA4HdXHYGiAHT5L96/jQJQ8/4dcgA/
oQU4KuGilkuH5CQmRb88Myf/V9cAJAQwai8TgQsuuqwsPt1hbt7pDtP2HO84ekdj52Fb6rsM3iQK
oLpb35zKB2Oyqx6Kzqp+JDKzUieAjIonQ9LKu5MAfBbZ/zz2EvYqYcDrKIGeAN/VP6XMAxUAAUgO
oCwQuU8loDwcwEdzTw6AUmAKlYCUcnoBykcLAVhSSqf6xhfM8F17ZC4x/oU3D5/VUhtucYiCAaCO
BJAACdAU1Ce+hBHQZYBewG9HANIEhAkBeFL/95bFoSQBffD+fgYB+KMAAon/g7YRAuwQ73+c2B/5
TwIwlrkD/Q6e0wZAAEMo/w0vvEoi65ou/ytvatPw/o1f/KF94AsZ/N20e1WAAN/Rfir4z3z3Ny3h
hnh8AT2Av6IDfjGAX8I0ocUAfiFDRRZwzHjBmS8BPBOG2CRkWu7N3ypwCwGI6cDXwW7aPaAXErAD
frsEAPBbDAJotCOBJjsSEAJQJGAQQB0qoNYwRQBYtUkCBviFACpNEjAIoAwCEBMlkNLwrRaWe1MR
QHDWdS0w45oWwOEg/2QGx4gKoBKgCIBuQE+68lRTkLQDcyJQvL+7qgKcvT8B2JKADgrgvhUAvQFo
SCYrwIn/Yzhh+syQeat+oAGovRXg9xPs/973R+057pJScdllLcNA3jl8hhwACmBHc+cRW491Gbqx
uuuA3OpusesrH6QE+FAUVYCIzAqVBAxLL38qNAMFkFbxDAoAAiiTEMBQAGU98fp9qAKgACCAlDKa
gcr8IYEg7kMtqWWRJP9iSQb2A/gSBgzjOtKSXDLOklg0yTehYJrPmoOzpQFoVeU1bT4NQJAE8b+d
ApAEIOB3FfCbBEATkJsYCUD3VOkBEIMAyAG0EgAbhNfX4/3rlPf3V9n/RuR/s5L/4cj/SCP+73tA
j/8HkAAcUtCWAKbh+a989+f7g78NAbRVAu2B/6coga84NHT04z9qy658DeixSwBeAR8PL6BnotBC
zhos4KThOzJjANDPY5+A2Fx2C8xlxHgqsr/lq7/awK+ALkTwA16+PeDbv9dGBbRHAhDAPSRATqCe
cECpAJMECAdMFaBIgASjqQCq2EBUidlUAGFAGeAXK775vTYAFdBKAIQBJgFwTNhCCCAE4B1/URGA
JwTgIR2BqAB3gwDcFAG0VQGts/31Of/2R4Dvkf9thoDoE4AnbdEnALvTkdrtudcH2TUAyQpwmQD8
864Ab4865h654JJYd8llUdmlDrMZBzZ5b0vHsTsJAbY2dBmyuY4QoKpbv+wqQoDKh/D+j4Rnlj8W
mlGBAih/MjS94umQ1IpnUQLPB6eWvRSYWialwNfw/j0BOonAMnfMy5paSh6gzEoYIInAUO7DIYgY
FQaklPXnOkTlAZJLR/slFU1A/k/1Xn1onhsPbj3x/+R9rOVStX87+Q8BuAoBmCRggl8RgMh/PQTw
MAjAy+gA9CEM8MN0AqjXApgtoMf/BgGwdCRy90kSgKfpUz+rDUABDDpygZLVZRTAFW0kFYBxFTe0
5s9/wPOboYBNAbRVAzoB/M89CsAkhvaUwJ0//G8t8+Z3DAj9CtDj5RkeslhGhwH6BXLASM4ZnP4c
sHPM2AD8HEA/W8aLY7OwuWwYqvnsz4AdAlAmwLe/2r3P3oHjNhPvL6/bUwH6+4oEDPDLtfkLQC9m
hAJCACYJKBUgBGCogHo7FdAmFLALARQBSBhgKAAJA5QKgABKb/5Bm87ZAhUGZLejABKFACQPcJFE
IEYzkCIAMXsCEBJYpPcBqEqAXQlQDwEc+v/tS34OHYA+NADNP/CeFl/2ofb6yrxvHeL/X2YFeHsE
MK/osktS/W2XZaUXO8w5cqLjlAPHO47Z0dB5uIQAEEC/DVXdYiGAmKzKh6MgAFEAeH9RAE9KDiA4
rezZ4NTy5wH/S0GplALTSl8LSCmFAEqFANysKaVegNwHEqASUEoYUEYvQKmEAVHkCfri2SUMGGRN
KhlOEnC0b3z+BN81h6a6r87LjcRDbyD+H7qN7T1rxfsbCgAykI5AnQC4JnC18/5tCEAqAJhXZhUh
QA0bZQwCIA9g3VCP/LdPALboCoAQIAYCUCEACmCwSQAlV4n/r2m7rn/1w57/RwlAwG9vejjQNkfQ
ehz42Bd/1lZextNf/ELZIo4RC+jni6dXoNc9/BwmDCmws1FoNhuF5Po2OwbeZr+g2Ibr35Hc+6tS
AC0A2naVe/O18TMFeAB8gqtYKxmY9wYZAPDjWHsEoEigHQJocCSANiqgNRdQTblR5QEAv252BCAK
wI4A5tFbYBJAEPG/KICAFCMEoCLgJ/0AAn68vxCAJ81AigCI/yUEUApArE0OQD8HIOC/LwHcM/1H
nwAUsva8lkoPxFushnt13rYGhwYg2QDk2AD089f/hRCm5p9mHuBdlxUFlyCAkyiA5o6jtx7TCWBj
bde4HAggixAgu+KhyKzyRyIyCAEyyh9XIUB6KQoAAkgrUwQgCgDJ3wN7IyClrDck4OafTB4gpdQH
s+DhA/D+wRBBGInACMgAFVAWx/1AS1LJMGykb3zeOLz/ZMBePY7Z/0IAzCCwEYBUApQJCZAIVKZC
gFI8P5YsZsr/SsBfocwHAhDwKwIA/Jb1BgFsOsbsORQAXYChVAEijBCgDQEQAgwtQgEUX9UmV9/U
Pv3+v/8FAmgLfj1PcG+OQN77jETfDkaELQbwiy98jrf/HOB/hrf/DNB/ps0F/DromSiMvQ3g35KN
QoB9JhuGZrBfcHrTp9r0RjYNcV9Kxr/5y7/YrAlgm6YIwDAb2AFwm3t5jbU4mBCAIgEHBfBDBNAA
6MWUCkAB2HIBdslAFQaYKsAgAVEAFYC/3IEA3qapyEYAma0E4C85gPsRgIQAigBoCDIJQEqBtiTg
fQigPdDb1n/pBBCXpjcADWGPxPPj16w34v9fdgX4/bIHiQ0fuCwsvNzhrQMnOk7e2dRx9LbGzkM3
13UesLGGJCCdgNmVD8TkKAJ4GAXwKOB/nPj/idC0su7I/2dQAM8FpZS+GJRW+kpgSlkPiOB1AN8r
ILnU1T+51N2aXOIN+P1QA/5YkDW5LBRVoBNASpmEAUIAQy0JBcMhgDE+K/dN7kUD0OLSS9rKiisa
B4sAfIEOfBsBCPiFCMw8AMAXElDJQMkBlKswwIOmIE/+vHcGBEAyUIUAnCgUAvAXBSAEQBtwCMeA
Q2kC0gnghBa7V68CxB08yyALCQEuUQG4ou248qUOfk70tZv1d6wEtBsG2IcEjvc6GVz+3d+1eLy+
Cfr5gP4dQD8PoM+1A/zbTBUW0JuAf5ONwtNl7qCMHGfV2LQGrvW0JbNivPELwP8TrAWSEKDfzxwJ
wHwtgHe0exQA3l8UgCMB6GHAnzX7EEBVBOwIQEKAyvsQwBhOEoYZIUBQOk1jogBIAvonXYYALtMU
dJEkoIMCsOUADAKgCqAUgFIBBviNBGBrDuA+I8Bs+wCYV7HwpDY6V28AsjJ67nHrgKk/0gD08x8A
MslgRcktl6za6y7Ly893mHXwVIepe5o7jt3e2ImDQJ0H5dZ0kRAgZn3VA9GogKhsCCC94pHw9DIU
QNkTIamlT+H9nwH8zwamlrwQkFryMvK/B8AnD1DaMyCppA+vhQC8IARf/+QSC9dAkn0hyH3CgLJo
XveVPIAlqXiwX0L+cL/Vh8b6rtw7mQag/8lovKXNOHSKuA2gr4YAaAJqQwKKAAwFQFOQAr+ogKQy
wC9mEAAdhD6UAwX8PowTMwnACgkE0gSkE0ATgyibIQCqAMwejGXwiI0A6AQczD7CoUVXtJNffq+D
vz27HzH8AyTwNf/doo/+F4m8z7T5pz8F9BwjlhFiMkdQjhYzVagV9OwTYLGIAP5N9gwI0Kce+4iu
RBaO1H2oTWLzkG4faEv48w2f0+xjGmGF3AspmGaSQwvvOVqzePn7KIAfIgD5c02f6fF/kwl+gwDs
cwDtKYAaqQJAAJU0A0kCUMAvJt7fXgEcoB8gil4ARQD0AkgIcA8BJEgVoJUAbDmAexQA4GcASCsB
GK3Ado1A7Y4At9sB6LnkjPb27rtaRtWnTAAu+S+w9uuZAOyoApYfZSNQ9WWXJaXnO7x9+GSHSbub
O47a3tBpGApgyPrqLnEbKrvGigIQAsgsewjwPxKWXvpYaGqpKIAnQ1JKnw5OKX4mMKXkeUD/IoB/
JSC5uAdgf8M/qbS3f3Kxm39KMWFAiRdxvh9A9wf8QdyjAkojsRgy/3HWxKKBfmuPDvddfXis+8pD
qwLo2tt4/I42ahdru9fkM9q5kCtmrwLaEEAJBCCmhwHulAPbEICEAEIAEgLQCKRCACzAJABIwEYA
JAGFAPruP60UwADyAIOkEoAKeP8PNPvcjwB+TBXcjwgM1fD+H/9by7r2tfaOAP6kGIdIOFQ0q+Uj
QM/pQqYLzWTGgA76DwH9h9o0gD65HpAzclyAPkHZ+/pVRpGziGQ8tgSlcOzTPysScDQbKQg5fPYX
knf3EoAiBE4XNgNmsRYxh1DgHgVg/K5JAOL5G8n8NzrIf1sIQBVAKQA8v837mwRAJ6AiAAP85UYZ
sIz24xWcO4ikDBjGzgAbAZD9tykAkoB+qgyoE4CnfRKQMwG2HIDqAxDw2ysARwK4zw4AOwIIXH1e
W8Ohp4V5t7Uei/ZdcYj/f9kJwI4EsLjgkswCcOEcQIe36QKcuKex48ht9Z2G5NZ0HgAB9MuugAAq
IIDyB6PSyx4Oz4AAUksUAQSnlD2J9++OiQp4PjC59MXAJFEBJUIArwP+ntbk4j7WlBJ3JL6XJbHY
B7MA/gBCghAs3JJSEuWXWBBrSSgc4LfmyFDflQdG9Vmdv2/YjhZtYwurtHOJ/1dDAKsLFQkwHagt
CXAgyNUw98RinQAYGe6OElAEQCjgKQpACEBCAAaC2BQAIYCqAsg5AJUHMBQAjUCxe09ofclB9GMT
UX+6AQcZvQCffP9f2rcy0MOwNmTQXiPQT3zv+Jd/0hadxdvLKUKZIyCgx96SuQIyXIShotMF8IB9
KmCfAsgnM214ogI7xiCS8YwjG88egnGVjCXDxlawf9CwGaweP/bJn+jQ+5PWaFiDEAImrxuoDjRC
AM2iCoxrE4BXBim0iHGvSMAwBWwBubxvgN0kiGY8vpj83GwEEvA3kP0XAnD0/nX3k/9GEtCmABy8
/yG8f+yWm1oE3j+UHoAQ4v8gOgEDDQKwMo3XIlUAmnJ8WM2lCIADQR4i/21JQDkMZPYBQACKBMwQ
oC0BtLsBWMl/cyU4PSRqAjBLUnapFeAHjAYgif9lBbi5AejnXQF+v/h/SeUNl2Rs6dGzHd7a34IC
aOw4Zkt95yEbazsP2AABrK/qGgMBRGeUPxiZTgiQVvZIOAQQllZKCFDyZHBqSfegVAggtfT5gOQS
FEDJy3j7VwNSil/j9RsQQW8kvxsE4AHwUQHFvpg/7wWiBEIJD8ItiQXR1oSifj6rDg72XrFnBMd8
z7ydd05Lrr2uUWo0CKDARgAmCaiyoDEbQK6KABJRASYBoAI8hQDSyvUQgG1CPrQE+1ENsEgVgFxA
AKXAIFqBg1UvQJMWvr2ZEOA4U2lQAOQB4vaf1fpTDhxIGDCEqcTXf8NabsBv2k8igh9QBl8wJ2DX
LXryOUegQC9HiWWeADaDo8XTGS4yTcaLGaCfxLHjicwcHF/NFbCPF7AziHRMBfMS2T04ppz1Y3Y2
ivdG8Vosn4TisU+/B5Df62RgZ42fGiQgRGBHBkIIpgkRNIt9amd2hNAI4BsBvDK5V4bHNw3gC/iP
GYk/0/PX4fUdY/9qAb6YyH8j9neU/yU3/qCNlbHi4v0dCMD0/joBXIIALmg+tAB7AX4bARgVAEkC
3kMAiwG0zAM0S4FGCGAjABvgzUWgrQQwNPuaIoAIdkx0j5ux2Ij/HVeAP8X7P98K8PsRwNLqmy5r
Km67LMg712HG/hMdx2091nHklmOdGQcOAVR1iYMA+mZV6QogDQWgQoAyEoGljysCSCl5ChJ4OjC5
+NnAlOLnCQVeDEgqftk/qehV/6SS1wB9T+R9H2tisZslERLQVYAfZrUkF6MEikP8EgoifNcVRPuu
OhjnuXjHkJ7ryn6XUHNdeyf/HGe6afhBAZhhgIBfbwhyKAtSCZAQwJXuQNck7pWV6QSA+aSXkwis
VCTgl1mtWcgFKAKQRCB7BhUBEAaE0w8QSR4g2sgD9OVAUD8IoP8RwgCSgfm3v2lDAPZqQMjgHkVg
vueoBHj/GseF15xhQ1AzpwibMAA/A7DLqcJpMlmI2YJiU5gzMEkAL/MGq5k7yOzBMewbHM32odFl
nJNg6/Cokjv0KLCJCBtezJXXw23GeyV3tRVsI6rjxOCxTyABzJEEjgkJKCJwIAMIoRml0My1yTB7
YAshNLVj6ndE8huyX4D/4+D/k2bG/mYJ0EYA4v1v6Q1AJdT+3ypktfhGvL9BAEr+SwLQJv8Bv0oA
QgDxOgF4U/5TJUBVATin5H/bTkBDAaACfpAA7lkHrhOBGweApmy7rRKAMpm68+NPx7XTAPQc7z2J
mROAOnP/8w0AsSeDNYQAyZW3XBYUQgD7OAi0o6HjKEIAzgF07p9b2aVvViUEUNktJrPswagMyQGU
kwQkB5Be8jjgfyIoueSpoJSS7oFJxc/g9QkDigkDil7yTxQCKIIAit9A3vfGw7taEorcufe0JBT7
WBNECRRZIYRAS0J+KId/InxW7I11X7p7nCdlPJH/43c14/ULFAH0IQnYhzCgFfjGvVIA0hXYGgrY
E4AkAyUM8EYFeEEA3igB3yxIALNk19gIIETOA9AVGEo1IIJqQJSQACoghp6AvlINIA8w8Oh5bUbV
De0bjvq2pwJMNdCuKrAnAu5L3/+d9nbTe9rMhne16eoo8XsK9NPw8FMB+WRsIqCfUHkXL38HL39H
G1t+W9kogD+y9LY2ohiQF7GCDBsmxuthxVwLWUjKbkIxuVdWpP9sM92D9XQTHoMIhATsrV5IwSQB
OzJQisAIFxo+gQQcTIDeIPJerua9AfxjXJUJ+Mn0H0Pqi9xXhucXM7v/aqj7i+dv1/ubsT8EkHft
D9okRolFbLqlvH/4BpQix27t5b9/8mVOBEIASH8/OgB91gB+mwJorwnIPA1oRwCm9wfUvbHWDcDm
CnDT6xvXRWyRlhXgTDlaLSvAlx/5xKEBqBevf5kV4PdTAAlHLrskVFxwWZDPOYD9zR3G76inDFjX
aegmcgA5FV36ZVV0jc4s7xaVWfpAeGbpg2GppQ+HpxY/GpZa/JhBAE8GJBcpBYDnJwwoehHwvyQK
AM//miWxsCfW2y+x0BXz4N7LL6HIl59ZLEmFAb4J+UH0/Yf7rt4f5b18V98+Kw8nxdCfnwsBcBaB
Ta4CftOoBAgR2Ly/2RikE4BbYpEyRQCqH0ByAToBeDFL0EsagsgBeJMLUCQAAVhUGFBHGKA3BSkV
AAGEcy4gChUQwzCS2L0kA8kFqGTgoXOUAj/7SQRgTwimMpAcQtaFz/Dsd3UD8FPw7JOZKSg2UcaL
AfgJjBobz6DRcQr0TBxm8OhIdg8ML2b/ALsHh7KAdAjXIWwhHso+wiH5vMYGs5l4EGvJB/G+aYO5
H1JwS9kwSCGTBiKTBIQI6g0yEAJQJGCEBkoNiPFahQgAv+FjTK52doz3Gk1T7+ugV78rBtgF/Pag
t8l+I+HXBvzI/jbSX4H/j8r7pzEbYIAMBxHw27w/4IcAxPurFmBpADLKf7723h8CEO/vIYk/xxJg
mxyADnh9JLh5ry8EvScEkJ9LOKB+j2PklBszOf77ploBvrnKSAD+eiYAOxLB2vKrLitLz7u8c+RM
h+n7mzuO29nYkSagTkM2VEMAlRBAZdeorLJukUIA6WUQQMnDISnFj4aSBwhOKSIRWPwU0r+7CgGS
ip4H+C9YEwtVCICHf8OSVKAIgEy/GwpACMBbCACzch/om5AX4rs2L8J39YFor8U7BvRaXVA+iez7
epaARmVVQgB5EICYHREYBKB6AzA9FyAJQIMAyAO4Jxn5ACEAyQVwlsCLswFCAt4sCpGcABuICQVq
CQUoB5ILCKTzUBKCoQwGUU1BigRoC5aTgRIKoAQGUBWQ1uD9dAOa8t8xH+CoBMzX1R/9Xpt9TMDO
BCExwC6AnwjQJ+DhxzFeTNqMx5XpgB/NnsFRzB4Yyejx4ZgCvYCdU4mDWUgyKI9dhKwjH3jkOmO1
uD/M9fA1TH8dJ9ejbCrGBh4RY2npUSz/lvZW1fvaVg4SlbMjQEjAJAIhg7b2J14b+QK5Yo2GCfDF
oyuTe8PqudqMn9Ubnt4EvcT7tQr4yH07r9/q+b9XXX9m1r+AWD+l6RttFLMDo7cCfMAfYYA/dAPJ
v5xrWkgWiT+Sf7YzACL98f6S/PMm+eeNAvAS8Iv8t4v97x//twJfeX9jI3BvIQET9DbgtyqAgXIA
iGGp/Ted1J4btTTFaAByjP9//hXg920CqrnpksBQ0IVHznaYua+lw3gIYOTm+k5DN1Z1pguwS2xO
BUnAsm7R6WUPRKYRAqSVPBKaVvoo8f9jwalFTwSlCgGgAFKKTAXwgj8EAE2+WusAACqiSURBVLh7
WJMK38AggKI+gJ8cQJEnwPfh3sLVn9dBEEAYgz+ivFbu7eexeNvgXmtL3ltScklbWnKBk1x4diEA
RQJ6GNBb4n8jB9CWAHTwKwWgEoFGWVCqASQFPSEBFQZAAt6QgI0Asqs1f5ULQAVs1ElAKgJhVARE
CURSjZB8gCgBqQrEyfmAQ+cVCSxrvKud/+p77RskvZgN+H9pvZckX+WHTOElzh/PMeLxjBFTBsDH
lWJcxwrgeW9MMWPGsJHYCIaOjgDsQ1k3PkRGkAP0oTKOXIyVZAOOXMUuA/IrlCpZUcaKcmUHeI33
iVOvIQFaUeUq1v+QGETAfLpBEMJgCGFIHqRDzmBOzYfaGroG19AwtKYFo4VYbC3nB9ae/EKL5xp/
/Asm83ypJZzA5MqosHhl8h5XMUaHyXsJLdwbtq7lS20Nk4TXNMv1S201I8VWNX6hrWSk2Apsef3n
ypYyTiydCUDpTAJaWv2ZtpCRYhNYqNGXoRoxbNaJMsAfLjX/DTcZBqKDP5ikmw5+Gn9U+6/e/OMr
tX9ifyX9MQV+8f5G7V9d5Siwg/fvYyYAlQIgw28QgAK/SQB2ysD0/q78ubGbOQAEAXizh+Jh16DR
Rvzvy/WXXQF+PwKIZxbAqrLrLvMO0QS0u6nj2G2SBKxVBNAfBdB3AyFABiFARtmDEeklD4Wll0gf
AAqgSK8CJEMAhABI/2exFwKSC5H/hXj/QpH/xP9Fvf0SCvH+hR6EAEr+c2/lGoiF+MQfjfBeezjG
a/meOI/F24fLCvCsBo7a7j/BsU28u40AdBJQBCDvSzmwjQIwCAAVoM4G0CFo9gV4cE7AAwXgLaEA
pUEvDgn5QAJ+lAYthAJWlQugJ4BQQJRAMFWBEEMJqKQgJBDFrMBo1ICEA/2kMnDwvDaQcGAQZDCt
/JqWcfoj7SjZ/MK732pF736nbbz0mbay5QNtLF58TOk1bQye3GYcKBqLjQboo5kvMJIpQyOKmDPI
ceNhCvCYLB7BhgjgAfkA1pENOMhOggOMJsf6spy0737D9l1ibiGLSvdj+9hWvO+qusayiCJ2P/di
+65BYNgBCGE/yqANGRjKgM21Q46SP6B+PSxfjLwBNrzwLnmEd7WRBVjRe8pGseVmVPH72qii97XR
RR+0a2N4f1S+biPz2OqMjch7Txt29H1t6CGuh9/VBh/A9t/VBu7F9mGs0O6/947Wf/cdrd/uW1rs
jtttwb/RAL80/WDB7NwLwusGpl3RCUCOAIv8ZwyY1P6V91exPwSACjBBb17d1FFg+/j/NGVAe/l/
PwIwB4e2yn/v5We0Ofvf01IrWQG+uvD7H2gAesJIAHbj+sslAIUUkhruuKwsuewy99CJDlN2tXQY
u72+4/DN1Z0GbazuTBMQIUA5BFDWjR4AyoAQAAoAeyw0rZgkYBF9AEXdg1QOoOg5QoAXAP/L/skk
ABMLX/NPKnjDmlDQG8ArAsC8aff184sv9Kf2H+QTfyTMZ/WhKJ+V+2O9VuwZ4Lri4NJgBnZuaCax
tbUB8B9tJQB7JaAIwDCahPqQKOwthBAP+DE9KQghSEhAdcADQnBPLgP4VAVUOEA+QCkBSQpWkguA
DHIIBzhzEMDg0QBmBQbRHxBCUjCMcCDCJAHahGNUedAgARUSQARyYhAiGCylwqMXaRu+qA2T+QGM
EBvOKcIRXEdwklBsOENFlcl0IaT8UK5iQ1gyOhiwD8C7D5TNQwA+7tAlwArI97GTgKWkYjF7LjCr
gLXkclV2kdblC5QuMbmn9mxaxK5LTDa+xOvL/M4V9u9hu68qi9kDKey9pqzffohh/w2uNyA2QoZD
NyGdW1xvoxRu8e+6zd/tDr0QTGY+cpf3dBtylINaR95VNuToe8qGmXbkPW34kff5s+9pgw/qNuTQ
uzynd7WB+8XuagMA/QAAPwCw96dzrt8eQL/rjha78xYjwW9r0dtu6V6fY7URAD+chF8onl8Bn6af
IDn7L33/6frBH2n71WN/OfwjmX/kv4B/bSv4ZQqQmflvHQSik4B+ClCSgCaoZUmITga9ZETYfb2/
/jvBHDaKZwLwPEi0x4Jd537VDUAC/pGHz7qkl152WVd2zuUdugCn7SUJCAGM2FLTaTAE0D+7okts
dpmeBDQUAD0AEIAkAYseD0oppAxY9JQigJSi5wISC18ITCp8KSCp8BUhAKsQgIr/C6kACAEUeHEl
/i+0ogwC/eLzQn3WHIr0WbW/r9eyXQN7r87fP4Ls+wZ2AMTmVGl9VkIAYvZEIIA3ycCOFJQyYGCI
dAvqcwMBvzosBPiVGijVPAgHPBgd5sG8AHVGAPOWg0LSKCRVAaM06C8dglIeZGhIMCFBqIQEWAR5
gUj2BkSRG4iGDGIVGVAhID8wAFUwgOnBAyECUxkMkhZiQgWb0U04mNmCgwC42MDDYowaB+gDDl0E
fBcAId59L2BnCWnMHhaS7GYrERa5C9uhWwQrpsXCt58nV3FOC91xXgvedp5GJu65hm67wN/5IlfD
tl5k3fYlLWzHZf4MpLDzCjMPMa6RYruuom6u8f91jfVc2J7rEIJuQgpxB26iOm5htyG82/w9Aex+
ww5wxQYcAMhiB8XetVl/3uuPZxeLA+xxgFxdBfS7bmt9xQC7eHrl7ZH7UdsBPuCP2EyJD0ktc/+U
5Gf2n37mXyb/GMd+Ab+V1l8L03ctkvVX3p/MP9N/VOefxP4i/2UpqDEJWHX+qROAxkhwcxag0QnY
mvgTAjB3A5oEYD8yXIBvvmaADH+XjaxKHyUrwKem7rRrAHL/1TUACQFM2XLOJaH8ksuSsrMus4+e
6jBlb2PH0TvrOg7bWttp8HohgHI6ASGA7PIHqAI8GJlarOcApBMwRRRA8ZPBSUVPBScXPgPwTQWg
KgCQwWt4f3oACigBFrhZ4gsMAhAFUOCPCgji3H+o9+ojkZ7L9vTzXLh9UK81xRdnU/tfV3VFo7NQ
gb+3zfK4xwD9vUZosErKhLr1plwoprcOt5KAB+cFPAkHVJsw5mWUB4UEfDks5Et1QEqD0h8gJkQg
JBAECeghQSO76hoggibm1DdTKmxBEZAghAT6iSoQMkAVSOOQzQC1ALvVBOg62ONYN9aPqcPK2Dwc
C+BjAHv0LpaRCOh3nAWkLCdhRVn4DlaUiTFeOmzbWQX8kK1nyVfgebacJXl5hirGWc42mHaOOQcX
OOcgBkFwDYEUxEK3XuLg0yX+WxACpBCxAzLAFBlgUTshBMggevd1/j4Qwd7r/N1ucL2JGrnJyG4I
Yd9t7BbkByns180khTgkvFg/uSrAYwL4PQbgDeDHco3dgbcH8GLR1M8j8fgR0tmHhW+iwQfgi4UY
4Bevrzy/mvrD2C8BP5l/Pe43yn6c/Rfp70PLr7d0/ZngVwSgg1+v/bdaHwG/MgAvPQBmH4A9AZhg
5/d6tzF+nz83HIUiBBCc1ag9FTFuttEAZB//v8B7v44GICGAGYeYBVB7jXFg5104CkwZkJOAO+s7
Dt1U3XlwblWXgesrUQCEAFmlD0SlQwDpJQ9HpBZDAEW0ApMDSCYESC6kB6DwWUKA57m+GJBQ8DLe
vwfAf90/EQJIKOhjjc+n/p/vaYnP9/Fbl2/hGsDrYN91h8O9Vh+K8Vq2u7/ngi1DaQD6Y3zNNe3t
I6f4AAG1gH/FEburQQJCBIoMBPitZhKAeXUlNFDtw3KISKoEEg5IhcBUAxwekrDACyXgIyRAOCCN
Qr6iBKRbkHDEVAJBnBmQkCCUhqFwiECpASYIRTFARCkCaRySMwTSNyBkwDyBflI5sBm7BdgxICQh
176yb4CtQzGsHlPGFqIowB65nXHkWASbiRXwuYZtPQVo2VO49QxExLbiLaws5xq06TSnGU+TuzjF
ZOPTmn/uGU44Yrln1X3AxnPKAsU2nSes0YlAEYMiAlEIKAMIIXwbRLAdIjAsEkIQIojaCRGIQQSK
EHbd4N+J7YEMlN2yWT8hCNtrwM19rMTxAnQxpL2S99tvIvEB/I6bSPwbSuabUj8cr6+AT5Y/TJJ8
uXh8mfWnJD/JPvH8yH5/GfxJzG8Pfsn6S83fd915HfwmAajpPzr4zeafNpOA7cBvIwDZESihgEkI
94DengTO8N89q00jjMk59mV7E4BlAIhMAPr1NAApAjh8ySWx+pLL8qJzLnOOHu8wBQIYQwVgBD0A
g3MrOQtQ0bUvFQDA/0BEeulDEalFD4v8B/yPhyVDAMh/vP/TkICUAF8A/DQAFSj5759Q8AbW2xov
8r/AA68v8b+v37oCC/dBdP+F+q47Eum96mCs19LdA90W75zqyRjvDc1kxHdyAAjZbyMAIQFFBA4E
oF5LYrDVVLVAkQLe3zw/IOEAuQF3ugTFFAmgBqQ64EVuwFtKhBwh9iEn4EuzkEoOogasMjmIGYIB
HB4ylUAwPQqhqAEJCcKlUmBWC0gSRnGGIBpCiOFqM/YLxrBjIIZrtDJ6xblGsXtAGSCPFLAD8kh2
Eso1fCuLSbYA+s0MltjEopLNrCnfdAoAnwLMJyElMVaYc7Vi/oZZN5zmgBMmV8x/PWSg7Cy/CyFs
gBAgh8BNqANUQRAkELzlkjIJGcK4ChEoMtgGGZhmkIKQQdROiECZEAPXHZDCzpvc30C+iwFuTF5H
874JdAF79DYD8Jt10Efi5SM3X9elPqAPp7xnAz779EJo8JH6fqDy+gJ+Yn1q/f4i+/H+Fhn3JaO/
Sfz5Jhngl44/+8Sfo/c3uv/0bUBG8q897y8KwAB/L5kO9CMEYCXPsJzVZ8tLWAG+9NC7DvG/NAD9
sivA26sCTNt3ziUeBbCsmKPAR1o6TKUEOHZLXUchgEEogH7ry7rGkgCMoQcgEgUQLgogreTRsJSi
xwA/XYAS/+sEEJSAAkiEAJIUAfQISIQA4kX+kwCMz0f+5/tY4wssXMX7QwD5Id6rD0Z5rdjX12vp
roF9VhxaF47cXg8B0IXY1vObBOBIAiscCUEHvyvhgKsQAKZOEZIgdCM/IG3EigA4POSBGlBNQoQE
QgImEfigBnxJELKoVCcBMakSSDjAOvEgEoTBjBMXNRCCGtDzA83KwhkqEikmZCDqwDSZNKzsBB5W
QM7ugS0n+f0TbSxs8wnWYAN4BfrjWvBG9hTmsq5sQ4sB+BOAWawFO24za04LIctxFMsJOhxPcGUn
vWHW7FP8/bEcnRz8c0QlGETANRALyiV/sJHwYBOKYLMYqgAL3wIZbL3Salsgha1X+Tdeg6y4bucq
92Lbr9ssavsNdR8B4CO2AnKukXIF7Arwm24oCxcD6JLcCxdvv56OPs7Rh2BBCviAHgvIYNx3hl7j
F+Ar8KtBH9T6Bfwy7YeGHx/p+CMR582BH0n+Sc+/8vym9DcUgNsyDv6IGSFAu/J/Cd7fCAV6/RD4
KSH2ZvxXX/5+Gxu/1sbtvucA0K8z/hdCmFN82iWHKsCa0gsdZu8/QRkQAqALcMTmKg4D0Qmo2oAh
gIwSDgOhADIgAJqAwlEAoanFTwQnFeoKQEKAxAIIgBAABSDxf0BC/hsBifm9UAGu1vg8T38IgDwA
8X+evxAA3j+M5p9In5V7+nov2TEID7++HyDKgQAYRKr1WnZQ6738kE4EjgSwQkIDwG9vhhpQnYPc
95GcgBCBzBFQppOBOzkBD8IBDxKDYu5SIiQU8IQMvKRXgLHiPrQi+0qZECKwkBuwcnZASMBfiAAS
EDWgmoYgAlUypGIQSgehIgLUQYSQAYtG5Rqx5bgyIQdlJBHDWEASxs8F5CGbBOgtCuzBgD0YsAdt
aFagD+QwSUAOewsBuH8O24vlCvit3FuysUzdfDNbUC6YXDOPE8Kc4DVkkCkGGYhBCNYcgwyyIYMc
wgQbGZxXRBAMEYjZyGDTJYMURCFc4e98mfzDVYjB3q4br+VqGB4+DKDrJvf6awV2OwvbyM8Bu5iA
X/f2gF7q+gr4dPWJIfd1r68v+1AmR3xN8Eu9X7y+Hfgl+ee50uj4UyvAiP0NU3V/w+zB3yr/xfuL
/DdCAAG5kIACu2EmKQB+r5XntBl73yX+/8pxA/D96v8PAr8u2M+3Arw9BTB33ymXnJpbHVZVXeow
//CpDtP2NchhoE7Dt9ZKCNBlAI1AcTmiAkofiMks4TBQMQRAFSC1gCSghAAkAZMLugclFj4LETwf
lFjwIkTwcmBifg8I4HVATw4gz9U/Md/dui7Py7Iu3xcSsJATCLCsOxzqs+pAhPfy3bEeC7cO7LP8
YFIkW3pyGmlhza3Swd+e2chASMDOlkvIAPD5uRCAuic8cBVFIIeJRA0oEiAcwNzpHpTqgKoQSHKQ
vICn5AQUCRAOCAmIEiAvYCMBiMCfeQIBEhbQPRjAdOFARowHsWI8eANHimW2gIQILBtta1QSZN7A
Ro4cY8H8PGijgJx15FwD5QrYA9ezoFQsm21FJJL8M40r99YMFplmNgFow9KbIKlG3TKaqGZgkIB3
ejOhTIvNfNMhhHSTDAxCyIIIxEwiWH9OqYLAbMIDueaSI8CCUAViwbmX+Ttf5u9u2KYr/Huu8m+8
xrZeiEEsV668NoAvPwvdKAa4BegAXwE9l/ewEOneA+hiUssPlk4+KemJzBfQC+DTqekD+la5T6IP
T+9Hmc9Xrf2SvX8k/Kj5C/il3OeNCfjVwI9VRtOP0fCjl/1M768n/GwEAJCVxxfZr8wAv7p3AL8d
EbgR+/fj778J7z+D3opX5m6tB2vhWADmhZkDQCX+N+v/MgHol63/CyGM29LokpZ3ocPqqvMdFhdK
J2Bjx4mUAJkJSCNQRZf+OVQB1pcqAojOKH4wOr3o4SjKgBGphY+FJRc8AQlQBizoHpxY8AxGElAn
gICEvB6B8fmvAfyeeH+SgHnuogIs6/IIA/ItkIG/Ze3hYOr/4d5Ld0eTAIxzXbR7oT9LO4QARm3h
DIACv6gAQwksc1ADyw7zM0xIQMDPtZcN/AYZKBLIsxGACgvsSQAloAhgHeVBIQHMCyLwQhV4Uy70
gQx8SQ4KCfihBCy0EFtpH5bcgBUi8IcI/BlcIoQQBBEEsm4skF2DUjUIZu24vQXJ+2KQRVAOo8i5
D2Q7sQK6AXYr++P8xbKOqasCfQYLTNIbCUkAenoDScoGwC7XRs0nlSvmldKINUFeYvq9d2ozuQ0s
XUhBCEGIwCCD9JP8e0QZQAKZqIEsQoMsQoNM8gSQQMD681wvYCiDnAvYRf6+l3TLvQRxkTfYACmI
5V7FrigLUXYVA9Dy/gYxGnXWX+XPcJ+DAXQxad4JysYyqPhgNtAzS89CU49FJfjEeK28vgCf2r7q
8AP4mA58jJKfAr/U/E3PD/g9VpD0U33/ZvefXfkPENvAL/V/G/AB/FLT+9MCLERg7/nlz0nPgDJU
FMSziDXnmXWfU1mq0Z4IHj4TaIVg5vl/cwConP9/HJMFoNIA9PMuAG1PAch7qTV3XJIrrnZYXnih
w9yDTR2nUQUYu7m68/BNlZ0H0QnYHwXQlxxATFrRQ9FpJQ9FpRU+EpFc8Fg4CiA0mT6AJCGA/GeC
E/KeDxICSMiDAPJ7cH3df10eCiC/jz8EYInP84AAvK1rj/opAlh9MMgXAvBZuifaY8HmAa6zs0f0
TKjQ0uquazMPHufDxItLGKBCAbk6EAAEIWFCr+VHdAP8Yroq0H+3D/d9CBMUCSiT3IAxXISwwF1y
AmwZViahAT0DnhCCmBfNQ94QgZCAIgJRA0oRQARUCmxGtUBUgW4mIaAMhAyoIogFsIswAFCL+fNa
zJrJViIIT10BulUBnX0FpqXWA3qMq0/aMUCPpRwD4PW6yb1hnkkNhDCNNmslg2beE1KACFKFCE4o
IvBJPQmxcXJNiEAMErBknFFk4J+BZZ7jXjf/rPP8fS8YdpHrRdQP5AApBORACFhQzmU7A9DZzHEU
yzLM7rU/YPfHs4sFpF9WZgX0ekYfWZ8K0FPEBPiU9eTeBL7M9UMBCPDNbb+eAn5j3Zcnk3jExPML
+O0JwCz/SfZfdf/ZEn924BcVIAbo+3AVgJtgFxJoBb5OAD78/4zdelt5/yHbzmgvv7W+CEiZ4798
uP+hBaC/DgJYWnDbJaf6SocEtgPPPXSy41t7mjgSXN+JdmDyABWUAsu7xmWXPtCXECCGEEAIIJIy
YERyIWXAgidDIICQZAggMf/5oIT8F4MS814OTMh/FRXwekDC0Z4BKAAhAAkBUAE+XC0Qgb9ljRDA
vnDvZbsjIYA4t1lZQ95YVXhq+uEzSgXEZNAHIMBfahqglnshgqU6+OW+F0pAN4MIlCqACOT3IIY+
qAMVFsg9IYEQgivE4AYhuAkJEB64S25A5QeKIIFiCADjKiTgRaXAG/MhN+ArRECS0I92YkUGXC3s
HbAyZMTKElJrGsqAXYZiFlaRWSAFK+rAylZiZepncpXX+r1FAb3OZr70kPuksLo8hQ1G3Hsns9CU
e2UA39Mwj6Rj9DTUk8Q8hjWgYDC5JjYqE+B7JDYrEwLQDWJNgQjE0k6iIoQIyBcoMoAEUk9BQKiC
jLP8/c9CAGJCBOfbMUghA0LI4prFNROT15mX+F0WuXC1pBuWAZi514F+WfMH5BaxNB3gugH+FDL5
mC+vfXmtzAC97vGR+WKy3APPL+D3ZNuPWvUFGCXZZwP/qlYCsMX/RgOQLQdgLAKxSX9FAK3gdxUS
kDDB9Pj8ebmXCoIvSmM0HYqt0n+LjP6OsvP+ntyb47+e/QH573I/5/yzvD94azGJwA9cshruqDDg
HcaCvXXgeKcp2+s7D99c1WVoblXXgRsqusVllTzQN73oodj04kei04sfi0wpfJxqwJOhKYXdIYGn
IYHngpPyXwhJzH8ZEngFBUAiMO8NrLd//FFXSMADRQAJHPX1X3vUalUKYF+Yz7LdUZ4LNsV5zMke
3HvBtpWyDDSrARWwH7m6BhWgCMAO/CYB8H4vm5kkoF8V+IUg5M+p+8MQgGEGAdhIgMYiRxLQ1YBB
ArQUKzVA5cBHFIEYCUNFBooUqBpgihQMsxIqSLhgSTWNnoJULIVpRFyVUfL0S6rhS86mIqSjTyLH
lHmtjHuvxGr+f8VqCU2wxDpAXkf5sp5KRq0yN+7d4o9BXLynjHt5DRm4xzfR/djEtVmZZ0KLMq+k
4zbzTj4BwWAoAp+UUygdiCDlNGrnNIR0hr8nhjLwSzsLQWBcLennDIMUuLdmyJWDW4ZZ0s7z8wv8
LmBOhQjSuBevbryW90ygq2uybr6mJVLGSzJMvD21fQV6yns68PXNPgJ+D8CvxnqtvKi5CQGQjJOr
6f0F+K4rz9qaf/S+fzMBqAO5NQkoHl5MAH+G37MDvhCA/K40EEEyQfy9JtKxKOCfx7kJ2fz7RNBQ
Wf0tsX8gZnr/17iX5h/z9J/I/19m/v8PscnEDeUuG6tuu2RVkw8oPd1xzpFTnWaxIHTS1rouo7bU
dCEc6DZ4ffkDA7JKHozLKnuoLweCCAkeQw08Tm/Ak+E0A4Um5T8bkpL/XGhS3ovBiXkvBSXkvSph
ACYqoDfmFhB/1BPw+1jXHvGzrj4Q4Ldib6j30l0RXou29oUABrnOSB3Zc+XRlrHM41uPChhBOdB7
NZLepgLsQW/cL+EqCkDIwFADOvj18KGXqAWlBEwSMNSALTQ4ypcERYAa0E1PFqokIclCDwhAFIFM
JvbibIEiA/IENjIgcegj+QKpHgghSBnRNEkkYpJQ9EEp+Cbr5sPGIzHvREyuAnQBvAn6dewyXFcD
8NlszNXDALz7OoBvmNu6OnIXurUSgEkEXA0CcFvXSgQeEIFHAmSQeBwygAi4eiWeUOadJAYRJJ+E
FOQqhAAZCCGknLGzsxCEbooY0s5h521mSTHuU8/zZwAyr31SuRrmKx4egJvWCvbzkKxuXpCAF55f
B74Oeg/l8fXFnsrjS31ftvxyyEeV+cQE/KbnJzmnCIENvW2AL6O/hQSUNzdBz5XkYJ9lgF7MngAM
4Av4ZZpQfzYPLS34WIF/8v4r2qsLdl/o3vfNZYb0D+IqR39l9p+997ef/iPZ/1+H/Lcnheml1102
1l9zSak9p0hgScG5TrMOHO88bWdtlwk7j3Uds7mu2/Dc8gchgodoEX4EIng0NqP4CRTBkyiC7lEp
hc9EJOc/H5FS8GIoB4JCEvN6hCTlv0ZloGdg4tHegQlH3SADj8D4PG//deQB1hwKsK7aF+yzbFeY
96KtMZ5z1g9wfzt9WO+3Mt56Y2Xe//XW0bOQwA2NCUUwLmBcAciXHGj1+gJ8ZbwnVztFIODvRfhg
IwUjT6CShpJcVAlEQgNFDEcUAei5AYMEKB+6mSazBiU0oKvQg6uXafQReGHeJA7FfCCCNsQgpKCM
igKjoWxGnsMH84pnOInYOk4nYp5r2V8oJqBfW8P/J4tNlVVDRJi8ZxIAv6Puec9GBGsggjWtBCDK
wG1dI70PGFd3iEAZxCCKwCO+BTJAFSgygAQgAK/EkwYhyBUiSKIjUwwiMM0n6QzE0Gq+KZBBCpLY
MB9eK0smRhbwyzXJuE/idSKWIAaguPfmXswr/hzPQbw85TsxPL/y9sYyTwG9p5zmE9CbwDdkv40A
KPsp0IvXFwPUbuQCXEUJQAi2CoCAXXIA9gQgoAf8pplKQAhBkosR5Cim7rqrgJ9Fwm8AjVqvzNnS
+IhbyERwFIkFG4k/kf6S+e/Rjvd3PP33y8p/R1XQt6TGZXXVLZfcppsd0movd1xVcqHTkiOnunBS
sOtb+5u6Td117MHxW2sfGr2l6uERm6oeHbqh/HEI4cmBOWVP9c8qebpvZvHzsZlFL0Snl7wclVbU
Iyq18PXI1MKeEUkFfcIpBYYlFniiEHxQCH5B6w4HBK45EAwJhPkt2RrrMz+3v8ecjGFuM5LG9pq3
KVUSglNZzSVKYE35RW3M1notKrWUgx4AVZJ8Sw/YlIHy8oC+pwL9Ia2nUgNiRiiggC+hgYMKEPCT
H3BdeQTA6zkBubqLAlAG+M17Iz+g5wiMRKEkC0UdCBlI9cA0aS4yTUqLEIGXXMXisbXYOt5bBxFg
nmuFAJhgLIBfxyozrm1sDYeX5H2UgXt8NYDGIAbXtbV2hhqABJStq+d9woO1hALrxCAAyRHEkx+A
EDwgAl0NGCSAGvCMb1UDOhE4GETglXhamXeSHSHYkYF34lmIhLq4WDL3gN9L3hNLkKsJet5nSKeY
N2rAW87si8TH+3uSzbcZRODOa3eA76bM9Px6rK9Mav0CfAE64HdFAci9er0CQIsJ+IUEhBBUA5Cd
qde65Bdz40ivB6rBiuKIJF8xlPLl2wfe13KY8bep6WttNgNVJNv/8sz1JeAn1vD8An6Z+iNlP0n8
ifQ3V3/Zl/5+nd7fkQjmF93qkFFxoWNG89WOaQ1XOiWWnOuysvhU1xX5Z7stPHLiwbkHGh+eva/p
kel7mx+buqvhiUk765+auL2u+/ht9c+O2Vbz/OgttS+O3lT9ysiNla8Nz63qOWxDZe8hGypdB+dU
egzOqfAetL7Md1BOuXVAWlFw35SjYdHxB2LCV+7qH7Ikd2jAO5mjLLNSJnrMzVkDaC9E0GyzrIwx
yxCB2PJimi72N2sTdzVgjTabwP0E3tON93fbmXrdpP8u10nKGrHmVtvbwh73Fo3lqDabsu+4NoXX
U/afbMdOaVP3i53Wph3EDpzSr5BW61XuMQ4HTWO0+FSmCU3l1KDYFLnyvvl66v5z3J/j/fPaFN5X
JvfYZGUXjKt5L68vaJM4PajbJTu7zD3GjIBJDAiZdIiVZgwImXIIL8awEJsduqZNZUCIsoM3ueo2
7R67xXu3tWmH73AVa72fzus3D91VNs00jgrb7s33OBY8TYw5ANM4Gqwbw0+VvccILV4zG2Aa5+nF
pogBPHXl+LBuxvvGe5M5TjyZBpwppu3mfg9GT75ud3TDc0/hmPFksZ2G8d7knfr75s/lfirvvc1/
f3nhh9qGhi+1zU1faeu5zmSAilRqXn1nx0kO+iwAM9FGzO8Ifhn7bbb9ivQ3J/9K7G/W/jtw/+vy
/vYk4DH6M5dBhy64zC092WFF+bWOCeWXO6VVXuqcXnu1a0b99W7JVVceTKy8/FBSxeVH1pZeemxN
yfknVhef67626NwzK4vOPr+88MwLywrOvLws/+SrS/JOvr4472SvRUdPui44csJjweHjXvMPt/i+
c6jFOnfPseC3d9WGv7mtMnryhsK4CRmHB49O3j1y2JpN4wcuzprWd17iLN+lOw8zAeirEFpwpwCm
leWXtc3NN7WtLbcMu83VsONc27FtvKfbnXvtROt720/e1e61d7Udp8Tea8fe57327EPe/1DbeeoD
dTVNXpvW9n35Xf33tt9jH/GeaR9z32rbTn2itdqnxr1cddvOVqFW+4x73XYYtpPdgva2Q73+QtkO
Fo7a38vrHWew01/xvvxMrj9k3/Bz7JSdyWt7O/Mtr+3tG56BYSe/4d/6LZ+HYXb323hvGz9Xdhw7
YVxbvuY1Jtc2xs+bxb7WtnLdqq732hb+zBbeX9/AFKRKdjBAkH05j+GWXK29Mm9rwxOBQ2cZwJdS
XygmCT+J+U3Pb4Jfmn7k1N9jmFn3F/Dbx/6/XgIwySA894jLoNzrLm+WXXRZVXKtQ07dzY5bT3/Q
cdOpW502HL/eaUvTu122NdzpsqXhZtfNDTce2NJ0+8Gtjbce3tR445HNDTcf3dp4+/HNjdef2tRw
vfvmxhvPbGy48Rz2wqZjN17a2HD91ezK869nlJ/unVzc4rbuQJX38h1FlgW5h4Jmpe+KnJG4sd/k
FelDxsxfN2bEnJUTnxsyb0KPd3Yc6LWm8HavlOr/rxeZ9HuMMpx6T66ORnWh17/F6vjvOO3f8gwo
f/aymcNnRgm01z1mfOZUU3q1a7SQU11RBmjbNZKuvQzryfUeI1/zBmvpXl+Z/+krszdXPjt0fkK3
p18eDCYkzpcsvwBfkn0i+SXbLwk/iflF9ovntwf/w7w29/4J+H/Z1l9Hqf8reC0sKCYPRh6QyCTp
k5Z56RI7PYO9iPXA5ESVHKzwxoR1pdVS5Jd8IGGYsLKYfFD2JrVZpzmfwQ99Bxy/M/JavksCePlu
yXdMvmvi8QX4vpgk+9yM76V8PyXm/6ng//V7f/4xP9f/5GFITCQkIDJJMqUimyR2khjKJAE5Ty1t
lX0wYV0hAvkg5APxNz4c+YCEncXkA3Oa8xn8I98B87sjV/kuiZOR75a09cp3Tb5z9sAXry9z/qXW
L99T+b6K7Dc9f3txvxP8PCD7/zmqAMmUOpKA9FE/j4nE6oEJEYjsEgYWMpAPRT4cMZFlYvKBOc35
DP6R74D53ZGrfJcktpfvlihP+a7Jd07q+ybwRZ2K15dGH1Gs4rTEeZmy3zHp5wQ/D8fxfyYBmCpA
QgFHEpCHKw9ZWiqFbUVuiSKQD0LIQD4UCRHkAxITleA05zP4Z78D5vdIvlPy/ZLknnzX5DsnTki+
gwJ8cUym15ew1Uz4meU++5jfCf52wG++9UMkYOYERFqZRCBySz4A+SCEheVDERM5Jh+S05zP4F/5
Dsj3SEy+U+Js5Dtmgl6+e+KMBPiPY/ZeX5SrE/w/APQf+tH9SEDiKJFUwq7CsiYRyAcgH4SwsHwo
og7EhBic5nwG/+p3wPw+yfdLvmdS1jNBL99B0+OLgzKBb5b6nJ7/30gC8lDNkMAkAkmyyAcg7Csf
hjCxqAMx+ZCc5nwG/8p3wPwuyVW+W/Idk++afOfku2fG+fcDvtno45T9/wQR2CsB+7yASQSiCOTB
CxkI+8qHIR+KafIhOc35DP6V74D990m+X2LyXZPvnHz35DsoTsnR49sD3wn+fwL85h8xScAsEdoT
gSQJTTKQD8EkBPlgTGKQD8ppzmfwz34HzO+SCXZ7wNuD3pT6TuD/C2D/oT/aHhGYZGA2DwkhmCYf
jtOcz+Df9R2w/27J9800+Q46gt7p8f9DJNCeKnAME8wPxP5q/4E571u/vM5ncf9n0d73yP49e4dk
3v+Hv/bO//yPPYH2PhTne3qLtdP+fc/gx76Hzp87n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A
8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJ
OJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTif
gPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4Dz
CTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4
n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A
8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJOJ+A8wk4n4DzCTifgPMJ
OJ+A8wk4n4DzCTifgPMJ/HqfwP8Pj5iqKRcA/fIAAAAASUVORK5CYII=')
	#endregion
	$ToolStripMenuItem_Powershell.Name = "ToolStripMenuItem_Powershell"
	$ToolStripMenuItem_Powershell.Size = '290, 22'
	$ToolStripMenuItem_Powershell.Text = "Powershell"
	$ToolStripMenuItem_Powershell.add_Click($ToolStripMenuItem_Powershell_Click)
	#
	# ToolStripMenuItem_Notepad
	#
	#region Binary Data
	$ToolStripMenuItem_Notepad.Image = [System.Convert]::FromBase64String('R0lGODlhEAAQAIcAAH6TmkROUr7h6cXk68rn7dHEp4/N2pLO26bX4abP2JnQ3YvDz6zS2rbW3qDN
18Di6pbI1Nbs8Z7M1qXW4afX4dzu87rg6GemtYfJ2Mjm7JDN2qzZ477a4KrR2rvg6Y7L2bzZ4KjP
2dve4NDo7bbe5oC9y0VRVbff54bBzoXCzrbe547M2Z3M16/T26/b5d/p7M7n7rvf6HKvvuf096jY
4p3S3s/p76HI0ZXH06PO1/3+/tXq8Xq8zMXl7Mbk7LnY35HO23y+y7je59Xr8drt8d7v9IbH1HKz
woTI1nW4x5nR3cHk6tLq8JHN25rR3YnK2KPW4JrQ3aza47Xd5o7N2onL2J7T3oTBzoXBzrPc5pzS
35PO25/N1p3T35XI05nK1ZDN23Cuu3qyv8vk6sfm7c3o7q/b5Kva44/E0a/a5Mnm7X6+zfP5+8bl
7K/U3JvM1aTW4Mje47Hb5ZTP3KPV4Ha2xI3E0Nnm6cjl7K7T29Dp75LG0o/F0sHc4rjf6HzE1JbI
06fP2Nfs8bLV3afX4r7g6aTV4Xa2xajN1WmntsHj67KpkJXP3cDi6Xm2xZ/U4IPAzcPd4q7a5JfQ
3K3a443E0YzI1YvE0e7x8ZGEYP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEB
AAAh+QQBAACbACwAAAAAEAAQAAAI8AA3CRQIYFPBgwYHCtxgAk+AQgHkBDAUwJKdAgMVVBCkR40i
Py4m1LiyIJPAGRSI7IDhQ8AUSlCilGBhclOGGHEicWjQIhAXQAvCIKophQCTMmQanTCDoEuTIyNq
KhjSB0SDPCEcQOAD6cKLmkpsEBggQEUaBFYYGamjw2QRGgR+DGKQQAIENCkcicFk8oGQAUssZDkD
R8uWKmtwaDJJZ8ADNx1yvPFSCQsPGTf4bprTxgMJSYQeTTKA4c+hMYvZOOkhgK6DL3suoQiS6A7f
CEieGAACRgOVFQcOfEiiabFCEZiSK19eU+CiTNCjSy8QEAA7')
	#endregion
	$ToolStripMenuItem_Notepad.Name = "ToolStripMenuItem_Notepad"
	$ToolStripMenuItem_Notepad.Size = '290, 22'
	$ToolStripMenuItem_Notepad.Text = "Notepad"
	$ToolStripMenuItem_Notepad.add_Click($ToolStripMenuItem_Notepad_Click)
	#
	# ToolStripMenuItem_RemoteDesktopConnection
	#
	#region Binary Data
	$ToolStripMenuItem_RemoteDesktopConnection.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAu5JREFU
OE+Vk3ssFAAcxy+vwuRRrZHHbV06mS1plLXWNGKpyFhsbDbRmDTyOMuV15GWoUOKedRxNwuZkxvm
zt159HAeseZ1OEeH4w63vPItVv6opfptv/32++P32W/f3/dHIPwIJosZF3wrXPdn/981O/cFLTWb
nRQQkuhFzSipLGDxxukvm/oDQ6lO/wS77B15ISW7pre2VbzZ0CmFaOILuiZWwKjtkFpZ26nvCjEj
konp9FejLaLP4PfK0C9RobV7GgNTq+C+G4Wlla3FHwG6egZalNRnoo/SFbT1yTA+twJ+lwTShTUI
RBMorxJuXL1y0y04KMkvLiY/6iGNmZ6fy86Pp9CpBvqH1Agksp1fx6ASg7I1dA/LMa/agEK1jjpO
D/i8SfA7FWC3L4HVtojSjiUUvl9GbpcKPJFsc7/egcME+3Ou97olKxiaWUP/mALiqQUwqttRVtGG
zNdyWFCHQKaN4CxdAneGDP518whpVoLTp4SRkSmZsE9b1zQiPmu4qLIDj55yEJXIQkwyCzn59Shq
WNgGkJKGcSpzDE6FUniwZuBTPYeanmWYGFs6bmujoaGpf8ScHOTpFz0Qm1KOrOcclDKFqOIqtgHE
+1tbjOJ01jjOF0ziYtEUioRKWJEd3HfE1dLS3hselzeXmsPGk+IWFJRy0SRUwDxhaAdimTICmwwx
Tj4eA61ejjMObv47ADU19T3Hre1jfQMpA3codPnt6EypUDC7PbyV5gmDID4YwVGaBKQ0KdLeKOHi
7Bvx23m3QOrqGprmZie0GxvEX51zymCdWY1rhXLEVy+C0bKEes7IaiQ1+cMxku3uLq1kdc01vu0F
XzC52S6YhoA3jbSUiiGv62EUT48wPyMjk90desk5wPuGz92KdFpp7+zMOj4NqCDkT4HHHQWznLtg
aGhM2tXiaamMPD5PjHbhOFqaBzdLihtm42Iz2I6OrqE6OvoH//pkRAtrKxsbRx8zU7KLjo7B0e+X
0vx16BszmK+MYtSO4wAAAABJRU5ErkJggg==')
	#endregion
	$ToolStripMenuItem_RemoteDesktopConnection.Name = "ToolStripMenuItem_RemoteDesktopConnection"
	$ToolStripMenuItem_RemoteDesktopConnection.Size = '290, 22'
	$ToolStripMenuItem_RemoteDesktopConnection.Text = "Remote Desktop Connection"
	$ToolStripMenuItem_RemoteDesktopConnection.add_Click($ToolStripMenuItem_RemoteDesktopConnection_Click)
	#
	# ToolStripMenuItem_localhost
	#
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_netstatsListening)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_registeredSnappins)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($toolstripseparator1)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_mmc)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_compmgmt)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_services)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($toolstripseparator3)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_systemproperties)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_devicemanager)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_taskManager)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_regedit)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_systemInformationMSinfo32exe)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_hostsFile)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_hostsFileGetContent)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_netstat)
	[void]$ToolStripMenuItem_localhost.DropDownItems.Add($ToolStripMenuItem_otherLocalTools)
	#region Binary Data
	$ToolStripMenuItem_localhost.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAlwSFlz
AAALDAAACwwBP0AiyAAAAodJREFUOE+lk11Ik1EYx4+ZqZmiqYSoiSZGoFREiJIXLYS6yAxGF0lK
aEXlZfRhlGGS9q2uyfZu02l+lKGw+RkilaU1P7eZy8SiiIggIrrRoPp19nohlkHQxY/zcuD5nec8
5/8KQPwP/1XsPXiRoOP+AEsx6nrDiMQxPsPQ6DSOsWkGhyYZdroXt+8tjkuqQwT1IaKdiMj3xGvm
KKsBxQY6idID1j44ctbNqOsFwm6353Z1dWGz2dTTNyTXIgLbEWufIaKmCdn0mZM3f1DXKYvbJXI1
dEPBGRdO9xSira0Nt9tNcXGxKkjZUoNY2YKIeYCIdUnesSNvjovKT0oscF5y2gTa405crpeIlpYW
JiYm5DSEKkjTWPENb0CEt8prSMmaUWLT3pJf9JXC0lmOXPhGXtF3duWM45yQgsbGRlWg/RioCjIy
DYTF1eATakZE3JN0E5DwFM3+V2gLP5B99BOZeV/I2D0wPwOvwOPxoNfrVcHG1EqiEhX8I6oRoVbZ
iZSs6SIpY5ht2inStTMk73zNZk0vI+OTiPr6+kWCqPhrrI6pYEXYDTkLPSJYSkLuEJrYQ0LqAOvS
HaxOcZC01cbQ8HOExWJRBUajUe3AP6Qcv1Vl+PhfwsfvMssCqvBdacYvvJngOLsUdeMT2UH0+iae
PBtbECiKogq8xf/Ko8eOBYFOp1syhUsls639IfbOfh72DyK8rXuvUH7lKr29vRhNZhnx+YSeKy1F
k7WHfXmH2Z6VzaniktnffzxhMBj+Krhltv7cm3OIgmMnyDqYT8PdVs8fAqvVmms2m9VnNJlMVOiV
5mrj7SCltpFKQw3XdUaqTbWUV1SjN9dRJffk9wGltmm5DJ/4BZ3IpG+IT6wAAAAAAElFTkSuQmCC')
	#endregion
	$ToolStripMenuItem_localhost.Name = "ToolStripMenuItem_localhost"
	$ToolStripMenuItem_localhost.Size = '90, 22'
	$ToolStripMenuItem_localhost.Text = "LocalHost"
	#
	# ToolStripMenuItem_compmgmt
	#
	$ToolStripMenuItem_compmgmt.Name = "ToolStripMenuItem_compmgmt"
	$ToolStripMenuItem_compmgmt.Size = '278, 22'
	$ToolStripMenuItem_compmgmt.Text = "MMC - Computer Management"
	$ToolStripMenuItem_compmgmt.add_Click($ToolStripMenuItem_compmgmt_Click)
	#
	# ToolStripMenuItem_taskManager
	#
	$ToolStripMenuItem_taskManager.Name = "ToolStripMenuItem_taskManager"
	$ToolStripMenuItem_taskManager.Size = '278, 22'
	$ToolStripMenuItem_taskManager.Text = "Task Manager"
	$ToolStripMenuItem_taskManager.add_Click($ToolStripMenuItem_taskManager_Click)
	#
	# ToolStripMenuItem_services
	#
	$ToolStripMenuItem_services.Name = "ToolStripMenuItem_services"
	$ToolStripMenuItem_services.Size = '278, 22'
	$ToolStripMenuItem_services.Text = "MMC - Services"
	$ToolStripMenuItem_services.add_Click($ToolStripMenuItem_services_Click)
	#
	# ToolStripMenuItem_regedit
	#
	$ToolStripMenuItem_regedit.Name = "ToolStripMenuItem_regedit"
	$ToolStripMenuItem_regedit.Size = '278, 22'
	$ToolStripMenuItem_regedit.Text = "Regedit"
	$ToolStripMenuItem_regedit.add_Click($ToolStripMenuItem_regedit_Click)
	#
	# ToolStripMenuItem_mmc
	#
	$ToolStripMenuItem_mmc.Name = "ToolStripMenuItem_mmc"
	$ToolStripMenuItem_mmc.Size = '278, 22'
	$ToolStripMenuItem_mmc.Text = "MMC.exe"
	$ToolStripMenuItem_mmc.add_Click($ToolStripMenuItem_mmc_Click)
	#
	# ToolStripMenuItem_shutdownGui
	#
	#region Binary Data
	$ToolStripMenuItem_shutdownGui.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAA0tJREFU
OE9tk2tI01EYxteauAzD7nQzInBd1jLa8jrddKO5dEtNSXOpgZe+hGEXLbtgV9OoIEK8VB+CIuiD
hBgkWQSBqdnmv92nbrOwrFZu/11a29PZgkDzgZfDObzn9573nOcwGLOkKZAzR3JEUkqe0qIrUXbp
y/KfavdJb+mKsxWm2sMRs/NnzIeliTuonDSNrvYIDJcvwdjUBMvt27A9eAB72x0YK/eb9GV54jkh
Q8LtipEihXuotBQDxcUYrqqC/dEjfOrqgqmlBWOtrZh4/BjW5gs+7V6RagZkMJnHUe+V0q8zMxEK
882bGCwpgctshttqhb6xEVN9fRhra4P94UNYrzX+MlQWJf2DvBdyu1+LRXgRH48JkhDSu8JCuEwm
uMfHYTh1KrzmNBgw3tGBj0+ewFCe3x8GDCXz1rzLEv3u3bgR6oqKcCJtNGIkNzc8ekZHYT52DG4C
C+lrby9sd+/CdqsZI4oMPmM4gVP0ViLGqw0b8PXZMwSDQZjLy2FUKuEhAC8BWGtqYGtoQMDng0un
Q39yMgbkWVCn8WoZ7xM21Q1JJeiPi4OH9Oz//BmjEgnsBOD98AFejQbWjAxYBAJ4yNz/4wcGOBwM
ikRQJ226wVAnbq6h9sih4XLhoSgEnE5MymSYIuEoKAjHFAFMpqfDb7fDPzkJiscDtXs3NAlxVxlU
Kk9qzM2Gic/HNHnvkNzXr4POzoZboYCHBJ2TA/rMmb/309MDy65dMOUpQSVtKWHoMgRsozLTMSEW
4zupFpyeRpD0Grh3D4HqagTIxQaIB4I0jaDXi5+HDuETOb4lP8unFwuWh19Cm8o9+6VMBadcDn9d
HeBwhKvNkMuF3xcvhk/2rfQgdMJtd/75YEwmjDRI+W/c1ZUIEBfi6FGguxvQagG9Hnj+HKivR1Cl
gq+qEpY9qfpxmTB6hht7UuIXqyWCPvdxsjnUb3Mz0N4OdHYCxJk4fx7e+hMwyBLf9gp3xs75H1oT
trN6krgVlgMK4/fG06A7WkHfb4fjyjnYSvMmXqZsrb2fymf/tzmKOY+5jMVcsIjFjFnBjly6Pnrh
qry1K1JOctYdaNgcqyqMXZkeFxO9ZnUUe+mSCFZMbCQramXEfGYI9AdHhzFu6obUdgAAAABJRU5E
rkJggg==')
	#endregion
	$ToolStripMenuItem_shutdownGui.Name = "ToolStripMenuItem_shutdownGui"
	$ToolStripMenuItem_shutdownGui.Size = '290, 22'
	$ToolStripMenuItem_shutdownGui.Text = "Shutdown Gui"
	$ToolStripMenuItem_shutdownGui.add_Click($ToolStripMenuItem_shutdownGui_Click)
	#
	# ToolStripMenuItem_registeredSnappins
	#
	$ToolStripMenuItem_registeredSnappins.Name = "ToolStripMenuItem_registeredSnappins"
	$ToolStripMenuItem_registeredSnappins.Size = '278, 22'
	$ToolStripMenuItem_registeredSnappins.Text = "Powershell - Get Registered Snappin"
	$ToolStripMenuItem_registeredSnappins.add_Click($ToolStripMenuItem_registeredSnappins_Click)
	#
	# ToolStripMenuItem_about
	#
	[void]$ToolStripMenuItem_about.DropDownItems.Add($ToolStripMenuItem_AboutInfo)
	#region Binary Data
	$ToolStripMenuItem_about.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAALeSURBVDhPZVNZT1NBFL4/gWcjpkHWImXrBiqCgktACFtR21CKQLEFuriyGBQ3NMDV
FxO38KDog0uiEQMaoyJRA4XbFWjRVgUUSBQX8MGYfM5c4Ao4yXmYZL7lnPMNw6w4YVk3ROE7O9jw
7FtcckknlNqHiMi9zUXm3WEj8++JVr4X7mGZ14MImN2i70JNmxuGFi/Uxz0oaHCioN6BHeY3kGof
I0p1n40qehC0jGgBzOma+lHFjmKj0QFphR1pZhcpN6SVTigMTqRWO6Esew3x7k5OvOfRPxKqTMF7
m72Qltt5sLTCgR+//vAlM7ggN7ohr3JDWe1BYkUfojXdLO+C9pxObFcTZQGsJw6IKgX/JKWo8UBh
GoLSPAylZYSvuLJerNM+FTF0YKY2j2BbugCWGYkqUaNAOQHKCUhh9UKx3wflAR/kJhdidM9Zhk7b
2LpofV5Zus+FpSfaMAxJjRdxFh/iraNIIJVk9UFS9pJj1us6oWny8H0nkL4jS+wI0XAI1TkFjngL
ae/QOyjq/FA2BEi9R0ZjgMzEBiaJ7Fp11AVJKYdglQ1rdg1irZYQlbsFAnmtH8mNH5ByYgybTk0g
9fQEclvHkWy1g6Ehya21Y1VuH1YX2iBScwgrdYHaXjwbjn1E2pkJZLROYtv5aWy/MI3Sa1OIrxrg
GJqwFH0vggv6EFw0gJBiOyKIuqR6RCBIJeCt7BSyLn5BzpUZFLZ/Q3n7ZySYHCxD4xmr7kJscb9g
P0rvQazZJxCkt0wik4Dz2r+j6OYc6p/MIetsAIkW93y0aTxjNT2IUA8itMQJceXQsi3QS/alGag6
ZtHw4jdq7s5AetA7HySegGSbj6f6FcIXCOjKFHUBpJwc5+3nX51Bbfcsqm5/hezIW052eHT5f6DZ
jtZ0sWJtD6LJOuWkhc0NfuScG4P28iQZ2idkNvt55f/AS38WjWeM7hlLQyIz2pBk4fhp04EJPS8B
/AUcqjGT/IqHlwAAAABJRU5ErkJggg==')
	#endregion
	$ToolStripMenuItem_about.Name = "ToolStripMenuItem_about"
	$ToolStripMenuItem_about.Size = '69, 22'
	$ToolStripMenuItem_about.Text = "About"
	#
	# ToolStripMenuItem_AboutInfo
	#
	$ToolStripMenuItem_AboutInfo.Name = "ToolStripMenuItem_AboutInfo"
	$ToolStripMenuItem_AboutInfo.Size = '211, 22'
	$ToolStripMenuItem_AboutInfo.Text = "About $ApplicationName"
	$ToolStripMenuItem_AboutInfo.add_Click($ToolStripMenuItem_AboutInfo_Click)
	#
	# contextmenustripServer
	#
	[void]$contextmenustripServer.Items.Add($ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Tools)
	[void]$contextmenustripServer.Items.Add($ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_ConsolesMMC)
	$contextmenustripServer.Name = "contextmenustripServer"
	$contextmenustripServer.ShowImageMargin = $False
	$contextmenustripServer.Size = '79, 26'
	#
	# ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Tools
	#
	[void]$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Tools.DropDownItems.Add($ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Ping)
	[void]$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Tools.DropDownItems.Add($ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_RDP)
	[void]$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Tools.DropDownItems.Add($ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Qwinsta)
	[void]$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Tools.DropDownItems.Add($ToolStripMenuItem_rwinsta)
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Tools.Name = "ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Tools"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Tools.Size = '78, 22'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Tools.Text = "Tools"
	#
	# ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_ConsolesMMC
	#
	[void]$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_ConsolesMMC.DropDownItems.Add($ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_compmgmt)
	[void]$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_ConsolesMMC.DropDownItems.Add($ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_services)
	[void]$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_ConsolesMMC.DropDownItems.Add($ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_eventvwr)
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_ConsolesMMC.Name = "ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_ConsolesMMC"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_ConsolesMMC.Size = '130, 22'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_ConsolesMMC.Text = "Consoles MMC"
	#
	# ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Ping
	#
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Ping.Name = "ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Ping"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Ping.Size = '117, 22'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Ping.Text = "Ping"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Ping.add_Click($button_ping_Click)
	#
	# ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_RDP
	#
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_RDP.Name = "ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_RDP"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_RDP.Size = '117, 22'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_RDP.Text = "RDP"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_RDP.add_Click($button_remot_Click)
	#
	# ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_compmgmt
	#
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_compmgmt.Name = "ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_compmgmt"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_compmgmt.Size = '202, 22'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_compmgmt.Text = "Computer Management"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_compmgmt.add_Click($button_mmcCompmgmt_Click)
	#
	# ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_services
	#
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_services.Name = "ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_services"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_services.Size = '202, 22'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_services.Text = "Services"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_services.add_Click($button_mmcServices_Click)
	#
	# ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_eventvwr
	#
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_eventvwr.Name = "ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_eventvwr"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_eventvwr.Size = '197, 22'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_eventvwr.Text = "Events Viewer"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_eventvwr.add_Click($button_mmcEvents_Click)
	#
	# ToolStripMenuItem_InternetExplorer
	#
	#region Binary Data
	$ToolStripMenuItem_InternetExplorer.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAA2BJREFU
OE9jYCAClEXoMp+aYB0xL1O6I8WOvTjWnDG9xJ05HKdWg6gmFe/KZUnhLetrFkxvrD071fFKkLNq
jpC0IgtMU5INqzUfJwOcDxY3yZqlmDjt+LbS5Vf+1ay+9P/M1u7/e2ZE/i9bdPB/wfLL3yL6dk1Q
8UznBqn11mPW5GRlYIa7wrJ4uV76/PNvcpdd+1+z/sL/uzuq/q+ZV/i/cNv9/3lbHv7P3XDvf+66
u/8jpx44I2zoJagqzsgB1yzllMIWOf30zZRFV/5XbDj//+musv9L55T9D55x6rfXhIPvk4CaUzY+
gGPjnGkrUfxvWrYqNnLu5f+Jy6/8v7+34f+q+QX/xT0qdzOwC4kzsHKzaMa3pEeuvvM/cv2D//Hb
nv6PXnvnL5emiyHcEIeuQyt95179v3vHrP8HFsX8D1x/47+IT36BbFS1vVxYlb1K5lRP31V3/wds
fvQ/cf/b/6kH3v9XiWruR/i/58TxuhXb/j9aE/w/bPPp/6En3v0POPbmv8fe5/+dtz7+77T58X/X
HU//Bxx49T/p5Of/mad+/DcvX7wfbgBv0fZ9D7bm/8+c3f/f/cTb/2Fn3v93WXntp8uKq9+tF1/+
ajrn4hfTWec+Wc05/8F14aV33gsvv9XLmoEwoHFSz4xts0L+My66/V/y8Ov/Rife/GdWtnVmZOdj
ZeTgZ2U3DRFgju7JZU6ckM+WPblANKenSMQpyQXugtfrIo479E79z7D68X/eY6//C55595+1bvVi
Vp9CVk7vEkbOjsv1DFPu/2dY8vC/5L7X/413vfwvap9WAjagNcVM5vIk0+fsOTNWMWx8/p8d6AXO
8+//M+x7959x2fOvjHOefGBY9OI/65aX/5XPfvzvcuX7f+P+w49Y+ST5wQYsrbT1n5wgvoJdw4Kd
oXn7RtbT7/+LPvr6X/zxt//8d77+F7jx9b/83W//HR7/+h/24Nd/x8WXXvMoWVrAnb+y0iys1pej
FSwgqsLMEtVYJrbz1lvt58CQ/vD7vxMQ+778+d/75Nu/2gWzN3NKqCujJKK2WCXtA+W8RzMcWDlB
EiWeHJpuhvyhQqomfgLWUUkiLqk5Agb+EWzCCopMrJyMWHNgXQBX9tRY7sVF7pzN2lJMlmwsDExE
5HKwEgChzpVxZmmPXQAAAABJRU5ErkJggg==')
	#endregion
	$ToolStripMenuItem_InternetExplorer.Name = "ToolStripMenuItem_InternetExplorer"
	$ToolStripMenuItem_InternetExplorer.Size = '290, 22'
	$ToolStripMenuItem_InternetExplorer.Text = "Internet Explorer"
	$ToolStripMenuItem_InternetExplorer.add_Click($ToolStripMenuItem_InternetExplorer_Click)
	#
	# ToolStripMenuItem_TerminalAdmin
	#
	#region Binary Data
	$ToolStripMenuItem_TerminalAdmin.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAlhJREFU
aEPVWe2SgzAI9NF9NN+sd6SlgwQSzILeZSZ/Oo2yfCxZ3DZg7fv+QjfweuwoGU7rOI7lTc/4tYL2
vSvL+EcAZBp/O4Bs4x8D0JJ/YVkFf2sNoBHQAD7G31fEmQDIeGKwfxkBNv6xGljlfjaYznM6lUQA
7a7eeen5MgAZee4RlPR8CQDUeDKcvEzPsdKslIUyjNc5rkFIAKksxMYv9KbvEZkSswikshDqeZ3X
0jgrArqQYRaSALaNrrfxzZ7WqcEd1sp5CzB0l+4BUCHGtgeAjdQpWcJCJgASGsQoTXD4YDwAsxrI
6jMtchUA2NMjFkpTcy4A8n5RBDKMZ8q2I5BUA1YEsowvBWDVQDZdlwKwagBtllbhN7quoFGOgKQw
NAJWTzEAtBlNeM/6gKyBTACnexT6YKuzVtQAR6C7R2UCkFdpDQJ9Dxdtp+YSuyI8Jx3ZMlNz4bz3
aoRfjvD8iKlC96gzI10buqIpQsDZCctqbhVAlvEzLaELudMSKwDQBiU9H9HTQzV3FQDq+XQ1hwC4
ouTov14TtHoIjyCnag4HEFNyJJI8AJ4cLWEh8x6VpOa0HLV6xKmI950GUv3mwvKaDPP+O4U+MhSQ
oxE1J9noOxAg49+rqeE2WaPfCIC33AgUqjnpyC4CbLwG4E2jTQCFak5nQTiFRteHLoVAAB4LTWtg
ogPM2dOfisDKdKwCAEdAqjmLQul/yWPJuJLTukHfcaw0Gub/ivf1UAz57CQBRGoA9jwDzrwLjdRc
2Tc1r7ld/X3WLM3GtZo2xjlYzV2YhHSv/wGeD3wz9WdSYQAAAABJRU5ErkJggg==')
	#endregion
	$ToolStripMenuItem_TerminalAdmin.Name = "ToolStripMenuItem_TerminalAdmin"
	$ToolStripMenuItem_TerminalAdmin.Size = '290, 22'
	$ToolStripMenuItem_TerminalAdmin.Text = "Terminal Admin (TsAdmin)"
	$ToolStripMenuItem_TerminalAdmin.add_Click($ToolStripMenuItem_TerminalAdmin_Click)
	#
	# ToolStripMenuItem_ADSearchDialog
	#
	#region Binary Data
	$ToolStripMenuItem_ADSearchDialog.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAQJJREFU
OE+Vkk0OgjAQhfFkeAu9BRyC6E6X7sQLaN0JcVNNjBHuoASjsoMb4OtMabQ0JjazmHS+92b647V/
Ls/Jz5YbFbHgmK+2vAPYIUCh+V7JIfNHAVvbgt+0LWC6KOrrtb7daiQ7qbzX6al63u0OLvoCGqjY
n1FljR7J0GxM3prubmUAxh+FSoAMrdNjnkhElhxynqQbY8AaProXTmN/HCAbjnUghxPRGm3bBVyK
qlGCYBJLKVEj45y8DKdz7IOOogguECyB4nKIUzLEp+yT1oemVxQoGBly7saTkHfZv1bhkmU8iflB
/ZcmGQ1pebu/Bu9Cg7C8fwlQez1KRP8vvwFHrYVIgfl+zgAAAABJRU5ErkJggg==')
	#endregion
	$ToolStripMenuItem_ADSearchDialog.Name = "ToolStripMenuItem_ADSearchDialog"
	$ToolStripMenuItem_ADSearchDialog.Size = '290, 22'
	$ToolStripMenuItem_ADSearchDialog.Text = "Active Directory Query - Search Dialog"
	$ToolStripMenuItem_ADSearchDialog.add_Click($ToolStripMenuItem_ADSearchDialog_Click)
	#
	# ToolStripMenuItem_ADPrinters
	#
	#region Binary Data
	$ToolStripMenuItem_ADPrinters.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAnZJREFU
OE+Nk+9LU1EYx++78O9wvhH/g6DBzKy0BAXRF8Iu0zcG4gsXbLDBWgVDJwSOlb4UMrQIogUyZOXu
fugmolttiLW00lku9W7u7u7Xt+eccCms6MIHLud8n895ngNHACCccdXyTn9rPOztmghXCXQ5w0rX
xIrS6QhUL9+Vps5nz/5rxWzhxkOpeCgr+JkrIJP9zaFcQGJPhuXVLgyPtvJX7ry+dF50QdDpCOZP
TlWsfSkTJYQ/q1jeLqBQqmBtr4z7b3ahM/me/lXQ4QgqTLBOgvWvZazuFCF9VJE6yFEnCg6OTtFm
XS7VFdhstoYOR0A9zqmI0WmxfTqVd1GE98MpPPEsjmm0a/f8ql6vb7hwB1RsILJ0WTgiQWK/ivck
2CRRdKfEx1jaytNeEdftEvr7+7M9PT0GJhGosG16ehrRaBS3x0PIkCCZriJBxL5VsEGjhKgLP42S
IcHNByH4/X6MjY2hvb29jQk26UM6nYbFYvkvWFaSJPT29m4zgVoul8GIRCKQZfmfBINBnmWMjo5W
BavVClVVOQsLC0ilUlxUD7Y3Oztby4uiCMFsNiORSHDcbjeSySR8Pl9dWGZycrKW12q1EIxGI7xe
L8fpdCIej2NxcbEusVgMdru9lm9uboZAc8Dj8XBcLhfoTjgmkwkjIyNgbXZ3d6O1tRU6nY6vneWb
mpogDA8PV+bm5vgiK5x//hJLbwN1eTb/Ai0tLTw7MzODxsZGCAaD4cnAwMBmX18fRFcIeUXF4YmK
H8TBcQF7GQU733P4lJaRLxQhToWg0WhY8QZhvvCYRFe4MvR4FUPuPwzS/6B7hcP2xKlw5fxb+AW7
EgTI9bZhkwAAAABJRU5ErkJggg==')
	#endregion
	$ToolStripMenuItem_ADPrinters.Name = "ToolStripMenuItem_ADPrinters"
	$ToolStripMenuItem_ADPrinters.Size = '290, 22'
	$ToolStripMenuItem_ADPrinters.Text = "Active Directory Query - Printers"
	$ToolStripMenuItem_ADPrinters.add_Click($ToolStripMenuItem_ADPrinters_Click)
	#
	# ToolStripMenuItem_netstatsListening
	#
	$ToolStripMenuItem_netstatsListening.Name = "ToolStripMenuItem_netstatsListening"
	$ToolStripMenuItem_netstatsListening.Size = '278, 22'
	$ToolStripMenuItem_netstatsListening.Text = "Netstats | Listening ports"
	$ToolStripMenuItem_netstatsListening.add_Click($ToolStripMenuItem_netstatsListening_Click)
	#
	# ToolStripMenuItem_systemInformationMSinfo32exe
	#
	$ToolStripMenuItem_systemInformationMSinfo32exe.Name = "ToolStripMenuItem_systemInformationMSinfo32exe"
	$ToolStripMenuItem_systemInformationMSinfo32exe.Size = '278, 22'
	$ToolStripMenuItem_systemInformationMSinfo32exe.Text = "System Information (MSinfo32.exe)"
	$ToolStripMenuItem_systemInformationMSinfo32exe.add_Click($ToolStripMenuItem_systemInformationMSinfo32exe_Click)
	#
	# ToolStripMenuItem_otherLocalTools
	#
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_addRemovePrograms)
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_addRemoveProgramsWindowsFeatures)
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_administrativeTools)
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_authprizationManager)
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_certificateManager)
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_componentServices)
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_diskManagement)
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_groupPolicyEditor)
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_localSecuritySettings)
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_localUsersAndGroups)
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_networkConnections)
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_performanceMonitor)
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_sharedFolders)
	[void]$ToolStripMenuItem_otherLocalTools.DropDownItems.Add($ToolStripMenuItem_scheduledTasks)
	$ToolStripMenuItem_otherLocalTools.Name = "ToolStripMenuItem_otherLocalTools"
	$ToolStripMenuItem_otherLocalTools.Size = '278, 22'
	$ToolStripMenuItem_otherLocalTools.Text = "Other Windows Apps"
	#
	# ToolStripMenuItem_addRemovePrograms
	#
	$ToolStripMenuItem_addRemovePrograms.Name = "ToolStripMenuItem_addRemovePrograms"
	$ToolStripMenuItem_addRemovePrograms.Size = '311, 22'
	$ToolStripMenuItem_addRemovePrograms.Text = "Add/Remove Programs"
	$ToolStripMenuItem_addRemovePrograms.add_Click($ToolStripMenuItem_addRemovePrograms_Click)
	#
	# ToolStripMenuItem_administrativeTools
	#
	$ToolStripMenuItem_administrativeTools.Name = "ToolStripMenuItem_administrativeTools"
	$ToolStripMenuItem_administrativeTools.Size = '311, 22'
	$ToolStripMenuItem_administrativeTools.Text = "Administrative Tools"
	$ToolStripMenuItem_administrativeTools.add_Click($ToolStripMenuItem_administrativeTools_Click)
	#
	# ToolStripMenuItem_authprizationManager
	#
	$ToolStripMenuItem_authprizationManager.Name = "ToolStripMenuItem_authprizationManager"
	$ToolStripMenuItem_authprizationManager.Size = '311, 22'
	$ToolStripMenuItem_authprizationManager.Text = "Authorization Manager"
	#
	# ToolStripMenuItem_certificateManager
	#
	$ToolStripMenuItem_certificateManager.Name = "ToolStripMenuItem_certificateManager"
	$ToolStripMenuItem_certificateManager.Size = '311, 22'
	$ToolStripMenuItem_certificateManager.Text = "Certificate Manager"
	$ToolStripMenuItem_certificateManager.add_Click($ToolStripMenuItem_certificateManager_Click)
	#
	# ToolStripMenuItem_devicemanager
	#
	$ToolStripMenuItem_devicemanager.Name = "ToolStripMenuItem_devicemanager"
	$ToolStripMenuItem_devicemanager.Size = '278, 22'
	$ToolStripMenuItem_devicemanager.Text = "Device Manager"
	$ToolStripMenuItem_devicemanager.add_Click($ToolStripMenuItem_devicemanager_Click)
	#
	# ToolStripMenuItem_addRemoveProgramsWindowsFeatures
	#
	$ToolStripMenuItem_addRemoveProgramsWindowsFeatures.Name = "ToolStripMenuItem_addRemoveProgramsWindowsFeatures"
	$ToolStripMenuItem_addRemoveProgramsWindowsFeatures.Size = '311, 22'
	$ToolStripMenuItem_addRemoveProgramsWindowsFeatures.Text = "Add/Remove Programs - Windows Features"
	$ToolStripMenuItem_addRemoveProgramsWindowsFeatures.add_Click($ToolStripMenuItem_addRemoveProgramsWindowsFeatures_Click)
	#
	# toolstripseparator1
	#
	$toolstripseparator1.Name = "toolstripseparator1"
	$toolstripseparator1.Size = '275, 6'
	#
	# toolstripseparator3
	#
	$toolstripseparator3.Name = "toolstripseparator3"
	$toolstripseparator3.Size = '275, 6'
	#
	# ToolStripMenuItem_systemproperties
	#
	$ToolStripMenuItem_systemproperties.Name = "ToolStripMenuItem_systemproperties"
	$ToolStripMenuItem_systemproperties.Size = '278, 22'
	$ToolStripMenuItem_systemproperties.Text = "System Properties"
	$ToolStripMenuItem_systemproperties.add_Click($ToolStripMenuItem_systemproperties_Click)
	#
	# toolstripseparator4
	#
	$toolstripseparator4.Name = "toolstripseparator4"
	$toolstripseparator4.Size = '287, 6'
	#
	# toolstripseparator5
	#
	$toolstripseparator5.Name = "toolstripseparator5"
	$toolstripseparator5.Size = '287, 6'
	#
	# ToolStripMenuItem_Wordpad
	#
	#region Binary Data
	$ToolStripMenuItem_Wordpad.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAI1JREFU
OE+VUlsOwCAI4+gczZtt5TFhOgnjg5jYllqkS4uIim4YR04cM+O8d9MKgiHqCZNDxGSEosYYjxxj
WJcg2mpNCNCoCxNAUOc/Joiv1hsYXqL00YUfoNV2ppxTMrQuR3Q9q1OsGW36vulPS2/fgfZYl61l
PVzNxcWE5qYrS0tu+f/5r85R7+ds4QYb3goYbbs8CAAAAABJRU5ErkJggg==')
	#endregion
	$ToolStripMenuItem_Wordpad.Name = "ToolStripMenuItem_Wordpad"
	$ToolStripMenuItem_Wordpad.Size = '290, 22'
	$ToolStripMenuItem_Wordpad.Text = "Wordpad"
	$ToolStripMenuItem_Wordpad.add_Click($ToolStripMenuItem_Wordpad_Click)
	#
	# ToolStripMenuItem_sharedFolders
	#
	$ToolStripMenuItem_sharedFolders.Name = "ToolStripMenuItem_sharedFolders"
	$ToolStripMenuItem_sharedFolders.Size = '311, 22'
	$ToolStripMenuItem_sharedFolders.Text = "Shared Folders"
	$ToolStripMenuItem_sharedFolders.add_Click($ToolStripMenuItem_sharedFolders_Click)
	#
	# ToolStripMenuItem_performanceMonitor
	#
	$ToolStripMenuItem_performanceMonitor.Name = "ToolStripMenuItem_performanceMonitor"
	$ToolStripMenuItem_performanceMonitor.Size = '311, 22'
	$ToolStripMenuItem_performanceMonitor.Text = "Performance Monitor"
	$ToolStripMenuItem_performanceMonitor.add_Click($ToolStripMenuItem_performanceMonitor_Click)
	#
	# ToolStripMenuItem_networkConnections
	#
	$ToolStripMenuItem_networkConnections.Name = "ToolStripMenuItem_networkConnections"
	$ToolStripMenuItem_networkConnections.Size = '311, 22'
	$ToolStripMenuItem_networkConnections.Text = "Network Connections"
	$ToolStripMenuItem_networkConnections.add_Click($ToolStripMenuItem_networkConnections_Click)
	#
	# ToolStripMenuItem_groupPolicyEditor
	#
	$ToolStripMenuItem_groupPolicyEditor.Name = "ToolStripMenuItem_groupPolicyEditor"
	$ToolStripMenuItem_groupPolicyEditor.Size = '311, 22'
	$ToolStripMenuItem_groupPolicyEditor.Text = "Group Policy Editor (local)"
	$ToolStripMenuItem_groupPolicyEditor.add_Click($ToolStripMenuItem_groupPolicyEditor_Click)
	#
	# ToolStripMenuItem_localUsersAndGroups
	#
	$ToolStripMenuItem_localUsersAndGroups.Name = "ToolStripMenuItem_localUsersAndGroups"
	$ToolStripMenuItem_localUsersAndGroups.Size = '311, 22'
	$ToolStripMenuItem_localUsersAndGroups.Text = "Local Users and Groups"
	$ToolStripMenuItem_localUsersAndGroups.add_Click($ToolStripMenuItem_localUsersAndGroups_Click)
	#
	# ToolStripMenuItem_diskManagement
	#
	$ToolStripMenuItem_diskManagement.Name = "ToolStripMenuItem_diskManagement"
	$ToolStripMenuItem_diskManagement.Size = '311, 22'
	$ToolStripMenuItem_diskManagement.Text = "Disk Management"
	$ToolStripMenuItem_diskManagement.add_Click($ToolStripMenuItem_diskManagement_Click)
	#
	# ToolStripMenuItem_localSecuritySettings
	#
	$ToolStripMenuItem_localSecuritySettings.Name = "ToolStripMenuItem_localSecuritySettings"
	$ToolStripMenuItem_localSecuritySettings.Size = '311, 22'
	$ToolStripMenuItem_localSecuritySettings.Text = "Local Security Settings"
	$ToolStripMenuItem_localSecuritySettings.add_Click($ToolStripMenuItem_localSecuritySettings_Click)
	#
	# ToolStripMenuItem_componentServices
	#
	$ToolStripMenuItem_componentServices.Name = "ToolStripMenuItem_componentServices"
	$ToolStripMenuItem_componentServices.Size = '311, 22'
	$ToolStripMenuItem_componentServices.Text = "Component Services"
	$ToolStripMenuItem_componentServices.add_Click($ToolStripMenuItem_componentServices_Click)
	#
	# ToolStripMenuItem_scheduledTasks
	#
	$ToolStripMenuItem_scheduledTasks.Name = "ToolStripMenuItem_scheduledTasks"
	$ToolStripMenuItem_scheduledTasks.Size = '311, 22'
	$ToolStripMenuItem_scheduledTasks.Text = "Scheduled Tasks"
	$ToolStripMenuItem_scheduledTasks.add_Click($ToolStripMenuItem_scheduledTasks_Click)
	#
	# ToolStripMenuItem_PowershellISE
	#
	#region Binary Data
	$ToolStripMenuItem_PowershellISE.Image = [System.Convert]::FromBase64String('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')
	#endregion
	$ToolStripMenuItem_PowershellISE.Name = "ToolStripMenuItem_PowershellISE"
	$ToolStripMenuItem_PowershellISE.Size = '290, 22'
	$ToolStripMenuItem_PowershellISE.Text = "Powershell ISE"
	$ToolStripMenuItem_PowershellISE.add_Click($ToolStripMenuItem_PowershellISE_Click)
	#
	# ToolStripMenuItem_hostsFile
	#
	$ToolStripMenuItem_hostsFile.Name = "ToolStripMenuItem_hostsFile"
	$ToolStripMenuItem_hostsFile.Size = '278, 22'
	$ToolStripMenuItem_hostsFile.Text = "Hosts File (Open)"
	#
	# ToolStripMenuItem_netstat
	#
	$ToolStripMenuItem_netstat.Name = "ToolStripMenuItem_netstat"
	$ToolStripMenuItem_netstat.Size = '278, 22'
	$ToolStripMenuItem_netstat.Text = "NetStat"
	#
	# errorprovider1
	#
	$errorprovider1.ContainerControl = $form_MainForm
	#
	# tooltipinfo
	#
	#
	# ToolStripMenuItem_sysInternals
	#
	[void]$ToolStripMenuItem_sysInternals.DropDownItems.Add($ToolStripMenuItem_adExplorer)
	#region Binary Data
	$ToolStripMenuItem_sysInternals.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAqlJREFU
OE+lk1tIlFEQx7/sonlFX0xTKAWhgtKiUkgiI3xLwtQwgyhSQlGRds27tqV5Dc0LhPaQLyWF2N1d
LyVq2ZK5Cga2aq1W61ppmogF/TqfH7kWPgQN/GE4Z+bHnJkzEiD9jxaTZSuvu/4wvbCIjJIyMkqv
rCxxJ8eI2AeLSbL9BhTfbpRJu/5FJUqsFfDEVmpoF6w2G4nWNUJr/1SbOGtfLdEhYjqFuoW6JGlg
qYJWW4kP1RUMqxOFkhlOTWbkfAojaYpG1UkMn0ukrqqGjPJqsipqqEiIV6qQnyADJqrL6XFbTY+T
xAsXCb27HXpPR/Qe9rx0taE2PIyW53pmF74zNmHh6bMeNEWlPxWAvYRWsB4v8qCxrx+d8LWrlPOh
U1Gk5Bdj+mCm8e59Ll4uIVNTQF5+oTLCFjuJ8bMxmFPjGZMBvQYs6YmYc1VMZKfwRRWHuqCIwSEj
Tzq6UWflYDlyUGm6DNCtk5i6Vs6QjzOtnna0edlj9HNjxM8Vk48D790lbt5/xJBxhN5XBpJVaagy
c8nI1SgVLALyzzO6fQPvArww7fTivb8H09ucORp7CU1aGabBfvoM/QwMvubT1xnMn6dIzcxWeqAV
TZxSnWZsjzfjgZsw7/VmLsCV43EXsK000jUHCY9MtNyoJU6dTmxaDnlRkdYnaEUPps+EMbHPh8lg
X+YCNxKTUMD6yjf0foPd9eMcujfDiTM5/NjhwkL0AYyno61jbBFTmD8WzGzoVuZCt8D+jdhcHcQw
D0H1Jg43TRJ05yMnz5XxM2QzCxFB6MTnWvoHOidpRoZohVpFNXoxOqeqAfY3WAhvshBy6y2REUm8
FOft4rlyrM5Rmlm+C/5/74DDRW2zb1kn2yq6cc1qbF5hR+Qc6zItLYfV8VmWJPsr2i9iBBGsinWg
ywAAAABJRU5ErkJggg==')
	#endregion
	$ToolStripMenuItem_sysInternals.Name = "ToolStripMenuItem_sysInternals"
	$ToolStripMenuItem_sysInternals.Size = '290, 22'
	$ToolStripMenuItem_sysInternals.Text = "SysInternals"
	#
	# ToolStripMenuItem_adExplorer
	#
	$ToolStripMenuItem_adExplorer.Name = "ToolStripMenuItem_adExplorer"
	$ToolStripMenuItem_adExplorer.Size = '152, 22'
	$ToolStripMenuItem_adExplorer.Text = "AdExplorer"
	$ToolStripMenuItem_adExplorer.add_Click($ToolStripMenuItem_adExplorer_Click)
	#
	# ToolStripMenuItem_hostsFileGetContent
	#
	$ToolStripMenuItem_hostsFileGetContent.Name = "ToolStripMenuItem_hostsFileGetContent"
	$ToolStripMenuItem_hostsFileGetContent.Size = '278, 22'
	$ToolStripMenuItem_hostsFileGetContent.Text = "Hosts File (Get content)"
	$ToolStripMenuItem_hostsFileGetContent.add_Click($ToolStripMenuItem_hostsFileGetContent_Click)
	#
	# ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Qwinsta
	#
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Qwinsta.Name = "ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Qwinsta"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Qwinsta.Size = '117, 22'
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Qwinsta.Text = "Qwinsta"
	$ContextMenuStripItem_consoleToolStripMenuItem_ComputerName_Qwinsta.add_Click($button_Qwinsta_Click)
	#
	# ToolStripMenuItem_rwinsta
	#
	$ToolStripMenuItem_rwinsta.Name = "ToolStripMenuItem_rwinsta"
	$ToolStripMenuItem_rwinsta.Size = '152, 22'
	$ToolStripMenuItem_rwinsta.Text = "Rwinsta"
	$ToolStripMenuItem_rwinsta.add_Click($button_Rwinsta_Click)
	#
	# ToolStripMenuItem_GeneratePassword
	#
	#region Binary Data
	$ToolStripMenuItem_GeneratePassword.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAo1JREFU
OE+Nk3tIk1EYxlcSVAhF9F9/SIpFRGCUXUgJxL/EyhKkUiMxLVuuZFpmEMWX2PKCOdNFsonWttTt
E7exOZ356fJumRqbLsec5XVeNvctBenpmyipoO3Aw3teOM+P5xzew2JtWHHh53YUcq+xy4mkdzWF
TxK4Ny97bTyzZc9PiapiACDzH0EvzQf5Or3EY0D8xSAfMi/lT0d1MZRvCbTKivDxJWcpMeL8Xo8g
zxIjjvfVFMBhagZt/bqsfnUJch5cPeQRQPEmPXK8pXwF8AX0cDemumTMNbinPQJkpcR4T+iFgw6D
FrRZD+ePJtg6JO2rZg6Hs+e/IIu28MZMexns3+SY7ZbCVFsUrdOqj6pUqu8kSZoZGTUaTcCmIIJ7
a79RVYCxRgF6q3Ohlgp85XJ5m0gkCnObeDxeCAPr2RRQpyR9LF1qVPEz0Fv/AT2tDQESiWR6rUEs
Fk+y2ezt6yAKFeVnMo/zrD9toyMDvdAr3mOorxNzdnpGqVTSekp3bNVQWVkxnv3i4b8Bo1oMqRbr
1BJzGE56AbRrETS9CBdTxfx7aKjIhFFfiqFOKQx6IeqlBIqJGAQH+nmxpPK6ff2GEdfElB3zzgVG
v1eqe78AUU4C2hVZ+NUjxbyVgqWrHC3VmcjNiETQCV8vVmOb8e7A0BjGJmYxM+eE3eFap2VAzQpg
mAF0lq0HCCVUaH1Tf5/RNLo0yaSwTc9j0uaAO5G7F2WvSbAM2JDA/TCXom5vS3vKP5BXRIYIxVS0
oFSXlC+oTeYLZEnFRKyrWUbAzMyGbbAWps8loCqf41X6FQSfPLj1Tw30370z7sKRqvvRZzVp8aG6
x3fCG1PjQj4lXz+jjQ07rDjlv8v7L4YVwdGFwpZPAAAAAElFTkSuQmCC')
	#endregion
	$ToolStripMenuItem_GeneratePassword.Name = "ToolStripMenuItem_GeneratePassword"
	$ToolStripMenuItem_GeneratePassword.Size = '290, 22'
	$ToolStripMenuItem_GeneratePassword.Text = "Generate a password"
	$ToolStripMenuItem_GeneratePassword.add_Click($button_PasswordGen_Click)
	#
	# ToolStripMenuItem_scripts
	#
	[void]$ToolStripMenuItem_scripts.DropDownItems.Add($ToolStripMenuItem_WMIExplorer)
	#region Binary Data
	$ToolStripMenuItem_scripts.Image = [System.Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAn9JREFU
OE9jYMABJMT5GNjYWLSyU23qpzd7RJsq8rC7mkrjUo4qLinBx8DIyKifHG9x/O7Jov8vtkR8mppl
5He815GwAarKogwsLEymaYmW5x+dL/3//1Ty//crA/7OKHZPf7E6Cb8BlmYKDOzsLNY5aTZXnl0A
aj6e8P/P1vD/2ydEbpFV1BVwd7DGbcD///MYeLnZnUty7G6+vFjy///h2P//d0T+/3+99v+9/RmP
JpTa+Pz//59BUpQb0xARYSGgs9mcc+IdHz46Wvb//4GY//+3QzT/vwl0yfms//c3RT2eUGzlCzJE
QgTTEDZtDcUNF3YU/r99pOT/10NF//9fqwYaUPz//7nM//9Pp4Hxva2xj3savMCGiIrxobiERUZa
fNGeFZn/v96s+P/7Vt3//1cL/v8/mwHXDDboZsn/W+cq7leVuRtP7QtBGMDExAziaNhbah85tR6o
6Ure//9n0oExkAoxAOgFkOb/r1r/f3/V/n/J9LDS/5+7UcOCmZkFbIitucbhE8vigbYDDQBpvpD9
//9tYLi8bvv//3Pv/6cXyj50Vbt6bFkQhRmYUEPUbUzVDhxfCjTkMtAldyv+/3/b8f//twn/X9+s
+baoP6AEqJPZQEsCe5QCUyBIQsfNRu/e61PAWPjS9///ryn/399v/LliWmgjUI7N1lQOd3pQlJNi
YOPgDG8LN/38Z5r3///Pev5/etX1Z/386D5pYS4uLwcVgsmZS19dfu+9fpf//zt0/39dm/Bv2/qs
2cba4nwRAfoENYMUsMpKis5aXe70+8Ukp597WvyXegbZiKQl2ROlGZgLmUAKJQw0FSPzIx3DQn2d
RHNivXBqBgD70EG6KrB0jQAAAABJRU5ErkJggg==')
	#endregion
	$ToolStripMenuItem_scripts.Name = "ToolStripMenuItem_scripts"
	$ToolStripMenuItem_scripts.Size = '74, 22'
	$ToolStripMenuItem_scripts.Text = "Scripts"
	#
	# ToolStripMenuItem_WMIExplorer
	#
	$ToolStripMenuItem_WMIExplorer.Name = "ToolStripMenuItem_WMIExplorer"
	$ToolStripMenuItem_WMIExplorer.Size = '152, 22'
	$ToolStripMenuItem_WMIExplorer.Text = "WMI Explorer"
	$ToolStripMenuItem_WMIExplorer.add_Click($ToolStripMenuItem_WMIExplorer_Click)
	#
	# imagelistAnimation
	#
	$Formatter_binaryFomatter = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
	#region Binary Data
	$System_IO_MemoryStream = New-Object System.IO.MemoryStream (,[byte[]][System.Convert]::FromBase64String('AAEAAAD/////AQAAAAAAAAAMAgAAAFdTeXN0ZW0uV2luZG93cy5Gb3JtcywgVmVyc2lvbj00LjAu
MC4wLCBDdWx0dXJlPW5ldXRyYWwsIFB1YmxpY0tleVRva2VuPWI3N2E1YzU2MTkzNGUwODkFAQAA
ACZTeXN0ZW0uV2luZG93cy5Gb3Jtcy5JbWFnZUxpc3RTdHJlYW1lcgEAAAAERGF0YQcCAgAAAAkD
AAAADwMAAAB2CgAAAk1TRnQBSQFMAgEBCAEAAcgBAAHIAQABEAEAARABAAT/ASEBAAj/AUIBTQE2
BwABNgMAASgDAAFAAwABMAMAAQEBAAEgBgABMP8A/wD/AP8A/wD/AP8A/wD/AP8A/wD/AP8A/wD/
AP8AugADwgH/AzAB/wMwAf8DwgH/MAADwgH/A1AB/wOCAf8DwgH/sAADMAH/AwAB/wMAAf8DMAH/
MAADggH/AzAB/wMwAf8DUAH/gAADwgH/AzAB/wMwAf8DwgH/IAADMAH/AwAB/wMAAf8DMAH/A8IB
/wNQAf8DggH/A8IB/xAAA8IB/wMwAf8DMAH/A8IB/wNQAf8DMAH/AzAB/wNQAf8EAAOSAf8DkgH/
A8IB/3AAAzAB/wMAAf8DAAH/AzAB/yAAA8IB/wMwAf8DMAH/A8IB/wOCAf8DMAH/AzAB/wOCAf8Q
AAMwAf8DAAH/AwAB/wMwAf8DwgH/A1AB/wOCAf8DwgH/A5IB/wOCAf8DggH/A5IB/3AAAzAB/wMA
Af8DAAH/AzAB/zAAA1AB/wMwAf8DMAH/A1AB/xAAAzAB/wMAAf8DAAH/AzAB/xAAA5IB/wOSAf8D
kgH/A8IB/3AAA8IB/wMwAf8DMAH/A8IB/zAAA8IB/wNQAf8DggH/A8IB/xAAA8IB/wMwAf8DMAH/
A8IB/xAAA8IB/wOSAf8DkgH/A8IB/zgAA8IB/wMwAf8DMAH/A8IB/zAAA8IB/wOCAf8DUAH/A8IB
/zAAA8IB/wPCAf8DkgH/A8IB/zQAA8IB/wPCAf80AAMwAf8DAAH/AwAB/wMwAf8wAANQAf8DMAH/
AzAB/wNQAf8wAAOSAf8DggH/A4IB/wOSAf8wAAPCAf8DwgH/A8IB/wPCAf8wAAMwAf8DAAH/AwAB
/wMwAf8wAAOCAf8DMAH/AzAB/wOCAf8wAAPCAf8DggH/A5IB/wOSAf8wAAPCAf8DwgH/A8IB/wPC
Af8wAAPCAf8DMAH/AzAB/wPCAf8wAAPCAf8DggH/A1AB/wPCAf8wAAPCAf8DkgH/A5IB/wPCAf80
AAPCAf8DwgH/EAADwgH/A8IB/xQAA8IB/wOCAf8DUAH/A8IB/zAAA8IB/wOSAf8DkgH/A8IB/zQA
A8IB/wPCAf9UAAPCAf8DwgH/A8IB/wPCAf8QAANQAf8DMAH/AzAB/wNQAf8wAAOSAf8DggH/A5IB
/wOSAf8wAAPCAf8DwgH/A8IB/wPCAf9QAAPCAf8DwgH/A8IB/wPCAf8DwgH/A8IB/wOSAf8DwgH/
A4IB/wMwAf8DMAH/A4IB/yQAA8IB/wPCAf8EAAPCAf8DggH/A5IB/wOSAf8wAAPCAf8DwgH/A8IB
/wPCAf9UAAPCAf8DwgH/BAADkgH/A4IB/wOCAf8DkgH/A8IB/wOCAf8DUAH/A8IB/yAAA8IB/wPC
Af8DwgH/A8IB/wPCAf8DkgH/A5IB/wPCAf80AAPCAf8DwgH/ZAADkgH/A5IB/wOSAf8DkgH/MAAD
wgH/A8IB/wPCAf8DwgH/sAADwgH/A5IB/wOSAf8DwgH/NAADwgH/A8IB/7QAA8IB/wPCAf8DkgH/
A8IB/zQAA8IB/wPCAf+0AAOSAf8DggH/A4IB/wOSAf8wAAPCAf8DwgH/A8IB/wPCAf+gAAPCAf8D
UAH/A4IB/wPCAf8DkgH/A5IB/wOSAf8DwgH/BAADwgH/A8IB/xQAA8IB/wPCAf8DkgH/A8IB/wPC
Af8DwgH/A8IB/wPCAf8kAAPCAf8DwgH/dAADggH/AzAB/wMwAf8DggH/A8IB/wOSAf8DkgH/A8IB
/wPCAf8DwgH/A8IB/wPCAf8QAAOSAf8DggH/A4IB/wOSAf8EAAPCAf8DwgH/JAADwgH/A8IB/wPC
Af8DwgH/cAADUAH/AzAB/wMwAf8DggH/EAADwgH/A8IB/wPCAf8DwgH/EAADkgH/A5IB/wOSAf8D
kgH/MAADwgH/A8IB/wPCAf8DwgH/cAADwgH/A1AB/wNQAf8DwgH/FAADwgH/A8IB/xQAA8IB/wOS
Af8DkgH/A8IB/zQAA8IB/wPCAf9sAAPCAf8DMAH/AzAB/wPCAf8wAAPCAf8DUAH/A4IB/wPCAf8w
AAPCAf8DwgH/A5IB/wPCAf80AAPCAf8DwgH/NAADMAH/AwAB/wMAAf8DMAH/MAADggH/AzAB/wMw
Af8DUAH/MAADkgH/A4IB/wOCAf8DkgH/MAADwgH/A8IB/wPCAf8DwgH/MAADMAH/AwAB/wMAAf8D
MAH/MAADUAH/AzAB/wMwAf8DggH/MAADkgH/A5IB/wOSAf8DkgH/MAADwgH/A8IB/wPCAf8DwgH/
MAADwgH/AzAB/wMwAf8DwgH/MAADwgH/A1AB/wNQAf8DwgH/MAADwgH/A5IB/wOSAf8DwgH/NAAD
wgH/A8IB/3wAA8IB/wMwAf8DMAH/A8IB/zAAA8IB/wNQAf8DggH/A8IB/zAAA8IB/wPCAf8DkgH/
A8IB/xAAA8IB/wMwAf8DMAH/A8IB/1AAAzAB/wMAAf8DAAH/AzAB/zAAA4IB/wMwAf8DMAH/A1AB
/zAAA5IB/wOCAf8DggH/A5IB/xAAAzAB/wMAAf8DAAH/AzAB/1AAAzAB/wMAAf8DAAH/AzAB/zAA
A1AB/wMwAf8DMAH/A4IB/wOSAf8DMAH/AzAB/wPCAf8gAAOSAf8DkgH/A5IB/wOSAf8DwgH/A1AB
/wOCAf8DwgH/AzAB/wMAAf8DAAH/AzAB/1AAA8IB/wMwAf8DMAH/A8IB/zAAA8IB/wOCAf8DUAH/
A8IB/wMwAf8DAAH/AwAB/wMwAf8gAAPCAf8DkgH/A5IB/wPCAf8DggH/AzAB/wMwAf8DUAH/A8IB
/wMwAf8DMAH/A8IB/6AAAzAB/wMAAf8DAAH/AzAB/zAAA1AB/wMwAf8DMAH/A4IB/7AAA8IB/wMw
Af8DMAH/A8IB/zAAA8IB/wOCAf8DUAH/A8IB/xgAAUIBTQE+BwABPgMAASgDAAFAAwABMAMAAQEB
AAEBBQABgAEBFgAD/4EABP8B/AE/AfwBPwT/AfwBPwH8AT8D/wHDAfwBAwHAASMD/wHDAfwBAwHA
AQMD/wHDAf8DwwP/AcMB/wPDAf8B8AH/AfAB/wHwAf8B+QH/AfAB/wHwAf8B8AH/AfAB/wHwAf8B
8AH/AfAB/wHwAf8B8AH/AfAB/wHwAf8B+QHnAcMB/wHDAf8B5wL/AsMB/wHDAf8BwwL/AcABAwH+
AUMB/wHDAv8B5AEDAfwBAwH/AecC/wH8AT8B/AE/BP8B/AE/Af4BfwT/AfwBPwH+AX8E/wH8AT8B
/AE/BP8BwAEnAcABPwHnA/8BwAEDAcIBfwHDA/8DwwH/AcMD/wHDAecBwwH/AecD/wEPAf8BDwH/
AQ8B/wGfAf8BDwH/AQ8B/wEPAf8BDwH/AQ8B/wEPAf8BDwH/AQ8B/wEPAf8BDwH/AQ8B/wGfA/8B
wwH/AcMB/wLDAv8BwwH/AcMB/wLDAv8BwwH/AcABPwHAAQMC/wHDAf8BwAE/AcABAwT/AfwBPwH8
AT8E/wH8AT8B/AE/Cw=='))
	#endregion
	$imagelistAnimation.ImageStream = $Formatter_binaryFomatter.Deserialize($System_IO_MemoryStream)
	$Formatter_binaryFomatter = $null
	$System_IO_MemoryStream = $null
	$imagelistAnimation.TransparentColor = 'Transparent'
	#
	# timerCheckJob
	#
	$timerCheckJob.add_Tick($timerCheckJob_Tick2)
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $form_MainForm.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$form_MainForm.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$form_MainForm.add_FormClosed($Form_Cleanup_FormClosed)
	#Store the control values when form is closing
	$form_MainForm.add_Closing($Form_StoreValues_Closing)
	#Show the Form
	return $form_MainForm.ShowDialog()

}
#endregion

#Start the application
Main ($CommandLine)
