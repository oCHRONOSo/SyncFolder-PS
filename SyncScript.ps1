param (
    [string]$SourceFolder,
    [string]$ReplicaFolder,
    [string]$LogFile
)

function Log-Message {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Write-Output $logEntry
    Add-Content -Path $LogFile -Value $logEntry
}

function Sync-Folders {
    param ([string]$Source, [string]$Replica)

    try {
        $sourceItems = Get-ChildItem -Recurse -Path $Source -ErrorAction Stop
        $replicaItems = Get-ChildItem -Recurse -Path $Replica -ErrorAction Stop

        $totalItems = $sourceItems.Count + $replicaItems.Count
        $currentItemIndex = 0
        $progressStep = [math]::Round($totalItems / 100)

        # Sync Files from Source to Replica
        foreach ($sourceItem in $sourceItems) {
            $replicaPath = $sourceItem.FullName.Replace($Source, $Replica)
            try {
                if (-not (Test-Path -Path $replicaPath)) {
                    if ($sourceItem.PSIsContainer) {
                        New-Item -ItemType Directory -Path $replicaPath -ErrorAction Stop | Out-Null
                        Log-Message "Created directory: $replicaPath"
                    } else {
                        Copy-Item -Path $sourceItem.FullName -Destination $replicaPath -ErrorAction Stop
                        Log-Message "Copied file: $replicaPath"
                    }
                } elseif ($sourceItem.LastWriteTime -gt (Get-Item $replicaPath -ErrorAction Stop).LastWriteTime) {
                    Copy-Item -Path $sourceItem.FullName -Destination $replicaPath -Force -ErrorAction Stop
                    Log-Message "Updated file: $replicaPath"
                }
            } catch {
                Log-Message "Error processing item: $($sourceItem.FullName). Error: $($_.Exception.Message)"
            }

            $currentItemIndex++
            if ($currentItemIndex % $progressStep -eq 0) {
                $progress = [math]::Round(($currentItemIndex / $totalItems) * 100)
                Write-Progress -Activity "Synchronizing Folders" -Status "$progress% Complete" -PercentComplete $progress
            }
        }

        # Remove Files/Directories in Replica that don't exist in Source
        foreach ($replicaItem in $replicaItems) {
            $sourcePath = $replicaItem.FullName.Replace($Replica, $Source)
            try {
                if (-not (Test-Path -Path $sourcePath)) {
                    if ($replicaItem.PSIsContainer) {
                        Remove-Item -Recurse -Force -Path $replicaItem.FullName -ErrorAction Stop
                        Log-Message "Removed directory: $($replicaItem.FullName)"
                    } else {
                        Remove-Item -Force -Path $replicaItem.FullName -ErrorAction Stop
                        Log-Message "Removed file: $($replicaItem.FullName)"
                    }
                }
            } catch {
                Log-Message "Error removing item: $($replicaItem.FullName). Error: $($_.Exception.Message)"
            }

            $currentItemIndex++
            if ($currentItemIndex % $progressStep -eq 0) {
                $progress = [math]::Round(($currentItemIndex / $totalItems) * 100)
                Write-Progress -Activity "Synchronizing Folders" -Status "$progress% Complete" -PercentComplete $progress
            }
        }

        Log-Message "Synchronization completed successfully."
        Write-Progress -Activity "Synchronizing Folders" -Completed

    } catch {
        Log-Message "An error occurred during synchronization. Error: $($_.Exception.Message)"
        Write-Progress -Activity "Synchronizing Folders" -Completed
    }
}

# Validate parameters
if (-not (Test-Path -Path $SourceFolder)) {
    Log-Message "Error: Source folder path is invalid."
    exit 1
}

if (-not (Test-Path -Path $ReplicaFolder)) {
    try {
        New-Item -ItemType Directory -Path $ReplicaFolder -ErrorAction Stop | Out-Null
        Log-Message "Created replica folder: $ReplicaFolder"
    } catch {
        Log-Message "Error: Failed to create replica folder. Error: $($_.Exception.Message)"
        exit 1
    }
}

try {
    # Run the synchronization
    Sync-Folders -Source $SourceFolder -Replica $ReplicaFolder
} catch {
    Log-Message "An unexpected error occurred. Error: $($_.Exception.Message)"
    exit 1
}
