#Requires -Version 7
<#
.SYNOPSIS
  Builds the Word (.docx) version of an LLD written in Markdown.

.DESCRIPTION
  1. Renders the Mermaid diagrams in the Markdown to PNG images (mermaid-cli).
  2. Converts the Markdown to .docx with pandoc, using docs/templates/lld-template.docx.
  Output: <Feature>.docx next to the Markdown file, and a _build/<Feature>/ folder with the
  images and the processed Markdown (used by publish-lld.ps1). Both are git-ignored.

.EXAMPLE
  pwsh scripts/build-lld.ps1 -Path docs/lld/Vehicle/VehicleInspection.md

.NOTES
  One-time setup (Windows):
    winget install Microsoft.PowerShell
    winget install JohnMacFarlane.Pandoc
    winget install OpenJS.NodeJS.LTS
  Diagrams are rendered with the Edge or Chrome already installed. To use another browser,
  set the LLD_BROWSER environment variable to its .exe path.
#>
param(
  [Parameter(Mandatory)] [string] $Path
)

$ErrorActionPreference = 'Stop'
$MermaidCli = '@mermaid-js/mermaid-cli@11.4.2'

function Fail($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }
function Need($cmd, $install) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) { Fail "$cmd not found. Install it with: $install" }
}

$repo     = Split-Path -Parent $PSScriptRoot
$template = Join-Path $repo 'docs/templates/lld-template.docx'
$source   = Resolve-Path $Path -ErrorAction SilentlyContinue
if (-not $source) { Fail "File not found: $Path" }
$source   = $source.Path
if (-not (Test-Path $template)) { Fail "Word template not found: $template" }

Need 'pandoc' 'winget install JohnMacFarlane.Pandoc'

$feature  = [IO.Path]::GetFileNameWithoutExtension($source)
$folder   = Split-Path -Parent $source
$build    = Join-Path $folder "_build/$feature"
$docx     = Join-Path $folder "$feature.docx"
$built    = Join-Path $build "$feature.md"

if (Test-Path $build) { Remove-Item $build -Recurse -Force }
New-Item -ItemType Directory -Path $build | Out-Null

$text = Get-Content $source -Raw
if ($text -match '(?m)^```mermaid') {
  Need 'npx' 'winget install OpenJS.NodeJS.LTS'

  # Use the browser already on the machine; never download one.
  $browser = $env:LLD_BROWSER
  if (-not $browser) {
    $candidates = @(
      "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
      "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
      "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
      "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
    )
    $browser = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
  }
  if (-not $browser) { Fail 'No Edge or Chrome found to render diagrams. Set LLD_BROWSER to a browser .exe path.' }

  $pp = @{ executablePath = $browser }
  if (-not $IsWindows) { $pp.args = @('--no-sandbox') }
  $ppFile = Join-Path $build 'puppeteer.json'
  $pp | ConvertTo-Json | Set-Content $ppFile

  $env:PUPPETEER_SKIP_DOWNLOAD = '1'
  Write-Host 'Rendering diagrams...'
  & npx -y $MermaidCli -i $source -o $built -e png -s 2 -b white -p $ppFile
  if ($LASTEXITCODE -ne 0) { Fail 'Diagram rendering failed. Check the Mermaid syntax in the file.' }
} else {
  Copy-Item $source $built
}

# Word only: start section 1 on a new page after the table of contents.
# (Kept out of the Markdown so the Confluence page doesn't get it.)
$pageBreak = "``````{=openxml}`n<w:p><w:r><w:br w:type=`"page`"/></w:r></w:p>`n``````"
$doc = Get-Content $built -Raw
$doc = [regex]::Replace($doc, '(?s)^(---\r?\n.*?\r?\n---\r?\n)', "`$1`n$pageBreak`n", 1)
$wordInput = Join-Path $build "$feature.word.md"
Set-Content $wordInput $doc -NoNewline

# Cover line under the title: date · version · status
$meta = @{}
if ($doc -match '(?s)^---\r?\n(.*?)\r?\n---') {
  foreach ($line in ($Matches[1] -split '\r?\n')) {
    if ($line -match '^\s*([A-Za-z]+)\s*:\s*"?([^"#]*?)"?\s*(#.*)?$') { $meta[$Matches[1]] = $Matches[2].Trim() }
  }
}
$cover = (@($meta.date, ($meta.version ? "Version $($meta.version)" : $null), $meta.status) | Where-Object { $_ }) -join '  ·  '

Write-Host 'Building Word document...'
& pandoc $wordInput `
  --from markdown-implicit_figures `
  --to docx `
  --reference-doc $template `
  --resource-path $build `
  --columns 1000 `
  --metadata "date=$cover" `
  --toc --toc-depth 2 `
  --output $docx
if ($LASTEXITCODE -ne 0) { Fail 'pandoc failed.' }

Write-Host "Done: $docx" -ForegroundColor Green
