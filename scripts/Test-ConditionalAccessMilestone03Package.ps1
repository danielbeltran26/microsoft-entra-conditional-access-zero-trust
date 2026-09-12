[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ExpectedFiles = @(
    '.gitignore'
    'README.md'
    'architecture\Zero-Trust-Conditional-Access-Architecture.md'
    'docs\Conditional-Access-Baseline-and-Recovery-Readiness.md'
    'docs\Conditional-Access-Business-Requirements.md'
    'docs\Conditional-Access-Prerequisite-and-Licensed-Feature-Readiness.md'
    'policies\Conditional-Access-Policy-Matrix.md'
    'runbooks\Conditional-Access-Test-and-Rollback-Plan.md'
    'scripts\Test-ConditionalAccessMilestone01Package.ps1'
    'scripts\Test-ConditionalAccessMilestone02Package.ps1'
    'scripts\Test-ConditionalAccessMilestone03Package.ps1'
    'data\m03-password-writeback-validation.txt'
    'screenshots\m01-01-security-defaults-enabled-baseline.png'
    'screenshots\m01-02-authentication-methods-policy-baseline.png'
    'screenshots\m01-03-authentication-strengths-baseline.png'
    'screenshots\m01-04-conditional-access-licence-gated-baseline.png'
    'screenshots\m01-05-named-locations-baseline.png'
    'screenshots\m01-06-device-inventory-baseline.png'
    'screenshots\m03-01-entra-id-p2-licensing-readiness.png'
    'screenshots\m03-02-emergency-access-exclusion-group.png'
    'screenshots\m03-03-conditional-access-policy-inventory-empty.png'
    'screenshots\m03-04-conditional-access-pilot-group.png'
    'screenshots\m03-05-passwordless-authentication-methods-enabled.png'
    'screenshots\m03-06-cloud-sync-password-writeback-configured.png'
)

$TextFiles = @(
    $ExpectedFiles | Where-Object {
        $_ -like '*.md' -or
        $_ -like '*.ps1' -or
        $_ -like '*.txt' -or
        $_ -eq '.gitignore'
    }
)

$MarkdownFiles = @(
    $ExpectedFiles | Where-Object {
        $_ -like '*.md'
    }
)

$RequiredScreenshots = @(
    $ExpectedFiles | Where-Object {
        $_ -like 'screenshots\*.png'
    }
)

$RequiredPolicyIds = 1..10 | ForEach-Object {
    'CA{0:D3}' -f $_
}

$RequiredRequirementIds = 1..11 | ForEach-Object {
    'BR-{0:D2}' -f $_
}

$RequiredTestIds = 1..26 | ForEach-Object {
    'TS-{0:D2}' -f $_
}

$RequiredIAMGroups = @(
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

$RequiredMilestone3Assertions = @(
    [pscustomobject]@{
        Name = 'README milestone status'
        Path = 'README.md'
        Pattern = '(?i)Milestone\s+3\s+complete'
    }
    [pscustomobject]@{
        Name = 'README P2 allocation'
        Path = 'README.md'
        Pattern = '(?i)7\s+of\s+100\s+licen[cs]es'
    }
    [pscustomobject]@{
        Name = 'README next milestone'
        Path = 'README.md'
        Pattern = '(?i)Milestone\s+4.+Report-only'
    }
    [pscustomobject]@{
        Name = 'Milestone 3 emergency membership'
        Path = 'docs\Conditional-Access-Prerequisite-and-Licensed-Feature-Readiness.md'
        Pattern = '(?i)exactly\s+2\s+direct\s+user\s+members'
    }
    [pscustomobject]@{
        Name = 'Milestone 3 pilot membership'
        Path = 'docs\Conditional-Access-Prerequisite-and-Licensed-Feature-Readiness.md'
        Pattern = '(?i)exactly\s+3\s+direct\s+user\s+members'
    }
    [pscustomobject]@{
        Name = 'Milestone 3 security defaults preserved'
        Path = 'docs\Conditional-Access-Prerequisite-and-Licensed-Feature-Readiness.md'
        Pattern = '(?i)security\s+defaults\s+remains\s+enabled'
    }
    [pscustomobject]@{
        Name = 'Milestone 3 empty policy inventory'
        Path = 'docs\Conditional-Access-Prerequisite-and-Licensed-Feature-Readiness.md'
        Pattern = '(?i)No\s+custom\s+or\s+Microsoft-managed\s+Conditional\s+Access\s+policies\s+were\s+visible'
    }
    [pscustomobject]@{
        Name = 'Milestone 3 CA003 dependency'
        Path = 'docs\Conditional-Access-Prerequisite-and-Licensed-Feature-Readiness.md'
        Pattern = '(?i)CA003.+remain\s+Report-only'
    }
    [pscustomobject]@{
        Name = 'Milestone 3 CA008 dependency'
        Path = 'docs\Conditional-Access-Prerequisite-and-Licensed-Feature-Readiness.md'
        Pattern = '(?i)CA008.+design-only'
    }
    [pscustomobject]@{
        Name = 'Password writeback observed'
        Path = 'data\m03-password-writeback-validation.txt'
        Pattern = '(?im)^PasswordWritebackObserved\s*:\s*True\s*$'
    }
    [pscustomobject]@{
        Name = 'Domain policy restored'
        Path = 'data\m03-password-writeback-validation.txt'
        Pattern = '(?im)^OriginalPolicyRestored\s*:\s*True\s*$'
    }
    [pscustomobject]@{
        Name = 'Password writeback test passed'
        Path = 'data\m03-password-writeback-validation.txt'
        Pattern = '(?im)^TestPassed\s*:\s*True\s*$'
    }
    [pscustomobject]@{
        Name = 'Fresh sign-in validated'
        Path = 'data\m03-password-writeback-validation.txt'
        Pattern = '(?im)^FreshSignInValidated\s*:\s*True\s*$'
    }
)

$RootExists = Test-Path `
    -LiteralPath $ProjectRoot `
    -PathType Container

$MissingFiles = @()
$UnexpectedFiles = @()
$EmptyFiles = @()
$InvalidPngFiles = @()
$BrokenLinks = @()
$SensitiveFindings = @()
$BannedLanguageFindings = @()
$MissingPolicyIds = @()
$MissingRequirementIds = @()
$MissingTestIds = @()
$MissingIAMGroups = @()
$MissingMilestone3Assertions = @()
$ValidatedFiles = 0
$PublishableFileCount = 0
$RelativeLinkCount = 0
$ExternalReferenceCount = 0
$MermaidDiagramCount = 0
$GitIgnoreRulePresent = $false

if ($RootExists) {
    $ResolvedProjectRoot = (
        Resolve-Path -LiteralPath $ProjectRoot
    ).Path.TrimEnd([char[]]@('\', '/'))

    $PublishableRelativePaths = @(
        Get-ChildItem `
            -LiteralPath $ResolvedProjectRoot `
            -File `
            -Recurse `
            -Force |
        ForEach-Object {
            $RelativePath = (
                $_.FullName.Substring(
                    $ResolvedProjectRoot.Length
                ).TrimStart([char[]]@('\', '/'))
            ) -replace '/', '\'

            if (
                $RelativePath -ne '.git' -and
                $RelativePath -notlike '.git\*' -and
                $RelativePath -notlike 'temporary\*'
            ) {
                $RelativePath
            }
        }
    )

    $PublishableFileCount = $PublishableRelativePaths.Count

    $UnexpectedFiles = @(
        $PublishableRelativePaths | Where-Object {
            $_ -notin $ExpectedFiles
        }
    )

    foreach ($RelativePath in $ExpectedFiles) {
        $FullPath = Join-Path $ProjectRoot $RelativePath

        if (-not (Test-Path -LiteralPath $FullPath -PathType Leaf)) {
            $MissingFiles += $RelativePath
            continue
        }

        $FileInfo = Get-Item -LiteralPath $FullPath -Force

        if ($FileInfo.Length -eq 0) {
            $EmptyFiles += $RelativePath
            continue
        }

        if ($RelativePath -like '*.png') {
            $Bytes = [System.IO.File]::ReadAllBytes($FullPath)
            $ExpectedSignature = [byte[]](137, 80, 78, 71, 13, 10, 26, 10)
            $SignatureIsValid = $Bytes.Length -ge 8

            if ($SignatureIsValid) {
                for ($Index = 0; $Index -lt 8; $Index++) {
                    if ($Bytes[$Index] -ne $ExpectedSignature[$Index]) {
                        $SignatureIsValid = $false
                        break
                    }
                }
            }

            if (-not $SignatureIsValid) {
                $InvalidPngFiles += $RelativePath
                continue
            }
        }

        $ValidatedFiles++
    }

    foreach ($RelativeTextPath in $TextFiles) {
        $FullTextPath = Join-Path $ProjectRoot $RelativeTextPath

        if (-not (Test-Path -LiteralPath $FullTextPath -PathType Leaf)) {
            continue
        }

        $Content = Get-Content `
            -LiteralPath $FullTextPath `
            -Raw

        if ($RelativeTextPath -in $MarkdownFiles) {
            $SourceDirectory = Split-Path -Parent $FullTextPath

            $RelativeLinkMatches = [regex]::Matches(
                $Content,
                '\[[^\]]+\]\((?!https?://|mailto:|#)(?<Target>[^)#]+)(?:#[^)]+)?\)'
            )

            $RelativeLinkCount += $RelativeLinkMatches.Count

            foreach ($LinkMatch in $RelativeLinkMatches) {
                $Target = $LinkMatch.Groups['Target'].Value
                $PlatformTarget = $Target -replace '/', [IO.Path]::DirectorySeparatorChar
                $ResolvedTarget = Join-Path $SourceDirectory $PlatformTarget

                if (-not (Test-Path -LiteralPath $ResolvedTarget)) {
                    $BrokenLinks += "$RelativeTextPath -> $Target"
                }
            }

            $ExternalReferenceCount += [regex]::Matches(
                $Content,
                '\[[^\]]+\]\(https://learn\.microsoft\.com/[^)]+\)'
            ).Count

            $MermaidDiagramCount += [regex]::Matches(
                $Content,
                '(?m)^```mermaid\s*$'
            ).Count
        }

        $SensitivePatterns = [ordered]@{
            EmailAddress       = '(?i)[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}'
            TenantDomain       = '(?i)\b[a-z0-9][a-z0-9-]{2,}\.onmicrosoft\.com\b'
            DirectoryObjectId  = '(?i)\b[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\b'
            CloudSyncGmsa      = '(?i)\bpGMSA_[0-9a-f]+\$?\b'
            TestUserName       = '(?i)\b(Adam\s+Fisher|Amelia\s+Hart|Ava\s+Mitchell)\b'
            CredentialMaterial = ('(?i)(client[_ -]?' + 'secret|pass' + 'word)\s*[:=]\s*["'']?[A-Za-z0-9+/=_-]{8,}')
        }

        foreach ($PatternName in $SensitivePatterns.Keys) {
            if ([regex]::IsMatch($Content, $SensitivePatterns[$PatternName])) {
                $SensitiveFindings += "$RelativeTextPath -> $PatternName"
            }
        }

        $BannedPatterns = [ordered]@{
            NonEngineeringAudienceA  = ('(?i)\binter' + 'view\b')
            NonEngineeringAudienceB  = ('(?i)private\s+port' + 'folio')
            RepositoryRemainsPrivate = ('(?i)repository\s+remains\s+' + 'private')
            PersonalWorkstation      = ('(?i)personal\s+' + 'workstation')
            ManufactureEvidence      = ('(?i)manufacture\s+project\s+' + 'evidence')
            NonEngineeringAudienceC  = ('(?i)port' + 'folio\s+package')
        }

        foreach ($PatternName in $BannedPatterns.Keys) {
            if ([regex]::IsMatch($Content, $BannedPatterns[$PatternName])) {
                $BannedLanguageFindings += "$RelativeTextPath -> $PatternName"
            }
        }
    }

    $PolicyPath = Join-Path `
        $ProjectRoot `
        'policies\Conditional-Access-Policy-Matrix.md'

    if (Test-Path -LiteralPath $PolicyPath -PathType Leaf) {
        $PolicyContent = Get-Content -LiteralPath $PolicyPath -Raw

        foreach ($PolicyId in $RequiredPolicyIds) {
            if ($PolicyContent -notmatch [regex]::Escape($PolicyId)) {
                $MissingPolicyIds += $PolicyId
            }
        }
    }

    $BusinessPath = Join-Path `
        $ProjectRoot `
        'docs\Conditional-Access-Business-Requirements.md'

    if (Test-Path -LiteralPath $BusinessPath -PathType Leaf) {
        $BusinessContent = Get-Content -LiteralPath $BusinessPath -Raw

        foreach ($RequirementId in $RequiredRequirementIds) {
            if ($BusinessContent -notmatch [regex]::Escape($RequirementId)) {
                $MissingRequirementIds += $RequirementId
            }
        }

        foreach ($IAMGroup in $RequiredIAMGroups) {
            if ($BusinessContent -notmatch [regex]::Escape($IAMGroup)) {
                $MissingIAMGroups += $IAMGroup
            }
        }
    }

    $RunbookPath = Join-Path `
        $ProjectRoot `
        'runbooks\Conditional-Access-Test-and-Rollback-Plan.md'

    if (Test-Path -LiteralPath $RunbookPath -PathType Leaf) {
        $RunbookContent = Get-Content -LiteralPath $RunbookPath -Raw

        foreach ($TestId in $RequiredTestIds) {
            if ($RunbookContent -notmatch [regex]::Escape($TestId)) {
                $MissingTestIds += $TestId
            }
        }
    }

    $GitIgnorePath = Join-Path $ProjectRoot '.gitignore'

    if (Test-Path -LiteralPath $GitIgnorePath -PathType Leaf) {
        $GitIgnoreRules = @(
            Get-Content -LiteralPath $GitIgnorePath | ForEach-Object {
                $_.Trim()
            }
        )

        $GitIgnoreRulePresent = '/temporary/' -in $GitIgnoreRules
    }

    foreach ($Assertion in $RequiredMilestone3Assertions) {
        $AssertionPath = Join-Path $ProjectRoot $Assertion.Path

        if (-not (Test-Path -LiteralPath $AssertionPath -PathType Leaf)) {
            $MissingMilestone3Assertions += "$($Assertion.Name) -> file missing"
            continue
        }

        $AssertionContent = Get-Content `
            -LiteralPath $AssertionPath `
            -Raw

        if ($AssertionContent -notmatch $Assertion.Pattern) {
            $MissingMilestone3Assertions += $Assertion.Name
        }
    }
}

$PolicyCoveragePassed = `
    $MissingPolicyIds.Count -eq 0 -and `
    $MissingRequirementIds.Count -eq 0 -and `
    $MissingTestIds.Count -eq 0 -and `
    $MissingIAMGroups.Count -eq 0

$Milestone3ExitGatesPassed = `
    $MissingMilestone3Assertions.Count -eq 0

$ValidationPassed = `
    $RootExists -and `
    $MissingFiles.Count -eq 0 -and `
    $UnexpectedFiles.Count -eq 0 -and `
    $EmptyFiles.Count -eq 0 -and `
    $InvalidPngFiles.Count -eq 0 -and `
    $BrokenLinks.Count -eq 0 -and `
    $SensitiveFindings.Count -eq 0 -and `
    $BannedLanguageFindings.Count -eq 0 -and `
    $ValidatedFiles -eq $ExpectedFiles.Count -and `
    $PublishableFileCount -eq $ExpectedFiles.Count -and `
    $RequiredScreenshots.Count -eq 12 -and `
    $ExternalReferenceCount -ge 20 -and `
    $MermaidDiagramCount -ge 4 -and `
    $GitIgnoreRulePresent -and `
    $PolicyCoveragePassed -and `
    $Milestone3ExitGatesPassed

[pscustomobject]@{
    ProjectRoot                       = $ProjectRoot
    ProjectRootExists                 = $RootExists
    ExpectedFileCount                 = $ExpectedFiles.Count
    ValidatedFileCount                = $ValidatedFiles
    MissingFileCount                  = $MissingFiles.Count
    PublishableFileCount              = $PublishableFileCount
    UnexpectedFileCount               = $UnexpectedFiles.Count
    EmptyFileCount                    = $EmptyFiles.Count
    RequiredScreenshotCount           = $RequiredScreenshots.Count
    InvalidPngFileCount               = $InvalidPngFiles.Count
    RelativeLinkCount                 = $RelativeLinkCount
    BrokenRelativeLinkCount           = $BrokenLinks.Count
    MicrosoftLearnReferenceCount      = $ExternalReferenceCount
    MermaidDiagramCount               = $MermaidDiagramCount
    MissingPolicyCount                = $MissingPolicyIds.Count
    MissingRequirementCount           = $MissingRequirementIds.Count
    MissingTestScenarioCount          = $MissingTestIds.Count
    MissingIAMGroupCount              = $MissingIAMGroups.Count
    SensitiveFindingCount             = $SensitiveFindings.Count
    BannedPublicLanguageFindingCount  = $BannedLanguageFindings.Count
    GitIgnoreProtectionPassed         = $GitIgnoreRulePresent
    Milestone3ExitGateCount           = $RequiredMilestone3Assertions.Count
    MissingMilestone3ExitGateCount    = $MissingMilestone3Assertions.Count
    PolicyCoveragePassed              = $PolicyCoveragePassed
    Milestone3ExitGatesPassed         = $Milestone3ExitGatesPassed
    ValidationPassed                  = $ValidationPassed
}

if (-not $ValidationPassed) {
    if ($MissingFiles.Count -gt 0) {
        Write-Warning "Missing files: $($MissingFiles -join ', ')"
    }

    if ($UnexpectedFiles.Count -gt 0) {
        Write-Warning "Unexpected publishable files: $($UnexpectedFiles -join ', ')"
    }

    if ($EmptyFiles.Count -gt 0) {
        Write-Warning "Empty files: $($EmptyFiles -join ', ')"
    }

    if ($InvalidPngFiles.Count -gt 0) {
        Write-Warning "Invalid PNG files: $($InvalidPngFiles -join ', ')"
    }

    if ($BrokenLinks.Count -gt 0) {
        Write-Warning "Broken links: $($BrokenLinks -join ', ')"
    }

    if ($SensitiveFindings.Count -gt 0) {
        Write-Warning "Potential sensitive findings: $($SensitiveFindings -join ', ')"
    }

    if ($BannedLanguageFindings.Count -gt 0) {
        Write-Warning "Banned public language: $($BannedLanguageFindings -join ', ')"
    }

    if ($MissingMilestone3Assertions.Count -gt 0) {
        Write-Warning "Missing Milestone 3 exit gates: $($MissingMilestone3Assertions -join ', ')"
    }

    if (-not $GitIgnoreRulePresent) {
        Write-Warning '.gitignore does not contain the required /temporary/ rule.'
    }

    throw 'FAIL: Conditional Access Milestone 3 package validation failed.'
}

Write-Host ''
Write-Host `
    'PASS: Conditional Access Milestone 3 package validation passed.' `
    -ForegroundColor Green
