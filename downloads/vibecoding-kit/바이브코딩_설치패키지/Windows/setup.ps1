param(
    [string]$Folder
)

if (-not $Folder) { $Folder = $PSScriptRoot }

function Refresh-Path {
    $m = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $u = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$m;$u"
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "관리자 권한이 필요합니다. 잠시 후 뜨는 창에서 '예'를 눌러주세요." -ForegroundColor Cyan
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $PSCommandPath, "-Folder", $Folder
    exit
}

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "처음 실행이므로 필요한 프로그램을 설치합니다 (몇 분 걸릴 수 있어요)..." -ForegroundColor Cyan
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "winget이 없습니다. Microsoft Store에서 '앱 설치 관리자'를 설치한 뒤 다시 실행해주세요." -ForegroundColor Red
        Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"
        Read-Host "엔터를 누르면 종료합니다"
        exit
    }
    winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
    winget install --id Microsoft.VisualStudioCode -e --silent --accept-package-agreements --accept-source-agreements
    Refresh-Path
    irm https://claude.ai/install.ps1 | iex
    Refresh-Path
    code --install-extension anthropic.claude-code --force
    Write-Host "설치 완료!" -ForegroundColor Green
}
else {
    Refresh-Path
    Write-Host "이미 설치되어 있습니다. 바로 실행합니다." -ForegroundColor Green
}

$promptPath = Join-Path $Folder "프롬프트.txt"
if (Test-Path $promptPath) {
    Get-Content $promptPath -Raw | Set-Clipboard
    Write-Host "설정용 프롬프트를 클립보드에 복사했습니다. Claude 대화창에서 Ctrl+V로 붙여넣으세요." -ForegroundColor Yellow
}

Start-Process code -ArgumentList "`"$Folder`""
Start-Process powershell -ArgumentList "-NoExit", "-Command", "claude"

Read-Host "`n두 창(VS Code, Claude)이 열렸는지 확인한 뒤 엔터를 누르면 이 창은 닫힙니다"
