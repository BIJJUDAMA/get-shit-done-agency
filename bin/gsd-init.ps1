Param(
    [string]$role = "",
    [string]$env = "",
    [switch]$DryRun,
    [switch]$Version,
    [switch]$Update,
    [switch]$Help
)

# GSD Integration Bridge (Zero-Dependency PowerShell)

if ($Help) {
    Write-Host @"

[GSD Integration Bridge]

Usage: powershell -ExecutionPolicy Bypass -File bin/gsd-init.ps1 [options]

Options:
  -role <name>     Automatically select a persona (e.g., -role engineering-senior-developer)
  -env <name>      Automatically select an environment (claude, gemini, cursor, antigravity)
  -DryRun          Print the composed output to stdout instead of writing files
  -Version         Show version information
  -Update          Update GSD Agency to the latest version
  -Help            Show this help message

Description:
  This tool dynamically bridges personas from the internal 'agency-agents' library
  with the Get Shit Done methodology, outputting a highly specialized agent configuration
  into your current project directory.

"@
    exit 0
}

if ($Version) {
    if (Test-Path $VersionFile) { Get-Content $VersionFile } else { Write-Host "unknown" }
    exit 0
}

if ($Update) {
    Write-Host "Checking for updates..."
    # Future: git pull or binary update logic
    Write-Host "You are on the latest version."
    exit 0
}

# --- Configuration ---
$ScriptPath = $MyInvocation.MyCommand.Path

if ([string]::IsNullOrEmpty($ScriptPath)) {
    Write-Host "`n[INFO] Remote execution detected. Bootstrapping GSD Agency..." -ForegroundColor Cyan
    $InstallDir = Join-Path $HOME ".gsd-agency"
    $ZipPath = Join-Path $env:TEMP "gsd-agency.zip"
    
    Write-Host "Downloading latest GSD Agency release..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri "https://github.com/BIJJUDAMA/get-shit-done-agency/archive/refs/heads/main.zip" -OutFile $ZipPath
    
    Write-Host "Extracting..."
    if (Test-Path $InstallDir) { Remove-Item $InstallDir -Recurse -Force }
    Expand-Archive -Path $ZipPath -DestinationPath $env:TEMP -Force
    Rename-Item -Path (Join-Path $env:TEMP "get-shit-done-agency-main") -NewName ".gsd-agency"
    Move-Item -Path (Join-Path $env:TEMP ".gsd-agency") -Destination $HOME -Force
    Remove-Item $ZipPath -Force

    Write-Host "Executing local copy...`n" -ForegroundColor Cyan
    
    $LocalScript = Join-Path $InstallDir "bin\gsd-init.ps1"
    
    $Cmd = "& `"$LocalScript`""
    if ($role) { $Cmd += " -role `"$role`"" }
    if ($env) { $Cmd += " -env `"$env`"" }
    if ($DryRun) { $Cmd += " -DryRun" }
    
    Invoke-Expression $Cmd
    exit 0
}

$ScriptDir = Split-Path -Parent $ScriptPath
$MethodologyDir = Split-Path -Parent $ScriptDir
$AgencyAgentsDir = if ([string]::IsNullOrEmpty($env:GSD_PERSONAS_DIR)) { Join-Path $MethodologyDir "agency-agents" } else { $env:GSD_PERSONAS_DIR }
$AdaptersDir = Join-Path $MethodologyDir "adapters"
$MethodologyFile = Join-Path $MethodologyDir "PROJECT_RULES.md"
$VersionFile = Join-Path $MethodologyDir "VERSION"

# Pre-defined mapping
$EnvFiles = @{
    "claude" = "CLAUDE.md"
    "gemini" = "GEMINI.md"
    "cursor" = "CURSOR.md"
    "antigravity" = "GEMINI.md"
    "other" = "GPT_OSS.md"
}
$EnvOutputs = @{
    "claude" = ".claude.md"
    "gemini" = ".gemini/GEMINI.md"
    "cursor" = ".cursorrules"
    "antigravity" = ".gemini/GEMINI.md"
    "other" = "INSTRUCTIONS.md"
}

if ($PWD.Path -eq $MethodologyDir) {
    Write-Host "`n[ERROR] You are running this inside the GSD template repository itself." -ForegroundColor Red
    Write-Host "Please run `"powershell -File path\to\get-shit-done-agency\bin\gsd-init.ps1`" from inside your ACTUAL project directory."
    exit 1
}

Write-Host "`n[Initializing GSD Context Composition]`n" -ForegroundColor Cyan

# Verify agency-agents exists
if (!(Test-Path $AgencyAgentsDir)) {
    Write-Host "[ERROR] No personas found in $AgencyAgentsDir" -ForegroundColor Red
    exit 1
}

# Load personas
$PersonaFiles = Get-ChildItem -Path $AgencyAgentsDir -Filter "*.md" -Recurse | Where-Object { $_.Directory.Name -notmatch "^\." }
if ($PersonaFiles.Count -eq 0) {
    Write-Host "[ERROR] No persona markdown files found in $AgencyAgentsDir" -ForegroundColor Red
    exit 1
}

$Personas = @()
foreach ($file in $PersonaFiles) {
    $Personas += [PSCustomObject]@{
        Name = $file.BaseName
        Path = $file.FullName
    }
}

# Local Persona Scan
$LocalPersonasDir = Join-Path $PWD.Path ".gsd\personas"
if (Test-Path $LocalPersonasDir) {
    Write-Host "[INFO] Scanning local personas in $LocalPersonasDir..." -ForegroundColor Cyan
    $LocalFiles = Get-ChildItem -Path $LocalPersonasDir -Filter "*.md"
    foreach ($file in $LocalFiles) {
        $Personas += [PSCustomObject]@{
            Name = "[LOCAL] $($file.BaseName)"
            Path = $file.FullName
        }
    }
}

# --- Role Selection ---
$SelectedPersona = $null

if ($role) {
    $Matches = $Personas | Where-Object { $_.Name -like "*$role*" }
    if ($Matches.Count -eq 0) {
        Write-Host "[ERROR] Auto-role `"$role`" not found." -ForegroundColor Red
        exit 1
    } elseif ($Matches.Count -gt 1) {
        $ExactMatch = $Matches | Where-Object { $_.Name -eq $role }
        if ($ExactMatch) {
            $SelectedPersona = $ExactMatch
        } else {
            $Names = ($Matches | Select-Object -ExpandProperty Name) -join ", "
            Write-Host "[ERROR] Multiple roles match `"$role`": $Names. Please be more specific." -ForegroundColor Red
            exit 1
        }
    } else {
        $SelectedPersona = $Matches[0]
    }
} else {
    Write-Host "Available Roles:"
    for ($i = 0; $i -lt $Personas.Count; $i++) {
        Write-Host "  [$($i+1)] $($Personas[$i].Name)"
    }
    Write-Host ""
    $RoleInput = Read-Host "Select a role (1-$($Personas.Count))"
    
    $Idx = 0
    if ([int]::TryParse($RoleInput, [ref]$Idx) -and $Idx -ge 1 -and $Idx -le $Personas.Count) {
        $SelectedPersona = $Personas[$Idx - 1]
    } else {
        Write-Host "`n[ERROR] Please enter a valid number between 1 and $($Personas.Count)." -ForegroundColor Red
        exit 1
    }
}

Write-Host "`nSelected Role: $($SelectedPersona.Name)`n" -ForegroundColor Green

# --- Environment Selection ---
$EnvKeys = @("claude", "gemini", "cursor", "antigravity", "other")
$SelectedEnv = ""

if (-not $env) {
    if (Test-Path ".claude") { $env = "claude" }
    elseif (Test-Path ".gemini") { $env = "antigravity" }
    elseif ((Test-Path ".cursor") -or (Test-Path ".cursorrules")) { $env = "cursor" }
    
    if ($env) {
        Write-Host "`n[INFO] Auto-detected environment: $env" -ForegroundColor Cyan
    }
}

if ($env) {
    if ($EnvKeys -contains $env) {
        $SelectedEnv = $env
    } else {
        Write-Host "[ERROR] Auto-env `"$env`" is invalid." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Available Environments:"
    for ($i = 0; $i -lt $EnvKeys.Count; $i++) {
        Write-Host "  [$($i+1)] $($EnvKeys[$i])"
    }
    Write-Host ""
    $EnvInput = Read-Host "Select target environment (1-$($EnvKeys.Count))"
    
    $Idx = 0
    if ([int]::TryParse($EnvInput, [ref]$Idx) -and $Idx -ge 1 -and $Idx -le $EnvKeys.Count) {
        $SelectedEnv = $EnvKeys[$Idx - 1]
    } else {
        Write-Host "`n[ERROR] Please enter a valid number between 1 and $($EnvKeys.Count)." -ForegroundColor Red
        exit 1
    }
}

Write-Host "`nSelected Environment: $SelectedEnv`n" -ForegroundColor Green
$AdapterFile = $EnvFiles[$SelectedEnv]
$OutputPath = $EnvOutputs[$SelectedEnv]

# --- Versioning ---
$GsdVersion = "0.0.0"
if (Test-Path $VersionFile) {
    $GsdVersion = (Get-Content $VersionFile -Raw).Trim()
}
Write-Host "[Active Methodology Version]: $GsdVersion" -ForegroundColor Yellow

# --- Read and Compose ---
Write-Host "Reading components from bridge..."

if (!(Test-Path $SelectedPersona.Path)) {
    Write-Host "[ERROR] Persona file not found: $($SelectedPersona.Path)" -ForegroundColor Red
    exit 1
}

$PersonaRaw = Get-Content $SelectedPersona.Path -Raw
$Frontmatter = ""
$Body = ""

# Parse Frontmatter
if ($PersonaRaw -match "(?s)^---\r?\n(.*?)\r?\n---\r?\n(.*)$") {
    $Frontmatter = $Matches[1]
    $Body = $Matches[2].Trim()
} else {
    $Body = $PersonaRaw.Trim()
}

# Compile new Frontmatter
$NewFrontmatterLines = @(
    "---"
    "name: $($SelectedPersona.Name) (GSD Integrated)"
    "generator: get-shit-done-agency"
    "integrated_methodology: true"
)

if (![string]::IsNullOrEmpty($Frontmatter)) {
    $lines = $Frontmatter -split "\r?\n"
    foreach ($line in $lines) {
        if (-not $line.StartsWith("name:")) {
            $NewFrontmatterLines += $line
        }
    }
}
$NewFrontmatterLines += "---"
$NewFrontmatter = $NewFrontmatterLines -join "`n"

# Load Methodology
if (!(Test-Path $MethodologyFile)) {
    Write-Host "[ERROR] Methodology file not found: $MethodologyFile" -ForegroundColor Red
    exit 1
}
$MethodologyContent = Get-Content $MethodologyFile -Raw

# Load Adapter
$AdapterPath = Join-Path $AdaptersDir $AdapterFile
$AdapterContent = ""
if (!(Test-Path $AdapterPath)) {
    Write-Host "[WARNING] Adapter $AdapterFile not found. Proceeding without adapter." -ForegroundColor Yellow
    $AdapterContent = "<!-- No specific adapter configuration provided -->"
} else {
    $AdapterContent = Get-Content $AdapterPath -Raw
}

# Dynamic Injection
$DynamicBlock = @"
## System Commands (Dynamic Integration)
This project uses GSD slash commands. You must obey these commands when issued by the user:
- `/plan` : Decompose requirements into SPEC.md.
- `/execute` : Implement the current phase from STATE.md.
- `/verify` : Run empirical tests (preferably sandboxed) and prove success.
- `/escalate` : Force a context break and prepare a handoff to a Debugger persona after 3 failures.
- `/sync` : Reconcile STATE.md with recent manual git commits.
- `/handoff` : Generate structured YAML to pass context cleanly to the next specialized agent.
- `/map` : AST-driven dependency graphing.
- `/pause` : Dump state for a clean session handoff.
"@

$FinalAdapter = "$DynamicBlock`n`n$AdapterContent"

# Compose Final Output
$FinalOutput = @"
$NewFrontmatter

$Body

---

# [GSD METHODOLOGY INJECTION]

The following instructions define your operational methodology. You must adhere to these rules strictly while acting as the persona defined above.

$MethodologyContent

---

# [ENVIRONMENT ADAPTER]

$FinalAdapter
"@

# --- Output Writing ---
$TargetFullPath = Join-Path $PWD.Path $OutputPath

if ($DryRun) {
    Write-Host "`n================ DRY RUN COMPOSITION OUTPUT ================`n" -ForegroundColor DarkCyan
    Write-Host $FinalOutput
    Write-Host "`n================ END DRY RUN ================`n" -ForegroundColor DarkCyan
    Write-Host "[INFO] This would be written to: $TargetFullPath" -ForegroundColor DarkCyan
} else {
    $TargetDir = Split-Path -Parent $TargetFullPath
    if (!(Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
    }
    
    Set-Content -Path $TargetFullPath -Value $FinalOutput -Encoding UTF8
    Write-Host "[SUCCESS] Successfully wrote composition to: $TargetFullPath" -ForegroundColor Green

    $GsdRunDir = Join-Path $PWD.Path ".gsd"
    $GsdTemplatesDir = Join-Path $GsdRunDir "templates"
    if (!(Test-Path $GsdTemplatesDir)) {
        New-Item -ItemType Directory -Force -Path $GsdTemplatesDir | Out-Null
    }
    
    # Deploy Templates
    $TemplatesSourceDir = Join-Path $MethodologyDir "templates"
    if (Test-Path $TemplatesSourceDir) {
        Copy-Item (Join-Path $TemplatesSourceDir "docker-compose.gsd.yml") (Join-Path $PWD.Path "docker-compose.gsd.yml") -Force
        Copy-Item (Join-Path $TemplatesSourceDir "HANDOFF.yaml") (Join-Path $GsdTemplatesDir "HANDOFF.yaml") -Force
        Copy-Item (Join-Path $TemplatesSourceDir "GSD_METHODOLOGY.md") (Join-Path $GsdTemplatesDir "GSD_METHODOLOGY.md") -Force
        Write-Host "[SUCCESS] GSD v1.0.0 templates deployed." -ForegroundColor Green
    }

    # Install Git Hooks
    $HooksScript = Join-Path $MethodologyDir "scripts\install-hooks.sh"
    if (Test-Path $HooksScript) {
        # Running via bash assuming git bash is in path
        & bash $HooksScript
    }

    # Write JSON Lockfile
    $LockfileData = @{
        generatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        version = $GsdVersion
        persona = $SelectedPersona.Name
        personaSource = $SelectedPersona.Path
        environment = $SelectedEnv
        outputPath = $OutputPath
    }
    $LockfileData | ConvertTo-Json | Set-Content -Path (Join-Path $GsdRunDir "gsd.config.json") -Encoding UTF8
    Write-Host "[LOCKED] Lockfile written to: .gsd/gsd.config.json" -ForegroundColor DarkGray
}
