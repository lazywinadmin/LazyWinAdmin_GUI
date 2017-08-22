# LazyWinAdmin_GUI
LazyWinAdmin is a project released in 2012, a PowerShell Script that generates a GUI/WinForms loaded with tons of functions.
For more information on LazyWinAdmin, check out the repo [here](https://github.com/lazywinadmin/LazyWinAdmin_GUI).

## What's Different?

While LazyWinAdmin has a built-in display of installed programs, remotely uninstalling any of them can be tedious, and involves sending remote commands. I added a button that pulls up a list of all MSI-installed apps and allows you to uninstall any of them remotely with a single click.
![alt text](/Media/newbutton.png "LazyWinAdmin")
![alt text](/Media/screen2.png "LazyWinAdmin")

## How it works

This fork uses WPF for the program list and WMI to query and uninstall programs
