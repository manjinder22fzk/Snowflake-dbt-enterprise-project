param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("dev","prd")]
  [string]$Env
)

$ErrorActionPreference = "Stop"

# Load vars JSON (auditable, versioned)
$varsPath = ".\schemachange\vars\$Env.json"
if (-not (Test-Path $varsPath)) { throw "Vars file not found: $varsPath" }

$varsJson = Get-Content $varsPath -Raw

# Choose history table based on env (also auditable)
$historyTable = if ($Env -eq "dev") { "RAW_DEV.SCHEMACHANGE.CHANGE_HISTORY" } else { "RAW_PRD.SCHEMACHANGE.CHANGE_HISTORY" }

Write-Host "Deploying schemachange migrations for env=$Env"
Write-Host "Using history table: $historyTable"
Write-Host "Changes folder: .\schemachange\changes"

schemachange deploy `
  -f .\schemachange\changes `
  -c $historyTable `
  --create-change-history-table `
  -V $varsJson `
  -ac
