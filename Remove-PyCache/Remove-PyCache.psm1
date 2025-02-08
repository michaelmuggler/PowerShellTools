<#
.SYNOPSIS
Recursively removes all __pycache__ directories starting from a specified directory.

.DESCRIPTION
This function will search for and delete all __pycache__ directories
recursively from the given starting directory. If no directory is provided, 
it will start from the current working directory.

.PARAMETER StartDir
The directory to start the search from. If not provided, defaults to the current directory.

.EXAMPLE
Remove-PyCache -StartDir "C:\Path\To\Directory"
This will remove all __pycache__ directories from "C:\Path\To\Directory" and subdirectories.

.EXAMPLE
Remove-PyCache
This will remove all __pycache__ directories starting from the current directory.

.NOTES
This function uses Get-ChildItem to find __pycache__ directories and Remove-Item to delete them.
#>
function Remove-PyCache {
    param (
        [string]$StartDir = (Get-Location)
    )

    # Validate that the directory exists
    if (-Not (Test-Path $StartDir)) {
        Write-Host "Directory does not exist: $StartDir"
        return
    }

    # Get all __pycache__ directories recursively
    $pycacheDirs = Get-ChildItem -Path $StartDir -Recurse -Directory -Filter "__pycache__"

    foreach ($dir in $pycacheDirs) {
        try {
            Write-Host "Removing: $($dir.FullName)"
            Remove-Item -Path $dir.FullName -Recurse -Force
        } catch {
            Write-Host "Failed to remove $($dir.FullName): $_"
        }
    }

    Write-Host "PyCache removal complete."
}
