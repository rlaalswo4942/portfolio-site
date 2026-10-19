# Run as a normal user: winget asks for admin itself (Git), and Claude/VS Code must live in the user's own profile.
$Work = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "vibe-coding"

function Refresh-Path {
    $m = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $u = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$m;$u"
}

function Has($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

function Install-App($id, $cmd, $override) {
    if (Has $cmd) { return }
    Write-Host "$id 설치 중... (몇 분 걸릴 수 있어요. '예/아니오' 창이 뜨면 '예')" -ForegroundColor Cyan
    $a = @("install", "--id", $id, "-e", "--source", "winget", "--silent", "--accept-package-agreements", "--accept-source-agreements")
    if ($override) { $a += @("--override", $override) }
    winget @a
    Refresh-Path
}

Refresh-Path
if (-not ((Has git) -and (Has code)) -and -not (Has winget)) {
    Write-Host "winget이 없습니다. Microsoft Store에서 '앱 설치 관리자'를 설치/업데이트한 뒤 다시 실행해주세요." -ForegroundColor Red
    Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"
    Read-Host "엔터를 누르면 종료합니다"
    exit
}

Install-App "Git.Git" "git"
# Same checkboxes the workbook asks for: "Code로 열기" right-click menu + PATH
Install-App "Microsoft.VisualStudioCode" "code" "/VERYSILENT /NORESTART /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"

if (-not (Has claude)) {
    Write-Host "Claude Code 설치 중..." -ForegroundColor Cyan
    # Separate process: the official installer calls exit/StrictMode, which would kill or alter this script under iex.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; irm https://claude.ai/install.ps1 | iex"
    Refresh-Path
    $bin = Join-Path $env:USERPROFILE ".local\bin"
    if (-not (Has claude) -and (Test-Path (Join-Path $bin "claude.exe"))) {
        [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";$bin", "User")
        Refresh-Path
    }
}

if (Has code) {
    Write-Host "VS Code 확장(Claude Code, Live Server) 확인 중..." -ForegroundColor Cyan
    code --install-extension anthropic.claude-code
    code --install-extension ritwickdey.LiveServer
}

$missing = @("git", "code", "claude") | Where-Object { -not (Has $_) }
if ($missing) {
    Write-Host "설치되지 않은 프로그램: $($missing -join ', ')" -ForegroundColor Red
    Write-Host "인터넷 연결을 확인하고 실행.bat을 다시 눌러주세요. 계속 안 되면 컴퓨터를 재시작한 뒤 다시 실행하세요." -ForegroundColor Red
    Read-Host "엔터를 누르면 종료합니다"
    exit
}
Write-Host "필요한 프로그램이 모두 준비되었습니다." -ForegroundColor Green

# First commit fails without a git identity (workbook ch.2)
if (-not (git config --global user.email)) {
    $email = Read-Host "GitHub 가입 이메일을 입력하세요 (아직 GitHub 계정이 없으면 그냥 엔터)"
    if ($email) {
        git config --global user.email $email
        git config --global user.name ($email -split "@")[0]
    }
}

New-Item -ItemType Directory -Force -Path $Work | Out-Null

# Kit layout keeps the prompt one level up (Windows\setup.ps1, ..\프롬프트.txt)
$promptPath = @((Join-Path $PSScriptRoot "프롬프트.txt"), (Join-Path $PSScriptRoot "..\프롬프트.txt")) |
    Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if ($promptPath) {
    Get-Content -LiteralPath $promptPath -Raw -Encoding UTF8 | Set-Clipboard
    Write-Host "설정용 프롬프트를 클립보드에 복사했습니다. Claude 대화창에서 Ctrl+V로 붙여넣으세요." -ForegroundColor Yellow
}

Write-Host "작업 폴더: $Work" -ForegroundColor Green
Start-Process code -ArgumentList "`"$Work`""
Start-Process powershell -WorkingDirectory $Work -ArgumentList "-NoExit", "-Command", "claude"

Read-Host "`n두 창(VS Code, Claude)이 열렸는지 확인한 뒤 엔터를 누르면 이 창은 닫힙니다"
