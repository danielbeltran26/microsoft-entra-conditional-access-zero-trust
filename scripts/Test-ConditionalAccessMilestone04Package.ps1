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
    'docs\Conditional-Access-Baseline-and-Recovery-Readiness.md'
    'docs\Conditional-Access-Business-Requirements.md'
    'docs\Conditional-Access-Prerequisite-and-Licensed-Feature-Readiness.md'
    'docs\Conditional-Access-Report-Only-Deployment.md'
    'policies\Conditional-Access-Policy-Matrix.md'
    'runbooks\Conditional-Access-Test-and-Rollback-Plan.md'
    'scripts\Test-ConditionalAccessMilestone01Package.ps1'
    'scripts\Test-ConditionalAccessMilestone02Package.ps1'
    'scripts\Test-ConditionalAccessMilestone03Package.ps1'
    'scripts\Test-ConditionalAccessMilestone04Package.ps1'
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
)

$RequiredMilestone4Assertions = @(
    [pscustomobject]@{
        Name = 'README Milestone 4 complete'
        Path = 'README.md'
        Pattern = '(?i)Milestone\s+4\s+complete'
    }
    [pscustomobject]@{
        Name = 'README Milestone 5 next'
        Path = 'README.md'
        Pattern = '(?i)Milestone\s+5.+Next'
    }
    [pscustomobject]@{
        Name = 'Deployment document complete'
        Path = 'docs\Conditional-Access-Report-Only-Deployment.md'
        Pattern = '(?i)Status:\s*Complete.+five\s+Wave\s+1\s+policies'
    }
    [pscustomobject]@{
        Name = 'Security defaults transition recorded'
        Path = 'docs\Conditional-Access-Report-Only-Deployment.md'
        Pattern = '(?i)security\s+defaults\s+to\s+be\s+disabled'
    }
    [pscustomobject]@{
        Name = 'Scenario-testing boundary recorded'
        Path = 'docs\Conditional-Access-Report-Only-Deployment.md'
        Pattern = '(?i)What\s+If.+controlled\s+sign-in.+begin\s+in\s+Milestone\s+5'
    }
    [pscustomobject]@{
        Name = 'CA008 remains deferred'
        Path = 'docs\Conditional-Access-Report-Only-Deployment.md'
        Pattern = '(?i)CA008.+not\s+created'
    }
    [pscustomobject]@{
        Name = 'Report-only inventory passed'
        Path = 'data\m04-wave1-report-only-validation.txt'
        Pattern = '(?im)^ReportOnlyInventoryPassed:\s*True\s*$'
    }
    [pscustomobject]@{
        Name = 'Configuration validation passed'
        Path = 'data\m04-wave1-report-only-validation.txt'
        Pattern = '(?im)^AllConfigurationsMatchedApprovedMatrix:\s*True\s*$'
    }
    [pscustomobject]@{
        Name = 'No enforced policy recorded'
        Path = 'data\m04-wave1-report-only-validation.txt'
        Pattern = '(?im)^EnforcedPolicyCount:\s*0\s*$'
    }
    [pscustomobject]@{
        Name = 'No scenario-testing claim'
        Path = 'data\m04-wave1-report-only-validation.txt'
        Pattern = '(?im)^ScenarioTestingExecuted:\s*False\s*$'
    }
    [pscustomobject]@{
        Name = 'Five policies observed'
        Path = 'data\m04-wave1-report-only-validation.txt'
        Pattern = '(?im)^ObservedPolicyCount:\s*5\s*$'
    }
)

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
$MissingMilestone4PolicyNames = @()
$PublishableFileCount = 0
$ValidatedFileCount = 0
$RelativeLinkCount = 0
$MicrosoftLearnReferenceCount = 0
$MermaidDiagramCount = 0
$InlineMilestone4ScreenshotCount = 0
$GitIgnoreProtectionPassed = $false
$ConfigurationMatchCount = 0

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

        $Content = [System.IO.File]::ReadAllText(
            $FullTextPath,
            [System.Text.Encoding]::UTF8
        )

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
                $PublicTextEncodingFindings += `
                    "$RelativeTextPath -> $PatternName"
            }
        }
    }

    $PolicyPath = Join-Path $ResolvedProjectRoot 'policies\Conditional-Access-Policy-Matrix.md'
    $BusinessPath = Join-Path $ResolvedProjectRoot 'docs\Conditional-Access-Business-Requirements.md'
    $RunbookPath = Join-Path $ResolvedProjectRoot 'runbooks\Conditional-Access-Test-and-Rollback-Plan.md'
    $DeploymentPath = Join-Path $ResolvedProjectRoot 'docs\Conditional-Access-Report-Only-Deployment.md'
    $ValidationDataPath = Join-Path $ResolvedProjectRoot 'data\m04-wave1-report-only-validation.txt'

    $PolicyContent = [System.IO.File]::ReadAllText(
        $PolicyPath,
        [System.Text.Encoding]::UTF8
    )
    $BusinessContent = [System.IO.File]::ReadAllText(
        $BusinessPath,
        [System.Text.Encoding]::UTF8
    )
    $RunbookContent = [System.IO.File]::ReadAllText(
        $RunbookPath,
        [System.Text.Encoding]::UTF8
    )
    $DeploymentContent = [System.IO.File]::ReadAllText(
        $DeploymentPath,
        [System.Text.Encoding]::UTF8
    )
    $ValidationData = [System.IO.File]::ReadAllText(
        $ValidationDataPath,
        [System.Text.Encoding]::UTF8
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

    $Milestone4PolicyNames = @(
        'CA001-BLOCK-LegacyAuthentication-AllUsers'
        'CA004-GRANT-MFA-ManagementSurfaces-AllUsers'
        'CA005-GRANT-MFA-SecurityInfoRegistration-AllUsers'
        'CA009-SESSION-NoPersistentBrowser-Contractors'
        'CA010-BLOCK-DeviceCodeFlow-AllUsers'
    )

    foreach ($PolicyName in $Milestone4PolicyNames) {
        if (
            $DeploymentContent -notmatch [regex]::Escape($PolicyName) -or
            $ValidationData -notmatch [regex]::Escape($PolicyName)
        ) {
            $MissingMilestone4PolicyNames += $PolicyName
        }
    }

    $InlineMilestone4ScreenshotCount = [regex]::Matches(
        $DeploymentContent,
        '!\[[^\]]+\]\(\.\./screenshots/m04-[^)]+\.png\)'
    ).Count

    $ConfigurationMatchCount = [regex]::Matches(
        $ValidationData,
        '(?im)^ConfigurationMatchedApprovedMatrix:\s*True\s*$'
    ).Count

    $GitIgnorePath = Join-Path $ResolvedProjectRoot '.gitignore'
    $GitIgnoreRules = @(
        Get-Content -LiteralPath $GitIgnorePath |
            ForEach-Object { $_.Trim() }
    )
    $GitIgnoreProtectionPassed = '/temporary/' -in $GitIgnoreRules

    foreach ($Assertion in $RequiredMilestone4Assertions) {
        $AssertionPath = Join-Path $ResolvedProjectRoot $Assertion.Path

        if (-not (Test-Path -LiteralPath $AssertionPath -PathType Leaf)) {
            $MissingAssertions += "$($Assertion.Name) -> file missing"
            continue
        }

        $AssertionContent = [System.IO.File]::ReadAllText(
            $AssertionPath,
            [System.Text.Encoding]::UTF8
        )

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

$Milestone4ExitGatesPassed = (
    $MissingAssertions.Count -eq 0 -and
    $MissingMilestone4PolicyNames.Count -eq 0 -and
    $InlineMilestone4ScreenshotCount -eq 7 -and
    $ConfigurationMatchCount -eq 5
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
    $Milestone4ExitGatesPassed
)

[pscustomobject]@{
    ProjectRoot                      = $ProjectRoot
    ProjectRootExists                = $RootExists
    ExpectedFileCount                = $ExpectedFiles.Count
    ValidatedFileCount               = $ValidatedFileCount
    MissingFileCount                 = $MissingFiles.Count
    PublishableFileCount             = $PublishableFileCount
    UnexpectedFileCount              = $UnexpectedFiles.Count
    EmptyFileCount                   = $EmptyFiles.Count
    RequiredScreenshotCount          = 19
    InvalidPngFileCount              = $InvalidPngFiles.Count
    RelativeLinkCount                = $RelativeLinkCount
    BrokenRelativeLinkCount          = $BrokenLinks.Count
    MicrosoftLearnReferenceCount     = $MicrosoftLearnReferenceCount
    MermaidDiagramCount              = $MermaidDiagramCount
    InlineMilestone4ScreenshotCount  = $InlineMilestone4ScreenshotCount
    ConfigurationMatchCount          = $ConfigurationMatchCount
    MissingPolicyCount               = $MissingPolicyIds.Count
    MissingRequirementCount          = $MissingRequirementIds.Count
    MissingTestScenarioCount         = $MissingTestIds.Count
    MissingMilestone4PolicyNameCount = $MissingMilestone4PolicyNames.Count
    SensitiveFindingCount            = $SensitiveFindings.Count
    PublicTextEncodingFindingCount   = $PublicTextEncodingFindings.Count
    GitIgnoreProtectionPassed        = $GitIgnoreProtectionPassed
    Milestone4ExitGateCount          = $RequiredMilestone4Assertions.Count
    MissingMilestone4ExitGateCount   = $MissingAssertions.Count
    PolicyCoveragePassed             = $PolicyCoveragePassed
    Milestone4ExitGatesPassed        = $Milestone4ExitGatesPassed
    ValidationPassed                 = $ValidationPassed
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
        Write-Warning "Missing Milestone 4 exit gates: $($MissingAssertions -join ', ')"
    }
    if ($MissingMilestone4PolicyNames.Count -gt 0) {
        Write-Warning "Missing Milestone 4 policy names: $($MissingMilestone4PolicyNames -join ', ')"
    }

    throw 'FAIL: Conditional Access Milestone 4 package validation failed.'
}

Write-Host ''
Write-Host `
    'PASS: Conditional Access Milestone 4 package validation passed.' `
    -ForegroundColor Green
