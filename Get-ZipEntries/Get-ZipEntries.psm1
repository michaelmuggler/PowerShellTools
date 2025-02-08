Add-Type -AssemblyName System.IO.Compression.FileSystem

function Convert-BytesToHumanReadable {
    param (
        [Parameter(Mandatory = $true)]
        [long]$Bytes
    )
    
    $units = @("Bytes", "KB", "MB", "GB", "TB", "PB")
    $unitIndex = 0
    $size = $Bytes

    while ($size -ge 1024 -and $unitIndex -lt $units.Length - 1) {
        $size /= 1024
        $unitIndex++
    }

    return "{0:N2} {1}" -f $size, $units[$unitIndex]
}


<#
.SYNOPSIS
Retrieves the list of files inside one or more zip archives.

.DESCRIPTION
The Get-ZipEntries function takes in one or more paths to zip files
and outputs a list of the files contained within them.

Wildcards are supported.

.PARAMETER Paths
One or more file paths to ZIP archives. Wildcards are supported.

.PARAMETER Filter
A regular expression to filter the entries by.

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
        [string[]]$Paths,

        [Parameter()]
        [string]$Filter
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
                    if ($Filter -and $entry.Name -notmatch $Filter) {
                        continue
                    }
                    [PSCustomObject]@{
                        ZipFile  = (Split-Path -Leaf $path)
                        Entry = $entry.FullName
                        Length = Convert-BytesToHumanReadable -Bytes $entry.CompressedLength
                    }
                }
                $zip.Dispose()
            } catch {
                Write-Error "Failed to read zip file: $path - $_"
            }
        }
    }
}

Export-ModuleMember -Function Get-ZipEntries
