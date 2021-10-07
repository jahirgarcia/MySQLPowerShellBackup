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
  $Path = "$Path/$Dir"

  New-Item -Path $Path -ItemType Directory -ErrorAction SilentlyContinue > $null
  Set-Location $Path

  mysql -h $Host --port $Port -u $User --password=$Password -N -e 'show databases' | ForEach-Object {
    $Database=$_

    if( $ExcludedDatabases -contains $Database ) {
      Write-Output "Se omitio $Database"
    } else {

      mysqldump -h $Host --port $Port -u $User --password=$Password `
      -R $Database > "$Database.sql"

      if( $LastExitCode -eq 0 ) {
        Write-Output "Respaldo de $Database completado con exito"
      } else {
        Write-Output "No se pudo completar el respaldo de $Database"
      }
    }
  }
}

Export-ModuleMember -Function Backup
