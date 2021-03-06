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
			   f_logMessage ("Failure on changing a folder to master, see more details below")
               f_logMessage $_.Exception.Message;
               #f_logMessage $_.Exception.ItemName;
               return
             }
        

        
        <# These ways to catch Git exceptions don't work (exceptions are not captured by the try/catch constructions 
        try{ Start-Process -FilePath "c:\Program Files\git\bin\git.exe" -ArgumentList 'reset1 --hard origin/master'  -Wait -NoNewWindow -ErrorAction Stop;
    	                       
		        }
        catch {
			
                    f_logMessage ("Failure on syncing files from the GitHub")
                    f_logMessage $_.Exception.Message;
                    Return
            
                }  
 

        try { git reset --hard origin/master }
        catch  {
			        write-host "*************"
                    f_logMessage ("Failure on syncing files from the GitHub")
                    f_logMessage $_.Exception.Message;
                    Return
            
                } #> 
       
       cmd.exe /c git clean -f > $FileName
       if( $LastExitCode -ne 0 ){
			f_logMessage ("Failure on deleting untracked files")
            Return
       }

       cmd.exe /c git fetch origin > $FileName
       if( $LastExitCode -ne 0 ){
			f_logMessage ("Failure on syncing files from GitHub")
            Return
       }

       cmd.exe /c git reset --hard origin/master > $FileName
       if( $LastExitCode -ne 0 ){
			f_logMessage ("Failure on syncing files from GitHub")
            Return
       }

       #Set location back to the script folder 
        try{ set-location -path $ScriptFolder -ErrorAction Stop }
        catch{
			   f_logMessage ("Failure on changing a folder to a script folder, see more details below")
               f_logMessage $_.Exception.Message;
               return
             }
        
        f_logMessage ("All web site files have been sucessfully synced from GitHub - master branch");

}


function f_handleFilesInFolder{

        #ftp server variables
        $ftp = "ftp://abespalov.com/www/site3/public_html/images/" 
        $user = "palych" 
        $pass = "cure1995"
        $SetType = "bin"  
        $ListOfFilesToUpload = Get-ChildItem $PicturesToUploadFolder -recurse 
        
        #Connect to ftp webclient
        $webclient = New-Object System.Net.WebClient 
        $webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)  
        
        #Set location back to the script folder 
        try   {set-location -path $PicturesToUploadFolder -ErrorAction Stop}
        catch {f_logMessage ("Failure on changing a folder to a script folder, see more details below")
               f_logMessage $_.Exception.Message;
               return
        }
      
        #handle each jpeg file in the list
        
        if((Test-Path $WebSiteImageFolder)){
        
        $ListOfImageLinks = ''
        foreach($item in (dir $ListOfFilesToUpload "*.jpg")){
                
                try{ $uri = New-Object System.Uri($ftp+$item.Name)
                     $webclient.UploadFile($uri, $item.FullName)
                     f_logMessage "The followig file has been successfully uploaded to FTP : $item.FullName";
                     #copying to the image folder
                         try{ Move-Item -path $item.FullName -destination $WebSiteImageFolder -force -ErrorAction Stop
                              f_logMessage "The followig file has been successfully copied to the Web images folder : $item.FullName"
                            }
                         catch [Exception]{ 
                             f_logMessage "Failure to move the file $item.FullName to a local image folder";
                         }
                     #adding the file into a list of links
                     $ListOfImageLinks = $ListOfImageLinks + '<img src="./images/' + $item.Name + '"><br><br>' 
                     
                }
                catch [Exception] {
                     f_logMessage "Failure to upload file $item.FullName to FTP";
                     f_logMessage $_.Exception.Message;
                } 
          } #for each#

        #Change content of an index file
        f_addNewImageLinks($ListOfImageLinks)

        } #if#
        else{f_logMessage "The image folder $WebSiteImageFolder doesn't exist";} 
                
} #function#


function f_uploadNewIndexPage{

        #ftp server variables
        $ftp = "ftp://abespalov.com/www/site3/public_html/" 
        $user = "palych" 
        $pass = "cure1995"
                
        #Connect to ftp webclient
        $webclient = New-Object System.Net.WebClient 
        $webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)  
        
        #Set location back to a root Web pages folder 
        try   {set-location -path $WebSiteRoot -ErrorAction Stop}
        catch {f_logMessage ("Failure on changing a folder to a root web page folder, see more details below")
               f_logMessage $_.Exception.Message;
               return
        }
                    
                try{ $uri = New-Object System.Uri($ftp+'index.htm')
                     write-host $uri
                     write-host $IndexFile
                     $webclient.UploadFile($uri, $IndexFile)
                     f_logMessage "The index.htm file has been successfully uploaded to FTP";
                   }
                catch [Exception] {
                     f_logMessage "Failure to upload an index file";
                     f_logMessage $_.Exception.Message;
                } 
} #function#



#-- Function to add a line into a log file
function f_logMessage ($message){
    $time = get-date
    "message   | $time | $message" >> $global:FileName
    #add-content -path $Filename -value $message
}#function f_logMessage


# To change content of an index file
function f_addNewImageLinks($ImageFileLinks){
   $ImageMark = '<!-- Marking images -->'
   $NewImageLinks = $ImageMark + $ImageFileLinks
   (Get-Content $IndexFile) | Foreach-Object{
        $_ -replace $ImageMark, $NewImageLinks 
    } | Set-Content $NewIndexFile
}#function f_addNewImageLinks


################ Main ###########################

# Define global variables
$global:LogsFolder   = "C:\abespalov\github-repositories\ftp-publishing-scripts\"
$global:ScriptFolder = "C:\abespalov\github-repositories\ftp-publishing-scripts\"
$global:WebSiteRoot  = "C:\abespalov\github-repositories\kabachki.spb.ru\"
$global:WebSiteImageFolder  = "C:\abespalov\github-repositories\kabachki.spb.ru\images"
$global:PicturesToUploadFolder = "C:\abespalov\PicturesToUpload"
$global:IndexFile  = "C:\abespalov\github-repositories\kabachki.spb.ru\index.htm"
$global:NewIndexFile  = "C:\abespalov\github-repositories\kabachki.spb.ru\new-index.htm"


# Initialize a log file with timestamp 
$global:FileName = InitLog

#Create a new empty index file 
New-Item -path $NewIndexFile -type file -force

# Deleting all local files and geting the actual version of files from GitHub
# GitHubSync

# Uploading files new pictures to FTP, plus copying the files to the web image folder locally
f_handleFilesInFolder

#Rename a new empty index file 
Remove-Item $IndexFile
Rename-Item $NewIndexFile $IndexFile

#Upload a new index page
f_uploadNewIndexPage

# Submit the copied files to GitHub

