[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

$expectedFiles = @(
    '.gitignore'
    'README.md'
    'docs\Conditional-Access-Baseline-and-Recovery-Readiness.md'
    'docs\Conditional-Access-Business-Requirements.md'
    'architecture\Zero-Trust-Conditional-Access-Architecture.md'
    'policies\Conditional-Access-Policy-Matrix.md'
    'runbooks\Conditional-Access-Test-and-Rollback-Plan.md'
    'scripts\Test-ConditionalAccessMilestone01Package.ps1'
    'scripts\Test-ConditionalAccessMilestone02Package.ps1'
    'screenshots\m01-01-security-defaults-enabled-baseline.png'
    'screenshots\m01-02-authentication-methods-policy-baseline.png'
    'screenshots\m01-03-authentication-strengths-baseline.png'
    'screenshots\m01-04-conditional-access-licence-gated-baseline.png'
    'screenshots\m01-05-named-locations-baseline.png'
    'screenshots\m01-06-device-inventory-baseline.png'
)

$textFiles = @(
    '.gitignore'
    'README.md'
    'docs\Conditional-Access-Baseline-and-Recovery-Readiness.md'
    'docs\Conditional-Access-Business-Requirements.md'
    'architecture\Zero-Trust-Conditional-Access-Architecture.md'
    'policies\Conditional-Access-Policy-Matrix.md'
    'runbooks\Conditional-Access-Test-and-Rollback-Plan.md'
    'scripts\Test-ConditionalAccessMilestone01Package.ps1'
    'scripts\Test-ConditionalAccessMilestone02Package.ps1'
)

$markdownFiles = @(
    $textFiles | Where-Object {
        $_ -like '*.md'
    }
)

$requiredGroups = @(
    'GG_IAM_Access_Contractor_Portal'
    'GG_IAM_Access_Finance_ERP'
    'GG_IAM_Access_HR_Records'
    'GG_IAM_Access_IT_ServiceDesk'
    'GG_IAM_Access_M365_Baseline'
    'GG_IAM_Access_Operations_Portal'
    'GG_IAM_Access_Sales_CRM'
    'GG_IAM_All_Contractors'
    'GG_IAM_All_Employees'
    'GG_IAM_All_Workforce'
    'GG_IAM_Department_Finance'
    'GG_IAM_Department_HumanResources'
    'GG_IAM_Department_InformationTechnology'
    'GG_IAM_Department_Operations'
    'GG_IAM_Department_Sales'
)

$requiredPolicyIds = 1..10 | ForEach-Object {
    'CA{0:D3}' -f $_
}

$requiredRequirementIds = 1..11 | ForEach-Object {
    'BR-{0:D2}' -f $_
}

$requiredTestIds = 1..26 | ForEach-Object {
    'TS-{0:D2}' -f $_
}

$requiredScreenshots = @(
    $expectedFiles | Where-Object {
        $_ -like 'screenshots\*.png'
    }
)

$missingFiles = @()
$unexpectedFiles = @()
$emptyFiles = @()
$invalidPngFiles = @()
$brokenLinks = @()
$sensitiveFindings = @()
$bannedLanguageFindings = @()
$missingPolicyIds = @()
$missingRequirementIds = @()
$missingTestIds = @()
$missingGroupNames = @()
$designAssuranceFindings = @()
$validatedFiles = 0
$publishableFileCount = 0
$relativeLinkCount = 0
$externalReferenceCount = 0
$mermaidDiagramCount = 0

$rootExists = Test-Path `
    -LiteralPath $ProjectRoot `
    -PathType Container

if ($rootExists) {
    $resolvedProjectRoot = (
        Resolve-Path -LiteralPath $ProjectRoot
    ).Path.TrimEnd([char[]]@('\', '/'))

    $publishableRelativePaths = @(
        Get-ChildItem `
            -LiteralPath $resolvedProjectRoot `
            -File `
            -Recurse `
            -Force |
        ForEach-Object {
            $relativePath = (
                $_.FullName.Substring(
                    $resolvedProjectRoot.Length
                ).TrimStart([char[]]@('\', '/'))
            ) -replace '/', '\'

            if (
                $relativePath -ne '.git' -and
                $relativePath -notlike '.git\*' -and
                $relativePath -notlike 'temporary\*'
            ) {
                $relativePath
            }
        }
    )

    $publishableFileCount = $publishableRelativePaths.Count

    $unexpectedFiles = @(
        $publishableRelativePaths | Where-Object {
            $_ -notin $expectedFiles
        }
    )

    foreach ($relativePath in $expectedFiles) {
        $fullPath = Join-Path $ProjectRoot $relativePath

        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            $missingFiles += $relativePath
            continue
        }

        $fileInfo = Get-Item -LiteralPath $fullPath -Force

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

        $content = Get-Content `
            -LiteralPath $fullTextPath `
            -Raw

        if ($relativeTextPath -in $markdownFiles) {
            $sourceDirectory = Split-Path -Parent $fullTextPath

            $relativeLinkMatches = [regex]::Matches(
                $content,
                '\[[^\]]+\]\((?!https?://|mailto:|#)(?<Target>[^)#]+)(?:#[^)]+)?\)'
            )

            $relativeLinkCount += $relativeLinkMatches.Count

            foreach ($linkMatch in $relativeLinkMatches) {
                $target = $linkMatch.Groups['Target'].Value
                $platformTarget = $target -replace '/', [IO.Path]::DirectorySeparatorChar
                $resolvedTarget = Join-Path $sourceDirectory $platformTarget

                if (-not (Test-Path -LiteralPath $resolvedTarget)) {
                    $brokenLinks += "$relativeTextPath -> $target"
                }
            }

            $externalReferenceCount += [regex]::Matches(
                $content,
                '\[[^\]]+\]\(https://learn\.microsoft\.com/[^)]+\)'
            ).Count

            $mermaidDiagramCount += [regex]::Matches(
                $content,
                '(?m)^```mermaid\s*$'
            ).Count
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

        $bannedPatterns = [ordered]@{
            NonEngineeringAudienceA  = ('(?i)\binter' + 'view\b')
            NonEngineeringAudienceB  = ('(?i)private\s+port' + 'folio')
            RepositoryRemainsPrivate = ('(?i)repository\s+remains\s+' + 'private')
            PersonalWorkstation      = ('(?i)personal\s+' + 'workstation')
            ManufactureEvidence      = ('(?i)manufacture\s+project\s+' + 'evidence')
            NonEngineeringAudienceC  = ('(?i)port' + 'folio\s+package')
        }

        foreach ($patternName in $bannedPatterns.Keys) {
            if ([regex]::IsMatch($content, $bannedPatterns[$patternName])) {
                $bannedLanguageFindings += "$relativeTextPath -> $patternName"
            }
        }
    }

    $policyPath = Join-Path `
        $ProjectRoot `
        'policies\Conditional-Access-Policy-Matrix.md'

    if (Test-Path -LiteralPath $policyPath -PathType Leaf) {
        $policyContent = Get-Content `
            -LiteralPath $policyPath `
            -Raw

        foreach ($policyId in $requiredPolicyIds) {
            if ($policyContent -notmatch [regex]::Escape($policyId)) {
                $missingPolicyIds += $policyId
            }
        }
    }

    $businessPath = Join-Path `
        $ProjectRoot `
        'docs\Conditional-Access-Business-Requirements.md'

    if (Test-Path -LiteralPath $businessPath -PathType Leaf) {
        $businessContent = Get-Content `
            -LiteralPath $businessPath `
            -Raw

        foreach ($requirementId in $requiredRequirementIds) {
            if ($businessContent -notmatch [regex]::Escape($requirementId)) {
                $missingRequirementIds += $requirementId
            }
        }

        foreach ($groupName in $requiredGroups) {
            if ($businessContent -notmatch [regex]::Escape($groupName)) {
                $missingGroupNames += $groupName
            }
        }
    }

    $runbookPath = Join-Path `
        $ProjectRoot `
        'runbooks\Conditional-Access-Test-and-Rollback-Plan.md'

    if (Test-Path -LiteralPath $runbookPath -PathType Leaf) {
        $runbookContent = Get-Content `
            -LiteralPath $runbookPath `
            -Raw

        foreach ($testId in $requiredTestIds) {
            if ($runbookContent -notmatch [regex]::Escape($testId)) {
                $missingTestIds += $testId
            }
        }
    }

    $gitIgnorePath = Join-Path $ProjectRoot '.gitignore'
    $gitIgnoreRulePresent = $false

    if (Test-Path -LiteralPath $gitIgnorePath -PathType Leaf) {
        $gitIgnoreRules = @(
            Get-Content -LiteralPath $gitIgnorePath | ForEach-Object {
                $_.Trim()
            }
        )

        $gitIgnoreRulePresent = '/temporary/' -in $gitIgnoreRules
    }

    if (-not $gitIgnoreRulePresent) {
        $designAssuranceFindings += '.gitignore -> missing /temporary/ rule'
    }

    $requiredDesignStatements = [ordered]@{
        'README.md -> ten-policy summary' = '(?i)ten-policy\s+Conditional\s+Access\s+matrix'
        'README.md -> managed-policy gate' = '(?i)Microsoft-managed\s+Conditional\s+Access\s+policies\s+are\s+inventoried'
        'README.md -> emergency cadence' = '(?i)at\s+least\s+every\s+90\s+days'
        'docs\Conditional-Access-Business-Requirements.md -> BR-11' = '(?i)BR-11.+device\s+code\s+flow'
        'docs\Conditional-Access-Business-Requirements.md -> managed-policy decision' = '(?i)adopt,\s+replace,\s+or\s+opt-out'
        'architecture\Zero-Trust-Conditional-Access-Architecture.md -> permanent role' = '(?i)Global\s+Administrator\s+role\s+permanently'
        'policies\Conditional-Access-Policy-Matrix.md -> CA010' = '(?i)CA010-BLOCK-DeviceCodeFlow-AllUsers'
        'policies\Conditional-Access-Policy-Matrix.md -> device-code condition' = '(?i)Authentication\s+flows:\s+Device\s+code\s+flow'
        'policies\Conditional-Access-Policy-Matrix.md -> CA004 retirement' = '(?is)CA002.{0,200}CA004\s+is\s+disabled'
        'runbooks\Conditional-Access-Test-and-Rollback-Plan.md -> TS-26' = '(?i)TS-26.+permanently\s+assigned\s+Global\s+Administrator'
    }

    foreach ($assertion in $requiredDesignStatements.GetEnumerator()) {
        $parts = $assertion.Key -split ' -> ', 2
        $assertionPath = Join-Path $ProjectRoot $parts[0]

        if (-not (Test-Path -LiteralPath $assertionPath -PathType Leaf)) {
            $designAssuranceFindings += "$($assertion.Key) -> file missing"
            continue
        }

        $assertionContent = Get-Content `
            -LiteralPath $assertionPath `
            -Raw

        if ($assertionContent -notmatch $assertion.Value) {
            $designAssuranceFindings += $assertion.Key
        }
    }
}

$policyCoveragePassed = `
    $missingPolicyIds.Count -eq 0 -and `
    $missingRequirementIds.Count -eq 0 -and `
    $missingTestIds.Count -eq 0 -and `
    $missingGroupNames.Count -eq 0

$validationPassed = `
    $rootExists -and `
    $missingFiles.Count -eq 0 -and `
    $unexpectedFiles.Count -eq 0 -and `
    $emptyFiles.Count -eq 0 -and `
    $invalidPngFiles.Count -eq 0 -and `
    $brokenLinks.Count -eq 0 -and `
    $sensitiveFindings.Count -eq 0 -and `
    $bannedLanguageFindings.Count -eq 0 -and `
    $designAssuranceFindings.Count -eq 0 -and `
    $validatedFiles -eq $expectedFiles.Count -and `
    $publishableFileCount -eq $expectedFiles.Count -and `
    $requiredScreenshots.Count -eq 6 -and `
    $externalReferenceCount -ge 12 -and `
    $mermaidDiagramCount -ge 4 -and `
    $policyCoveragePassed

[pscustomobject]@{
    ProjectRoot                       = $ProjectRoot
    ProjectRootExists                 = $rootExists
    ExpectedFileCount                 = $expectedFiles.Count
    ValidatedFileCount                = $validatedFiles
    MissingFileCount                  = $missingFiles.Count
    PublishableFileCount              = $publishableFileCount
    UnexpectedFileCount               = $unexpectedFiles.Count
    EmptyFileCount                    = $emptyFiles.Count
    RequiredScreenshotCount           = $requiredScreenshots.Count
    InvalidPngFileCount               = $invalidPngFiles.Count
    RelativeLinkCount                 = $relativeLinkCount
    BrokenRelativeLinkCount           = $brokenLinks.Count
    MicrosoftLearnReferenceCount      = $externalReferenceCount
    MermaidDiagramCount               = $mermaidDiagramCount
    RequiredPolicyCount               = $requiredPolicyIds.Count
    MissingPolicyCount                = $missingPolicyIds.Count
    RequiredBusinessRequirementCount  = $requiredRequirementIds.Count
    MissingBusinessRequirementCount   = $missingRequirementIds.Count
    RequiredTestScenarioCount         = $requiredTestIds.Count
    MissingTestScenarioCount          = $missingTestIds.Count
    RequiredIAMGroupCount             = $requiredGroups.Count
    MissingIAMGroupCount              = $missingGroupNames.Count
    SensitiveFindingCount             = $sensitiveFindings.Count
    BannedPublicLanguageFindingCount  = $bannedLanguageFindings.Count
    DesignAssuranceFindingCount       = $designAssuranceFindings.Count
    PolicyCoveragePassed              = $policyCoveragePassed
    ValidationPassed                  = $validationPassed
}

if (-not $validationPassed) {
    if ($missingFiles.Count -gt 0) {
        Write-Warning "Missing files: $($missingFiles -join ', ')"
    }

    if ($unexpectedFiles.Count -gt 0) {
        Write-Warning "Unexpected publishable files: $($unexpectedFiles -join ', ')"
    }

    if ($emptyFiles.Count -gt 0) {
        Write-Warning "Empty files: $($emptyFiles -join ', ')"
    }

    if ($invalidPngFiles.Count -gt 0) {
        Write-Warning "Invalid PNG files: $($invalidPngFiles -join ', ')"
    }

    if ($brokenLinks.Count -gt 0) {
        Write-Warning "Broken links: $($brokenLinks -join ', ')"
    }

    if ($missingPolicyIds.Count -gt 0) {
        Write-Warning "Missing policy IDs: $($missingPolicyIds -join ', ')"
    }

    if ($missingRequirementIds.Count -gt 0) {
        Write-Warning "Missing requirement IDs: $($missingRequirementIds -join ', ')"
    }

    if ($missingTestIds.Count -gt 0) {
        Write-Warning "Missing test IDs: $($missingTestIds -join ', ')"
    }

    if ($missingGroupNames.Count -gt 0) {
        Write-Warning "Missing IAM groups: $($missingGroupNames -join ', ')"
    }

    if ($sensitiveFindings.Count -gt 0) {
        Write-Warning "Potential sensitive findings: $($sensitiveFindings -join ', ')"
    }

    if ($bannedLanguageFindings.Count -gt 0) {
        Write-Warning "Banned public language: $($bannedLanguageFindings -join ', ')"
    }

    if ($designAssuranceFindings.Count -gt 0) {
        Write-Warning "Design assurance findings: $($designAssuranceFindings -join ', ')"
    }

    throw 'FAIL: Conditional Access Milestone 2 package validation failed.'
}

Write-Host ''
Write-Host `
    'PASS: Conditional Access Milestone 2 package validation passed.' `
    -ForegroundColor Green
