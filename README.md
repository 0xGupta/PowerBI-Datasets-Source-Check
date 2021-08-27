## Check Power BI Dataset Source

The script will help PBI users to check the datasources. The script will save the data in current working directory with name PBIDatasetSources.csv

As of now only following datasource check are added
- Salesforce
- Oracle
- Folder
- Sql
- SAPHana
- SharePointList
- Web
- Exchange
- Extension

### Usage

Copy the file in one of the environment path, check the paths
```PowerShell
$env:Path.split(':')
```

Before running script user need to be authenticated
```Powershell
Login-PowerBI
```

###### Params Defination
```
-CheckAllWorkspaces : Check All workspaces 
-WorkspaceId : Check Datasets only specific to the workspaceID
-WorkspaceName : Specify workspace name when id is provided, default 'NA' will be displayed
-ExportToFile : Export data in csv file 
-FileName : Specify the csv file name
```

###### Run Script
Check All Workspace and save in file
```PowerShell
pbidatasetsource.ps1 -CheckAllWorkspaces -ExportToFile -FileName output.csv
```
Check All Workspace and show result on display
```PowerShell
pbidatasetsource.ps1 -CheckAllWorkspaces 
```
Check specific Workspace datasets with name provided
```PowerShell
pbidatasetsource.ps1 -WorkspaceId '01234567-89ab-cdef-0123-456789abcdef' -WorkspaceName 'Test Workspace'
```
Check specific Workspace datasets without providing name
```PowerShell
pbidatasetsource.ps1 -WorkspaceId '01234567-89ab-cdef-0123-456789abcdef'
```
