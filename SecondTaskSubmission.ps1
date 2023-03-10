try {
    #--init
    $global:ErrorActionPreference = "Stop"
    $global:RootPath = split-path -parent $MyInvocation.MyCommand.Definition
    $json = Get-Content "$RootPath\config.json" -Raw | ConvertFrom-Json 
    $counter = 0 

    

    function Get-Kill {
        param (
            $Mode
        )
        if ($Mode -eq "Hard") {
            $e = $_.Exception.GetType().FullName
            $line = $_.InvocationInfo.ScriptLineNumber
            $msg = $_.Exception.Message
            Write-Output "$(Get-Date -Format "HH:mm")[Error]: Initialization failed at line [$line] due [$e] `n`nwith details `n`n[$msg]`n"
            Write-Output "`n`n------------------END-------------------------"
            Stop-Transcript | Out-Null
            ClearCreateCSV
            exit
        }else{
            Write-Output "`n`n------------------END-------------------------"
            Stop-Transcript | Out-Null
            ClearCreateCSV
            exit
        }
        
    }

    function CheckCreateCSV {
        $global:CreateCSV = Import-Csv -Path "$RootPath\create.csv"
        
        $missingValue = $false
        foreach ($c in $CreateCSV){
          if ($c.Name -eq "" -or $c.Members -eq "" -or $c.Purpose -eq "") {
            $missingValue = $true
            break
          }
        }
      
        if ($missingValue) {
          Write-Output "$(Get-Date -Format "HH:mm")[Error]: Missing value in the create.csv file. Aborting."
          Stop-Transcript | Out-Null
          exit
        }
    }

    function ClearCreateCSV {
         $global:CreateCSV = Import-Csv -Path "$RootPath\create.csv"
        $CreateCSV | ForEach-Object {
            $_.Name = ""
            $_.Members = ""
            $_.Purpose = ""
          }
          $CreateCSV | Export-Csv -Path "$RootPath\create.csv" -NoTypeInformation   
    }

    Start-Transcript -Path "$RootPath\Create_localtime_$(Get-Date -Format "MMddyyyyHHmm").txt" | Out-Null
    
    Write-Output "`n`n------------------BEGIN-------------------------"
    Write-Output "$(Get-Date -Format "HH:mm")[Log]: Initialization success"
    CheckCreateCSV
    foreach($c in $CreateCSV){
        #--transform
        Write-Output "`n$(Get-Date -Format "HH:mm")[Log]: Transforming data"
        $NoCharsItem = $(($($c.Name).TrimEnd()).TrimStart())  -replace '[\W]', '' #remove whitespace and special chars
        #--assembly
        Write-Output "$(Get-Date -Format "HH:mm")[Log]: Assembling output"
        $AssembledObj = [PSCustomObject]@{
            Name = $NoCharsItem
            DisplayName  = $json.DisplayNamePrefix + $NoCharsItem
            PrimarySmtpAddress  = $($json.AliasPrefix + $($NoCharsItem.ToLower())) + "@" + $json.DomainName #join and convert to lowercases
            Description = "`n Created at: " + $env:COMPUTERNAME + "`n Created by: " + $env:USERNAME + "`n Created on: "  + ($(Get-Date)) + "`n`n=========`n" + $c.Purpose
            Members = ($c.Members) -split (',') #turm members to array
        }
        #--output
        $counter++
        Write-Output "`n------------------OUTPUT($counter)-------------------------"
        foreach ($currentItemName in $(@("Name","DisplayName","PrimarySmtpAddress","Description","Members")) ) {
            Write-Host "`n`n $($currentItemName):" -foregroundcolor Cyan
            $AssembledObj.$($currentItemName)
        }
        if ($($AssembledObj.Members).length -gt 0) {
            
        }else{
            Write-Host "No members found" -foregroundcolor Yellow
        }
    }
    Get-Kill 
}
catch {
    Get-Kill -Mode "Hard"
}