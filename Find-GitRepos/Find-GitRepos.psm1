function Find-GitRepos {
    <#
    .SYNOPSIS
    Lists Git repositories in a specified directory (or current working directory), showing their current branch, last commit hash and date.

    .DESCRIPTION
    For each folder in the specified directory, if it is a Git repository (`.git` directory exists), it will output the following info:
    - Folder name
    - Current Git branch
    - Last commit hash (first 7 characters)
    - Last commit date in a human-readable format

    .PARAMETER SearchDirectory
    The directory where the search for Git repositories will be conducted. If not specified, the current working directory will be used by default.

    .PARAMETER FullName
    If this flag is passed, the function will return the absolute path of the folder instead of just the folder name.

    .EXAMPLE
    Find-GitRepos -SearchDirectory "C:\path\to\your\projects"

    This will list all Git repositories in the specified directory and show their status.

    .EXAMPLE
    Find-GitRepos

    This will list all Git repositories in the current working directory and show their status.
    #>
    param (
        [string]$SearchDirectory = (Get-Location),
        [switch]$FullName
    )

    # Create an array to hold the repo info objects
    $repoInfoList = @()

    # Get all directories in the specified directory
    $folders = Get-ChildItem -Path $SearchDirectory -Directory

    # Loop through each folder
    foreach ($folder in $folders) {
        # Check if the folder contains a .git directory
        if (Test-Path "$($folder.FullName)\.git") {
            # Get the current branch name
            $branch = git -C $folder.FullName rev-parse --abbrev-ref HEAD

            # Get the last commit hash (first 7 characters)
            $commitHash = git -C $folder.FullName log -1 --format="%H" | Select-Object -First 1
            $commitHash = $commitHash.Substring(0, 7)

            # Get the last commit date and time in a human-readable format
            $commitDate = git -C $folder.FullName log -1 --format="%cd" --date=format-local:"%Y-%m-%d %H:%M:%S"

            # Create a custom object to store the data
            $repoInfo = [PSCustomObject]@{
                Name            = if ($FullName) { $folder.FullName } else { $folder.Name }
                Branch          = $branch
                LastCommitHash  = $commitHash
                LastCommitDate  = $commitDate
            }

            # Add the object to the list
            $repoInfoList += $repoInfo
        }
    }

    # Return the collected information as a table
    return $repoInfoList
}
