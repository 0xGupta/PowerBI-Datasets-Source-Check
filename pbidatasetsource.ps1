#First authenticate to Power BI service using Login-PowerBI
Param(
    [Parameter()]
    [String]$WorkspaceId,
    [Parameter()]
    [switch]$CheckAllWorkspaces,
    [Parameter()]
    [switch]$ExportToFile,
    [Parameter()]
    [String]$FileName='PBIDatasetSources.csv',
    [Parameter()]
    [String]$WorkspaceName
)
if ($CheckAllWorkspaces.IsPresent){
    Write-Host 'Checking for all the workspaces'`n 'WorkspaceID if provided will be discarded' -ForegroundColor Yellow
    $allworkspace = Get-PowerBIWorkspace -All
}else{
    if ($WorkspaceId){
        Write-Host 'Checking for all dataset for workspaceid:' $WorkspaceId -ForegroundColor Cyan
        if ($WorkspaceName) {
            $allworkspace = [PSCustomObject]@{
            id = $WorkspaceId
            Name =$WorkspaceName
            }
        }else{
            Write-Host "Workspace name not provided, will be putting workspace name as NA" -ForegroundColor Yellow
            $allworkspace = [PSCustomObject]@{
            id = $WorkspaceId
            Name ='NA'
            }
        }
    }else{
        Write-Host "WorkspaceID not provided, exiting the process..." -ForegroundColor Red
        exit;
    }
}
if($exporttofile.IsPresent){
    Write-Host "Result will be exported in" $filename -ForegroundColor Green
    $showdisplay = 0
}else{
    Write-Host "Result will be displayed on screen" -ForegroundColor Green
    $showdisplay= 1
}

function CheckConnectionString(){
    $fileentry = [pscustomobject]@{
            WorkspaceName = $args[0]
            DatasetName = $args[1]
            SourceType = $args[2].datasourcetype
        }
    Switch ($args[2].datasourceType){
        'Oracle' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.server
        }
        'Folder' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.Path
        }
        'SAPHana' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.server
        }
        'Sql' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.server
        }
        'Salesforce' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.loginServer 
        }
        'SharePointList' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.url 
        }
        'Web' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.url 
        }
        'Extension' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.path 
        }
        'Exchange' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.emailAddress 
        }
        'SAPBWMessageServer' {
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.server 
        }
        'OData'{
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.url 
        }
        'File'{
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.path 
        }
        'AnalysisServices'{
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.server 
        }
        'ActiveDirectory'{
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.domain 
        }
        'GoogleAnalytics'{
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.path 
        }
        'OleDb'{
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.connectionString 
        }
        'ODBC'{
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.connectionString 
        }
        default{
            $fileentry | Add-Member -NotePropertyName connectionstring -NotePropertyValue $args[2].connectionDetails.server 
        }
    }
    if ($args[3] -eq 1){
        $fileentry
    }else{
        $fileentry | Export-Csv -Path $args[4] -Append -NoTypeInformation -NoClobber
    } 
}

$allworkspace | %{
    $wrkspacename = $_.Name
    Write-Host "Checking Workspace :"$_.Name $_.Id `n -ForegroundColor Yellow
    $datsets = Get-PowerBIDataset -WorkspaceId $_.Id

    foreach ($d in $datsets){
            Write-Host "Checking datset connection :$($d.Name) [ $($d.ID) ]" -ForegroundColor Cyan
            $gatewaydetails = (Invoke-PowerBIRestMethod -Method GET -Url "groups/$($_.Id)/datasets/$($d.Id)/Datasources" | ConvertFrom-Json).value 
            $datasetsources= $gatewaydetails | Select-Object datasourceType,connectionDetails
            if ($datasetsources.count -ge 2){
                foreach( $datasrc in $datasetsources){
                    CheckConnectionString $wrkspacename $d.Name $datasrc $showdisplay $FileName
                }
            }else{
                if ($datasetsources) {
                    CheckConnectionString $wrkspacename $d.Name $datasetsources $showdisplay $FileName
                }else{
                    Write-Host 'No datasource found' -ForegroundColor Red
                }
            }
        Write-Host
    }
}