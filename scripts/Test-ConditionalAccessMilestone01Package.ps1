[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

$expectedFiles = @(
    'README.md'
    'docs\Conditional-Access-Baseline-and-Recovery-Readiness.md'
    'scripts\Test-ConditionalAccessMilestone01Package.ps1'
    'screenshots\m01-01-security-defaults-enabled-baseline.png'
    'screenshots\m01-02-authentication-methods-policy-baseline.png'
    'screenshots\m01-03-authentication-strengths-baseline.png'
    'screenshots\m01-04-conditional-access-licence-gated-baseline.png'
    'screenshots\m01-05-named-locations-baseline.png'
    'screenshots\m01-06-device-inventory-baseline.png'
)

$textFiles = @(
    'README.md'
    'docs\Conditional-Access-Baseline-and-Recovery-Readiness.md'
)

$requiredScreenshots = $expectedFiles | Where-Object { $_ -like 'screenshots\*.png' }
$missingFiles = @()
$emptyFiles = @()
$invalidPngFiles = @()
$brokenLinks = @()
$sensitiveFindings = @()
$validatedFiles = 0

$rootExists = Test-Path -LiteralPath $ProjectRoot -PathType Container

if ($rootExists) {
    foreach ($relativePath in $expectedFiles) {
        $fullPath = Join-Path $ProjectRoot $relativePath
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            $missingFiles += $relativePath
            continue
        }

        $fileInfo = Get-Item -LiteralPath $fullPath
        if ($fileInfo.Length -eq 0) {
            $emptyFiles += $relativePath
            continue
        }

        if ($relativePath -like '*.png') {
            $bytes = [System.IO.File]::ReadAllBytes($fullPath)
            $expectedSignature = [byte[]](137, 80, 78, 71, 13, 10, 26, 10)
            $signatureIsValid = $bytes.Length -ge 8
            if ($signatureIsValid) {
                for ($index = 0; $index -lt 8; $index++) {
                    if ($bytes[$index] -ne $expectedSignature[$index]) {
                        $signatureIsValid = $false
                        break
                    }
                }
            }

            if (-not $signatureIsValid) {
                $invalidPngFiles += $relativePath
                continue
            }
        }

        $validatedFiles++
    }

    foreach ($relativeTextPath in $textFiles) {
        $fullTextPath = Join-Path $ProjectRoot $relativeTextPath
        if (-not (Test-Path -LiteralPath $fullTextPath -PathType Leaf)) {
            continue
        }

        $content = Get-Content -LiteralPath $fullTextPath -Raw
        $sourceDirectory = Split-Path -Parent $fullTextPath
        $linkMatches = [regex]::Matches($content, '\[[^\]]+\]\((?!https?://|mailto:|#)(?<Target>[^)#]+)(?:#[^)]+)?\)')

        foreach ($linkMatch in $linkMatches) {
            $target = $linkMatch.Groups['Target'].Value
            $resolvedTarget = Join-Path $sourceDirectory ($target -replace '/', [IO.Path]::DirectorySeparatorChar)
            if (-not (Test-Path -LiteralPath $resolvedTarget)) {
                $brokenLinks += "$relativeTextPath -> $target"
            }
        }

        $sensitivePatterns = @(
            '(?i)[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}'
            '(?i)\b[a-z0-9][a-z0-9-]{2,}\.onmicrosoft\.com\b'
            ('(?i)(client[_ -]?' + 'secret|pass' + 'word)\s*[:=]\s*["'']?[A-Za-z0-9+/=_-]{8,}')
            '(?i)\b[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\b'
        )

        foreach ($pattern in $sensitivePatterns) {
            if ([regex]::IsMatch($content, $pattern)) {
                $sensitiveFindings += "$relativeTextPath matched $pattern"
            }
        }
    }
}

$validationPassed = $rootExists -and
    $missingFiles.Count -eq 0 -and
    $emptyFiles.Count -eq 0 -and
    $invalidPngFiles.Count -eq 0 -and
    $brokenLinks.Count -eq 0 -and
    $sensitiveFindings.Count -eq 0 -and
    $validatedFiles -eq $expectedFiles.Count

[pscustomobject]@{
    ProjectRoot                 = $ProjectRoot
    ProjectRootExists           = $rootExists
    ExpectedFileCount           = $expectedFiles.Count
    ValidatedFileCount          = $validatedFiles
    MissingFileCount            = $missingFiles.Count
    EmptyFileCount              = $emptyFiles.Count
    InvalidPngFileCount         = $invalidPngFiles.Count
    RequiredScreenshotCount     = $requiredScreenshots.Count
    BrokenRelativeLinkCount     = $brokenLinks.Count
    SensitiveFindingCount       = $sensitiveFindings.Count
    ValidationPassed            = $validationPassed
}

if (-not $validationPassed) {
    if ($missingFiles.Count -gt 0) {
        Write-Warning "Missing files: $($missingFiles -join ', ')"
    }
    if ($emptyFiles.Count -gt 0) {
        Write-Warning "Empty files: $($emptyFiles -join ', ')"
    }
    if ($invalidPngFiles.Count -gt 0) {
        Write-Warning "Invalid PNG files: $($invalidPngFiles -join ', ')"
    }
    if ($brokenLinks.Count -gt 0) {
        Write-Warning "Broken relative links: $($brokenLinks -join ', ')"
    }
    if ($sensitiveFindings.Count -gt 0) {
        Write-Warning "Potential sensitive findings: $($sensitiveFindings -join ', ')"
    }
    throw 'FAIL: Conditional Access Milestone 1 package validation failed.'
}

Write-Host ''
Write-Host 'PASS: Conditional Access Milestone 1 package validation passed.' -ForegroundColor Green
