# LazyWinAdmin_GUI
LazyWinAdmin is a project released in 2012, a PowerShell Script that generates a GUI/WinForms loaded with tons of functions.
This utility is very helpful for anyone managing workstations or servers. I hope this help you in your day to day tasks.

The Form was created using Sapien Powershell Studio 2012.

![alt text](/Media/lwa-v0.4-main01.png "LazyWinAdmin")

## Requirements
 * Powershell 2.0
 * Permission on the targeted System(s)

## Optional tools
 * External Tools
  * SystemInfo.exe
  * DriverQuery
  * AdExplorer -  http://technet.microsoft.com/en-us/sysinternals/bb963907.aspx
  * PSExec - http://technet.microsoft.com/en-us/sysinternals/bb897553.aspx
  * PAExec - http://www.poweradmin.com/PAExec/
  * WMIExplorer.ps1 - http://gallery.technet.microsoft.com/scriptcenter/89c759b7-20b4-49e8-98a8-3c8fbdb2dd69
 * Scripts
  * sydi-server.vbs - http://sydiproject.com/products/sydi-server/
  * WmiExplorer.ps1

## Contributions
You are welcome to contribute. Refer to the License for details.


## Version History
```
2011.06.29
	-Added link to Powershell ISE
2011.06.26
	-RDP Check/Enable/Disable Added
2011.06.24
	-Added Application List, PSRemoting, Inventory Buttons moved in TOOLS
	-Services - AutoNotStarted - Check if all the services with StartMode AUTOMATIC are actually Running
	-Services - Auto - Removed ProcessID in results
2011.06.30
	-Fixed the Problems with Start/Stop Service buttons
	-Add AutoComplete (Append and Suggest) (need to fill the computers.txt)
	-Add AutoDisable Buttons/TabControl if not Server Entered
	-Add Get-USB - Report all the USB device on the Computer
2011.08.11
	-Correct Compmgmt.msc button
2011.08.15
	-Title bar with current username and domain
	-Change font from Microsoft Sans cherif to Trebuchet MS
	-Scroll to bottom when text is changed
	-ADD more logs to buttons
2011.08.30
	-ADD ErrorProvider on TextBox ComputerName
2011.08.31
	-SYDI Works (only .DOC for now)
	-ADD the tool SysInternals AdExplorer
2011.10.02
	-FIX Query/Stop/Start Service buttons
	-ADD Descriptions in logs RichTextBox for Query/Stop/Start Service buttons
	-CHANGE Button :80 to HTTP
	-ADD FTP, TELNET, HTTPS buttons
2011.10.04
	-FIX some problem with Uptime Button
	-FIX Modified The Service Query/start/stop
	-ADD Restart Service Button
	-ADD TextBox with AutoCompletion on some Services i added
2011.10.06
	-ERROR AutoCompletion in the TEXTBOX of Services seems to make the thing crash :-(
2011.10.23
	-REMOVE AutoCompletion in Service Tab, in ServiceName TextBox
	-ADD Get Local Hosts File (Menu: LocalHost/Hosts File)
	-ADD Get Remote Hosts File (in General Tab,need permission on remote c$)
	-REMOVE Computers.txt auto-completion, seems buggy :-(
	-ADD Active Directory Form
	-ADD IP Calculator Form
2011.11.24
	-FIX ENTER-PSSESSION button.
2011.12.05
	-REPLACED some function by button with icons below Computername
	-MOVED the TEST-PSSESSION button to TOOL tab
	-ADD the TEST-PSSESSION inside the ENTER-PSSESSION button. (2 in 1 :)
2011.12.26
	-MODIFY Inventory button and output (add more info)
	-MODIFY IpConfig to use the one from BSonPosh module
2011.12.28
	-ADD button IPCONFIG, DISK USAGE
2012.01.06
	-ADD START COMMANDS in General Tab
	-ADD SYDI option (dropdown) to choose DOC or XML format.
	-ADD Combobox in TOOLS Tab, and ADD the present tools in combobox
	-REMOVE Buttons in TOOLS tab (the ones placed in Combobox)
	-FIX the ContextMenuStrip on TextBox SERVERNAME.
	-ADD option of type for SYDI (DOC or XML)
2012.01.29
	-FIX the names of all the variables (for Winforms controls only)
	-ADD Qwinsta and Rwinsta to contextmenu of computername textbox
	-FIX SYDI (DOC and XML now work) auto-save on Desktop of Current User
	-FIX "Installed Applications" show the full names of each application,vendors and versions.
2012.01.31
	-ADD Connectivity Testing Button (Remote registry, ping, RPC, RDP, WsMan)
	-ADD another more info to ipconfig button
2012.02.02
	-ADD Invoke-item in SYDI to open the Explorer
2012.04.09
	-Remove Button Test PsRemoting
	-Moved "Generate a Password" under AdminArsenal Menu
	-Delete Menu TOOLS
	-Change the size of Author Form (smaller)
2012.04.10
	-Redesign a bit the interface
	-Add a few tabs (Software, Other Powershell script, external tools)
	-Add a Panel for basic connectivity test and properties
	-Correct Logs RichTextBox, fix error "Property ENABLED does not exist"
	-Add some colors to the Connectivity Panel (OK: green, FAIL: red, other: blue)
	-Add PAExec and PSexec in the TOOLS directory, Button are in the tab "External tools".
	 by default, it will launch a CMD.exe
	-Moved all the external tools (tools that are not Powershell) under "External Tools"
2012.04.14
	-Add ActiveDirectory Tab
	-Add GPUpdate function, Tab "Active Directory"
	-Remove EMAIL options
	-Remove NOTEPAD button (export of richtextbox)
	-Add EXPORT RTF button (open in wordpad)
	-Comment all the "Clear-RichTextBox" function use
	-Rename the COPY button (close to the richtextbox) to ClipBoard
	-Move EXIT button to the bottom.
	-Remove PASTE button
2012.04.17
	-MODIFY Function Add-Logs (Alias, Add the return to line)
	-MODIFY Function Add-RichTextBox (Alias, Add the return to line
	-FIX the ComputersList Load.
	-Clean some variable and add comments of the mainform script.
	-ADD a SCRIPTS folder with the variable: $ScriptsPath
2012.04.18
	-Upgraded my PrimalForms 2011 to PowerShell Studio 2012
	-Remove the ListBox from the Beta and readd the buttons
2012.04.20
	-Ability to Maximize the windows (i used WinForm Docking/Move Front,Back)
2012.05.12
	-Cleaning Some code
	-Fixes some bugs
	-Remove unused Functions
	-Checking if tools are present when the form load, disable buttons if not present.
	-Add MotherBoard,PageFile Settings, System Type buttons
	-AD KMS Information, FSMO
2012.05.16
	-Adding functions BackgroundJobs for long process(not used yet)
2012.05.17
	-Renaming a couple of buttons and add ToolTip Info for each.
	-Modify Ipconfig button under Network, only one result come out now
	-Remove the ROUTE PRINT button form Network, kept only ROUTE TABLE
	-Add a button to show Process CommandLine Argument (command line used to launch each process)
	-Modify Button CommandLine with Out-String Width = $richtextbox.width
	-Modify Button Shares with Out-String Width = $richtextbox.width
	-CTRL+Scroll in the RichTextBox is working now
	-Richtextbox dont overlap on middle bar anymore (middle bar=buttons exit,copy clipboard...)
	-Add Button to change and set local Computer Description
	-Add Button to change and set Active Directory Computer Description
2012.05.28
	-Getting ready for a public open source version
	-Remove and move a couple of function, tabs and unused buttons
	-Add Tip info on most of the button (pass over button help)
	-Add WindowsUpdate.log and ReportingEvents.log Button
	-Fix Open C$ button
	-Icons added to the main functions
	-OnLoad of the Form, the script will test the path of the scrtips and External tools
	 if not present, the script will disable the buttons
	-Load of Computers.txt works with an Export to PS1 (not with Export to EXE)
2012.05.30
	-Corrected color of the check buttons
	-Corrected the Restart and Shutdown button to have a prompt.
	-Corrected MsINFO32.exe check (during the load of the form)
2012.06.06
	-Changed some Icons
	-Add confirmation on EXIT Button
2012.06.07
	-Press Enter on ComputerTxtBox will ping the machine
	-Modified the CHECK, now the full OS information is returned
2012.06.10
	-Fixed the directory issue (scripts tools)
2012.06.13
	-Renamed the forms
	-Removed the form "LocalHost Current information"
	-Fix Qwinsta and Rwinsta, if and else based on 32 or 64bits now
	-Align the CHECK textboxes
```
