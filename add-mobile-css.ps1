# PowerShell script to add mobile-responsive.css to all HTML files
# that don't already have it

$directory = "c:\Users\theni\OneDrive\Desktop\Mind haven  mobile"
$cssLink = '  <link href="mobile-responsive.css" rel="stylesheet">'

# Get all HTML files
$htmlFiles = Get-ChildItem -Path $directory -Filter "*.html"

$updatedCount = 0
$skippedCount = 0

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    
    # Check if mobile-responsive.css is already linked
    if ($content -like '*mobile-responsive.css*') {
        Write-Host "Skipped (already has mobile CSS): $($file.Name)" -ForegroundColor Yellow
        $skippedCount++
        continue
    }
    
    # Check if file has a <head> section
    if ($content -like '*<head>*') {
        # Find position after </head> tag opening or after last link tag
        if ($content -match '(?s)(<link[^>]*>)(?!.*<link)') {
            # Add the mobile CSS link after the last link tag
            $lastLinkPos = $content.LastIndexOf('</link>')
            if ($lastLinkPos -eq -1) {
                # No closing link tags, find last opening link tag
                $pattern = '<link[^>]*>'
                $matches = [regex]::Matches($content, $pattern)
                if ($matches.Count -gt 0) {
                    $lastMatch = $matches[$matches.Count - 1]
                    $insertPos = $lastMatch.Index + $lastMatch.Length
                    $newContent = $content.Insert($insertPos, "`r`n$cssLink")
                    
                    # Write the updated content back to the file
                    Set-Content -Path $file.FullName -Value $newContent -NoNewline
                    Write-Host "Updated: $($file.Name)" -ForegroundColor Green
                    $updatedCount++
                }
                else {
                    Write-Host "Skipped (no link tags found): $($file.Name)" -ForegroundColor Cyan
                    $skippedCount++
                }
            }
        }
        else {
            Write-Host "Skipped (no link tags found): $($file.Name)" -ForegroundColor Cyan
            $skippedCount++
        }
    }
    else {
        Write-Host "Skipped (no <head> section): $($file.Name)" -ForegroundColor Red
        $skippedCount++
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Magenta
Write-Host "Updated: $updatedCount files" -ForegroundColor Green
Write-Host "Skipped: $skippedCount files" -ForegroundColor Yellow
Write-Host "Total: $($htmlFiles.Count) HTML files processed" -ForegroundColor Cyan
