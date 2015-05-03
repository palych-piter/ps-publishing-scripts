
#Functions

#--- Function to initialize log file

function InitLog {
	$TempFileName = "file_transfer_to_FTP_{0:yyyy.MM.dd.HH.mm.ss}.log"
	$TempFileName = Join-Path $LogsFolder $TempFileName
	# "System.Datetime" is the .NET class, "Now" is the method
    $TempFileName = $TempFileName -f [System.Datetime]::Now
	return New-Item -path $TempFileName -type file -force
}

#-- Function to add a line into a log file

function LogMessage ($message){
    $time = get-date
    "message   | $time | $message" >> $global:FileName
    #add-content -path $Filename -value $message
}


$global:LogsFolder = "C:\abespalov\Home Site Publishing Scripts\"

# Initialize a log file with timestamp
$global:FileName = InitLog

# Get the actual version of files from GitHub


# Publish the files synced from the GitHub

LogMessage ("Inserted message in the log file - line 1");
LogMessage ("Inserted message in the log file - line 2");
