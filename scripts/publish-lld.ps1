#Requires -Version 7
<#
.SYNOPSIS
  Publishes an LLD to Confluence Cloud: one page per feature, under <Domain> — LLD,
  inside the LLD folder. Diagrams and the Word file are attached to the page.

.DESCRIPTION
  Run scripts/build-lld.ps1 first. Then:
  - creates the "<Domain> — LLD" page in the LLD folder if it doesn't exist
  - creates the feature page under it, or updates it (Confluence keeps the history)
  - uploads the diagrams and the .docx as attachments (new versions on update)
  - writes the page id into the Markdown front matter (commit that change)

  Settings: docs/lld/lld.config.json (baseUrl, spaceKey, lldFolderId).
  Credentials: your own, in user environment variables — never in the repo:
    CONFLUENCE_EMAIL      your Atlassian account email
    CONFLUENCE_API_TOKEN  create at https://id.atlassian.com/manage-profile/security/api-tokens

.EXAMPLE
  pwsh scripts/publish-lld.ps1 -Path docs/lld/Vehicle/VehicleInspection.md -DryRun
  pwsh scripts/publish-lld.ps1 -Path docs/lld/Vehicle/VehicleInspection.md
#>
param(
  [Parameter(Mandatory)] [string] $Path,
  [switch] $DryRun
)

$ErrorActionPreference = 'Stop'
function Fail($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }

# --- inputs -------------------------------------------------------------------
$repo   = Split-Path -Parent $PSScriptRoot
$source = (Resolve-Path $Path -ErrorAction SilentlyContinue)?.Path
if (-not $source) { Fail "File not found: $Path" }

$feature = [IO.Path]::GetFileNameWithoutExtension($source)
$folder  = Split-Path -Parent $source
$build   = Join-Path $folder "_build/$feature"
$built   = Join-Path $build "$feature.md"
$docx    = Join-Path $folder "$feature.docx"
if (-not (Test-Path $built) -or -not (Test-Path $docx)) {
  Fail "Build output not found. Run first: pwsh scripts/build-lld.ps1 -Path $Path"
}
if ((Get-Item $source).LastWriteTime -gt (Get-Item $docx).LastWriteTime) {
  Fail "The Markdown changed after the last build. Run build-lld.ps1 again."
}

$raw = Get-Content $source -Raw
if ($raw -notmatch '(?s)^---\r?\n(.*?)\r?\n---') { Fail 'Front matter (--- ... ---) not found at the top of the file.' }
$meta = @{}
foreach ($line in ($Matches[1] -split '\r?\n')) {
  if ($line -match '^\s*([A-Za-z]+)\s*:\s*"?([^"#]*?)"?\s*(#.*)?$') { $meta[$Matches[1]] = $Matches[2].Trim() }
}
foreach ($k in 'title', 'domain', 'version') { if (-not $meta[$k]) { Fail "Front matter is missing '$k'." } }

$configFile = Join-Path $repo 'docs/lld/lld.config.json'
if (-not (Test-Path $configFile)) { Fail "Config not found: $configFile" }
$config = Get-Content $configFile -Raw | ConvertFrom-Json
foreach ($k in 'baseUrl', 'spaceKey', 'lldFolderId') {
  if (-not $config.$k -or $config.$k -like '<*') { Fail "Set '$k' in docs/lld/lld.config.json." }
}
$base = $config.baseUrl.TrimEnd('/')

$domainTitle  = "$($meta.domain) — LLD"
$featureTitle = "$($meta.title) — LLD"
$relPath      = [IO.Path]::GetRelativePath($repo, $source) -replace '\\', '/'

# --- page body (Confluence storage format) -------------------------------------
$html = & pandoc $built --from markdown-implicit_figures --to html5
if ($LASTEXITCODE -ne 0) { Fail 'pandoc failed to convert the page body.' }
$html = ($html -join "`n")
$images = [regex]::Matches($html, '<img src="(?:\./)?([^"]+\.png)"[^>]*?/?>') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
$html = [regex]::Replace($html, '<img src="(?:\./)?([^"]+\.png)"[^>]*?/?>',
  '<ac:image ac:width="900"><ri:attachment ri:filename="$1" /></ac:image>')
$docxName = Split-Path -Leaf $docx
$banner = @"
<ac:structured-macro ac:name="info"><ac:rich-text-body>
<p>Version $($meta.version) · Status: $($meta.status) · Story: $($meta.story)</p>
<p>Generated from <code>$relPath</code>. Do not edit this page: change the LLD with <code>/lld edit</code> and publish again.
Word version: <ac:link><ri:attachment ri:filename="$docxName" /></ac:link></p>
</ac:rich-text-body></ac:structured-macro>
"@
$body = $banner + "`n" + $html
$body | Set-Content (Join-Path $build 'confluence-storage.html')

$attachments = @($docx) + ($images | ForEach-Object { Join-Path $build $_ })

if ($DryRun) {
  Write-Host 'DRY RUN — nothing sent to Confluence.' -ForegroundColor Yellow
  Write-Host "Space:        $($config.spaceKey)  (folder $($config.lldFolderId))"
  Write-Host "Domain page:  $domainTitle"
  Write-Host "Feature page: $featureTitle  $(if ($meta.confluencePageId) { "(update page $($meta.confluencePageId))" } else { '(create or find by title)' })"
  Write-Host "Attachments:  $(($attachments | ForEach-Object { Split-Path -Leaf $_ }) -join ', ')"
  Write-Host "Body saved:   $(Join-Path $build 'confluence-storage.html')"
  exit 0
}

# --- Confluence API -------------------------------------------------------------
if (-not $env:CONFLUENCE_EMAIL -or -not $env:CONFLUENCE_API_TOKEN) {
  Fail 'Set CONFLUENCE_EMAIL and CONFLUENCE_API_TOKEN as user environment variables.'
}
$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("$($env:CONFLUENCE_EMAIL):$($env:CONFLUENCE_API_TOKEN)"))
$headers = @{ Authorization = "Basic $auth"; Accept = 'application/json' }

function Api($method, $uri, $json) {
  $p = @{ Method = $method; Uri = "$base$uri"; Headers = $headers }
  if ($null -ne $json) { $p.Body = ($json | ConvertTo-Json -Depth 10); $p.ContentType = 'application/json; charset=utf-8' }
  try { Invoke-RestMethod @p }
  catch { Fail "$method $uri failed: $($_.Exception.Message) $($_.ErrorDetails.Message)" }
}
function FindPage($spaceId, $title) {
  $t = [uri]::EscapeDataString($title)
  (Api GET "/wiki/api/v2/pages?space-id=$spaceId&title=$t&status=current" $null).results | Select-Object -First 1
}

$space = (Api GET "/wiki/api/v2/spaces?keys=$($config.spaceKey)" $null).results | Select-Object -First 1
if (-not $space) { Fail "Space '$($config.spaceKey)' not found or no access." }

# Domain page inside the LLD folder. The API can't create a page directly in a folder,
# so the page is created at the space root and then moved into the folder.
$domainPage = FindPage $space.id $domainTitle
if (-not $domainPage) {
  Write-Host "Creating '$domainTitle'..."
  $domainPage = Api POST '/wiki/api/v2/pages' @{
    spaceId = $space.id; status = 'current'; title = $domainTitle
    body    = @{ representation = 'storage'; value = "<p>Low-level designs for the $($meta.domain) domain.</p>" }
  }
  Api PUT "/wiki/rest/api/content/$($domainPage.id)/move/append/$($config.lldFolderId)" $null | Out-Null
}

# Feature page: update if known, otherwise find by title or create.
$pageId = $meta.confluencePageId
if (-not $pageId) { $pageId = (FindPage $space.id $featureTitle)?.id }

if ($pageId) {
  $current = Api GET "/wiki/api/v2/pages/$pageId" $null
  Write-Host "Updating '$featureTitle' (version $($current.version.number) → $($current.version.number + 1))..."
  Api PUT "/wiki/api/v2/pages/$pageId" @{
    id = $pageId; status = 'current'; title = $featureTitle
    body    = @{ representation = 'storage'; value = $body }
    version = @{ number = $current.version.number + 1; message = "LLD v$($meta.version)" }
  } | Out-Null
} else {
  Write-Host "Creating '$featureTitle'..."
  $page = Api POST '/wiki/api/v2/pages' @{
    spaceId = $space.id; status = 'current'; title = $featureTitle; parentId = $domainPage.id
    body    = @{ representation = 'storage'; value = $body }
  }
  $pageId = $page.id
}

# Attachments: PUT creates the attachment, or adds a new version if it exists.
foreach ($file in $attachments) {
  Write-Host "Attaching $(Split-Path -Leaf $file)..."
  try {
    Invoke-RestMethod -Method PUT -Uri "$base/wiki/rest/api/content/$pageId/child/attachment" `
      -Headers ($headers + @{ 'X-Atlassian-Token' = 'no-check' }) `
      -Form @{ file = Get-Item $file; minorEdit = 'true' } | Out-Null
  } catch { Fail "Upload of $(Split-Path -Leaf $file) failed: $($_.Exception.Message) $($_.ErrorDetails.Message)" }
}

# Remember the page id so the next publish updates the same page.
if ($meta.confluencePageId -ne $pageId) {
  $updated = [regex]::Replace($raw, '(?m)^confluencePageId:.*$', "confluencePageId: `"$pageId`"", 1)
  Set-Content -Path $source -Value $updated -NoNewline
  Write-Host 'Page id saved in the front matter — commit this change.'
}

Write-Host "Published: $base/wiki/spaces/$($config.spaceKey)/pages/$pageId" -ForegroundColor Green
