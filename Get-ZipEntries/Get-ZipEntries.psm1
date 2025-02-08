Add-Type -AssemblyName System.IO.Compression.FileSystem

<#
.SYNOPSIS
Retrieves the list of files inside one or more zip archives.

.DESCRIPTION
The Get-ZipEntries function takes in one or more paths to zip files
and outputs a list of the files contained within them.

Wildcards are supported.

.PARAMETER Paths
One or more file paths to ZIP archives. Wildcards are supported.

.EXAMPLE
Get-ZipEntries -Paths "C:\Downloads\archive.zip", "C:\Documents\*.zip"
Retrieves the list of files inside "archive.zip" and any zip inside "C:\Documents".

.EXAMPLE
"a.zip", "b.zip" | Get-ZipEntries
Retrieves the list of files inside "a.zip" and "b.zip".

.NOTES
Uses System.IO.Compression.FileSystem assembly from .NET.
#>
function Get-ZipEntries {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$Paths
    )
    
    process {
        $ValidPaths = @()

        foreach ($path in $Paths) {
            try {
                $item = Get-Item -Path $path -ErrorAction Stop
                $ValidPaths += $item
            } catch {
                Write-Warning "Path not found: $path"
            }
        }

        foreach ($path in $ValidPaths) {
            try {
                $zip = [System.IO.Compression.ZipFile]::OpenRead((Get-Item $path).FullName)
                foreach ($entry in $zip.Entries) {
                    [PSCustomObject]@{
                        ZipFile  = (Split-Path -Leaf $path)
                        FileName = $entry.FullName
                    }
                }
                $zip.Dispose()
            } catch {
                Write-Error "Failed to read zip file: $path - $_"
            }
        }
    }
}
