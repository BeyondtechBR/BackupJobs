########################################################
# Nome     : fncBackupJobs.ps1
# Data     : 24/06/2020 
# Autor    : Alexandre Caneo
# Objetivo : Tem por objetivo extrair o script de cada
#            job de uma instância SQL Server.
# Versão   : 1.0
#
########################################################

# importação do módulo mFunction para utilização das funções contidas nele.
Import-Module -Name .\mFunctions 

function backup_jobs{
  param (
           [string]$instancia, 
           [string]$folder
          )

  # Instância a ser lida
  $ServerNameList = $instancia
   
  $Date = Get-Date -Format "yyyyMMdd"

  # Diretório para salvar os scripts
  $OutputFolder = $folder + "\" + $instancia + "\" + $Date
  Write-Host $OutputFolder

  # Se o diretório não existir, sertá criado.
  $DoesFolderExist = Test-Path $OutputFolder
  $null = if (!$DoesFolderExist){MKDIR "$OutputFolder"}
 
  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
 
  # cria um novo objeto para conexão com a instância.
  $objSQLConnection = New-Object System.Data.SqlClient.SqlConnection

  # loop para percorrer a instância
  foreach ($ServerName in $ServerNameList)
  {
 
    Try
    {
        $objSQLConnection.ConnectionString = "Server=$ServerName;Integrated Security=SSPI;"
        Write-Host "Tentando se conectar na instância do servidor $ServerName..." -NoNewline
        $objSQLConnection.Open() | Out-Null
        Write-Host "Conectado."
        $objSQLConnection.Close()
    }
    Catch
    {
        Write-Host -BackgroundColor Red -ForegroundColor White "Falha"
        $errText = $Error[0].ToString()
        if ($errText.Contains("network-related"))
            {Write-Host "Erro de conexão à instância. Por favor, verifique o nome do servidor digitado, porta ou firewall."}
 
        Write-Host $errText
        
        continue
 
    }
 
    $srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $ServerName
    
    # loop para percorrer todos os jobs
    $srv.JobServer.Jobs | foreach-object -process {
      $arq =$($_.Name -replace "\\", "")
#      $arq =$($arq -replace " ", "_")
#      $arq =$($arq -replace "-", "_")
#      $arq =$($arq -replace ":", "_")
#      $arq =$($arq -replace ".", "_")

      # tratamento do nome do arquivo para eliminar carctere especial
      $arq = Replace-SpecialChars -InputString $arq
      #Replace-SpecialChars -InputString $arq
  
      # gera o arquivo com o script do job
      out-file -filepath $("$OutputFolder\" + $($arq) + ".sql") -inputobject $_.Script() 
    }
  }
   
 
}

