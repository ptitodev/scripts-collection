# Set-Privacy.ps1
PowerShell script to batch-change privacy settings in Windows 10

## Description

With so many different privacy settings in Windows 10, it makes sense to have a script to change them.

April 2017 - Updated script to include all new privacy settings in Version 1703 (Creator's Update)

## Requirements

- Windows 10 or Windows Server 2016

## Getting the script

There are several ways to get the script file to your computer, download the zip, clone the repository, save the content manually into a file. 
You can also get it with PowerShell:

Open a PowerShell window, first cd into a directory of your choice to store the script in, e.g.:

	cd ~\Downloads

then download the script by running the following:

	(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/hahndorf/Set-Privacy/master/Set-Privacy.ps1') | out-file .\Set-Privacy.ps1 -force 

After downloading a PowerShell script from the Internet, you should always review it to make sure it doesn't do anything bad.

     ise .\Set-Privacy.ps1

## Getting the script 2

You could also open an elevated PowerShell window and run:

     Install-Script -Name Set-Privacy

You may have to confirm a few additional things, but this should be the easiest way.

## Running the script

Assuming you are still in the location you downloaded the script to, run it with one of the required parameters:

    .\Set-Privacy.ps1 -Strong

this sets the privacy settings for the current user to **Strong**, you also have the choice of **Default** (same as the Windows Express Setup settings) and **Balanced** (somewhere in the middle)

There are some settings for the whole computer rather than individual users, to change those run with the -admin switch

    .\Set-Privacy.ps1 -Strong -admin

To do this, your PowerShell session has to run under an elevated administrator account.

### Getting more help

To find out more about the parameters you can use for the script:

    help .\Set-Privacy.ps1 -full

## Script Output
The script shows the actual registry settings it is changing. A green line means, the settings was already in place and has not been changed. A yellow line means the settings has been changed.

## Problems running the script

You may get one of the following messages when trying to run a script:

**Execution Policy**

    ...Set-Privacy.ps1 cannot be loaded because running scripts is disabled on this system...

PowerShell doesn't allow the execution of unsigned scripts, to
allow the execution of local unsigned scripts for this session run:

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

To change the execution policy permanently, run:

	Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force


## What does the script change?

Here's a list of things the three different modes (-Default,-Balanced,-Strong) change.

A * means the feature will be enabled, a - means it will be disabled.

The names can be used with the -Feature parameter to specify individual settings to change.

<table>
<tbody>
<tr>
<td colspan="5"><b>Privacy Section (per user)</b></td>
</tr>
<tr>
<th>Name</th>
<th>Default</th>
<th>Balanced</th>
<th>Strong</th>
<th>Info</th>
</tr>
<tr>
<td>AdvertisingId</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let apps use my advertising ID for experience across apps</td>
</tr>
<tr>
<td>ImproveTyping</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Send Microsoft info about how to write to help us improve typing and writing in the future</td>
</tr>
<tr>
<td>SmartScreen</td>
<td>*</td>
<td>*</td>
<td>-</td>
<td>SmartScreen Filter</td>
</tr>
<tr>
<td>LanguageList</td>
<td>*</td>
<td>*</td>
<td>-</td>
<td>Let websites provice locally relevant content by accessing my language list</td>
</tr>
<tr>
<td>Location</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Use location information for this user account</td>
</tr>
<tr>
<td>Camera</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let apps use my camera</td>
</tr>
<tr>
<td>Microphone</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let apps use my microphone</td>
</tr>
<tr>
<td>SpeachInkingTyping</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>'Getting to know you' - monitoring voice input, inking and typing for Cortana</td>
</tr>
<tr>
<td>AccountInfo</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let apps access my name, picture, and other account info</td>
</tr>
<tr>
<td>Contacts</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Apps that can access your contacts</td>
</tr>
<tr>
<td>Calendar</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let apps access my calandar</td>
</tr>
<tr>
<td>Messaging</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let apps read or send messages (text or MMS)</td>
</tr>
<tr>
<td>Radios</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let apps use Bluetooth and other radios</td>
</tr>
<tr>
<td>OtherDevices</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let app share and sync data with other devices</td>
</tr>
<tr>
<td>FeedbackFrequency</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Windows should ask for my feedback</td>
</tr>

<tr>
<td>DoNotTrack</td>
<td>-</td>
<td>*</td>
<td>*</td>
<td>Edge - Add a Do-Not-Track http header</td>
</tr>

<tr>
<td>SearchSuggestions</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Edge - Search suggestions</td>
</tr>

<tr>
<td>PagePrediction</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Edge - Preload expected pages</td>
</tr>

<tr>
<td>PhishingFilter</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Edge - SmartScreen filter for malicious sites</td>
</tr>

<tr>
<td>StartTrackProgs</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let Windows track app launches to improve Start and search results</td>
</tr>

<tr>
<td>AppNotifications</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let apps access my notifications</td>
</tr>

<tr>
<td>CallHistory</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let apps access my call history</td>
</tr>

<tr>
<td>Email</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let Apps access and send email</td>
</tr>
<tr>
<td>Tasks</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let apps access tasks</td>
</tr>
<tr>
<td>AppDiagnostics</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let apps access diagnostics of other apps</td>
</tr>
<tr>
<td>TailoredExperiences</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Let Microsoft provide more tailored experiences with relevant tips...</td>
</tr>



<tr>
<td colspan="5"><b>-admin switch (machine scope)</b></td>
</tr>
<tr>
<th>Name</th>
<th>Default</th>
<th>Balanced</th>
<th>Strong</th>
<th>Info</th>
</tr>
<tr>
<td>ShareUpdates</td>
<td>*</td>
<td>+</td>
<td>-</td>
<td>In addition to get updates from Microsoft share updates on local network (+) or with the Internet (*)</td>
</tr>
<tr>
<td>WifiSense</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Sharing of Wi-Fi password and using Wi-Fi sense to connect to networks.</td>
</tr>
<tr>
<td>Telemetry</td>
<td>*</td>
<td>-</td>
<td>-</td>
<td>Diagnostic and usage data</td>
</tr>
<tr>
<td>SpyNet</td>
<td>*</td>
<td>*</td>
<td>-</td>
<td>Windows Defender, cloud-based Protection and sample submission</td>
</tr>
</tbody>
</table>


## What is NOT changed?

There are a few things this script doesn't change:

* Background Apps - I don't consider this a privacy issue, even though it appeas under the privacy section of the Windows 10 settings app.

* Any other tweaks and changes that may be nice to have but have nothing to do with privacy

* SpyNet Reporting - Administratrators can no longer change this settings. Sample submission is still turned off in -strong mode.