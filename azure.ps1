# Last step on Create a linked service
# https://docs.microsoft.com/en-us/azure/data-factory/quickstart-create-data-factory-powershell

Select-AzureRmSubscription -SubscriptionId "Nutzungsbasierte Bezahlung" 
$resourceGroupName = "ADFQuickStartRG";
$ResGrp = New-AzureRmResourceGroup $resourceGroupName -location 'West Europe'
$dataFactoryName = "ADFQuickStartFactoryV1AVOIDCONFLICT";
$DataFactory = Set-AzureRmDataFactoryV2 -ResourceGroupName $ResGrp.ResourceGroupName -Location $ResGrp.Location -Name $dataFactoryName
Set-Location 'C:\ADFv2QuickStartPSH'
Set-AzureRmDataFactoryV2LinkedService -DataFactoryName $dataFactoryName -ResourceGroupName $ResGrp.ResourceGroupName -Name "AzureStorageLinkedService" -DefinitionFile ".\AzureStorageLinkedService.json"
Set-AzureRmDataFactoryV2Dataset -DataFactoryName $DataFactory.DataFactoryName -ResourceGroupName $ResGrp.ResourceGroupName -Name "BlobDataset" -DefinitionFile ".\BlobDataset.json"
$DFPipeLine = Set-AzureRmDataFactoryV2Pipeline -DataFactoryName $DataFactory.DataFactoryName -ResourceGroupName $ResGrp.ResourceGroupName -Name "Adfv2QuickStartPipeline" -DefinitionFile ".\Adfv2QuickStartPipeline.json"
# Save from output to inpurt
$RunId = Invoke-AzureRmDataFactoryV2Pipeline 
-DataFactoryName $DataFactory.DataFactoryName 
-ResourceGroupName $ResGrp.ResourceGroupName 
-PipelineName $DFPipeLine.Name 
-ParameterFile .\PipelineParameters.json

# Run
while ($True) {
    $Run = Get-AzureRmDataFactoryV2PipelineRun -ResourceGroupName $ResGrp.ResourceGroupName -DataFactoryName $DataFactory.DataFactoryName -PipelineRunId $RunId

    if ($Run) {
        if ($run.Status -ne 'InProgress') {
            Write-Output ("Pipeline run finished. The status is: " +  $Run.Status)
            $Run
            break
        }
        Write-Output  "Pipeline is running...status: InProgress"
    }

    Start-Sleep -Seconds 10
}

# 2. 
Write-Output "Activity run details:"
$Result = Get-AzureRmDataFactoryV2ActivityRun -DataFactoryName $DataFactory.DataFactoryName -ResourceGroupName $ResGrp.ResourceGroupName -PipelineRunId $RunId -RunStartedAfter (Get-Date).AddMinutes(-30) -RunStartedBefore (Get-Date).AddMinutes(30)
$Result

Write-Output "Activity 'Output' section:"
$Result.Output -join "`r`n"

Write-Output "Activity 'Error' section:"
$Result.Error -join "`r`n"

# Clean Data Factory
Remove-AzureRmDataFactoryV2 -Name $dataFactoryName -ResourceGroupName $resourceGroupName

# Clean Resources
Select-AzureRmSubscription -SubscriptionId "Nutzungsbasierte Bezahlung" 
$resourceGroupName = "ADFQuickStartRG";
Remove-AzureRmResourceGroup -ResourceGroupName $resourcegroupname