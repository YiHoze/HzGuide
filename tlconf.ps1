[CmdletBinding()]
param (
    # [Parameter(Position=0 Mandatory=$false)]
    [alias('h')][switch] $help = $false,
    [alias('t')][switch] $texmfhome = $false,
    [alias('e')][switch] $texedit = $false,
    [alias('s')][switch] $sumatrapdf = $false,
    [alias('b')][switch] $batch = $false,
    [alias('c')][switch] $conf = $false,
    [string] $arg
)

function help()
{
    write-output "
tlconf.ps1 -t, -texmfhome [path]
    Set the TEXMFHOME environment variable. The default is
    C:\home\texmf
tlconf.ps1 -e, -texedit [path]
    Set the TEXEIDT environment variable. The default is
    code.exe -r -g  %s:%d
tlconf.ps1 -s, -sumatrapdf [path]
    Set the inverse search command-line option of SumatraPDF. The  defalt is
    code.exe -r -g  %f:%l
tlconf.ps1 -c, -conf
    Create local.conf that contains the user's local font directory. The default is
    C:\texlive\2022\texmf-var\fonts\conf\local.conf
tlconf.ps1 -b, -batch
    Perform all the settings.
"
}

function SetTexmfhome()
{
    if (!$arg) {
        $path = "C:\home\texmf"
    } else {
        $path = $arg
    }

    $question = "Are you sure to set the TEXMFHOME environment variable with '{0}'?`nEnter Y to proceed, n to abandon, or another path" -f $path
    $answer = Read-Host $question
    if ($answer.ToLower() -eq 'n') { 
        Exit 
    } elseif ( -not($answer.ToLower() -eq 'y' -or $answer -eq '')) {
        $path = $answer
    }

    if (Test-Path $path) {
        $env:TEXMFHOME = $path
        write-output "$env:TEXMFHOME is set to TEXMFHOME."
    } else {
        write-output "$path does not exist."
    }
}
function SetTexedit()
{
    if (!$arg) {
        $editor = "code.exe -r -g %s:%d"
    } else {
        $editor = $arg
    }

    $question = "Are you sure to set the TEXEDIT environment variable with '{0}'?`nEnter Y to proceed, n to abandon, or another text editor with its options" -f $editor
    $answer = Read-Host $question
    if ($answer.ToLower() -eq 'n') { 
        Exit 
    } elseif ( -not($answer.ToLower() -eq 'y' -or $answer -eq '')) {
        $editor = $answer
    }

    $env:TEXEDIT = $editor
    write-output "$env:TEXEDIT is set to TEXEDIT."
}

function SetSumatrapdf()
{
    $installed = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -Contains 'SumatraPDF'
    if (!$installed) {
        Write-Host "SumatraPDF is not installed."
        Exit
    }
    if ($env:Path -contains 'SumatraPDF') {
        $path = 'SumatraPDF.exe'
    } else {
        $path = Read-Host "SumatraPDF is not in the PATH environment variable.`nEnter the full path of SmatraPDF"
        if (!$path) {
            Exit 
        }
        if (-not(Test-Path -Path $path)){
            write-output "'$path' is not found."
            Exit 
        }
    }

    if (!$arg) {
        $editor = 'code.exe -r -g  %f:%l'
    } else {
        $editor = $arg
    }

    $question = "Are you sure to use '{0}' to enable the inverse search feature of SumatraPDF?`nEnter Y to proceed, n to abandon, or another text editor with its options" -f $editor
    $answer = Read-Host $question
    if ($answer.ToLower() -eq 'n') {
        Exit
    } elseif ( -not($answer.ToLower() -eq 'y' -or $answer -eq '')) {
        $editor = $answer
    }

    $cmd = "{0} -inverse-search '{1}'" -f $path, $editor
    Write-Output $cmd
    Invoke-Expression $cmd
}

function CreateLocalconf {
    $path = "C:\texlive\2022\texmf-var\fonts\conf\local.conf"
    $content = "<dir>C:/Users/{0}/AppData/Local/Microsoft/Windows/Fonts</dir>" -f $env:USERNAME

    $question = "{0} will be created, containing '{1}'`nEnter Y to proceed, n to abandon, or another path" -f $path, $content

    $answer = Read-Host $question
    if ($answer.ToLower() -eq 'n') {
        Exit
    } elseif ( -not($answer.ToLower() -eq 'y' -or $answer -eq '')) {
        $path = $answer
    }

    $cmd = "Add-Content -Path {0} -Value '{1}'" -f $path, $content
    Write-Output $cmd
    Invoke-Expression $cmd
}

try {
    $tlroot = &kpsewhich -var-value=TEXMFROOT
    $tlroot = $tlroot.replace('/', '\')
} catch {
    Write-Output "TeX Live is not found. Aborted."
    Exit
}

if ($help) { help } 
elseif ($texmfhome)  {SetTexmfhome}
elseif ($texedit)    {SetTexedit}
elseif ($sumatrapdf) {SetSumatrapdf}
elseif ($conf)       {CreateLocalconf}
elseif ($batch)      {
    SetTexmfhome
    SetTexedit
    SetSumatrapdf
    CreateLocalconf
}
elseif (!$arg) {help}