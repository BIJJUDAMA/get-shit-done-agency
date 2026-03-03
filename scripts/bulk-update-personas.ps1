$personaPaths = Get-ChildItem -Recurse -Path "agency-agents" -Filter "*.md"
foreach ($file in $personaPaths) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match "---[\s\S]*?---") {
        $frontmatter = $Matches[0]
        if ($frontmatter -notmatch "tags:") {
            $newFrontmatter = $frontmatter -replace "---", "tags: [unclassified]`ndifficulty: medium`n---"
            # Fix double --- replacement
            $newFrontmatter = $newFrontmatter -replace "^---[\s\S]*?tags:", "---`ntags:"
            # Wait, easier approach
            $lines = $content -split "`r?`n"
            $newLines = @()
            $frontMatterEndFound = $false
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($i -gt 0 -and $lines[$i] -match "^---$" -and -not $frontMatterEndFound) {
                    $newLines += "tags: [unclassified]"
                    $newLines += "difficulty: medium"
                    $frontMatterEndFound = $true
                }
                $newLines += $lines[$i]
            }
            $newContent = $newLines -join "`r`n"
            Set-Content $file.FullName $newContent
            Write-Host "Updated $($file.Name)"
        }
    }
}
