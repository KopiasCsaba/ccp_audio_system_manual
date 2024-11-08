# This script is called by the command task-start-google-drive-sync.cmd
# Which is called by the task scheduler job exported into: scheduled-task-for-google-drive-sync.xml

$sourceFolder = "e:\OBSRecordings"
$destinationFolder = "g:\My Drive\Recordings\StreamPcObsRecordings\"
$lastRunFile = "e:\OBSRecordings.last.sync"

#Echo "OK"
#Start-Sleep -Seconds 5
#Exit

$now = (Get-Date).ToString("yyy-MM-ddTHH:mm:ss")
echo "Syncing at $now"

# Get the timestamp of the last run
if (Test-Path $lastRunFile) {
    $lastRun = Get-Content $lastRunFile
} else {
    $lastRun = (Get-Date).AddDays(-365).ToString("yyy-MM-ddTHH:mm:ss")  # Default to a year ago
}
echo "Last run: $lastRun"

# Get files modified after the last run
$files = Get-ChildItem $sourceFolder | Where-Object { $_.LastWriteTime -gt $lastRun }

# Copy the files to the destination folder
foreach ($file in $files) {
    
    # Copy-Item $file.FullName $destinationFolder

    $destinationFile = Join-Path $destinationFolder $file.Name
    
    if ($file.Extension -ne ".mp4") { 
        echo "Skipping non .mp4 file: $file"
         continue
    }

   
    $success = $false

    while (-not $success) {
        try {
            # Check if the file is still changing
            if ((Get-Item (Join-Path $sourceFolder $file)).LastWriteTime.AddSeconds(120) -gt (Get-Date)) {
                $fileSize = (Get-Item (Join-Path $sourceFolder $file)).length
                echo "Waiting on still changing/recently changed file: $file ($fileSize bytes)..."
            } else {
                # File has stopped changing, attempt to get hash
                $fileMD5 = (Get-FileHash -Path (Join-Path $sourceFolder $file) -Algorithm MD5 -ErrorAction Stop).Hash
                $success = $true
            }
        }
        catch {
            # Handle any errors (e.g., file in use), and retry after waiting
            echo "The file '$file' is in use by another process or an error occurred. Retrying in 10 seconds..."
        }

        # Wait before the next iteration (either after detecting a changing file or handling an error)
        Start-Sleep 10
    }

   

    if (!(Test-Path $destinationFile) -or ($file.Length -ne (Get-Item $destinationFile).Length)) {
    

        # File not copied yet or size is different
        try {
            $fileSize = (Get-Item $file.FullName).length
            $fileMD5 = (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash
	        echo "Copying $file (size: $fileSize b, md5: $fileMD5)..."

            Copy-Item $file.FullName $destinationFolder -ErrorAction Stop
        } catch {
            # Handle the error as needed
            echo "Failed to copy $file to $destinationFile, will try again next time..."
            Exit
        }
    } else {
        echo "Already copied: $file ..."
    }


}

echo "Finished properly, saving last-sync time."
# Save the current timestamp as the last run
(Get-Date).ToString("yyy-MM-ddTHH:mm:ss") | Set-Content $lastRunFile