$ExcludedDatabases = "mysql", "phpmyadmin", "information_schema", "performance_schema"

function Backup {

  param (
    [int] $Port = 3306,
    [string] $Password,
    [string[]] $Exclude,
    [string] $User = "root",
    [string] $Host = "localhost",
    [string] $Path = "$Home/Backups"
  )

  $ExcludedDatabases = $ExcludedDatabases + $Exclude
  
  $Dir = Get-Date -Format "yyyy-MM-dd"

  New-Item -Path "$Path/$Dir" -ItemType Directory -ErrorAction SilentlyContinue > $null

  mysql -h $Host --port $Port -u $User --password=$Password -N -e 'show databases' | ForEach-Object {
    $Database = $_

    if( $ExcludedDatabases -contains $Database ) {
      Write-Output "Se omitio $Database"
    } else {

      mysqldump -h $Host --port $Port -u $User --password=$Password `
      -R $Database > "$Path/$Dir/$Database.sql"

      if( $LastExitCode -eq 0 ) {
        Write-Output "Respaldo de $Database completado con exito"
      } else {
        Write-Output "No se pudo completar el respaldo de $Database"
      }
    }
  }

  Compress-Archive -Path "$Path/$Dir/*.sql" -Update -DestinationPath "$Path/$Dir.zip"
  Remove-Item -Path "$Path/$Dir" -Recurse
}

Export-ModuleMember -Function Backup
