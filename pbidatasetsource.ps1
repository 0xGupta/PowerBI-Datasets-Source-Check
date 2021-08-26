cls

﻿Login-PowerBI

# To intially test for one workspace uncomment the following lines and updated the workspace id and name

#$allworkspace = [PSCustomObject]@{
#id = '01234567-89ab-cdef-0123-456789abcdef'
#Name ='Test Workspace'
#}

#and comment the below line

$allworkspace = Get-PowerBIWorkspace -All

function CheckConnectionString(){
    $datasrc = $args[2]
    $datasetname = $args[1]
    $workspacename = $args[0]
    $fileentry = [pscustomobject]@{
            WorkspaceName = $workspacename
            DatasetName = $datasetname
            SourceType = $datasrc.datasourcetype
        }
    Switch ($datasrc.datasourceType){
        'Oracle' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue ($datasrc.connectionDetails).server
        }
        'Folder' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue ($datasrc.connectionDetails).Path
        }
        'SAPHana' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue ($datasrc.connectionDetails).server
        }
        'Sql' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue ($datasrc.connectionDetails).server
        }
        'Salesforce' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $datasrc.connectionDetails.loginServer 
        }
        'SharePointList' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $datasrc.connectionDetails.url 
        }
        'Web' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $datasrc.connectionDetails.url 
        }
        'Extension' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $datasrc.connectionDetails.path 
        }
        'Exchange' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $datasrc.connectionDetails.emailAddress 
        }
    }
    $fileentry | Export-Csv -Path PBIDatasetSources.csv -Append -NoTypeInformation -NoClobber
}

$allworkspace | %{
    $wrkspacename = $_.Name
    Write-Host "Checking Workspace :"$_.Name $_.Id `n -ForegroundColor Yellow
    $datsets = Get-PowerBIDataset -WorkspaceId $_.Id

    foreach ($d in $datsets){
            Write-Host "Checking datset connection :"$d.Id,$d.Name -ForegroundColor Cyan
            $gatewaydetails = (Invoke-PowerBIRestMethod -Method GET -Url "groups/$($_.Id)/datasets/$($d.Id)/Datasources" | ConvertFrom-Json).value 
            $datasetsources= $gatewaydetails | Select-Object datasourceType,connectionDetails
            if ($datasetsources.count -ge 2){
                foreach( $datasrc in $datasetsources){
                    CheckConnectionString $wrkspacename $d.Name $datasrc
                }

            }else{
                if ($datasetsources) {
                    CheckConnectionString $wrkspacename $d.Name $datasetsources
                }else{
                    Write-Host 'No datasource found' -ForegroundColor Red
                }
            }
        Write-Host
    }
}