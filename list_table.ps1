  param (
           [string]$instancia, 
           [string]$folder
          )


$ServerNameList = $instancia #"SPDWVSQL002"
 
Write-Host $Date
 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
 
$database = “BeyondAdmin”
$connectionString = "Server=$ServerNameList;Database=$database;Integrated Security=SSPI;"


$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

$connection.Open()

#Alright. We set up our connection, and opened in. Houston we are in the building ( I know I can’t say that, but it’s my story).
#Time to tell that lousy SQL Server what to do, let’s create some commands to our little spinning server slave.

$query = “SELECT distinct servidor FROM logins_eliminados " #where servidor in ('SPDWVSQL001','SPDWVSQL002','SPDWVSQL003')”

$command = $connection.CreateCommand()
$command.CommandText = $query

$result = $command.ExecuteReader()

#We’ll get all the people, and worry about how to sort them out later.
#Of course we want this nicely formatted, and so we’ll use a DataTable which gives us an in-memory table with the data, and we need to create it first then load it.

$table = new-object “System.Data.DataTable”
$table.Load($result)

#Once we output the information we want to not use the column names, to boring. We want our own table, so we will create a variable called format that defines how we want our table to look like. We want the Id column to be named User Id, and we set a smaller width, and Name to be Identified Swede.

#$format = @{Expression={$_.servidor};Label=”Servidor”;width=100}

#We have all our people. Now we need to identify the Swedes that are born earlier than 1990. And how are identifying Swedes? Easy, we are so unimaginative (or traditional) that all our surnames end in sson.

$table | ForEach-Object {
           Write-Host $_.servidor
           . .\fncBackupJobs.ps1
 backup_jobs -instancia $_.servidor -folder $folder 

         }  

$connection.Close()