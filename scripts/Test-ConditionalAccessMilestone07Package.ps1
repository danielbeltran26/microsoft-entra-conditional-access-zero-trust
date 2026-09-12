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
    'data\m07-final-assurance-validation.txt'
    'data\m07-operational-control-register.csv'
    'docs\Conditional-Access-Baseline-and-Recovery-Readiness.md'
    'docs\Conditional-Access-Business-Requirements.md'
    'docs\Conditional-Access-Prerequisite-and-Licensed-Feature-Readiness.md'
    'docs\Conditional-Access-Report-Only-Deployment.md'
    'docs\Conditional-Access-Scenario-Testing-and-Report-Only-Analysis.md'
    'docs\Conditional-Access-Controlled-Enforcement-and-Operational-Monitoring.md'
    'docs\Conditional-Access-Lessons-Learned.md'
    'docs\Conditional-Access-Operational-Handover-and-Final-Assurance.md'
    'policies\Conditional-Access-Policy-Matrix.md'
    'runbooks\Conditional-Access-Test-and-Rollback-Plan.md'
    'runbooks\Conditional-Access-Operations-Handover-Runbook.md'
    'scripts\Test-ConditionalAccessMilestone01Package.ps1'
    'scripts\Test-ConditionalAccessMilestone02Package.ps1'
    'scripts\Test-ConditionalAccessMilestone03Package.ps1'
    'scripts\Test-ConditionalAccessMilestone04Package.ps1'
    'scripts\Test-ConditionalAccessMilestone05Package.ps1'
    'scripts\Test-ConditionalAccessMilestone06Package.ps1'
    'scripts\Test-ConditionalAccessMilestone07Package.ps1'
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
    'screenshots\m07-01-final-five-policy-state.png'
    'screenshots\m07-02-conditional-access-failure-monitoring-review.png'
    'screenshots\m07-03-conditional-access-success-monitoring-review.png'
    'screenshots\m07-04-conditional-access-change-audit-review.png'
    'screenshots\m07-05-no-deleted-conditional-access-policies.png'
    'screenshots\m07-06-entra-id-p2-license-allocation.png'
    'screenshots\m07-07-entra-id-p2-active-trial-expiration.png'
    'screenshots\m07-08-entra-id-p2-recurring-billing-off.png'
    'screenshots\m07-09-emergency-exclusion-membership-count.png'
    'screenshots\m07-10-workforce-pilot-membership-count.png'
    'screenshots\m07-11-contractor-scope-membership-count.png'
    'screenshots\m07-12-permanent-global-administrator-finding.png'
)

$RequiredMilestone7Assertions = @(
    [pscustomobject]@{ Name = 'README implementation complete'; Path = 'README.md'; Pattern = '(?i)\*\*Status:\s*Complete\.\*\*' }
    [pscustomobject]@{ Name = 'README implementation status'; Path = 'README.md'; Pattern = '(?i)\*\*Implementation\s+status:\s*Complete\.\*\*' }
    [pscustomobject]@{ Name = 'README lessons learned linked'; Path = 'README.md'; Pattern = '(?i)\[implementation\s+lessons\s+learned\]\(docs/Conditional-Access-Lessons-Learned\.md\)' }
    [pscustomobject]@{ Name = 'Lessons learned complete'; Path = 'docs\Conditional-Access-Lessons-Learned.md'; Pattern = '(?i)##\s+10\.\s+Final\s+conclusion' }
    [pscustomobject]@{ Name = 'Lessons learned production boundary'; Path = 'docs\Conditional-Access-Lessons-Learned.md'; Pattern = '(?i)not\s+a\s+claim\s+of\s+organization-wide\s+production\s+readiness' }
    [pscustomobject]@{ Name = 'Handover links lessons learned'; Path = 'docs\Conditional-Access-Operational-Handover-and-Final-Assurance.md'; Pattern = '(?i)\[Conditional\s+Access\s+Implementation\s+Lessons\s+Learned\]\(Conditional-Access-Lessons-Learned\.md\)' }
    [pscustomobject]@{ Name = 'Final assurance document complete'; Path = 'docs\Conditional-Access-Operational-Handover-and-Final-Assurance.md'; Pattern = '(?i)Status:\s*Complete.+five\s+Wave\s+1\s+policies\s+remain\s+On' }
    [pscustomobject]@{ Name = 'Controlled scope boundary recorded'; Path = 'docs\Conditional-Access-Operational-Handover-and-Final-Assurance.md'; Pattern = '(?i)does\s+not\s+claim\s+organization-wide\s+production\s+deployment' }
    [pscustomobject]@{ Name = 'Five user-created policies'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^FinalUserCreatedPolicyCount:\s*5\s*$' }
    [pscustomobject]@{ Name = 'No Microsoft-managed policies'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^FinalMicrosoftManagedPolicyCount:\s*0\s*$' }
    [pscustomobject]@{ Name = 'Five enabled policies'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^FinalEnabledPolicyCount:\s*5\s*$' }
    [pscustomobject]@{ Name = 'No deleted policies'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^DeletedConditionalAccessPolicyCount:\s*0\s*$' }
    [pscustomobject]@{ Name = 'CA001 final state On'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^CA001FinalState:\s*On\s*$' }
    [pscustomobject]@{ Name = 'CA004 final state On'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^CA004FinalState:\s*On\s*$' }
    [pscustomobject]@{ Name = 'CA005 final state On'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^CA005FinalState:\s*On\s*$' }
    [pscustomobject]@{ Name = 'CA009 final state On'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^CA009FinalState:\s*On\s*$' }
    [pscustomobject]@{ Name = 'CA010 final state On'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^CA010FinalState:\s*On\s*$' }
    [pscustomobject]@{ Name = 'First emergency final test passed'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^EmergencyAccount01FinalAccessTest:\s*Passed\s*$' }
    [pscustomobject]@{ Name = 'Second emergency final test passed'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^EmergencyAccount02FinalAccessTest:\s*Passed\s*$' }
    [pscustomobject]@{ Name = 'Emergency review cadence recorded'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^EmergencyAccessReviewCadenceDays:\s*90\s*$' }
    [pscustomobject]@{ Name = 'Expected CA010 failure count'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^ExpectedCA010DeviceCodeFailureCount:\s*1\s*$' }
    [pscustomobject]@{ Name = 'No unexpected CA failure'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^UnexpectedConditionalAccessFailureCount:\s*0\s*$' }
    [pscustomobject]@{ Name = 'Five successful policy creates'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^SuccessfulConditionalAccessPolicyCreateCount:\s*5\s*$' }
    [pscustomobject]@{ Name = 'Five successful policy updates'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^SuccessfulConditionalAccessPolicyUpdateCount:\s*5\s*$' }
    [pscustomobject]@{ Name = 'No failed CA change'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^FailedConditionalAccessChangeCount:\s*0\s*$' }
    [pscustomobject]@{ Name = 'No unexplained CA change'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^UnexplainedConditionalAccessChangeCount:\s*0\s*$' }
    [pscustomobject]@{ Name = 'P2 subscription active'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^EntraIDP2SubscriptionStatus:\s*Active\s*$' }
    [pscustomobject]@{ Name = 'P2 assigned count seven'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^EntraIDP2AssignedLicenseCount:\s*7\s*$' }
    [pscustomobject]@{ Name = 'P2 expiry recorded'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^EntraIDP2ExpirationDate:\s*2026-10-06\s*$' }
    [pscustomobject]@{ Name = 'P2 recurring billing Off'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^EntraIDP2RecurringBilling:\s*Off\s*$' }
    [pscustomobject]@{ Name = 'Standard Conditional Access licence boundary'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^StandardConditionalAccessLicenseBaseline:\s*Entra ID P1\s*$' }
    [pscustomobject]@{ Name = 'Risk-based Conditional Access licence boundary'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^RiskBasedConditionalAccessLicenseBaseline:\s*Entra ID P2\s*$' }
    [pscustomobject]@{ Name = 'CA009 licence mapping limitation'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^CA009TargetLicenseMappingPubliclyProven:\s*False\s*$' }
    [pscustomobject]@{ Name = 'Tenant-wide replacement coverage limitation'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^SecurityDefaultsReplacementCoverageTenantWideProven:\s*False\s*$' }
    [pscustomobject]@{ Name = 'Emergency method independence limitation'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^EmergencyAuthenticationProductionIndependent:\s*False\s*$' }
    [pscustomobject]@{ Name = 'Workbook limitation documented'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^InsightsReportingLimitationDocumented:\s*True\s*$' }
    [pscustomobject]@{ Name = 'No production-wide claim'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^ProductionWideDeploymentClaimed:\s*False\s*$' }
    [pscustomobject]@{ Name = 'Five deferred policies'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^DeferredPolicyCount:\s*5\s*$' }
    [pscustomobject]@{ Name = 'Operations control register complete'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^OperationalControlRegisterComplete:\s*True\s*$' }
    [pscustomobject]@{ Name = 'Monitoring runbook complete'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^MonitoringRunbookComplete:\s*True\s*$' }
    [pscustomobject]@{ Name = 'Twelve screenshots recorded'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^RequiredMilestone7ScreenshotCount:\s*12\s*$' }
    [pscustomobject]@{ Name = 'Screenshot privacy review passed'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^ScreenshotPrivacyReviewPassed:\s*True\s*$' }
    [pscustomobject]@{ Name = 'No sensitive identifier published'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^SensitiveIdentifiersPublished:\s*0\s*$' }
    [pscustomobject]@{ Name = 'Operational handover passed'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^OperationalHandoverPassed:\s*True\s*$' }
    [pscustomobject]@{ Name = 'Final assurance passed'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^FinalTechnicalAssurancePassed:\s*True\s*$' }
    [pscustomobject]@{ Name = 'Final assurance scope'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^FinalTechnicalAssuranceScope:\s*ControlledWave1Only\s*$' }
    [pscustomobject]@{ Name = 'Implementation complete'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^ImplementationComplete:\s*True\s*$' }
    [pscustomobject]@{ Name = 'Milestone 7 validation passed'; Path = 'data\m07-final-assurance-validation.txt'; Pattern = '(?im)^ValidationPassed:\s*True\s*$' }
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
$NonEngineeringLanguageFindings = @()
$NonEngineeringPathFindings = @()
$PublicTextEncodingFindings = @()
$MissingAssertions = @()
$MissingPolicyIds = @()
$MissingRequirementIds = @()
$MissingTestIds = @()
$MissingMilestone7PolicyNames = @()
$ValidatedFileCount = 0
$PublishableFileCount = 0
$RelativeLinkCount = 0
$MicrosoftLearnReferenceCount = 0
$MermaidDiagramCount = 0
$InlineMilestone7ScreenshotCount = 0
$Milestone7HandoverChecklistCount = 0
$Milestone7ControlRegisterRowCount = 0
$Milestone7ValidatedPolicyCount = 0
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

    $NonEngineeringPathPatterns = [ordered]@{
        InternalNumberedLabel = ('(?i)\b(?:IAM[\s_-]*)?Proj' + 'ect[\s_-]*[1-5]\b')
        SelfPromotionalLabel  = ('(?i)Sk' + 'ills?[\s_-]+Demonstr' + 'ated')
        InformalOverviewLabel = ('(?i)30[\s_-]+Second[\s_-]+Overview')
    }

    foreach ($PublishableRelativePath in $PublishableRelativePaths) {
        foreach ($PatternName in $NonEngineeringPathPatterns.Keys) {
            if ([regex]::IsMatch($PublishableRelativePath, $NonEngineeringPathPatterns[$PatternName])) {
                $NonEngineeringPathFindings += "$PublishableRelativePath -> $PatternName"
            }
        }
    }

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
                $_ -like '*.csv' -or
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
            EmergencyUserName  = ('(?i)\bemergency-' + 'admin-\d{2}\b')
            AdminIdentityName  = ('(?i)\bIAM-' + 'Admin\b')
            CredentialMaterial = ('(?i)(client[_ -]?' + 'secret|pass' + 'word)\s*[:=]\s*["'']?[A-Za-z0-9+/=_-]{8,}')
        }

        foreach ($PatternName in $SensitivePatterns.Keys) {
            if ([regex]::IsMatch($Content, $SensitivePatterns[$PatternName])) {
                $SensitiveFindings += "$RelativeTextPath -> $PatternName"
            }
        }

        $NonEngineeringLanguagePatterns = [ordered]@{
            ExternalAudienceTermA = ('(?i)\brecr' + 'uiter(s)?\b')
            ExternalAudienceTermB = ('(?i)\binter' + 'view(er|ing|s)?\b')
            ExternalAudienceTermC = ('(?i)\bemployer\s*-\s*' + 'facing\b')
            ExternalAudienceTermD = ('(?i)\bport' + 'folio\b')
            ExternalAudienceTermE = ('(?i)\bjob\s+(application|search|seeker)\b')
            ExternalAudienceTermF = ('(?i)\bhiring\s+(manager|team|process)\b')
            InternalNumberedLabel  = ('(?i)\b(?:IAM[\s_-]*)?Proj' + 'ect[\s_-]*[1-5]\b')
            SelfPromotionalHeading = ('(?im)^#{1,6}\s*Sk' + 'ills?\s+Demonstr' + 'ated\s*$')
            InformalOverviewHeading = ('(?im)^#{1,6}\s*30(?:-|\s+)Second\s+Overview\s*$')
        }

        foreach ($PatternName in $NonEngineeringLanguagePatterns.Keys) {
            if ([regex]::IsMatch($Content, $NonEngineeringLanguagePatterns[$PatternName])) {
                $NonEngineeringLanguageFindings += "$RelativeTextPath -> $PatternName"
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
    $Milestone7Content = Read-Utf8Text -Path (Join-Path $ResolvedProjectRoot 'docs\Conditional-Access-Operational-Handover-and-Final-Assurance.md')
    $OperationsRunbookContent = Read-Utf8Text -Path (Join-Path $ResolvedProjectRoot 'runbooks\Conditional-Access-Operations-Handover-Runbook.md')
    $ValidationData = Read-Utf8Text -Path (Join-Path $ResolvedProjectRoot 'data\m07-final-assurance-validation.txt')
    $ControlRegisterContent = Read-Utf8Text -Path (Join-Path $ResolvedProjectRoot 'data\m07-operational-control-register.csv')

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

    $Milestone7PolicyNames = @(
        'CA001-BLOCK-LegacyAuthentication-AllUsers'
        'CA004-GRANT-MFA-ManagementSurfaces-AllUsers'
        'CA005-GRANT-MFA-SecurityInfoRegistration-AllUsers'
        'CA009-SESSION-NoPersistentBrowser-Contractors'
        'CA010-BLOCK-DeviceCodeFlow-AllUsers'
    )

    foreach ($PolicyName in $Milestone7PolicyNames) {
        if (
            $Milestone7Content -notmatch [regex]::Escape($PolicyName) -or
            $ValidationData -notmatch [regex]::Escape($PolicyName)
        ) {
            $MissingMilestone7PolicyNames += $PolicyName
        }
    }

    $InlineMilestone7ScreenshotCount = [regex]::Matches(
        $Milestone7Content,
        '!\[[^\]]+\]\(\.\./screenshots/m07-[^)]+\.png\)'
    ).Count

    $Milestone7HandoverChecklistCount = [regex]::Matches(
        $OperationsRunbookContent,
        '(?m)^- \[x\] '
    ).Count

    $Milestone7ControlRegisterRowCount = [regex]::Matches(
        $ControlRegisterContent,
        '(?m)^CA\d{3},'
    ).Count

    $Milestone7ValidatedPolicyCount = [regex]::Matches(
        $ValidationData,
        '(?im)^ValidatedPolicy:\s*CA\d{3}-'
    ).Count

    $GitIgnoreRules = @(
        Get-Content -LiteralPath (Join-Path $ResolvedProjectRoot '.gitignore') |
            ForEach-Object { $_.Trim() }
    )
    $GitIgnoreProtectionPassed = '/temporary/' -in $GitIgnoreRules

    foreach ($Assertion in $RequiredMilestone7Assertions) {
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
$ExpectedMilestone7ScreenshotCount = @($ExpectedFiles | Where-Object { $_ -like 'screenshots\m07-*.png' }).Count

$PolicyCoveragePassed = (
    $MissingPolicyIds.Count -eq 0 -and
    $MissingRequirementIds.Count -eq 0 -and
    $MissingTestIds.Count -eq 0
)

$Milestone7ExitGatesPassed = (
    $MissingAssertions.Count -eq 0 -and
    $MissingMilestone7PolicyNames.Count -eq 0 -and
    $ExpectedMilestone7ScreenshotCount -eq 12 -and
    $InlineMilestone7ScreenshotCount -eq 12 -and
    $Milestone7HandoverChecklistCount -eq 11 -and
    $Milestone7ControlRegisterRowCount -eq 5 -and
    $Milestone7ValidatedPolicyCount -eq 5
)

$ValidationPassed = (
    $RootExists -and
    $MissingFiles.Count -eq 0 -and
    $UnexpectedFiles.Count -eq 0 -and
    $EmptyFiles.Count -eq 0 -and
    $InvalidPngFiles.Count -eq 0 -and
    $BrokenLinks.Count -eq 0 -and
    $SensitiveFindings.Count -eq 0 -and
    $NonEngineeringLanguageFindings.Count -eq 0 -and
    $NonEngineeringPathFindings.Count -eq 0 -and
    $PublicTextEncodingFindings.Count -eq 0 -and
    $ValidatedFileCount -eq $ExpectedFiles.Count -and
    $PublishableFileCount -eq $ExpectedFiles.Count -and
    $ExpectedScreenshotCount -eq 59 -and
    $GitIgnoreProtectionPassed -and
    $PolicyCoveragePassed -and
    $Milestone7ExitGatesPassed
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
    InlineMilestone7ScreenshotCount    = $InlineMilestone7ScreenshotCount
    Milestone7HandoverChecklistCount    = $Milestone7HandoverChecklistCount
    Milestone7ControlRegisterRowCount   = $Milestone7ControlRegisterRowCount
    Milestone7ValidatedPolicyCount     = $Milestone7ValidatedPolicyCount
    MissingPolicyCount                 = $MissingPolicyIds.Count
    MissingRequirementCount            = $MissingRequirementIds.Count
    MissingTestScenarioCount           = $MissingTestIds.Count
    MissingMilestone7PolicyNameCount   = $MissingMilestone7PolicyNames.Count
    SensitiveFindingCount              = $SensitiveFindings.Count
    NonEngineeringLanguageFindingCount = $NonEngineeringLanguageFindings.Count
    NonEngineeringPathFindingCount     = $NonEngineeringPathFindings.Count
    PublicTextEncodingFindingCount     = $PublicTextEncodingFindings.Count
    GitIgnoreProtectionPassed          = $GitIgnoreProtectionPassed
    Milestone7ExitGateCount            = $RequiredMilestone7Assertions.Count
    MissingMilestone7ExitGateCount     = $MissingAssertions.Count
    PolicyCoveragePassed               = $PolicyCoveragePassed
    Milestone7ExitGatesPassed          = $Milestone7ExitGatesPassed
    ValidationPassed                   = $ValidationPassed
}

if (-not $ValidationPassed) {
    if ($MissingFiles.Count -gt 0) { Write-Warning "Missing files: $($MissingFiles -join ', ')" }
    if ($UnexpectedFiles.Count -gt 0) { Write-Warning "Unexpected publishable files: $($UnexpectedFiles -join ', ')" }
    if ($EmptyFiles.Count -gt 0) { Write-Warning "Empty files: $($EmptyFiles -join ', ')" }
    if ($InvalidPngFiles.Count -gt 0) { Write-Warning "Invalid PNG files: $($InvalidPngFiles -join ', ')" }
    if ($BrokenLinks.Count -gt 0) { Write-Warning "Broken links: $($BrokenLinks -join ', ')" }
    if ($SensitiveFindings.Count -gt 0) { Write-Warning "Potential sensitive findings: $($SensitiveFindings -join ', ')" }
    if ($NonEngineeringLanguageFindings.Count -gt 0) { Write-Warning "Non-engineering public language findings: $($NonEngineeringLanguageFindings -join ', ')" }
    if ($NonEngineeringPathFindings.Count -gt 0) { Write-Warning "Non-engineering public path findings: $($NonEngineeringPathFindings -join ', ')" }
    if ($PublicTextEncodingFindings.Count -gt 0) { Write-Warning "Public text encoding findings: $($PublicTextEncodingFindings -join ', ')" }
    if ($MissingAssertions.Count -gt 0) { Write-Warning "Missing Milestone 7 exit gates: $($MissingAssertions -join ', ')" }
    if ($MissingMilestone7PolicyNames.Count -gt 0) { Write-Warning "Missing Milestone 7 policy names: $($MissingMilestone7PolicyNames -join ', ')" }

    throw 'FAIL: Conditional Access Milestone 7 package validation failed.'
}

Write-Host ''
Write-Host 'PASS: Conditional Access release validation passed.' -ForegroundColor Green
