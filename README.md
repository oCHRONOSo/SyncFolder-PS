# SyncFolder-PS

This PowerShell script synchronizes the contents of a source folder with a replica folder. It ensures that files and directories in the replica folder match those in the source folder by copying new or updated items and removing any items in the replica that do not exist in the source.

## Features

- **Folder Synchronization**: Keeps the replica folder in sync with the source folder.
- **Logging**: Logs all actions taken during the synchronization process to a specified log file.
- **Progress Indicator**: Displays a progress bar to indicate the synchronization process.

## Parameters

- **`SourceFolder`**: The path to the source folder that will be synchronized.
- **`ReplicaFolder`**: The path to the replica folder that will be synchronized with the source.
- **`LogFile`**: The path to the log file where all actions and errors will be recorded.

## Usage

1. Open a PowerShell window.
2. Run the script with the required parameters:

   ```powershell
   .\SyncScript.ps1 -SourceFolder "C:\Path\To\Source" -ReplicaFolder "C:\Path\To\Replica" -LogFile "C:\Path\To\LogFile.txt"
