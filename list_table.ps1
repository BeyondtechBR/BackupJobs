########################################################
# Nome arquivo : list_table.ps1
# Versão       : 1.0
# Data         : 25/06/2020 
# Autor        : Alexandre Caneo
# Objetivo     : Leitura de uma tabela de uma instância
#                SQL Server
########################################################  
  
# parâmetros do progrma  
param (
       [string]$instancia, 
       [string]$folder
      )


# Recebe a instancia informada pelo parâmetro
$ServerNameList = $instancia #"SPDWVSQL002"
 
Write-Host $Date
 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
 
# String de conexão e banco a ser usado 
$database = “BeyondAdmin”
$connectionString = "Server=$ServerNameList;Database=$database;Integrated Security=SSPI;"

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

$connection.Open()

# Atributi à variável a query que será executada
$query = “SELECT distinct servidor FROM logins_eliminados " #where servidor in ('SPDWVSQL001','SPDWVSQL002','SPDWVSQL003')”

$command = $connection.CreateCommand()
$command.CommandText = $query

# execução da query
$result = $command.ExecuteReader()


# atribuição da tabela
$table = new-object “System.Data.DataTable”
$table.Load($result)

# leitura das linhas da tabela
$table | ForEach-Object {
           Write-Host $_.servidor
           . .\fncBackupJobs.ps1
 backup_jobs -instancia $_.servidor -folder $folder 

         }  
# fechando a conexão
$connection.Close()
