# Authored by Bruce https://github.com/brootware
function Verify-Hash {
    param(
        [string]$hash_algo,
        [string]$file,
        [string]$source_hash
    )
    $RED = [ConsoleColor]::Red
    $GREEN = [ConsoleColor]::Green

    if ($args.Length -ne 3) {
        Write-Host "Illegal parameters: run '$($MyInvocation.MyCommand.Name) -h' for usage."
        exit
    }

    $sha_compute = (Get-FileHash $args[1] -Algorithm $args[0]).Hash.ToLower()
    $sha_generate = $args[2].ToLower()

    Write-Host "Computed hash: $sha_compute"
    Write-Host "Given hash:    $sha_generate"

    if ($sha_compute -eq $sha_generate) {
        Write-Host -ForegroundColor $GREEN "OK: Keys match correctly."
    } else {
        Write-Host -ForegroundColor $RED "Failed: Keys don't match."
    }
}

Export-ModuleMember -Function Verify-Hash