function Replace-SpecialChars {
    param(
        [string]$InputString,
        [string]$Replacement  = "_",
        [string]$SpecialChars = ".:- #?()[]{}<>/"
    )

    $rePattern = ($SpecialChars.ToCharArray() |ForEach-Object { [regex]::Escape($_) }) -join "|"
    $InputString -replace $rePattern,$Replacement
}
