# Set the system variable to treat all errors as terminating. The variable will be actual for session 
# initialized by running the script. As an alternative way you are able to use the -ErrorAction parameter 
# to mark a particular command as terminating, for instance "set-location -path $WebsiteRoot -ErrorAction Stop"
# $ErrorActionPreference = Stop


#Functions

#--- Function to initialize log file

function InitLog {
	$TempFileName = "file_transfer_to_FTP_{0:yyyy.MM.dd.HH.mm.ss}.log"
	$TempFileName = Join-Path $LogsFolder $TempFileName
	# "System.Datetime" is the .NET class, "Now" is the method
    $TempFileName = $TempFileName -f [System.Datetime]::Now
	return New-Item -path $TempFileName -type file -force
}


#--- Function to sync files from GitHub

function GitHubSync {

        #Set location to a folder where web files are located
        try{ set-location -path $WebsiteRoot -ErrorAction Stop }
        catch{
			   LogMessage ("Failure on changing a folder to master, see more details below")
               LogMessage $_.Exception.Message;
               #LogMessage $_.Exception.ItemName;
               return
             }
        

        try{ Start-Process -FilePath "c:\Program Files\git\bin\git.exe" -ArgumentList 'fetch origin' -Wait -NoNewWindow -ErrorAction Stop;
             }

        catch{
			
                    LogMessage ("Failure on syncing files from the GitHub")
                    LogMessage $_.Exception.Message;
                    Return
            
             }
        


        try{ Start-Process -FilePath "c:\Program Files\git\bin\git.exe" -ArgumentList 'clean -f' -Wait -NoNewWindow -ErrorAction Stop;
    
		        }
        catch {
			
                    LogMessage ("Failure on deleting untracked files")
                    LogMessage $_.Exception.Message;
                    Return
            
                }



        <#try{ Start-Process -FilePath "c:\Program Files\git\bin\git.exe" -ArgumentList 'reset1 --hard origin/master'  -Wait -NoNewWindow -ErrorAction Stop;
    	                       
		        }
        catch {
			
                    LogMessage ("Failure on syncing files from the GitHub")
                    LogMessage $_.Exception.Message;
                    Return
            
                } #> 
 

        <#try { git reset --hard origin/master }
        catch  [Exception] {
			
                    LogMessage ("Failure on syncing files from the GitHub")
                    LogMessage $_.Exception.Message;
                    Return
            
                } #>
       

       cmd.exe /c git reset1 --hard origin/master > $FileName
       if( $LastExitCode -ne 0 ){
			LogMessage ("Failure on syncing files from GitHub")
            LogMessage $_;
            Return
        }

       #Set location back to the script folder 
        try{ set-location -path $ScriptFolder -ErrorAction Stop }
        catch{
			   LogMessage ("Failure on changing a folder to a script folder, see more details below")
               LogMessage $_.Exception.Message;
               #LogMessage $_.Exception.ItemName;
               return
             }
        

        LogMessage ("All web site files have been sucessfully synced from GitHub - master branch");

}



#-- Function to add a line into a log file

function LogMessage ($message){
    $time = get-date
    "message   | $time | $message" >> $global:FileName
    #add-content -path $Filename -value $message
}


$global:LogsFolder   = "C:\abespalov\github-repositories\ftp-publishing-scripts\"
$global:ScriptFolder = "C:\abespalov\github-repositories\ftp-publishing-scripts\"
$global:WebSiteRoot  = "C:\abespalov\github-repositories\abespalov-master\"


# Initialize a log file with timestampal 
$global:FileName = InitLog

# Deleting all local files and geting the actual version of 
# files from GitHub
GitHubSync

# Publish the files synced from the GitHub

