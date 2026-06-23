$nramExe = "$env:LOCALAPPDATA\opencode-mcp\nram\nram.exe"
$nramDir = "$env:LOCALAPPDATA\opencode-mcp\nram"
$dbDir = "E:\Agent team\.opencode"
$log = "$nramDir\nram.log"

# Check if already running
$proc = Get-Process -Name nram -ErrorAction SilentlyContinue
if ($proc) {
  "nram already running (PID $($proc.Id))"
  exit 0
}

# Ensure binary exists
if (-not (Test-Path $nramExe)) {
  "ERROR: nram binary not found at $nramExe"
  exit 1
}

# Ensure db directory exists
if (-not (Test-Path $dbDir)) {
  New-Item -ItemType Directory -Path $dbDir -Force | Out-Null
}

# Start server in background
$env:NRAM_ADMIN_EMAIL = "admin@agent-team.local"
$env:NRAM_ADMIN_PASSWORD = "admin12345"
$env:NRAM_DB_PATH = "$dbDir\nram.db"
$env:NRAM_LISTEN = ":8674"

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $nramExe
$psi.Arguments = "serve"
$psi.WorkingDirectory = $nramDir
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.EnvironmentVariables["NRAM_ADMIN_EMAIL"] = $env:NRAM_ADMIN_EMAIL
$psi.EnvironmentVariables["NRAM_ADMIN_PASSWORD"] = $env:NRAM_ADMIN_PASSWORD
$psi.EnvironmentVariables["NRAM_DB_PATH"] = $env:NRAM_DB_PATH
$psi.EnvironmentVariables["NRAM_LISTEN"] = $env:NRAM_LISTEN

$p = [System.Diagnostics.Process]::Start($psi)

# Wait for it to be ready
Start-Sleep 3
$ready = $false
for ($i = 0; $i -lt 10; $i++) {
  try {
    $r = Invoke-WebRequest -Uri "http://localhost:8674/health" -UseBasicParsing -TimeoutSec 2
    if ($r.StatusCode -eq 200) { $ready = $true; break }
  } catch {}
  Start-Sleep 1
}

if ($ready) {
  "nram started on PID $($p.Id) - http://localhost:8674"
  exit 0
} else {
  "ERROR: nram failed to start - check $log"
  exit 1
}
