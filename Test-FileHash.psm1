<#
.SYNOPSIS
    Verifies a file's hash against an expected value.
.DESCRIPTION
    This function computes the hash of a specified file using a given algorithm
    and compares it (case-insensitively) to an expected hash string.
    It prints a color-coded "OK" or "Failed" message, similar to the
    original verify-hash.sh script.
.PARAMETER Algorithm
    The hash algorithm to use. This is passed to Get-FileHash.
    Supported values: SHA1, SHA256, SHA384, SHA512, MD5.
.PARAMETER FilePath
    The path to the file to verify.
.PARAMETER ExpectedHash
    The expected hash string to compare against.
.EXAMPLE
    Test-FileHash -Algorithm SHA256 -FilePath "C:\iso\image.iso" -ExpectedHash "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

    This will compute the SHA256 hash of image.iso and compare it to the provided string.
.EXAMPLE
    Test-FileHash SHA512 ".\my-document.zip" "long-hash-string-here"

    You can also use positional parameters.
.NOTES
    Comparison is case-insensitive.
    The function name `Test-FileHash` follows the standard PowerShell
    Verb-Noun naming convention.
#>
function Test-FileHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5')]
        [string]$Algorithm,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateScript({
            if (Test-Path -Path $_ -PathType Leaf) {
                return $true
            }
            else {
                throw "File not found: $_"
            }
        })]
        [string]$FilePath,

        [Parameter(Mandatory = $true, Position = 2)]
        [string]$ExpectedHash
    )

    process {
        Write-Host "Computing hash for: $FilePath (Algorithm: $Algorithm)"

        try {
            # Get the hash object from PowerShell and select only the hash string
            $computedHash = (Get-FileHash -Path $FilePath -Algorithm $Algorithm -ErrorAction Stop).Hash

            # Normalize both to lowercase for a case-insensitive comparison
            $computedHashLower = $computedHash.ToLower()
            $expectedHashLower = $ExpectedHash.ToLower()

            Write-Host "Computed hash: $computedHashLower"
            Write-Host "Given hash:    $expectedHashLower"

            if ($computedHashLower -eq $expectedHashLower) {
                Write-Host -ForegroundColor Green "OK: Keys match correctly."
            }
            else {
                Write-Host -ForegroundColor Red "Failed: Keys don't match."
            }
        }
        catch {
            # This will catch errors from Get-FileHash (e.g., permissions error)
            Write-Error "Failed to compute hash: $_"
        }
    }
}

# Export the function from the module so it can be imported
Export-ModuleMember -Function Test-FileHash