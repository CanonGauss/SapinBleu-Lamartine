# Publie la maquette sur GitHub Pages.
# Copie etude_ombres\maquette_3d.html -> index.html (avec noindex) et le dossier
# LamartineSource, puis commit et push.
# Usage : powershell -ExecutionPolicy Bypass -File publier.ps1

$ErrorActionPreference = 'Stop'
$site = $PSScriptRoot
$source = Join-Path $site '..\lamartine\etude_ombres\maquette_3d.html'
$cible = Join-Path $site 'index.html'

$utf8 = New-Object System.Text.UTF8Encoding($false)
$html = [IO.File]::ReadAllText((Resolve-Path $source), [Text.Encoding]::UTF8)

# Empêche le référencement par les moteurs de recherche
$noindex = '<meta name="robots" content="noindex, nofollow">'
if (-not $html.Contains('name="robots"')) {
    $html = [regex]::Replace($html, '<head([^>]*)>', "<head`$1>`n$noindex", 1)
}
[IO.File]::WriteAllText($cible, $html, $utf8)

# Planche du 20 mars (PDF A3, lien de l'onglet « Planche du 20 mars »)
$planche = Join-Path $site '..\lamartine\etude_ombres\planche_20mars.pdf'
if (Test-Path $planche) { Copy-Item $planche (Join-Path $site 'planche_20mars.pdf') -Force }

# Synchronise le dossier des documents sources (PDF, photos)
$docs = Join-Path $site '..\lamartine\LamartineSource'
robocopy (Resolve-Path $docs) (Join-Path $site 'LamartineSource') /MIR /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "Echec de la copie de LamartineSource (robocopy $LASTEXITCODE)" }

Set-Location $site
git add index.html LamartineSource planche_20mars.pdf
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) { Write-Host 'Aucun changement a publier.'; exit 0 }
git commit -m ("Mise a jour de la maquette " + (Get-Date -Format 'yyyy-MM-dd HH:mm'))
if (git remote) { git push } else { Write-Host 'Pas de depot distant configure : push ignore.' }
