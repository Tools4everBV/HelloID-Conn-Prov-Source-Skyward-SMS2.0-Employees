Write-Information "Processing Departments"

#Wait for VPN to open
Start-Sleep -s 5

#region Configuration
$config = ConvertFrom-Json $configuration;
$connectionString =  "DRIVER={Progress OpenEdge $($config.driver_version) driver};HOST=$($config.host_name);PORT=$($config.port);DB=$($config.database);UID=$($config.user);PWD=$($config.password);DIL=$($config.isolation_mode);AS=$($config.array_size);"

if($config.enableETWT) { $connectionString += "ETWT=1;" }
if($config.enableUWCT) { $connectionString += "UWCT=1;" }
if($config.enableKA) { $connectionString += "KA=1;" }
#endregion Configuration

#region Functions
function get_data_objects {
[cmdletbinding()]
Param (
[string]$connectionString,
[string]$query
   )
    Process
    {
        $conn = (new-object System.Data.Odbc.OdbcConnection);
        $conn.connectionstring = $connectionString;
        $conn.open();
 
        $cmd = (New-object System.Data.Odbc.OdbcCommand($query,$conn));
        $dataSet = (New-Object System.Data.DataSet);
        $dataAdapter = (New-Object System.Data.Odbc.OdbcDataAdapter($cmd));
        $dataAdapter.Fill($dataSet) | Out-Null
        $conn.Close()
 
        $result = $dataset.Tables[0];
 
        @($result);
    }
}
#endregion Functions

#region Execute
$buildingCodes = get_data_objects `
            -connectionString $connectionString `
            -query 'SELECT   "HAABLD-BLD-CODE"
						       , "HAABLD-SDESC"
						       , "HAABLD-DESC"
						       , "HAABLD-STATE-CODE"
						       , "HAABLD-SCHOOL-TYPE"
						FROM "PUB"."HAABLD-BLD-CODES"'

foreach($building in $buildingCodes)
{
   $row = @{
              ExternalId = $building.'HAABLD-BLD-CODE';
              DisplayName = $building.'HAABLD-DESC';
              Code = $building.'HAABLD-SDESC'
              CodeName = $building.'HAABLD-DESC';
    }
 
    $row | ConvertTo-Json -Depth 10
}
#endregion Execute

Write-Information "Finished Processing Departments"