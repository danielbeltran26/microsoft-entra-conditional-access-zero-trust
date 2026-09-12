# Conditional Access Test and Rollback Plan

## 1. Purpose

This runbook defines how the ten Conditional Access designs will be validated before and after enforcement. It separates design approval, prerequisite testing, Report-only analysis, pilot enforcement, broad enforcement, and recovery.

No test in this document authorizes a production change by itself.

## 2. Roles

| Operational role | Responsibility |
| --- | --- |
| Change operator | Implements only the approved policy and state transition |
| Independent validator | Confirms assignments, exclusions, outcomes, and evidence |
| Recovery operator | Holds an independent emergency-access path and can reverse the change |
| Security reviewer | Reviews sign-in, risk, audit, and policy-impact evidence |
| Application owner | Confirms required business access and records exceptions |

One person may perform multiple roles in the controlled lab, but the evidence must still distinguish implementation from validation.

## 3. Mandatory pre-test gates

The change operator must stop if any applicable gate fails:

- The exact policy version and approved matrix entry are identified.
- Microsoft Entra ID P2 is active for the required test identities.
- Security defaults remains enabled until the documented replacement-policy cutover.
- Two cloud-only emergency accounts exist, both can authenticate, and each holds a permanent-active Global Administrator assignment.
- `GG_CA_Exclude_EmergencyAccess` contains exactly those two accounts.
- Both emergency accounts use approved phishing-resistant credentials and have a successful test recorded within the previous 90 days.
- Every Microsoft-managed Conditional Access policy is inventoried with its current state, any scheduled enablement, overlap, and explicit adopt, replace, or opt-out decision.
- The policy exclusions match the approved design.
- `GG_CA_Pilot_Workforce` contains only the intended enabled synthetic identities.
- Pilot users have the authentication methods required by the test.
- The What If tool and sign-in logs are available.
- A separate browser profile or private session is available for the test identity.
- The recovery operator is signed in through an independent administrative path.
- For CA007, synchronized-user password writeback has passed a controlled test.
- For CA008, Intune, device enrollment, compliance evaluation, and an isolated pilot device have passed validation.
- For CA010, device-code-flow and Device Registration Service sign-in usage has been reviewed before any enforcement decision.

## 4. Evidence record

Every executed scenario must record:

| Field | Requirement |
| --- | --- |
| Scenario ID | Stable identifier from the matrix below |
| Timestamp | UTC time of the test |
| Policy | Exact policy name and state |
| Test identity class | Workforce, contractor, privileged, emergency, or disabled; no public UPN |
| Resource | Target resource or user action |
| Signals | Client app, risk level, role, device state, and network context where relevant |
| Expected result | Allow, MFA, stronger authentication, remediation, session control, block, or not applied |
| Observed result | Portal and sign-in evidence |
| Outcome | Pass, fail, blocked by dependency, or not executed |
| Sanitization | Confirmation that no personal identifier, token, session ID, or tenant ID is published |

## 5. Test-scenario matrix

| ID | Policy | Scenario | Expected Conditional Access result | Execution gate |
| --- | --- | --- | --- | --- |
| TS-01 | CA001 | Enabled pilot user attempts a legacy client flow | Policy is reported as applicable and would block; enforcement blocks the flow | Safe legacy-flow method approved |
| TS-02 | CA001 | Same pilot user uses modern authentication | CA001 is not applied; other relevant policies continue evaluating | Modern client available |
| TS-03 | CA002 | Prepared workforce pilot user accesses a resource and satisfies MFA | Access succeeds and CA002 records successful satisfaction | MFA method registered |
| TS-04 | CA002 | Pilot user cannot satisfy an allowed MFA method | Report-only shows expected interruption; pilot enforcement denies access | Recovery and service-desk path ready |
| TS-05 | CA002 | Emergency account is evaluated | Emergency exclusion is recorded; the account is not blocked by CA002 | Both emergency accounts tested first |
| TS-06 | CA003 | Included administrator uses a FIDO2/passkey credential | Phishing-resistant strength is satisfied | Approved credential registered |
| TS-07 | CA003 | Included administrator attempts password plus Authenticator push or OTP | The weaker method does not satisfy CA003 | Emergency administrator session active |
| TS-08 | CA003 | Nonprivileged workforce user accesses a normal resource | CA003 is not applied; CA002 can still apply | Role assignments verified |
| TS-09 | CA004 | User accesses Microsoft Admin Portals or Azure management | MFA is required even when the user is not in a targeted directory role | Resource access exists |
| TS-10 | CA005 | Prepared user registers security information through approved authentication or TAP | Registration proceeds and audit evidence is generated | Combined registration and TAP process ready |
| TS-11 | CA005 | Unprepared user attempts registration without an acceptable bootstrap path | The grant requirement is not satisfied | Recovery/help-desk path ready |
| TS-12 | CA006 | Simulated medium- or high-risk sign-in occurs | Fresh MFA is required and sign-in frequency is Every time | P2 and supported risk simulation available |
| TS-13 | CA006 | Low-risk sign-in occurs | CA006 is not applied; baseline policies still evaluate | P2 active |
| TS-14 | CA007 | High-risk synchronized user has MFA and verified password writeback | Secure risk remediation can complete | P2 and password writeback validated |
| TS-15 | CA007 | High-risk synchronized user lacks a working password-writeback path | Self-remediation is treated as blocked by dependency; policy remains Report-only | Controlled test only |
| TS-16 | CA008 | Sensitive-cohort pilot accesses Office 365 from a compliant isolated device | Device grant control is satisfied | Intune and compliance prerequisites passed |
| TS-17 | CA008 | Same cohort accesses from an unmanaged or noncompliant isolated device | Policy records failure and pilot enforcement blocks access | No personal device used |
| TS-18 | CA009 | Contractor closes and reopens the browser after sign-in | Persistent browser state is not retained | Contractor test identity available |
| TS-19 | Shared | Disabled IAM identity attempts authentication | Authentication fails independently of Conditional Access | Account remains disabled |
| TS-20 | Shared | What If evaluates each emergency account against every planned policy | Exclusion or nonapplicability is confirmed for every restrictive policy | P2 and policies available |
| TS-21 | Cutover | Security defaults is disabled only when replacement policies are ready | No intentional gap exists between baseline and replacement protection | Approved cutover window |
| TS-22 | Recovery | A pilot policy is deliberately returned to Report-only by the recovery operator | Normal administrator access is restored and the event is documented | Emergency path verified |
| TS-23 | CA010 | A controlled test identity attempts device code flow | CA010 is reported as applicable and enforcement blocks the flow | Approved safe test method and sign-in-log access available |
| TS-24 | CA010 | The same identity performs normal interactive browser authentication | CA010 is not applied; other relevant controls continue evaluating | Modern browser available |
| TS-25 | Prerequisite | Microsoft-managed Conditional Access policies are inventoried after premium-licence activation | Every managed policy has a recorded state, scheduled enablement, overlap, and adopt, replace, or opt-out decision | P1-or-higher entitlement active before custom policy creation |
| TS-26 | Recovery | Both emergency identities are inspected and tested | Each identity is cloud-only, permanently assigned Global Administrator, uses phishing-resistant authentication, is excluded as designed, and has a successful test within 90 days | Independent recovery operator available |

## 6. Report-only review procedure

For each created policy:

1. Confirm the policy name, assignment, exclusions, target resources, conditions, controls, and Report-only state against the approved matrix.
2. Use the Conditional Access What If tool for at least one expected applicable case, one nonapplicable case, and the emergency exclusion.
3. Generate only the approved controlled sign-in scenarios.
4. Review user sign-ins and non-interactive sign-ins where relevant.
5. For CA010, filter for authentication protocol Device code flow and inspect original transfer method, protocol tracking, and Device Registration Service usage.
6. Open the Conditional Access details for the event and record whether each policy was successful, failed, interrupted, or not applied.
7. Compare the observed decision with the expected result in the test matrix.
8. Investigate every unexpected application, exclusion, or dependency failure.
9. Do not move the policy to On until the reviewer records an accepted result.

Report-only proves evaluated impact; it does not prove that users were blocked or challenged. Enforcement evidence must be collected separately during the approved pilot.

## 7. Pilot-enforcement procedure

1. Reconfirm both emergency accounts immediately before the change.
2. Confirm the policy is assigned only to the approved pilot population.
3. Record the pre-change state and UTC time.
4. Change only one policy from Report-only to On.
5. Run the positive, negative, and exclusion tests mapped to that policy.
6. Review sign-in and audit evidence before changing another policy.
7. Keep the policy in pilot scope for the approved observation period.
8. Return the policy to Report-only immediately if a rollback criterion is met.
9. After CA002 reaches verified broad enforcement, disable CA004 and confirm management-resource sign-ins remain protected by CA002.

## 8. Rollback triggers

Rollback is mandatory when any of the following occurs:

- Neither normal administrator nor tested recovery access is available.
- An emergency account is unexpectedly affected by a restrictive policy.
- A policy applies outside the approved pilot population.
- Required users cannot satisfy the authentication method or strength.
- A business-critical application fails with no approved workaround.
- Risk remediation cannot complete because password writeback or registration is unavailable.
- Device compliance is missing, stale, or inconsistent for the isolated pilot.
- Sign-in evidence contradicts the approved expected result.
- The implementation differs from the policy matrix.
- Monitoring is unavailable during an enforcement change.
- Device code flow or Device Registration Service behavior differs from the approved CA010 analysis.
- CA004 remains active after CA002 reaches verified broad enforcement without a separately approved stronger control.

## 9. Standard rollback sequence

1. Stop further policy changes and preserve the current browser sessions.
2. Use the independent recovery operator or an emergency account if normal administration is unavailable.
3. Identify the last changed policy from the audit log and change it from On to Report-only. Disable it only when Report-only does not restore the required access path.
4. Confirm that normal administration and the affected application are available.
5. If security defaults was disabled during cutover and replacement coverage is no longer adequate, restore security defaults after confirming that doing so will not conflict with the active Conditional Access state.
6. Export or record sanitized sign-in, audit, and policy evidence.
7. Document the trigger, impact, operator, action, recovery time, and required design correction.
8. Do not re-enable enforcement until the failed prerequisite or design defect is corrected and retested.

## 10. Policy-specific rollback map

| Policy | Primary rollback action | Control that should remain |
| --- | --- | --- |
| CA001 | Return legacy-authentication block to Report-only and create only a time-bound, owner-approved exception | CA002 universal MFA |
| CA002 | Return universal MFA to Report-only; restore security defaults if this was the replacement cutover | CA001 and CA010 where safe, CA004 transitional management MFA, and emergency monitoring |
| CA003 | Return phishing-resistant requirement to Report-only | CA002 universal MFA and CA004 management MFA |
| CA004 | Before CA002 broad enforcement, return to Report-only and correct identity classification; after CA002 broad enforcement, keep CA004 disabled unless a distinct stronger control is approved | CA002 and CA003 |
| CA005 | Return registration protection to Report-only and repair TAP onboarding | CA002 for normal access |
| CA006 | Return sign-in-risk policy to Report-only and investigate false positives | CA002 universal MFA |
| CA007 | Keep in Report-only and perform controlled administrator remediation | CA006 sign-in-risk policy |
| CA008 | Return to Report-only or disable; repair Intune/compliance state | CA002 universal MFA |
| CA009 | Return session policy to Report-only while reviewing contractor workflow | CA002 universal MFA |
| CA010 | Return device-code-flow block to Report-only; create only an approved resource-specific exception after dependency evidence is reviewed | CA001 and CA002 where safe |

## 11. Security-defaults cutover

Security defaults is disabled only once, at the approved transition point where the replacement policies are ready for controlled enforcement. The cutover record must prove:

- Emergency access was tested immediately beforehand.
- CA001, CA002, CA010, and the required transitional management protection are correctly configured.
- Microsoft-managed policy overlaps and any scheduled enablement have documented treatment decisions.
- The pilot population can satisfy MFA.
- The recovery operator can restore security defaults if replacement coverage is withdrawn.
- No policy is simultaneously broadened beyond its approved scope during the same change.

## 12. Closeout criteria

A policy test is closed only when the expected and observed decisions match, the exclusion path is verified, no unexplained users or resources are affected, evidence is sanitized, and rollback readiness remains intact. Milestone 2 design assurance is not closed until CA004's retirement trigger, CA010 coverage, Microsoft-managed policy reconciliation, and 90-day emergency-account test cadence are recorded.

### Milestone 6 execution record

On 8 September 2026, CA001, CA004, CA005, CA009, and CA010 moved from Report-only to On sequentially in their approved controlled scopes. Mapped sign-in and What If checks matched the expected results, five successful update events were present in the audit log, and both emergency identities retained administrator access after enforcement.

No rollback trigger occurred, so TS-22 was not invoked against a correctly functioning policy. The independent recovery session and the standard rollback sequence remained available throughout the window.

The lab used a documented observation period shorter than Microsoft's recommended minimum of one week in Report-only. That decision was limited to the isolated synthetic tenant and must not be treated as a production change template.

The recovery review found four permanent-active Global Administrator assignments. Remediation of the two non-emergency standing assignments is deferred to the planned Privileged Identity Management project so that privileged-role redesign is not combined with the Conditional Access enforcement window.

### Milestone 7 final assurance record

On 9 September 2026, both emergency identities passed fresh Microsoft Entra admin-center access tests. The final inventory contained five user-created policies On and no Microsoft-managed policies. Seven-day monitoring found one Conditional Access failure, matching the expected CA010 device-code block, and no unexpected failure.

The audit review contained the documented successful security-default transition, five successful policy creations, and five successful enforcement updates. No failed or unexplained policy change was present, and the deleted-policy inventory was empty.

The P2 Trial was Active with 7 of 100 licences assigned, recurring billing Off, and expiration on 6 October 2026. The licence expiry, four permanent-active Global Administrator assignments, absence of project-specific Log Analytics reporting, shortened lab observation window, and five design-only policies remain explicit operational dependencies or accepted findings.

No rollback trigger occurred. The final handover therefore preserves the tested policies in their controlled scopes and transfers monitoring, change, recovery, rollback, privacy, and licensing responsibilities to the [operations handover runbook](Conditional-Access-Operations-Handover-Runbook.md).

## 13. Microsoft Learn references

- [Use report-only mode](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-report-only)
- [Conditional Access What If](https://learn.microsoft.com/en-us/entra/identity/conditional-access/what-if-tool)
- [Manage emergency access accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)
- [Configure risk policies](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)
- [Control authentication flows](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-authentication-flows)
- [Microsoft-managed Conditional Access policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/managed-policies)
- [Conditional Access insights and reporting](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-insights-reporting)
- [Microsoft Entra authentication error codes](https://learn.microsoft.com/en-us/entra/identity-platform/reference-error-codes)
- [Microsoft Graph policy soft-delete resource](https://learn.microsoft.com/en-us/graph/api/resources/policydeletableitem?view=graph-rest-beta)
