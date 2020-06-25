########################################################
# Nome arquivo : fncBackupJobs.ps1
# Versão       : 1.0
# Data         : 25/06/2020 
# Autor        : Alexandre Caneo
# Objetivo     : Leitura e extração do scrips de todos
#                os jobs da instância SQL Server
########################################################

Import-Module -Name .\mFunctions 

function backup_jobs{
  param (
           [string]$instancia, 
           [string]$folder
          )

  # Instância a ser processada
  $ServerNameList = $instancia
   
  $Date = Get-Date -Format "yyyyMMdd"

  # Diretório para salvar os scripts
  $OutputFolder = $folder + "\" + $instancia + "\" + $Date
  Write-Host $OutputFolder
  $DoesFolderExist = Test-Path $OutputFolder
  $null = if (!$DoesFolderExist){MKDIR "$OutputFolder"}
 
  #Novo obejteto para conexão com o banco SQL Server
  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
 
  $objSQLConnection = New-Object System.Data.SqlClient.SqlConnection

  # loop para conexão com uma ou mais instâncias
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

    # o srv receberá o "objeto tipo instÂncia"
    $srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $ServerName
    
    # loop de todos os jobs 
    $srv.JobServer.Jobs | foreach-object -process {
      $arq =$($_.Name -replace "\\", "")
      # função para tratar caracteres especiais 
      $arq = Replace-SpecialChars -InputString $arq
  
      # geração do script do job em disco
      out-file -filepath $("$OutputFolder\" + $($arq) + ".sql") -inputobject $_.Script() 
    }
  }
   
 
}

