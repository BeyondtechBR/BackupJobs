########################################################
# Nome arquivo : mFunctions.ps1
# Versão       : 1.0
# Data         : 25/06/2020 
# Autor        : Alexandre Caneo
# Objetivo     : Esse é um módulo que conterá várias funções
# Funções      : 
#  - Replace-SpecialChars : eliminar caracteres especiais da string
########################################################  


function Replace-SpecialChars {
    param(
        [string]$InputString,
        [string]$Replacement  = "_",
        [string]$SpecialChars = ".:- #?()[]{}<>/"
    )

    $rePattern = ($SpecialChars.ToCharArray() |ForEach-Object { [regex]::Escape($_) }) -join "|"
    $InputString -replace $rePattern,$Replacement
}
