# Conditional Access Business Requirements and Control Objectives

## 1. Document control

| Field | Value |
| --- | --- |
| Framework | Microsoft Entra Conditional Access & Zero Trust Policy Framework |
| Milestone | 2 — Business requirements and control objectives |
| Design date | 2026-09-06 |
| Environment | Microsoft Entra lab tenant with hybrid identities from `corporate.test` |
| Change type | Design only; no tenant configuration change |
| Premium state | Microsoft Entra ID P2 not activated |

## 2. Scenario

Northbridge Financial Services Ltd. is a fictional organization used to model a controlled hybrid identity environment. Active Directory Domain Services remains authoritative for the scoped workforce identities, Microsoft Entra Cloud Sync provides password-hash and object synchronization, and Microsoft Entra ID is the cloud policy enforcement point.

The organization needs to replace broad baseline protection with a measurable Conditional Access framework. The design must reduce credential-based compromise without creating an administrator lockout, an authentication-registration dead end, or an unsupported dependency on device compliance.

## 3. Verified identity foundation

The following inventory was read directly from the protected `IAM-Lab` organizational unit after the hybrid identity foundation was established:

| Population | Verified count | Design use |
| --- | ---: | --- |
| Synthetic IAM users | 34 | Complete retained hybrid population |
| Enabled workforce users | 30 | Primary sign-in and policy-test population |
| Disabled users | 4 | Negative-control population; no interactive access expected |
| Employees | 25 | Standard workforce cohort |
| Contractors | 5 | Higher-session-risk cohort |
| IAM security groups | 15 | Verified assignment and entitlement references |
| Direct memberships | 140 | Baseline for population integrity |

The complete verified group inventory is:

| Group | Direct members | Primary function |
| --- | ---: | --- |
| `GG_IAM_Access_Contractor_Portal` | 5 | Contractor application access |
| `GG_IAM_Access_Finance_ERP` | 5 | Finance application access |
| `GG_IAM_Access_HR_Records` | 5 | Human Resources application access |
| `GG_IAM_Access_IT_ServiceDesk` | 5 | IT service-desk access |
| `GG_IAM_Access_M365_Baseline` | 25 | Employee Microsoft 365 baseline access |
| `GG_IAM_Access_Operations_Portal` | 5 | Operations application access |
| `GG_IAM_Access_Sales_CRM` | 5 | Sales application access |
| `GG_IAM_All_Contractors` | 5 | Contractor population |
| `GG_IAM_All_Employees` | 25 | Employee population |
| `GG_IAM_All_Workforce` | 30 | Enabled workforce population |
| `GG_IAM_Department_Finance` | 5 | Finance department |
| `GG_IAM_Department_HumanResources` | 5 | Human Resources department |
| `GG_IAM_Department_InformationTechnology` | 5 | Information Technology department |
| `GG_IAM_Department_Operations` | 5 | Operations department |
| `GG_IAM_Department_Sales` | 5 | Sales department |

These groups retain their application, population, and departmental authorization purposes. Conditional Access does not replace application authorization or Active Directory group governance.

## 4. Stakeholders and accountability

| Role | Accountability in this design |
| --- | --- |
| Executive security owner | Accepts residual risk and approves broad enforcement |
| IAM service owner | Owns policy design, exclusions, naming, lifecycle, and periodic review |
| Conditional Access administrator | Implements approved settings and records configuration evidence |
| Security operations | Monitors sign-ins, risk, emergency-account use, and policy impact |
| IT operations | Owns endpoint-management, application, and user-support dependencies |
| Application owners | Validate that access controls do not break required business workflows |
| Service desk | Supports registration and recovery without bypassing the approved controls |

These are organizational roles, not named individuals. Personal details are excluded from the public evidence.

## 5. Business requirements

| ID | Requirement | Risk addressed | Success criterion | Mapped control |
| --- | --- | --- | --- | --- |
| BR-01 | Prevent legacy clients from bypassing modern authentication controls | Password spray and credential stuffing through protocols without MFA support | Legacy client attempts are identified in report-only analysis and blocked after approval | `CA001` |
| BR-02 | Require MFA for the complete interactive user population and all resources | Password-only account compromise | Every applicable user must satisfy the built-in Multifactor authentication strength | `CA002` |
| BR-03 | Require phishing-resistant authentication for privileged directory roles | Token theft, adversary-in-the-middle phishing, and privileged account takeover | Privileged users can use an approved phishing-resistant method; weaker methods do not satisfy the policy | `CA003` |
| BR-04 | Protect Microsoft administrative portals and Azure management access | Management-plane compromise by users outside directory-admin role scope | Every user reaching either management surface must satisfy MFA | `CA004` |
| BR-05 | Protect registration of authentication and recovery information | Attacker persistence through malicious method registration | Registration requires approved strong authentication or controlled Temporary Access Pass onboarding | `CA005` |
| BR-06 | Respond to medium- and high-risk sign-ins | Suspicious sign-in activity using otherwise valid credentials | Affected users must satisfy MFA and reauthenticate for each risky sign-in | `CA006` |
| BR-07 | Remediate high-risk users | Identity compromise that persists beyond one sign-in | High-risk users complete secure risk remediation only after MFA; hybrid password change is allowed only after password writeback is verified | `CA007` |
| BR-08 | Require managed-device trust for sensitive workforce cohorts | Data access from unmanaged or noncompliant endpoints | In-scope Finance and HR access cohorts can reach the protected resource only from a compliant device | `CA008` |
| BR-09 | Reduce session persistence for contractors | Extended exposure from shared or unmanaged contractor browsers | Contractor browser sessions are not persisted after the browser closes | `CA009` |
| BR-10 | Preserve tenant recovery during identity or policy failure | Total administrative lockout | Two independent cloud-only emergency accounts remain usable, monitored, and tested | Shared exclusion and recovery design |
| BR-11 | Prevent device code flow from becoming a phishing or unmanaged-device access path | OAuth device-code phishing and access from devices without an approved interactive browser | Device code flow is identified in sign-in evidence and blocked except for any narrowly approved, resource-specific business dependency | `CA010` |

## 6. Security and availability constraints

1. Security defaults remains enabled throughout Milestone 2.
2. Microsoft Entra ID P2 is activated only during Milestone 3 after the implementation prerequisites are prepared.
3. Two cloud-only emergency accounts and their dedicated exclusion group must exist before any blocking or grant policy is enforced.
4. Each emergency account must use the tenant's `onmicrosoft.com` domain, remain outside synchronization, hold a permanent-active Global Administrator assignment, and use an approved phishing-resistant credential.
5. Each emergency account must be tested at creation, immediately before an enforcement change, and at least every 90 days; every sign-in and administrative change involving either account must be monitored.
6. Policy templates are treated as design accelerators, not automatically approved configurations. Assignments and exclusions require explicit review.
7. After premium-licence activation, every Microsoft-managed Conditional Access policy must be inventoried with its current state, scheduled enablement, overlap, and explicit adopt, replace, or opt-out decision before custom policy deployment.
8. The first deployment state is **Report-only** unless a documented technical limitation prevents meaningful report-only evaluation.
9. Sign-in risk and user risk remain separate policies.
10. No location is treated as trusted without a stable public egress address, ownership, and a documented business justification.
11. Device compliance is not enforceable until Intune licensing, enrollment, a compliance policy, and an isolated pilot device are verified.
12. Secure password change for synchronized users is not enforceable until Cloud Sync password writeback and recovery behavior are tested.
13. Device code flow is blocked wherever possible. Any exception requires verified sign-in evidence, a named business owner, a resource-specific scope, and a review or retirement date.
14. User-based Conditional Access does not provide workload-identity coverage. Service principals and managed identities require a separate control scope.
15. Disabled identities are not used to generate successful sign-ins for evidence.

## 7. Planned prerequisite objects

The following objects do not exist at the end of Milestone 2. They are approved designs for controlled creation and validation in Milestone 3.

| Planned object | Type | Purpose |
| --- | --- | --- |
| `GG_CA_Exclude_EmergencyAccess` | Cloud-only security group | Single auditable exclusion container for the two emergency accounts |
| `EAA-01` and `EAA-02` | Cloud-only users | Permanent-active Global Administrator recovery paths using phishing-resistant credentials and sanitized public labels |
| `GG_CA_Pilot_Workforce` | Cloud-only security group | Narrow report-only and enforcement pilot using selected enabled workforce identities |
| `GG_CA_Pilot_DeviceCompliance` | Cloud-only security group | Isolated device-control test population; created only if device prerequisites are approved |

The public repository does not record real user principal names, object identifiers, credentials, or recovery locations.

## 8. Control acceptance gates

| Gate | Required evidence | Approval owner |
| --- | --- | --- |
| Design completeness | Every policy has scope, exclusions, dependencies, expected outcomes, monitoring, and rollback criteria | IAM service owner |
| Recovery readiness | Two emergency accounts authenticate successfully through independent recovery paths | Executive security owner and IAM service owner |
| Authentication readiness | Pilot users can satisfy the required MFA or authentication strength | IAM service owner |
| Licensing readiness | P2 and any additional dependency licences are assigned only to required test populations | IAM service owner |
| Managed-policy reconciliation | Every Microsoft-managed Conditional Access policy is recorded with state, scheduled enablement, overlap, and an adopt, replace, or opt-out decision | IAM service owner and security operations |
| Report-only analysis | Expected and unexpected impact is reviewed in sign-in evidence | Security operations |
| Application acceptance | Application owners confirm that required workflows succeed | Application owners |
| Enforcement approval | False positives are resolved and rollback execution is ready | Executive security owner |

## 9. Out of scope

- Production rollout to real users
- Entra ID P2 activation during this milestone
- Intune tenant configuration or personal-device enrollment
- Federation, AD FS, or device synchronization
- Workload-identity Conditional Access
- Application entitlement redesign
- Privileged Identity Management implementation, which is addressed separately
- Location-based bypasses without a verified business network

## 10. Milestone decision

The business requirements are approved for technical implementation planning. The ten-policy design can proceed to Milestone 3 prerequisite validation only after Microsoft-managed policy reconciliation, but no policy is approved for enforcement solely because it appears in the matrix.

## 11. Microsoft Learn references

- [Plan a Conditional Access deployment](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)
- [Conditional Access policy templates](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policy-common)
- [Control authentication flows](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-authentication-flows)
- [Microsoft-managed Conditional Access policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/managed-policies)
- [Require MFA for all users](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-mfa-strength)
- [Manage emergency access accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)
- [Configure risk policies](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)
- [Install Cloud Sync and enable password writeback](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/how-to-install)
