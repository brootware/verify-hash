# Get the directory where this script/command is being executed from.
# $PSScriptRoot is an automatic variable that provides this path.
$currentDirectory = $PSScriptRoot

# Define the path to the current user's PowerShell profile.
# This is typically located at: C:\Users\<YourUsername>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
$profilePath = $profile

Write-Host "Looking for *.psm1 files in: $currentDirectory"
Write-Host "Your PowerShell profile is located at: $profilePath"

# Ensure the directory for the profile exists.
try {
    $profileDirectory = Split-Path $profilePath
    if (-not (Test-Path $profileDirectory)) {
        New-Item -Path $profileDirectory -ItemType Directory -Force | Out-Null
        Write-Host "Created profile directory: $profileDirectory"
    }
} catch {
    Write-Error "Failed to ensure profile directory exists. Error: $($_.Exception.Message)"
}

# Get all .psm1 files in the current directory.
$psm1Files = Get-ChildItem -Path $currentDirectory -Filter "*.psm1" -File

if ($psm1Files.Count -eq 0) {
    Write-Warning "No *.psm1 files found in '$currentDirectory'. No changes made to profile."
} else {
    # Read existing profile content, if any
    $existingProfileContent = ""
    if (Test-Path $profilePath) {
        $existingProfileContent = Get-Content -Path $profilePath -Raw
    }

    foreach ($file in $psm1Files) {
        $fullPath = $file.FullName
        $importCommand = "Import-Module `"$fullPath`"" # Use backticks for escaping quotes within the string

        # Check if the import command already exists in the profile to avoid duplicates
        if ($existingProfileContent -notlike "*$($importCommand)*") {
            try {
                Add-Content -Path $profilePath -Value $importCommand
                Write-Host "Added '$importCommand' to your PowerShell profile."
            } catch {
                Write-Error "Failed to append to profile '$profilePath'. Error: $($_.Exception.Message)"
            }
        } else {
            Write-Host "Skipping '$importCommand': Already exists in your PowerShell profile."
        }
    }

    Write-Host "`nProfile updated. Please restart your PowerShell session(s) for changes to take effect."
    Write-Host "You can verify the contents of your profile by typing 'Get-Content $profilePath'."
}