try {
    #--init
    $global:ErrorActionPreference = "Stop"
    $global:RootPath = split-path -parent $MyInvocation.MyCommand.Definition
    $global:json = Get-Content "$RootPath\config.json" -Raw | ConvertFrom-Json 
    
    #---init>gui-util
        Add-Type -AssemblyName System.Windows.Forms,System.Drawing
        Add-Type -AssemblyName PresentationCore,PresentationFramework
        $global:YesNoButton = [System.Windows.MessageBoxButton]::YesNo
        $global:OKButton = [System.Windows.MessageBoxButton]::OK
        $global:InfoIcon = [System.Windows.MessageBoxImage]::Information
        $global:WarningIcon = [System.Windows.MessageBoxImage]::Warning
        $global:ErrorIcon = [System.Windows.MessageBoxImage]::Error
        $global:QButton = [System.Windows.MessageBoxImage]::Question
        $objIcon = New-Object system.drawing.icon ("$RootPath\heart.ico")
        $GifFile_CompBackground= (Get-Item -Path "$RootPath\hello.gif")

        function ShowScreen {
            param (
                $Control
            )

            if ($Control -eq "TOA") {
                $btnStart.Show()
                $lblTOA.Show()
                $cbxTOA.Show()
                $lblMainMenu.Hide()
                $shpDivider.Hide()
                $btnCreate.Hide()
                $btnRead.Hide()
                $btnUpdate.Hide()
                $btnDelete.Hide()
                
            }elseif ($Control -eq "MainMenu") {
                $btnStart.Hide()
                $lblTOA.Hide()
                $cbxTOA.Hide()
                $lblMainMenu.Show()
                $shpDivider.Show()
                $btnCreate.Show()
                $btnRead.Show()
                $btnUpdate.Show()
                $btnDelete.Show()
                
            }
            else{}
            
        }
    
    function global:Get-Kill {
        param (
            $Mode
        )
        if ($Mode -eq "Hard") {
            $e = $_.Exception.GetType().FullName
            $line = $_.InvocationInfo.ScriptLineNumber
            $msg = $_.Exception.Message
            Write-Output "$(Get-Date -Format "HH:mm")[Error]: Initialization failed at line [$line] due [$e] `n`nwith details `n`n[$msg]`n"
            Write-Output "`n`n------------------END ROOT-------------------------"
            Stop-Transcript | Out-Null
            DisConEXO
            exit
        }else{
            Write-Output "`n`n------------------END ROOT-------------------------"
            Stop-Transcript | Out-Null
            ClearCreateCSV
            DisConEXO
            exit
        }
        
    }
    
    function global:ClearCreateCSV {
        Remove-Item -Path "$RootPath\create.csv"
        New-Item $RootPath\create.csv -ItemType File | Out-Null
        Set-Content $RootPath\create.csv 'Name,Purpose,Members'    
    }

    function SetToolMode {
        param (
            $Mode
        )
        If($Mode -eq "Enabled")
        {
            $btnCreate.enabled = $true
            $btnRead.enabled = $true
            $btnUpdate.enabled = $true
            $btnDelete.enabled = $true
        }else{
            $btnCreate.enabled = $false
            $btnRead.enabled = $false
            $btnUpdate.enabled = $false
            $btnDelete.enabled = $false
        }
    }

    #---init>m365 Util
    function global:ConEXO {

        try {
            Connect-ExchangeOnline | Out-Null
            Write-Host "$(Get-Date -Format "HH:mm")[Log]: EXO connected success"
        }
        catch {
            Write-Host "$(Get-Date -Format "HH:mm")[Error]: EXO connected failed"
            Get-Kill -Mode "Hard"
        }
        
    }
    function global:DisConEXO {

        try {
            Disconnect-ExchangeOnline -Confirm:$false | Out-Null
            Write-Host "$(Get-Date -Format "HH:mm")[Log]: EXO disconnected success"
        }
        catch {
            Write-Host "$(Get-Date -Format "HH:mm")[Error]: EXO disconnected  failed"
        }
        
    }

    function global:GetDL {
        param (
            $Identity
        )
        try {
            Get-DistributionGroup -Identity $Identity 
        }
        catch {
        }

        return
        
    }
    function global:GetDLMember {
        param (
            $Identity
        )
        try {
            Get-DistributionGroupMember -Identity $Identity 
        }
        catch {
        }

        return
        
    }

    function global:UpDLMember {
        param (
            $Identity
        )
        try {
            Add-DistributionGroupMember -Identity $Identity  
        }
        catch {
        }

        return
        
    }

    Start-Transcript -Path "$RootPath\Toolbox_localtime_$(Get-Date -Format "MMddyyyyHHmm").txt" | Out-Null
    
    Write-Output "`n`n------------------BEGIN ROOT-------------------------"
    Write-Output "$(Get-Date -Format "HH:mm")[Log]: Form init success"
    
    $ConResult = [System.Windows.MessageBox]::Show("Do you want to connect to EXO?","$($json.ToolName) $($json.ToolVersion)",$YesNoButton,$QButton)
    
    If($ConResult -eq "Yes")
    {
        ConEXO | Out-Null
        $EXOStatus = "(Online)"
    }else{
        $EXOStatus = "(Offline)"
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: EXO connection skipped"
    }



    #--form
    $IMG_CompBackground = [System.Drawing.Image]::fromfile($GifFile_CompBackground)
    $Gif_CompBackground = New-Object Windows.Forms.picturebox -Property @{
        Location = New-Object System.Drawing.Point(02,200)
        AutoSize = $true
        Size = New-Object System.Drawing.Size(400,400)
        Image = $IMG_CompBackground
    }
    #---form-assembly
    $form = New-Object Windows.Forms.Form -Property @{
        Size = New-Object System.Drawing.Size(485,460)
        Text = "$($json.ToolName) $($json.ToolVersion)"
        StartPosition = 'CenterScreen'
        BackColor = $json.ToolUIBackColor
        FormBorderStyle = 'Fixed3D'
        Icon = $objIcon
    }
    $lblTOA = New-Object System.Windows.Forms.Label -Property @{
        Location = New-Object System.Drawing.Point(85,50)
        Size = New-Object System.Drawing.Size(290,150)
        ForeColor = $json.ToolUILabelColorDark
        BackColor = $json.ToolUIBackColorDark
        Text = "$($json.ToolTOAText)"
    }

    $cbxTOA = New-Object System.Windows.Forms.Checkbox -Property @{
        Location = New-Object System.Drawing.Point(90,200)
        Size = New-Object System.Drawing.Size(500,20)
        ForeColor = $json.ToolUILabelColorDark
        Text = "Do not show this again"
    }

    $btnStart = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(160,240)
        Size = New-Object System.Drawing.Size(125,50)
        ForeColor = $json.ToolUILabelColor
        BackColor = $json.ToolUIBtnColor
        Text = 'START'      
    }

    $btnStart.Add_Click({
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: TOA confirm success"
        #TOA hide?
        If ($cbxTOA.Checked -eq $true)
        {
            $json.ToolShowTOA = "False"
            $json | ConvertTo-Json | Out-File "$RootPath\config.json"
        }else{}

        ShowScreen -Control "MainMenu"
    })

    $shpDivider = New-Object System.Windows.Forms.Label -Property @{
        Location = New-Object System.Drawing.Point(30,50)
        Size = New-Object System.Drawing.Size(400,2)
        Text = ""
        BorderStyle = 'Fixed3D'
    }
    $lblMainMenu = New-Object System.Windows.Forms.Label -Property @{
        Location = New-Object System.Drawing.Point(30,30)
        Size = New-Object System.Drawing.Size(280,20)
        Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9,[System.Drawing.FontStyle]::Bold)
        Text = "Group Management Tools $EXOStatus"
    }
    $btnCreate = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(30,70)
        Size = New-Object System.Drawing.Size(125,50)
        ForeColor = $json.ToolUILabelColor
        BackColor = $json.ToolUIBtnColor
        Text = 'CREATE'      
    }

    $form2 = New-Object System.Windows.Forms.Form -Property @{
        Text = "$($json.ToolName) $($json.ToolVersion)"
        Size = New-Object System.Drawing.Size(500,500)
        StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
        FormBorderStyle = 'Fixed3D'
        Icon = $objIcon
    }

    $form3 = New-Object System.Windows.Forms.Form -Property @{
        Text = "$($json.ToolName) $($json.ToolVersion)"
        Size = New-Object System.Drawing.Size(500,500)
        StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
        FormBorderStyle = 'Fixed3D'
        Icon = $objIcon
    }
    
    $readbutton = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(185,250)
        Size = New-Object System.Drawing.Size(125,50)
        ForeColor = $json.ToolUILabelColor
        BackColor = $json.ToolUIBtnColor
        Text = "Read DL"
    }

    $updbutton = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(185,250)
        Size = New-Object System.Drawing.Size(125,50)
        ForeColor = $json.ToolUILabelColor
        BackColor = $json.ToolUIBtnColor
        Text = "Update DL"
    }

    $textBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location = New-Object System.Drawing.Point(125,215)
        Size = New-Object System.Drawing.Size(250,50)
    }

    $textBox2 = New-Object System.Windows.Forms.TextBox -Property @{
        Location = New-Object System.Drawing.Point(125,215)
        Size = New-Object System.Drawing.Size(250,50)
    }

    $readlabel = New-Object System.Windows.Forms.Label -Property @{
        Text = "Please Enter DL:"
        Size = New-Object System.Drawing.Size(215,225)
        Location = New-Object System.Drawing.Point(185,175)
        Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9,[System.Drawing.FontStyle]::Bold)
}

$updlabel = New-Object System.Windows.Forms.Label -Property @{
    Text = "Please Enter DL:"
    Size = New-Object System.Drawing.Size(215,225)
    Location = New-Object System.Drawing.Point(185,175)
    Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9,[System.Drawing.FontStyle]::Bold)
}

    $btnCreate.Add_Click({
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: CREATE selected"
        Import-Module "$RootPath\create.ps1" -Force
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: CREATE function imported"
        CreateDL
        Write-Host "`n`n$(Get-Date -Format "HH:mm")[Log]: CREATE function completed"
        [System.Windows.MessageBox]::Show("CREATE function completed","$($json.ToolName) $($json.ToolVersion)",$OKButton,$InfoIcon)
    })

    $btnRead = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(175,70)
        Size = New-Object System.Drawing.Size(125,50)
        ForeColor = $json.ToolUILabelColor
        BackColor = $json.ToolUIBtnColor
        Text = 'READ'      
    }
    $btnRead.Add_Click({
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: Read selected"
        Import-Module "$RootPath\read.ps1" -Force
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: READ function imported"

                 $form2.ShowDialog()
                $updbutton.Show()
                $textBox.Show()
                $readlabel.Show()
    })

    $readbutton.Add_Click( {
        ReadDL
        Write-Host "`n`n$(Get-Date -Format "HH:mm")[Log]: Clearing reading.txt file"
        Clear-Content -path "$RootPath\reading.txt"
        Write-Host "`n`n$(Get-Date -Format "HH:mm")[Log]: READ function completed"
        [System.Windows.MessageBox]::Show("READ function completed","$($json.ToolName) $($json.ToolVersion)",$OKButton,$InfoIcon)
                $form2.Close()
                $updbutton.Hide()
                $textBox.Hide()
                $readlabel.Hide()
    })


    $btnUpdate = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(30,140)
        Size = New-Object System.Drawing.Size(125,50)
        ForeColor = $json.ToolUILabelColor
        BackColor = $json.ToolUIBtnColor
        Text = 'UPDATE'     
    } 

        $btnUpdate.Add_Click({
            Write-Host "$(Get-Date -Format "HH:mm")[Log]: UPDATE selected"
            Import-Module "$RootPath\update.ps1" -Force
            Write-Host "$(Get-Date -Format "HH:mm")[Log]: UPDATE function imported"
    
                     $form3.ShowDialog()
                    $updbutton.Show()
                    $textBox2.Show()
                    $updlabel.Show()
                    
        })
        $updbutton.Add_Click( {
            CheckCreatememlist
            UpdateDL
            Write-Host "`n`n$(Get-Date -Format "HH:mm")[Log]: Clearing memberlist.txt file"
            Clear-Content -path "$RootPath\memberlist.txt" 
            Write-Output "Member" | Out-File -Filepath "$RootPath\memberlist.txt"
            Write-Host "`n`n$(Get-Date -Format "HH:mm")[Log]: UPDATE function completed"
            [System.Windows.MessageBox]::Show("UPDATE function completed","$($json.ToolName) $($json.ToolVersion)",$OKButton,$InfoIcon)
                    $form3.Close()
                    $updbutton.Hide()
                    $textBox2.Hide()
                    $updlabel.Hide()
        })
    
    $btnDelete = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(175,140)
        Size = New-Object System.Drawing.Size(125,50)
        ForeColor = $json.ToolUILabelColor
        BackColor = $json.ToolUIBtnColor
        Text = 'DELETE'      
    }

    If($ConResult -eq "Yes")
    {
        SetToolMode -Mode "Enabled"
    }else{
        SetToolMode -Mode "Disabled"
    }

    #---form-render
    $form.Controls.Add($lblTOA)
    $form.Controls.Add($btnStart) 
    $form.Controls.Add($cbxTOA) 
    $form.Controls.Add($shpDivider)
    $form.Controls.Add($lblMainMenu)
    $form.Controls.Add($btnCreate)
    $form.Controls.Add($btnRead)
    $form.Controls.Add($btnUpdate)
    $form.Controls.Add($btnDelete)
    $form2.Controls.Add($readbutton)
    $form2.Controls.Add($textBox)
    $form2.Controls.Add($readlabel)
    $form3.Controls.Add($updbutton)
    $form3.Controls.Add($textBox2)
    $form3.Controls.Add($updlabel)

   

    If($json.ToolShowTOA -eq "True")
    {
        ShowScreen -Control "TOA"
    }else{
        ShowScreen -Control "MainMenu"
    }
    $form.Controls.Add($Gif_CompBackground)
    $Gif_CompBackground.SendToBack()
    $form.ShowDialog() | Out-Null
    Write-Host "$(Get-Date -Format "HH:mm")[Log]: Form closed"
    
    Get-Kill 
}
catch {
    Get-Kill -Mode "Hard"
}