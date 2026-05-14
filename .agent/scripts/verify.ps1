# HM ERP — BA Spec Verification Script
Set-StrictMode -Version Latest
Write-Host "
[1/2] Checking Generated Markdown Specs..." -ForegroundColor Cyan
$issues = 0

$specs = Get-ChildItem -Path "c:\ai.pipeline\Hoai-Minh-Project\guides" -Include "BE_*.md", "FE_*.md" -Recurse
foreach ($spec in $specs) {
    $content = Get-Content $spec.FullName -Raw
    if ($content -notmatch "## API Contract" -and $spec.Name -match "BE_") {
        Write-Host "[X] ERROR: Backend Spec  is missing '## API Contract' section." -ForegroundColor Red
        $issues++
    }
}

if ($issues -eq 0) {
    Write-Host "[OK] Specs meet formatting standards." -ForegroundColor Green
} else {
    exit 1
}
exit 0
