# Conditional Access Policy Matrix

## 1. Purpose

This matrix translates the approved business requirements into ten implementation-ready Microsoft Entra Conditional Access designs. It records the intended lifecycle state and the prerequisites that must be satisfied before configuration or enforcement.

No policy described here exists in the tenant at the end of Milestone 2.

## 2. Naming standard

Policy names follow this pattern:

`CA###-<ACTION>-<CONTROL>-<SCOPE>`

| Element | Meaning |
| --- | --- |
| `CA###` | Stable sequential control identifier |
| `ACTION` | Primary result: `BLOCK`, `GRANT`, or `SESSION` |
| `CONTROL` | Security requirement such as MFA, risk remediation, or device compliance |
| `SCOPE` | Population or resource boundary |

Names remain stable across Report-only and On states. State, owner, review date, and change record are metadata rather than part of the name.

## 3. Shared assignment and exclusion rules

- **All users** is preferred for tenant-wide baseline controls to prevent coverage gaps created by group drift.
- The planned `GG_CA_Exclude_EmergencyAccess` group is excluded from every policy that could block or restrict emergency sign-in.
- The Directory Synchronization Accounts role is excluded from tenant-wide interactive-user policies when a real account assignment is confirmed. Service principals are not user identities and require workload-identity controls outside this project.
- Guest and external-user handling is recorded explicitly. No guest population was validated in Milestone 1, so guest-specific enforcement is deferred rather than assumed.
- Pilot groups narrow early testing; they do not replace the approved final assignment.
- No resource is excluded from the universal MFA baseline merely to make testing easier.
- Microsoft-managed Conditional Access policies are inventoried after premium-licence activation. Every overlap receives an explicit adopt, replace, or opt-out decision before a custom equivalent is deployed.

Licensing is evaluated per assigned population. Microsoft Entra ID P1 supports standard Conditional Access controls; P2 is required when Identity Protection user-risk or sign-in-risk signals are used. A P2 entitlement includes the required P1 capability, but the assigned users still require appropriate licence coverage.

## 4. Policy summary

| ID | Policy name | Primary purpose | Approved scope | Dependency status | Planned first state |
| --- | --- | --- | --- | --- | --- |
| CA001 | `CA001-BLOCK-LegacyAuthentication-AllUsers` | Block clients that cannot perform modern authentication | All users; all resources | Entra ID P1-or-higher entitlement for the assigned population | Report-only |
| CA002 | `CA002-GRANT-MFA-AllUsers-AllResources` | Establish universal MFA baseline | All users; all resources | Entra ID P1-or-higher entitlement, MFA registration readiness, and emergency access | Report-only |
| CA003 | `CA003-GRANT-PhishingResistantMFA-AdminRoles` | Protect privileged directory roles with stronger authentication | Selected built-in admin roles; all resources | Entra ID P1-or-higher entitlement and an approved phishing-resistant method for each targeted privileged user | Report-only |
| CA004 | `CA004-GRANT-MFA-ManagementSurfaces-AllUsers` | Provide transitional protection for Microsoft admin portals and Azure management | All users; two management resources until CA002 broad enforcement is verified | Entra ID P1-or-higher entitlement, MFA readiness, and a documented retirement trigger | Report-only |
| CA005 | `CA005-GRANT-MFA-SecurityInfoRegistration-AllUsers` | Protect authentication-method registration | All users; Register security information user action | Entra ID P1-or-higher entitlement, combined registration, and a controlled TAP process | Report-only |
| CA006 | `CA006-GRANT-MFA-MediumHighSignInRisk-AllUsers` | Remediate risky sign-ins | All users; all resources; medium/high sign-in risk | Entra ID P2 and usable MFA methods | Report-only |
| CA007 | `CA007-GRANT-RiskRemediation-HighUserRisk-AllUsers` | Remediate high-risk users | All users; all resources; high user risk | Entra ID P2, MFA registration, and tested password writeback for synchronized users | Report-only only until dependencies pass |
| CA008 | `CA008-GRANT-CompliantDevice-SensitiveWorkforce` | Protect sensitive workforce access from unmanaged devices | Finance and HR access cohorts; Office 365 | Entra ID P1-or-higher entitlement, Intune, compliance policy, enrollment, and an isolated pilot device are required; device prerequisites are absent | Design-only; do not create yet |
| CA009 | `CA009-SESSION-NoPersistentBrowser-Contractors` | Reduce contractor browser-session persistence | `GG_IAM_All_Contractors`; all resources | Entra ID P1-or-higher entitlement for every targeted contractor, a browser test account, and sign-in evidence | Report-only |
| CA010 | `CA010-BLOCK-DeviceCodeFlow-AllUsers` | Block high-risk device code authentication | All users; all resources, with a resource exception only for a verified dependency | Entra ID P1-or-higher entitlement, device-code-flow sign-in review, and Device Registration Service impact review | Report-only |

## 5. Detailed policy definitions

### CA001 — Block legacy authentication

| Field | Approved design |
| --- | --- |
| Name | `CA001-BLOCK-LegacyAuthentication-AllUsers` |
| Requirement | BR-01 |
| Include | Final: All users. Pilot: `GG_CA_Pilot_Workforce` for impact validation where applicable |
| Exclude | `GG_CA_Exclude_EmergencyAccess`; confirmed Directory Synchronization Accounts; any temporary legacy dependency requires written owner and retirement date |
| Target resources | All resources |
| Conditions | Client apps: Exchange ActiveSync clients and Other clients |
| Grant | Block access |
| Session | None |
| Expected result | Legacy authentication attempts are reported as affected in Report-only and blocked after enforcement; modern authentication remains available |
| Monitoring | Sign-in logs filtered for legacy client apps, including non-interactive sign-ins; policy result and affected identity reviewed |
| Rollback trigger | A validated business-critical dependency has no modern-authentication path and the approved exception was omitted |
| Rollback action | Return the policy to Report-only or exclude only the approved dependency while recording an expiry date |

### CA002 — Require MFA for all users and all resources

| Field | Approved design |
| --- | --- |
| Name | `CA002-GRANT-MFA-AllUsers-AllResources` |
| Requirement | BR-02 |
| Include | Final: All users. Pilot: `GG_CA_Pilot_Workforce` |
| Exclude | `GG_CA_Exclude_EmergencyAccess`; confirmed Directory Synchronization Accounts; guests only if an approved guest-specific policy provides equivalent coverage |
| Target resources | All resources, with no application exclusions |
| Conditions | None; the baseline should not depend on location or device state |
| Grant | Grant access and require the built-in Multifactor authentication strength |
| Session | Default token/session behavior |
| Expected result | Applicable users must satisfy an allowed MFA method before accessing any resource |
| Monitoring | Policy impact, sign-in result, authentication requirement, authentication details, and service-desk registration failures |
| Rollback trigger | Widespread inability to satisfy MFA, emergency exclusion failure, or unanticipated service-account impact |
| Rollback action | Disable the policy using an emergency account, restore security defaults if the cutover occurred, and correct the readiness gap |

### CA003 — Require phishing-resistant MFA for administrators

| Field | Approved design |
| --- | --- |
| Name | `CA003-GRANT-PhishingResistantMFA-AdminRoles` |
| Requirement | BR-03 |
| Include | Global Administrator, Application Administrator, Authentication Administrator, Billing Administrator, Cloud Application Administrator, Conditional Access Administrator, Exchange Administrator, Helpdesk Administrator, Password Administrator, Privileged Authentication Administrator, Privileged Role Administrator, Security Administrator, SharePoint Administrator, and User Administrator |
| Exclude | `GG_CA_Exclude_EmergencyAccess` |
| Target resources | All resources |
| Conditions | None |
| Grant | Grant access and require the built-in Phishing-resistant MFA strength |
| Session | Default token/session behavior |
| Expected result | An included administrator using an approved phishing-resistant credential succeeds; password plus Authenticator push or OTP does not satisfy this policy |
| Monitoring | Privileged sign-ins, authentication-strength result, registration readiness, exclusions, and policy modifications |
| Rollback trigger | Every non-emergency administrator loses access because required credentials were not registered or supported |
| Rollback action | Use an emergency account to return the policy to Report-only while preserving the universal MFA baseline |

### CA004 — Require MFA for management surfaces

| Field | Approved design |
| --- | --- |
| Name | `CA004-GRANT-MFA-ManagementSurfaces-AllUsers` |
| Requirement | BR-04 |
| Include | All users; pilot with `GG_CA_Pilot_Workforce` |
| Exclude | `GG_CA_Exclude_EmergencyAccess`; confirmed Directory Synchronization Accounts |
| Target resources | Microsoft Admin Portals and Windows Azure Service Management API |
| Conditions | None |
| Grant | Grant access and require the built-in Multifactor authentication strength |
| Session | Default token/session behavior |
| Expected result | Directory administrators and Azure RBAC users must satisfy MFA when accessing either management surface |
| Monitoring | Sign-in logs for both target resources, policy result, role context, and unexpected non-administrator access |
| Rollback trigger | Required management automation is incorrectly represented as an interactive user and is disrupted |
| Rollback action | Move to Report-only and correct the identity model; do not add broad resource exclusions |
| Lifecycle decision | Transitional control. Enforce before CA002 reaches broad scope, then disable after CA002 broad enforcement and management-resource coverage are verified |

### CA005 — Protect security-information registration

| Field | Approved design |
| --- | --- |
| Name | `CA005-GRANT-MFA-SecurityInfoRegistration-AllUsers` |
| Requirement | BR-05 |
| Include | All users; pilot with `GG_CA_Pilot_Workforce` |
| Exclude | `GG_CA_Exclude_EmergencyAccess`; guest and external users until a supported guest-registration path is designed |
| Target resources | User action: Register security information |
| Conditions | Any network or location; no trusted-location exclusion because no stable trusted network was validated |
| Grant | Grant access and require the built-in Multifactor authentication strength; Temporary Access Pass supports controlled bootstrap |
| Session | Not applicable |
| Expected result | A prepared user can register through strong authentication or approved TAP onboarding; an unprepared user cannot establish a malicious recovery method |
| Monitoring | Registration and audit events, TAP issuance, failed registration, and method changes |
| Rollback trigger | Legitimate pilot onboarding cannot complete through the documented TAP path |
| Rollback action | Return to Report-only and correct the registration workflow before expanding scope |

### CA006 — Require MFA for medium- and high-risk sign-ins

| Field | Approved design |
| --- | --- |
| Name | `CA006-GRANT-MFA-MediumHighSignInRisk-AllUsers` |
| Requirement | BR-06 |
| Include | All users; pilot with `GG_CA_Pilot_Workforce` |
| Exclude | `GG_CA_Exclude_EmergencyAccess`; confirmed Directory Synchronization Accounts |
| Target resources | All resources |
| Conditions | Sign-in risk: Medium and High |
| Grant | Grant access and require the built-in Multifactor authentication strength |
| Session | Sign-in frequency: Every time |
| Expected result | A medium- or high-risk sign-in requires fresh MFA; low-risk sign-ins do not trigger this policy |
| Monitoring | Identity Protection risk event, sign-in risk, authentication result, remediation state, and false-positive disposition |
| Rollback trigger | Sustained false positives block approved business access or the pilot cannot satisfy MFA |
| Rollback action | Return to Report-only and investigate the detections; do not merge sign-in risk with user risk |

### CA007 — Require remediation for high-risk users

| Field | Approved design |
| --- | --- |
| Name | `CA007-GRANT-RiskRemediation-HighUserRisk-AllUsers` |
| Requirement | BR-07 |
| Include | All users; pilot with `GG_CA_Pilot_Workforce` only after dependencies pass |
| Exclude | `GG_CA_Exclude_EmergencyAccess`; confirmed Directory Synchronization Accounts |
| Target resources | All resources |
| Conditions | User risk: High |
| Grant | Require risk remediation; the appropriate authentication strength is part of the remediation control |
| Session | Sign-in frequency: Every time, applied by the remediation control |
| Expected result | A registered high-risk user completes secure remediation; a synchronized user without password writeback cannot self-remediate and requires administrator intervention |
| Monitoring | Risky users, remediation status, secure password change, password-writeback events, and help-desk intervention |
| Rollback trigger | Password writeback or MFA registration is unavailable for an in-scope synchronized user |
| Rollback action | Keep the policy in Report-only, revoke sessions as appropriate, investigate, and use controlled administrator remediation |

### CA008 — Require compliant device for sensitive workforce access

| Field | Approved design |
| --- | --- |
| Name | `CA008-GRANT-CompliantDevice-SensitiveWorkforce` |
| Requirement | BR-08 |
| Include | `GG_IAM_Access_Finance_ERP` and `GG_IAM_Access_HR_Records`; pilot through `GG_CA_Pilot_DeviceCompliance` |
| Exclude | `GG_CA_Exclude_EmergencyAccess` |
| Target resources | Office 365 for the controlled design; application-specific targets require verified enterprise applications |
| Conditions | All device platforms initially; platform exclusions require evidence |
| Grant | Grant access and require device to be marked as compliant |
| Session | Default token/session behavior |
| Expected result | A compliant isolated pilot device succeeds; an unmanaged or noncompliant device is reported as failing the required grant control |
| Monitoring | Device ID, compliance state, operating system, policy result, enrollment state, and application impact |
| Rollback trigger | Compliance reporting is stale, no recovery device exists, or the policy affects users outside the approved cohorts |
| Rollback action | Return to Report-only or disable the policy; fix Intune compliance and enrollment before retesting |
| Deployment decision | **Deferred. Do not create in Milestone 4 unless Intune, a compliance policy, and an isolated managed pilot device are verified.** |

### CA009 — Prevent persistent browser sessions for contractors

| Field | Approved design |
| --- | --- |
| Name | `CA009-SESSION-NoPersistentBrowser-Contractors` |
| Requirement | BR-09 |
| Include | `GG_IAM_All_Contractors` |
| Exclude | `GG_CA_Exclude_EmergencyAccess` |
| Target resources | All resources |
| Conditions | Browser client apps |
| Grant | No additional grant control; CA002 provides the MFA baseline |
| Session | Persistent browser session: Never persistent |
| Expected result | Contractor sessions do not retain the persistent browser state after the browser closes |
| Monitoring | Contractor browser sign-ins, applied session control, repeat authentication behavior, and user-impact reports |
| Rollback trigger | Required contractor workflow depends on persistence and has documented owner approval |
| Rollback action | Return to Report-only while the session requirement and application behavior are reviewed |

### CA010 — Block device code flow

| Field | Approved design |
| --- | --- |
| Name | `CA010-BLOCK-DeviceCodeFlow-AllUsers` |
| Requirement | BR-11 |
| Include | Final: All users. Pilot: `GG_CA_Pilot_Workforce` for controlled validation |
| Exclude | `GG_CA_Exclude_EmergencyAccess`; confirmed Directory Synchronization Accounts |
| Target resources | All resources. Exclude Device Registration Service only if sign-in evidence proves a required device-registration dependency and the exception is approved, monitored, and time-bound |
| Conditions | Authentication flows: Device code flow |
| Grant | Block access |
| Session | None |
| Expected result | Device code flow attempts are reported as affected in Report-only and blocked after enforcement; normal interactive browser authentication is unaffected |
| Monitoring | Sign-in logs filtered for authentication protocol Device code flow; original transfer method, protocol-tracking state, target resource, identity, and result reviewed |
| Rollback trigger | A verified business-critical device flow or Device Registration Service workflow is disrupted and was not represented in the approved exception design |
| Rollback action | Return the policy to Report-only and create only a resource-specific, owner-approved, monitored exception with a review or retirement date |

## 6. Overlap and precedence

Multiple policies can apply to one sign-in. Their requirements are cumulative:

- Before CA002 reaches broad enforcement, a privileged administrator can receive CA002 pilot MFA, CA003 phishing-resistant MFA, and CA004 transitional management-surface protection. The strongest applicable authentication requirement must be satisfied.
- After CA002 reaches verified broad enforcement, CA004 is disabled because its MFA requirement and management-resource population are fully covered by CA002.
- A contractor can receive CA002 universal MFA and CA009 nonpersistent browser behavior.
- A Finance or HR user can receive CA002 universal MFA and, only when approved, CA008 compliant-device enforcement.
- A medium- or high-risk sign-in can receive CA002 and CA006; CA006 additionally requires reauthentication every time.
- High user risk and sign-in risk are evaluated through separate CA007 and CA006 policies to preserve distinct remediation logic.
- CA010 evaluates authentication flow independently of CA001 client-app conditions; device code flow is modern OAuth and is not treated as legacy authentication.

Overlap is intentional only where it supplies a distinct control or broader coverage. It must be reviewed through What If and sign-in evidence before enforcement.

## 7. Deployment waves

| Wave | Policies | Entry gate | Exit gate |
| --- | --- | --- | --- |
| 0 | No policy creation | Milestone 2 design approved | Emergency access and pilot prerequisites ready |
| 1 | CA001, CA004, CA005, CA009, CA010 | P1-or-higher entitlement confirmed for assigned identities; Microsoft-managed policy decisions recorded; emergency exclusions and pilot group verified | Report-only results match the test matrix |
| 2 | CA002 | Universal-MFA readiness verified | Broad CA002 coverage is accepted and CA004 retirement is approved |
| 3 | CA003 | Privileged authentication readiness verified | Strong and weak method tests behave as designed |
| 4 | CA006, CA007 | Identity Protection available; risk and remediation dependencies validated | Risk simulations and investigation evidence accepted |
| 5 | CA008 | Intune and isolated device pilot fully operational | Compliant and noncompliant device tests accepted |

CA008 can remain deferred without blocking approval of the other controls. CA007 remains Report-only if password writeback is not ready. CA004 is not a permanent duplicate of CA002: its retirement is required after CA002 reaches verified broad enforcement.

## 8. Final implementation and assurance status

The matrix remains the approved implementation plan. Milestone 6 supplied controlled-enforcement proof and Milestone 7 completed operational handover and final assurance for the Wave 1 subset only.

| Policy set | Current implementation status |
| --- | --- |
| CA001, CA004, CA005, CA009, CA010 | On in their approved controlled pilot or contractor scopes; mapped tests and Milestone 7 final assurance passed |
| CA002, CA003, CA006, CA007, CA008 | Design-only; no deployment or enforcement claim |

This is not organization-wide production approval. Tenant state, licences, target resources, pilot membership, emergency access, authentication readiness, application impact, and rollback readiness must be revalidated before any scope expansion or later-wave deployment.

## 9. Operational handover decision

The enforced subset transfers to the operating model in the [Conditional Access Operations Handover Runbook](../runbooks/Conditional-Access-Operations-Handover-Runbook.md) and [Operational Control Register](../data/m07-operational-control-register.csv).

Final assurance confirmed five policies On, both emergency identities accessible, zero unexpected Conditional Access failures, zero failed or unexplained Conditional Access changes, zero deleted policies, and an Active P2 trial. Recurring billing is Off and the trial expires on 6 October 2026, so licensing is a time-bound operational dependency.

Four permanent-active Global Administrator assignments remain a documented least-privilege finding. The two routine standing assignments are deferred to the planned PIM implementation; the two emergency assignments remain permanent recovery paths.

## 10. Microsoft Learn references

- [Conditional Access policy templates](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policy-common)
- [Block legacy authentication](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-block-legacy-authentication)
- [Require MFA for all users](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-mfa-strength)
- [Require phishing-resistant MFA for administrators](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-admin-phish-resistant-mfa)
- [Protect security-information registration](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-security-info-registration)
- [Require MFA for Azure management](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-old-require-mfa-azure-mgmt)
- [Configure risk policies](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)
- [Install Cloud Sync and enable password writeback](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/how-to-install)
- [Require device compliance](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-device-compliance)
- [Require reauthentication](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-persistent-browser)
- [Control authentication flows](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-authentication-flows)
- [Microsoft-managed Conditional Access policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/managed-policies)
