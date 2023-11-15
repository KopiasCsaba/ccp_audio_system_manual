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

    while ((Get-Item (Join-Path $sourceFolder $file)).LastWriteTime -gt (Get-Date).AddSeconds(-20)) {
        echo "Waiting on still changing file: $file ..."
        Start-Sleep 5
    }
  

    if (!(Test-Path $destinationFile) -or ($file.Length -ne (Get-Item $destinationFile).Length)) {
    

        # File not copied yet or size is different
        try {
	        echo "Copying $file ..."
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