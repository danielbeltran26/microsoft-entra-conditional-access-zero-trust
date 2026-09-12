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
    'data\m03-password-writeback-validation.txt'
    'data\m04-wave1-report-only-validation.txt'
    'data\m05-report-only-validation.txt'
    'docs\Conditional-Access-Baseline-and-Recovery-Readiness.md'
    'docs\Conditional-Access-Business-Requirements.md'
    'docs\Conditional-Access-Prerequisite-and-Licensed-Feature-Readiness.md'
    'docs\Conditional-Access-Report-Only-Deployment.md'
    'docs\Conditional-Access-Scenario-Testing-and-Report-Only-Analysis.md'
    'policies\Conditional-Access-Policy-Matrix.md'
    'runbooks\Conditional-Access-Test-and-Rollback-Plan.md'
    'scripts\Test-ConditionalAccessMilestone01Package.ps1'
    'scripts\Test-ConditionalAccessMilestone02Package.ps1'
    'scripts\Test-ConditionalAccessMilestone03Package.ps1'
    'scripts\Test-ConditionalAccessMilestone04Package.ps1'
    'scripts\Test-ConditionalAccessMilestone05Package.ps1'
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
    'screenshots\m04-01-security-defaults-disabled-for-conditional-access.png'
    'screenshots\m04-02-ca001-report-only-created.png'
    'screenshots\m04-03-ca004-management-resources-selected.png'
    'screenshots\m04-04-ca001-ca004-ca005-report-only.png'
    'screenshots\m04-05-ca009-session-control-report-only.png'
    'screenshots\m04-06-ca010-device-code-report-only.png'
    'screenshots\m04-07-wave1-report-only-policy-inventory.png'
    'screenshots\m05-01-ca001-what-if-applicable.png'
    'screenshots\m05-02-ca001-what-if-modern-browser-not-applicable.png'
    'screenshots\m05-03-ca004-what-if-management-mfa-applicable.png'
    'screenshots\m05-04-ca005-what-if-registration-mfa-applicable.png'
    'screenshots\m05-05-ca010-what-if-device-code-block-applicable.png'
    'screenshots\m05-06-ca010-emergency-account-01-excluded.png'
    'screenshots\m05-07-ca010-emergency-account-02-excluded.png'
    'screenshots\m05-08-ca004-report-only-sign-in-evaluation.png'
    'screenshots\m05-09-ca010-device-code-report-only-block-evaluation.png'
    'screenshots\m05-10-ca001-legacy-auth-log-review-no-results.png'
    'screenshots\m05-11-ca005-registration-report-only-evaluation.png'
)

$RequiredMilestone5Assertions = @(
    [pscustomobject]@{
        Name = 'README Milestone 5 complete'
        Path = 'README.md'
        Pattern = '(?i)Milestone\s+5\s+complete'
    }
    [pscustomobject]@{
        Name = 'README Milestone 6 next'
        Path = 'README.md'
        Pattern = '(?i)Milestone\s+6\s+is\s+next'
    }
    [pscustomobject]@{
        Name = 'Scenario document complete'
        Path = 'docs\Conditional-Access-Scenario-Testing-and-Report-Only-Analysis.md'
        Pattern = '(?i)Status:\s*Complete.+Wave\s+1\s+Report-only\s+scenarios'
    }
    [pscustomobject]@{
        Name = 'Report-only boundary recorded'
        Path = 'docs\Conditional-Access-Scenario-Testing-and-Report-Only-Analysis.md'
        Pattern = '(?i)does\s+not\s+claim.+Report-only.+enforced'
    }
    [pscustomobject]@{
        Name = 'CA001 applicable case passed'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^CA001WhatIfApplicable:\s*Passed\s*$'
    }
    [pscustomobject]@{
        Name = 'CA001 modern browser not applicable'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^CA001ModernBrowserNotApplicable:\s*Passed\s*$'
    }
    [pscustomobject]@{
        Name = 'No legacy event generated'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^LegacyAuthenticationGeneratedForTest:\s*False\s*$'
    }
    [pscustomobject]@{
        Name = 'No legacy activity observed'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^LegacyNonInteractiveEventCount:\s*0\s*$'
    }
    [pscustomobject]@{
        Name = 'CA004 Report-only success'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^CA004ReportOnlyResult:\s*reportOnlySuccess\s*$'
    }
    [pscustomobject]@{
        Name = 'CA005 Report-only success'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^CA005ReportOnlyResult:\s*reportOnlySuccess\s*$'
    }
    [pscustomobject]@{
        Name = 'CA009 Report-only success'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^CA009ReportOnlyResult:\s*reportOnlySuccess\s*$'
    }
    [pscustomobject]@{
        Name = 'CA009 enforcement deferred'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^CA009SessionEnforcementExecuted:\s*False\s*$'
    }
    [pscustomobject]@{
        Name = 'CA010 Report-only failure'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^CA010ReportOnlyResult:\s*reportOnlyFailure\s*$'
    }
    [pscustomobject]@{
        Name = 'Device-code signal observed'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^DeviceCodeSignalObserved:\s*True\s*$'
    }
    [pscustomobject]@{
        Name = 'First emergency evaluation passed'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^EmergencyAccount01Evaluation:\s*Passed\s*$'
    }
    [pscustomobject]@{
        Name = 'Second emergency evaluation passed'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^EmergencyAccount02Evaluation:\s*Passed\s*$'
    }
    [pscustomobject]@{
        Name = 'No enforced policy'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^EnforcedPolicyCount:\s*0\s*$'
    }
    [pscustomobject]@{
        Name = 'Eleven screenshots recorded'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^RequiredScreenshotCount:\s*11\s*$'
    }
    [pscustomobject]@{
        Name = 'No missing screenshot'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^MissingScreenshotCount:\s*0\s*$'
    }
    [pscustomobject]@{
        Name = 'No sensitive identifier published'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^SensitiveIdentifiersPublished:\s*0\s*$'
    }
    [pscustomobject]@{
        Name = 'Milestone 5 validation passed'
        Path = 'data\m05-report-only-validation.txt'
        Pattern = '(?im)^ValidationPassed:\s*True\s*$'
    }
)

function Read-Utf8Text {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return ''
    }

    return [System.IO.File]::ReadAllText(
        $Path,
        [System.Text.Encoding]::UTF8
    )
}

$RootExists = Test-Path -LiteralPath $ProjectRoot -PathType Container
$MissingFiles = @()
$UnexpectedFiles = @()
$EmptyFiles = @()
$InvalidPngFiles = @()
$BrokenLinks = @()
$SensitiveFindings = @()
$PublicTextEncodingFindings = @()
$MissingAssertions = @()
$MissingPolicyIds = @()
$MissingRequirementIds = @()
$MissingTestIds = @()
$MissingMilestone5PolicyNames = @()
$PublishableFileCount = 0
$ValidatedFileCount = 0
$RelativeLinkCount = 0
$MicrosoftLearnReferenceCount = 0
$MermaidDiagramCount = 0
$InlineMilestone5ScreenshotCount = 0
$Milestone5ScenarioDispositionCount = 0
$Milestone5ValidatedPolicyCount = 0
$GitIgnoreProtectionPassed = $false

if ($RootExists) {
    $ResolvedProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path.TrimEnd([char[]]@('\', '/'))

    $PublishableRelativePaths = @(
        Get-ChildItem -LiteralPath $ResolvedProjectRoot -File -Recurse -Force |
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
        $PublishableRelativePaths |
            Where-Object { $_ -notin $ExpectedFiles }
    )

    foreach ($RelativePath in $ExpectedFiles) {
        $FullPath = Join-Path $ResolvedProjectRoot $RelativePath

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

        $ValidatedFileCount++
    }

    $TextFiles = @(
        $ExpectedFiles |
            Where-Object {
                $_ -like '*.md' -or
                $_ -like '*.ps1' -or
                $_ -like '*.txt' -or
                $_ -eq '.gitignore'
            }
    )

    foreach ($RelativeTextPath in $TextFiles) {
        $FullTextPath = Join-Path $ResolvedProjectRoot $RelativeTextPath

        if (-not (Test-Path -LiteralPath $FullTextPath -PathType Leaf)) {
            continue
        }

        $Content = Read-Utf8Text -Path $FullTextPath

        if ($RelativeTextPath -like '*.md') {
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

            $MicrosoftLearnReferenceCount += [regex]::Matches(
                $Content,
                '\[[^\]]+\]\(https://learn\.microsoft\.com/[^)]+\)'
            ).Count

            $MermaidDiagramCount += [regex]::Matches(
                $Content,
                '(?m)^[\x60]{3}mermaid\s*$'
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

        $PublicTextEncodingPatterns = [ordered]@{
            MojibakePunctuation = '\u00E2\u20AC[\u0080-\u20FF]'
            MojibakeNbsp        = '\u00C2\u00A0'
        }

        foreach ($PatternName in $PublicTextEncodingPatterns.Keys) {
            if (
                [regex]::IsMatch(
                    $Content,
                    $PublicTextEncodingPatterns[$PatternName]
                )
            ) {
                $PublicTextEncodingFindings += "$RelativeTextPath -> $PatternName"
            }
        }
    }

    $PolicyContent = Read-Utf8Text -Path (
        Join-Path $ResolvedProjectRoot 'policies\Conditional-Access-Policy-Matrix.md'
    )
    $BusinessContent = Read-Utf8Text -Path (
        Join-Path $ResolvedProjectRoot 'docs\Conditional-Access-Business-Requirements.md'
    )
    $RunbookContent = Read-Utf8Text -Path (
        Join-Path $ResolvedProjectRoot 'runbooks\Conditional-Access-Test-and-Rollback-Plan.md'
    )
    $Milestone5Content = Read-Utf8Text -Path (
        Join-Path $ResolvedProjectRoot 'docs\Conditional-Access-Scenario-Testing-and-Report-Only-Analysis.md'
    )
    $ValidationData = Read-Utf8Text -Path (
        Join-Path $ResolvedProjectRoot 'data\m05-report-only-validation.txt'
    )

    foreach ($PolicyNumber in 1..10) {
        $PolicyId = 'CA{0:D3}' -f $PolicyNumber
        if ($PolicyContent -notmatch [regex]::Escape($PolicyId)) {
            $MissingPolicyIds += $PolicyId
        }
    }

    foreach ($RequirementNumber in 1..11) {
        $RequirementId = 'BR-{0:D2}' -f $RequirementNumber
        if ($BusinessContent -notmatch [regex]::Escape($RequirementId)) {
            $MissingRequirementIds += $RequirementId
        }
    }

    foreach ($TestNumber in 1..26) {
        $TestId = 'TS-{0:D2}' -f $TestNumber
        if ($RunbookContent -notmatch [regex]::Escape($TestId)) {
            $MissingTestIds += $TestId
        }
    }

    $Milestone5PolicyNames = @(
        'CA001-BLOCK-LegacyAuthentication-AllUsers'
        'CA004-GRANT-MFA-ManagementSurfaces-AllUsers'
        'CA005-GRANT-MFA-SecurityInfoRegistration-AllUsers'
        'CA009-SESSION-NoPersistentBrowser-Contractors'
        'CA010-BLOCK-DeviceCodeFlow-AllUsers'
    )

    foreach ($PolicyName in $Milestone5PolicyNames) {
        if (
            $Milestone5Content -notmatch [regex]::Escape($PolicyName) -or
            $ValidationData -notmatch [regex]::Escape($PolicyName)
        ) {
            $MissingMilestone5PolicyNames += $PolicyName
        }
    }

    $InlineMilestone5ScreenshotCount = [regex]::Matches(
        $Milestone5Content,
        '!\[[^\]]+\]\(\.\./screenshots/m05-[^)]+\.png\)'
    ).Count

    $Milestone5ScenarioDispositionCount = [regex]::Matches(
        $Milestone5Content,
        '(?m)^\| TS-\d{2} \|'
    ).Count

    $Milestone5ValidatedPolicyCount = [regex]::Matches(
        $ValidationData,
        '(?im)^ValidatedPolicy:\s*CA\d{3}-'
    ).Count

    $GitIgnoreRules = @(
        Get-Content -LiteralPath (
            Join-Path $ResolvedProjectRoot '.gitignore'
        ) |
            ForEach-Object { $_.Trim() }
    )
    $GitIgnoreProtectionPassed = '/temporary/' -in $GitIgnoreRules

    foreach ($Assertion in $RequiredMilestone5Assertions) {
        $AssertionPath = Join-Path $ResolvedProjectRoot $Assertion.Path

        if (-not (Test-Path -LiteralPath $AssertionPath -PathType Leaf)) {
            $MissingAssertions += "$($Assertion.Name) -> file missing"
            continue
        }

        $AssertionContent = Read-Utf8Text -Path $AssertionPath

        if ($AssertionContent -notmatch $Assertion.Pattern) {
            $MissingAssertions += $Assertion.Name
        }
    }
}

$PolicyCoveragePassed = (
    $MissingPolicyIds.Count -eq 0 -and
    $MissingRequirementIds.Count -eq 0 -and
    $MissingTestIds.Count -eq 0
)

$Milestone5ExitGatesPassed = (
    $MissingAssertions.Count -eq 0 -and
    $MissingMilestone5PolicyNames.Count -eq 0 -and
    $InlineMilestone5ScreenshotCount -eq 11 -and
    $Milestone5ScenarioDispositionCount -eq 9 -and
    $Milestone5ValidatedPolicyCount -eq 5
)

$ValidationPassed = (
    $RootExists -and
    $MissingFiles.Count -eq 0 -and
    $UnexpectedFiles.Count -eq 0 -and
    $EmptyFiles.Count -eq 0 -and
    $InvalidPngFiles.Count -eq 0 -and
    $BrokenLinks.Count -eq 0 -and
    $SensitiveFindings.Count -eq 0 -and
    $PublicTextEncodingFindings.Count -eq 0 -and
    $ValidatedFileCount -eq $ExpectedFiles.Count -and
    $PublishableFileCount -eq $ExpectedFiles.Count -and
    $GitIgnoreProtectionPassed -and
    $PolicyCoveragePassed -and
    $Milestone5ExitGatesPassed
)

[pscustomobject]@{
    ProjectRoot                        = $ProjectRoot
    ProjectRootExists                  = $RootExists
    ExpectedFileCount                  = $ExpectedFiles.Count
    ValidatedFileCount                 = $ValidatedFileCount
    MissingFileCount                   = $MissingFiles.Count
    PublishableFileCount               = $PublishableFileCount
    UnexpectedFileCount                = $UnexpectedFiles.Count
    EmptyFileCount                     = $EmptyFiles.Count
    RequiredScreenshotCount            = 30
    InvalidPngFileCount                = $InvalidPngFiles.Count
    RelativeLinkCount                  = $RelativeLinkCount
    BrokenRelativeLinkCount            = $BrokenLinks.Count
    MicrosoftLearnReferenceCount       = $MicrosoftLearnReferenceCount
    MermaidDiagramCount                = $MermaidDiagramCount
    InlineMilestone5ScreenshotCount    = $InlineMilestone5ScreenshotCount
    Milestone5ScenarioDispositionCount = $Milestone5ScenarioDispositionCount
    Milestone5ValidatedPolicyCount     = $Milestone5ValidatedPolicyCount
    MissingPolicyCount                 = $MissingPolicyIds.Count
    MissingRequirementCount            = $MissingRequirementIds.Count
    MissingTestScenarioCount           = $MissingTestIds.Count
    MissingMilestone5PolicyNameCount   = $MissingMilestone5PolicyNames.Count
    SensitiveFindingCount              = $SensitiveFindings.Count
    PublicTextEncodingFindingCount     = $PublicTextEncodingFindings.Count
    GitIgnoreProtectionPassed          = $GitIgnoreProtectionPassed
    Milestone5ExitGateCount            = $RequiredMilestone5Assertions.Count
    MissingMilestone5ExitGateCount     = $MissingAssertions.Count
    PolicyCoveragePassed               = $PolicyCoveragePassed
    Milestone5ExitGatesPassed          = $Milestone5ExitGatesPassed
    ValidationPassed                   = $ValidationPassed
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
    if ($PublicTextEncodingFindings.Count -gt 0) {
        Write-Warning "Public text encoding findings: $($PublicTextEncodingFindings -join ', ')"
    }
    if ($MissingAssertions.Count -gt 0) {
        Write-Warning "Missing Milestone 5 exit gates: $($MissingAssertions -join ', ')"
    }
    if ($MissingMilestone5PolicyNames.Count -gt 0) {
        Write-Warning "Missing Milestone 5 policy names: $($MissingMilestone5PolicyNames -join ', ')"
    }

    throw 'FAIL: Conditional Access Milestone 5 package validation failed.'
}

Write-Host ''
Write-Host 'PASS: Conditional Access Milestone 5 package validation passed.' -ForegroundColor Green
