function Get-Color {
    param(
        [string]$title
    )

    $colors = @(
        "#FF5733",  # Red
        "#33FF57",  # Green
        "#3357FF",  # Blue
        "#FF33A8",  # Pink
        "#33FFF5",  # Cyan
        "#FFC433",  # Yellow
        "#8E35FF",  # Purple
        "#FF8633"   # Orange
    )

    $hashCode = [Math]::Abs([System.Math]::Abs($title.GetHashCode()) % $colors.Count)
    return $colors[$hashCode]
}

function Open-Tabs {
    <# 
    .SYNOPSIS 
        Opens new Windows Terminal tabs given a list of firectories.

    .DESCRIPTION 
        The Open-Tabs function accepts directories as pipeline input or as an array of objects with a Name property. 
        It sets custom titles and colors for each tab via hash-map lookup based on the directory name.

    .PARAMETER Directory 
        An array of directories to open in new tabs. The input can be a string array or objects with a Name property. 
        This parameter is required and supports pipeline input.

    .EXAMPLE 
        $directories = @("C:\Users\michael\Project1", "C:\Users\michael\Project2") 
        $directories | Open-Tabs

    .EXAMPLE 
        $directories = @( 
            [PSCustomObject]@{Name="C:\Users\michael\Project1"}, 
            [PSCustomObject]@{Name="C:\Users\michael\Project2"} 
        ) 
        $directories | Open-Tabs

    .EXAMPLE 
        Open-Tabs -Directory @("C:\Users\michael\Project1", "C:\Users\michael\Project2")

    .EXAMPLE 
        Find-GitRepos -FullName | Open-Tabs

    .NOTES 
        The function requires Windows Terminal which may not be installed on Windows 10 and earlier.
    #>
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        [object[]]$Directory
    )

    process {
        foreach ($dir in $Directory) {
            $path = if ($dir -is [string]) { $dir } elseif ($dir.PSObject.Properties['Name']) { $dir.Name } else { $null }
            
            if ($path -and (Test-Path $path -PathType Container)) {
                $title = Split-Path -Path $path -Leaf
                $color = Get-Color -title $title
                wt -w 0 nt --title "$title" --suppressApplicationTitle --tabColor "$color" -p PowerShell -d "$path"
            } else {
                Write-Host "Skipping invalid directory: $path" -ForegroundColor Red
            }
        }
    }
}

# Ensures that Get-Color is not made available outside this file.
Export-ModuleMember -Function Open-Tabs
