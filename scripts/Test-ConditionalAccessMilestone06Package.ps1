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
    'data\m06-controlled-enforcement-validation.txt'
    'docs\Conditional-Access-Baseline-and-Recovery-Readiness.md'
    'docs\Conditional-Access-Business-Requirements.md'
    'docs\Conditional-Access-Prerequisite-and-Licensed-Feature-Readiness.md'
    'docs\Conditional-Access-Report-Only-Deployment.md'
    'docs\Conditional-Access-Scenario-Testing-and-Report-Only-Analysis.md'
    'docs\Conditional-Access-Controlled-Enforcement-and-Operational-Monitoring.md'
    'policies\Conditional-Access-Policy-Matrix.md'
    'runbooks\Conditional-Access-Test-and-Rollback-Plan.md'
    'scripts\Test-ConditionalAccessMilestone01Package.ps1'
    'scripts\Test-ConditionalAccessMilestone02Package.ps1'
    'scripts\Test-ConditionalAccessMilestone03Package.ps1'
    'scripts\Test-ConditionalAccessMilestone04Package.ps1'
    'scripts\Test-ConditionalAccessMilestone05Package.ps1'
    'scripts\Test-ConditionalAccessMilestone06Package.ps1'
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
    'screenshots\m06-01-wave1-pre-enforcement-report-only-inventory.png'
    'screenshots\m06-02-ca010-device-registration-interactive-review-no-results.png'
    'screenshots\m06-03-ca010-device-registration-noninteractive-review-no-results.png'
    'screenshots\m06-04-ca001-enforced-other-wave1-report-only.png'
    'screenshots\m06-05-ca001-enforced-modern-browser-not-applied.png'
    'screenshots\m06-06-ca001-enforcement-audit-success.png'
    'screenshots\m06-07-ca001-enforced-legacy-what-if-block.png'
    'screenshots\m06-08-ca004-enforced-policy-inventory.png'
    'screenshots\m06-09-ca004-enforced-mfa-success.png'
    'screenshots\m06-10-ca005-enforced-policy-inventory.png'
    'screenshots\m06-11-ca005-enforced-mfa-success.png'
    'screenshots\m06-12-ca009-enforced-policy-inventory.png'
    'screenshots\m06-13-ca009-enforced-session-control-success.png'
    'screenshots\m06-14-all-five-policies-enforced.png'
    'screenshots\m06-15-ca010-enforced-device-code-browser-block.png'
    'screenshots\m06-16-ca010-enforced-device-code-block-failure.png'
    'screenshots\m06-17-five-policy-enforcement-audit-success.png'
)

$RequiredMilestone6Assertions = @(
    [pscustomobject]@{ Name = 'README Milestone 6 complete'; Path = 'README.md'; Pattern = '(?i)Milestone\s+6\s+complete' }
    [pscustomobject]@{ Name = 'README Milestone 7 next'; Path = 'README.md'; Pattern = '(?i)Milestone\s+7.+Next' }
    [pscustomobject]@{ Name = 'Controlled enforcement document complete'; Path = 'docs\Conditional-Access-Controlled-Enforcement-and-Operational-Monitoring.md'; Pattern = '(?i)Status:\s*Complete.+all\s+five\s+Wave\s+1\s+policies' }
    [pscustomobject]@{ Name = 'Controlled scope boundary recorded'; Path = 'docs\Conditional-Access-Controlled-Enforcement-and-Operational-Monitoring.md'; Pattern = '(?i)does\s+not\s+claim\s+organization-wide\s+production\s+deployment' }
    [pscustomobject]@{ Name = 'Shortened observation exception recorded'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^ObservationWindowExceptionDocumented:\s*True\s*$' }
    [pscustomobject]@{ Name = 'Production equivalence rejected'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^ProductionEquivalentObservationWindow:\s*False\s*$' }
    [pscustomobject]@{ Name = 'CA001 is On'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^CA001PolicyState:\s*On\s*$' }
    [pscustomobject]@{ Name = 'CA001 safe-test limitation recorded'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^CA001SafeTestLimitationDocumented:\s*True\s*$' }
    [pscustomobject]@{ Name = 'CA004 MFA observed'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^CA004MFAChallengeObserved:\s*True\s*$' }
    [pscustomobject]@{ Name = 'CA004 success'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^CA004ConditionalAccessResult:\s*Success\s*$' }
    [pscustomobject]@{ Name = 'CA005 MFA observed'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^CA005MFAChallengeObserved:\s*True\s*$' }
    [pscustomobject]@{ Name = 'CA005 success'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^CA005ConditionalAccessResult:\s*Success\s*$' }
    [pscustomobject]@{ Name = 'CA009 persistence test passed'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^CA009BrowserPersistenceTest:\s*Passed\s*$' }
    [pscustomobject]@{ Name = 'CA009 password required after restart'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^CA009PasswordRequiredAfterBrowserRestart:\s*True\s*$' }
    [pscustomobject]@{ Name = 'CA010 dependency review clear'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^CA010ResourceExceptionRequired:\s*False\s*$' }
    [pscustomobject]@{ Name = 'CA010 device code blocked'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^CA010DeviceCodeBrowserBlocked:\s*True\s*$' }
    [pscustomobject]@{ Name = 'CA010 enforced failure'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^CA010ConditionalAccessResult:\s*Failure\s*$' }
    [pscustomobject]@{ Name = 'First emergency post-test passed'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^EmergencyAccount01PostEnforcementTest:\s*Passed\s*$' }
    [pscustomobject]@{ Name = 'Second emergency post-test passed'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^EmergencyAccount02PostEnforcementTest:\s*Passed\s*$' }
    [pscustomobject]@{ Name = 'Least-privilege finding recorded'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^LeastPrivilegeFindingRecorded:\s*True\s*$' }
    [pscustomobject]@{ Name = 'Five successful policy updates'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^SuccessfulConditionalAccessUpdateCount:\s*5\s*$' }
    [pscustomobject]@{ Name = 'Five enforced policies'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^EnforcedPolicyCount:\s*5\s*$' }
    [pscustomobject]@{ Name = 'Seventeen screenshots recorded'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^RequiredScreenshotCount:\s*17\s*$' }
    [pscustomobject]@{ Name = 'Screenshot privacy review passed'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^ScreenshotPrivacyReviewPassed:\s*True\s*$' }
    [pscustomobject]@{ Name = 'No sensitive identifier published'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^SensitiveIdentifiersPublished:\s*0\s*$' }
    [pscustomobject]@{ Name = 'Milestone 6 validation passed'; Path = 'data\m06-controlled-enforcement-validation.txt'; Pattern = '(?im)^ValidationPassed:\s*True\s*$' }
)

function Read-Utf8Text {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return ''
    }

    [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
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
$MissingMilestone6PolicyNames = @()
$ValidatedFileCount = 0
$PublishableFileCount = 0
$RelativeLinkCount = 0
$MicrosoftLearnReferenceCount = 0
$MermaidDiagramCount = 0
$InlineMilestone6ScreenshotCount = 0
$Milestone6ScenarioDispositionCount = 0
$Milestone6ValidatedPolicyCount = 0
$GitIgnoreProtectionPassed = $false

if ($RootExists) {
    $ResolvedProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path.TrimEnd([char[]]@('\', '/'))

    $PublishableRelativePaths = @(
        Get-ChildItem -LiteralPath $ResolvedProjectRoot -File -Recurse -Force |
            ForEach-Object {
                (
                    $_.FullName.Substring($ResolvedProjectRoot.Length).TrimStart([char[]]@('\', '/'))
                ) -replace '/', '\'
            } |
            Where-Object {
                $_ -ne '.git' -and
                $_ -notlike '.git\*' -and
                $_ -notlike 'temporary\*'
            }
    )

    $PublishableFileCount = $PublishableRelativePaths.Count
    $UnexpectedFiles = @($PublishableRelativePaths | Where-Object { $_ -notin $ExpectedFiles })

    foreach ($RelativePath in $ExpectedFiles) {
        $FullPath = Join-Path $ResolvedProjectRoot $RelativePath

        if (-not (Test-Path -LiteralPath $FullPath -PathType Leaf)) {
            $MissingFiles += $RelativePath
            continue
        }

        if ((Get-Item -LiteralPath $FullPath -Force).Length -eq 0) {
            $EmptyFiles += $RelativePath
            continue
        }

        if ($RelativePath -like '*.png') {
            $Bytes = [System.IO.File]::ReadAllBytes($FullPath)
            $Signature = [byte[]](137, 80, 78, 71, 13, 10, 26, 10)
            $ValidSignature = $Bytes.Length -ge 8

            if ($ValidSignature) {
                for ($Index = 0; $Index -lt 8; $Index++) {
                    if ($Bytes[$Index] -ne $Signature[$Index]) {
                        $ValidSignature = $false
                        break
                    }
                }
            }

            if (-not $ValidSignature) {
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
            $LinkMatches = [regex]::Matches(
                $Content,
                '\[[^\]]+\]\((?!https?://|mailto:|#)(?<Target>[^)#]+)(?:#[^)]+)?\)'
            )

            $RelativeLinkCount += $LinkMatches.Count

            foreach ($LinkMatch in $LinkMatches) {
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

        $EncodingPatterns = [ordered]@{
            MojibakePunctuation = '\u00E2\u20AC[\u0080-\u20FF]'
            MojibakeNbsp        = '\u00C2\u00A0'
        }

        foreach ($PatternName in $EncodingPatterns.Keys) {
            if ([regex]::IsMatch($Content, $EncodingPatterns[$PatternName])) {
                $PublicTextEncodingFindings += "$RelativeTextPath -> $PatternName"
            }
        }
    }

    $PolicyContent = Read-Utf8Text -Path (Join-Path $ResolvedProjectRoot 'policies\Conditional-Access-Policy-Matrix.md')
    $BusinessContent = Read-Utf8Text -Path (Join-Path $ResolvedProjectRoot 'docs\Conditional-Access-Business-Requirements.md')
    $RunbookContent = Read-Utf8Text -Path (Join-Path $ResolvedProjectRoot 'runbooks\Conditional-Access-Test-and-Rollback-Plan.md')
    $Milestone6Content = Read-Utf8Text -Path (Join-Path $ResolvedProjectRoot 'docs\Conditional-Access-Controlled-Enforcement-and-Operational-Monitoring.md')
    $ValidationData = Read-Utf8Text -Path (Join-Path $ResolvedProjectRoot 'data\m06-controlled-enforcement-validation.txt')

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

    $Milestone6PolicyNames = @(
        'CA001-BLOCK-LegacyAuthentication-AllUsers'
        'CA004-GRANT-MFA-ManagementSurfaces-AllUsers'
        'CA005-GRANT-MFA-SecurityInfoRegistration-AllUsers'
        'CA009-SESSION-NoPersistentBrowser-Contractors'
        'CA010-BLOCK-DeviceCodeFlow-AllUsers'
    )

    foreach ($PolicyName in $Milestone6PolicyNames) {
        if (
            $Milestone6Content -notmatch [regex]::Escape($PolicyName) -or
            $ValidationData -notmatch [regex]::Escape($PolicyName)
        ) {
            $MissingMilestone6PolicyNames += $PolicyName
        }
    }

    $InlineMilestone6ScreenshotCount = [regex]::Matches(
        $Milestone6Content,
        '!\[[^\]]+\]\(\.\./screenshots/m06-[^)]+\.png\)'
    ).Count

    $Milestone6ScenarioDispositionCount = [regex]::Matches(
        $Milestone6Content,
        '(?m)^\| TS-\d{2} \|'
    ).Count

    $Milestone6ValidatedPolicyCount = [regex]::Matches(
        $ValidationData,
        '(?im)^ValidatedPolicy:\s*CA\d{3}-'
    ).Count

    $GitIgnoreRules = @(
        Get-Content -LiteralPath (Join-Path $ResolvedProjectRoot '.gitignore') |
            ForEach-Object { $_.Trim() }
    )
    $GitIgnoreProtectionPassed = '/temporary/' -in $GitIgnoreRules

    foreach ($Assertion in $RequiredMilestone6Assertions) {
        $AssertionPath = Join-Path $ResolvedProjectRoot $Assertion.Path

        if (-not (Test-Path -LiteralPath $AssertionPath -PathType Leaf)) {
            $MissingAssertions += "$($Assertion.Name) -> file missing"
            continue
        }

        if ((Read-Utf8Text -Path $AssertionPath) -notmatch $Assertion.Pattern) {
            $MissingAssertions += $Assertion.Name
        }
    }
}

$ExpectedScreenshotCount = @($ExpectedFiles | Where-Object { $_ -like 'screenshots\*.png' }).Count
$ExpectedMilestone6ScreenshotCount = @($ExpectedFiles | Where-Object { $_ -like 'screenshots\m06-*.png' }).Count

$PolicyCoveragePassed = (
    $MissingPolicyIds.Count -eq 0 -and
    $MissingRequirementIds.Count -eq 0 -and
    $MissingTestIds.Count -eq 0
)

$Milestone6ExitGatesPassed = (
    $MissingAssertions.Count -eq 0 -and
    $MissingMilestone6PolicyNames.Count -eq 0 -and
    $ExpectedMilestone6ScreenshotCount -eq 17 -and
    $InlineMilestone6ScreenshotCount -eq 17 -and
    $Milestone6ScenarioDispositionCount -eq 11 -and
    $Milestone6ValidatedPolicyCount -eq 5
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
    $ExpectedScreenshotCount -eq 47 -and
    $GitIgnoreProtectionPassed -and
    $PolicyCoveragePassed -and
    $Milestone6ExitGatesPassed
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
    RequiredScreenshotCount            = $ExpectedScreenshotCount
    InvalidPngFileCount                = $InvalidPngFiles.Count
    RelativeLinkCount                  = $RelativeLinkCount
    BrokenRelativeLinkCount            = $BrokenLinks.Count
    MicrosoftLearnReferenceCount       = $MicrosoftLearnReferenceCount
    MermaidDiagramCount                = $MermaidDiagramCount
    InlineMilestone6ScreenshotCount    = $InlineMilestone6ScreenshotCount
    Milestone6ScenarioDispositionCount = $Milestone6ScenarioDispositionCount
    Milestone6ValidatedPolicyCount     = $Milestone6ValidatedPolicyCount
    MissingPolicyCount                 = $MissingPolicyIds.Count
    MissingRequirementCount            = $MissingRequirementIds.Count
    MissingTestScenarioCount           = $MissingTestIds.Count
    MissingMilestone6PolicyNameCount   = $MissingMilestone6PolicyNames.Count
    SensitiveFindingCount              = $SensitiveFindings.Count
    PublicTextEncodingFindingCount     = $PublicTextEncodingFindings.Count
    GitIgnoreProtectionPassed          = $GitIgnoreProtectionPassed
    Milestone6ExitGateCount            = $RequiredMilestone6Assertions.Count
    MissingMilestone6ExitGateCount     = $MissingAssertions.Count
    PolicyCoveragePassed               = $PolicyCoveragePassed
    Milestone6ExitGatesPassed          = $Milestone6ExitGatesPassed
    ValidationPassed                   = $ValidationPassed
}

if (-not $ValidationPassed) {
    if ($MissingFiles.Count -gt 0) { Write-Warning "Missing files: $($MissingFiles -join ', ')" }
    if ($UnexpectedFiles.Count -gt 0) { Write-Warning "Unexpected publishable files: $($UnexpectedFiles -join ', ')" }
    if ($EmptyFiles.Count -gt 0) { Write-Warning "Empty files: $($EmptyFiles -join ', ')" }
    if ($InvalidPngFiles.Count -gt 0) { Write-Warning "Invalid PNG files: $($InvalidPngFiles -join ', ')" }
    if ($BrokenLinks.Count -gt 0) { Write-Warning "Broken links: $($BrokenLinks -join ', ')" }
    if ($SensitiveFindings.Count -gt 0) { Write-Warning "Potential sensitive findings: $($SensitiveFindings -join ', ')" }
    if ($PublicTextEncodingFindings.Count -gt 0) { Write-Warning "Public text encoding findings: $($PublicTextEncodingFindings -join ', ')" }
    if ($MissingAssertions.Count -gt 0) { Write-Warning "Missing Milestone 6 exit gates: $($MissingAssertions -join ', ')" }
    if ($MissingMilestone6PolicyNames.Count -gt 0) { Write-Warning "Missing Milestone 6 policy names: $($MissingMilestone6PolicyNames -join ', ')" }

    throw 'FAIL: Conditional Access Milestone 6 package validation failed.'
}

Write-Host ''
Write-Host 'PASS: Conditional Access Milestone 6 package validation passed.' -ForegroundColor Green
