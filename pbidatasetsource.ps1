cls

﻿Login-PowerBI

# To intially test for one workspace uncomment the following lines and updated the workspace id and name

#$allworkspace = [PSCustomObject]@{
#id = '01234567-89ab-cdef-0123-456789abcdef'
#Name ='Test Workspace'
#}

#and comment the below line

$allworkspace = Get-PowerBIWorkspace -All -Scope Organization

function CheckConnectionString(){
    $datasrc = $args[2]
    $datasetname = $args[1]
    $workspacename = $args[0]
    Switch ($datasrc.datasourceType){
        'Oracle' {
            $fileentry = [pscustomobject]@{
            WorkspaceName = $workspacename
            DatasetName = $datasetname
            sourcetype = $datasrc.datasourceType
            connectionstring = ($datasrc.connectionDetails).server
            }
        }
        'Folder' {
            $fileentry = [pscustomobject]@{
            WorkspaceName = $workspacename
            DatasetName = $datasetname
            sourcetype = $datasrc.datasourceType
            connectionstring = ($datasrc.connectionDetails).Path
            }
        }
        'SAPHana' {
            $fileentry = [pscustomobject]@{
            WorkspaceName = $workspacename
            DatasetName = $datasetname
            sourcetype = $datasrc.datasourceType
            connectionstring = ($datasrc.connectionDetails).server
            }
        }
        'Sql' {
            $fileentry = [pscustomobject]@{
            WorkspaceName = $workspacename
            DatasetName = $datasetname
            sourcetype = $datasrc.datasourceType
            connectionstring = ($datasrc.connectionDetails).server
            }
        }
        'Salesforce' {
            $fileentry = [pscustomobject]@{
            WorkspaceName = $workspacename
            DatasetName = $datasetname
            sourcetype = $datasrc.datasourceType
            connectionstring = $datasrc.connectionDetails.loginServer
            }
        }
    }
    $fileentry | Export-Csv -Path PBIDatasetSources.csv -Append -NoTypeInformation -NoClobber
}

$allworkspace | %{
    $wrkspacename = $_.Name
    Write-Host "Checking Workspace :"$_.Name $_.Id 
    $datsets = Get-PowerBIDataset -WorkspaceId $_.Id

    foreach ($d in $datsets){

        if($d.IsOnPremGatewayRequired -eq 'True') {

            Write-Host "Checking datset connection :"$d.Id,$d.Name `n
            $gatewaydetails = (Invoke-PowerBIRestMethod -Method GET -Url "groups/$($_.Id)/datasets/$($d.Id)/Datasources" | ConvertFrom-Json).value 
            $datasetsources= $gatewaydetails | Select-Object datasourceType,connectionDetails
            if ($datasetsources.count -ge 2){
                foreach( $datasrc in $datasetsources){
                    CheckConnectionString $wrkspacename $d.Name $datasrc
                }

            }else{
               CheckConnectionString $wrkspacename $d.Name $datasetsources    
            }
        }
    }
    Write-Host `n
}
