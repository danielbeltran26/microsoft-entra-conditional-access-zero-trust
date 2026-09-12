# Conditional Access Baseline and Recovery Readiness

## 1. Document control

| Field | Value |
| --- | --- |
| Framework | Microsoft Entra Conditional Access & Zero Trust Policy Framework |
| Milestone | 1 — Current-state baseline and recovery readiness |
| Assessment date | 2026-09-06 |
| Environment | Microsoft Entra lab tenant with hybrid users and groups from `corporate.test` |
| Change type | Read-only discovery; no Conditional Access policy changes |
| Premium state | Microsoft Entra ID P2 not activated |

## 2. Purpose

This document records the tenant state that exists before Conditional Access design or deployment. It separates observed evidence from assumptions, identifies licensing and recovery dependencies, and defines the safety gates that must be satisfied before security defaults can be replaced.

The assessment supports the Zero Trust principles of explicit verification, least privilege, and assumed breach. It does not treat possession of portal access as proof that a control is deployable or effective.

## 3. Scope and method

The following Microsoft Entra areas were reviewed in the portal:

- Tenant subscriptions and Premium feature availability
- Security defaults
- Authentication method policies
- Authentication strengths
- Conditional Access policy blade
- Named locations
- Global Administrator role membership
- Authentication registration reporting
- Microsoft Entra device inventory

Only sanitized screenshots suitable for the public repository are included. Captures containing personal display names, user principal names, or session identifiers were used for assessment but deliberately omitted from the package.

## 4. Current-state findings

### 4.1 Licensing and Conditional Access availability

No account SKUs were shown in the tenant. The Conditional Access blade displayed an insufficient-licensing notice, and the controls for creating a policy and opening What If were unavailable.

**Interpretation:** Microsoft Entra ID P2 is not currently active. Risk-based Conditional Access and Premium registration reporting cannot yet be validated. Because the policy list is licence-gated, the assessment does **not** claim that the tenant contains zero Conditional Access policies; that inventory must be repeated after P2 activation.

**Decision:** Preserve the P2 evaluation period until the design, emergency-access prerequisites, pilot scope, and test scenarios are ready.

Evidence: [M01-04](../screenshots/m01-04-conditional-access-licence-gated-baseline.png)

### 4.2 Security defaults

Security defaults is enabled and currently supplies baseline identity protection.

**Interpretation:** It must not be disabled during the design-only phase. Microsoft documents that security defaults and Conditional Access are separate approaches; the cutover must be controlled so the tenant is never intentionally left without the planned replacement protections.

**Safety gate:** Disable security defaults only during the licensed implementation milestone, after emergency access has been tested and the replacement policies are ready in their documented deployment states.

Evidence: [M01-01](../screenshots/m01-01-security-defaults-enabled-baseline.png)

### 4.3 Authentication method policy

| Method | Observed state | Current target |
| --- | --- | --- |
| Passkey (FIDO2) | Enabled | All users |
| Microsoft Authenticator | Enabled | All users |
| SMS | Disabled | Not applicable |
| Temporary Access Pass | Enabled | All users |
| Hardware OATH tokens (Preview) | Disabled | Not applicable |
| Software OATH tokens | Enabled | All users |
| Voice call | Disabled | Not applicable |
| Email OTP | Enabled | All users |
| Certificate-based authentication | Disabled | Not applicable |
| Verified ID | Disabled | Not applicable |
| QR code | Disabled | Not applicable |

**Interpretation:** Authentication methods define what users may register and use; Conditional Access authentication strengths restrict which combinations satisfy a specific access decision. Those two layers must be designed together. Email OTP is primarily relevant to external collaboration and is not treated as a workforce MFA method in this design.

**Follow-up:** Review registration and actual method readiness after P2 activation, then narrow method scopes if the business design requires it.

Evidence: [M01-02](../screenshots/m01-02-authentication-methods-policy-baseline.png)

### 4.4 Authentication strengths

The portal displayed the three built-in strengths:

- Multifactor authentication
- Passwordless MFA
- Phishing-resistant MFA

No custom authentication strength was present, and the page reported that none of the built-in strengths was configured in a Conditional Access policy.

**Design direction:** Prefer the Microsoft-managed phishing-resistant MFA strength for privileged access. A custom strength should be introduced only if an explicit business or technical requirement cannot be met by the built-in controls.

Evidence: [M01-03](../screenshots/m01-03-authentication-strengths-baseline.png)

### 4.5 Named locations

Zero named locations were found.

**Interpretation:** This is not a gap by itself. Location is a signal, not proof of user trust. A named or trusted location will be introduced only if there is a stable public egress address and a documented business need. Location-based exceptions must not replace strong authentication for administrators.

Evidence: [M01-05](../screenshots/m01-05-named-locations-baseline.png)

### 4.6 Privileged access and emergency recovery

Two Global Administrator assignments were observed. No dedicated cloud-only emergency-access accounts were present.

**Risk:** Broad Conditional Access enforcement without tested emergency access could lock out every administrator.

**Required design before enforcement:**

1. Create two cloud-only emergency-access accounts using the tenant's `onmicrosoft.com` domain.
2. Use long, unique credentials stored through separate controlled recovery processes.
3. Avoid dependencies that can fail together with the normal authentication path.
4. Assign only the privilege needed for tenant recovery, following current Microsoft guidance.
5. Exclude the emergency accounts from Conditional Access policies only where necessary to preserve recovery.
6. Alert on every sign-in and every account or role change involving those identities.
7. Test access at creation and on a documented recurring schedule.
8. Never use the emergency accounts for routine administration.

The role-assignment screenshot is intentionally excluded because it displays personal identity data.

### 4.7 Authentication registration reporting

The User registration details page returned HTTP 401 and stated that a Microsoft Entra ID Premium license is required.

**Interpretation:** Registration readiness cannot be assessed conclusively in this milestone. The report must be repeated after P2 activation, before policies depend on MFA or phishing-resistant credentials for the full target population.

The error screenshot is intentionally excluded because it includes a session identifier.

### 4.8 Devices and compliance

Zero devices were found in Microsoft Entra ID. The synchronization architecture uses Microsoft Entra Cloud Sync for users and groups; it does not provide hybrid device registration. No evidence of an Intune compliance authority or compliant device population was found in this assessment.

**Design consequence:** A broad require-compliant-device policy would currently block its target population. Device compliance must therefore remain a design scenario until licensing, management authority, enrollment, compliance policy, pilot device, and recovery behavior are deliberately established.

**Device-testing boundary:** No unmanaged endpoint will be enrolled solely for demonstration. If device-control testing is approved later, use an isolated lab device or virtual machine, a defined compliance policy, and a narrow pilot assignment.

Evidence: [M01-06](../screenshots/m01-06-device-inventory-baseline.png)

## 5. Recovery-readiness gates

The following gates must all be satisfied before broad Conditional Access enforcement:

| Gate | Required evidence | Current state |
| --- | --- | --- |
| Licensing | Required Entra licence active for every in-scope user | Not ready; activation intentionally deferred |
| Emergency identities | Two cloud-only emergency accounts created and tested | Not ready |
| Monitoring | Alerts for emergency-account sign-ins and changes | Not ready |
| Pilot scope | Dedicated test users/groups with expected authentication readiness | Not ready |
| Policy design | Approved matrix with target resources, conditions, grant controls, exclusions, dependencies, and owner | Planned for Milestone 2 |
| Simulation | What If results recorded for expected allow, challenge, block, and exclusion cases | Licence-gated |
| Report-only review | Sign-in evidence reviewed and false positives resolved | Licence-gated |
| Rollback | Named operator, access path, disable sequence, and success criteria documented | Planned |
| Security-defaults cutover | Replacement coverage confirmed at the exact transition point | Not ready |

## 6. Initial risk register

| ID | Risk | Likelihood | Impact | Treatment |
| --- | --- | --- | --- | --- |
| R-01 | Administrator lockout during broad policy deployment | Medium | Critical | Two tested emergency accounts, staged deployment, explicit exclusions, rollback procedure |
| R-02 | Gap in MFA protection when security defaults is disabled | Medium | High | Prepare replacement policies first and execute a documented cutover |
| R-03 | Users cannot satisfy required authentication strength | High until measured | High | Registration-readiness review, pilot testing, Temporary Access Pass onboarding where appropriate |
| R-04 | Compliant-device policy blocks all users because no managed devices exist | High | High | Keep out of enforcement until Intune/device prerequisites and an isolated pilot exist |
| R-05 | Risk policy cannot be validated after evaluation expiry | Medium | Medium | Complete licensed configuration, tests, screenshots, and sanitized exports within the planned window |
| R-06 | Location-based trust creates an avoidable bypass | Low | High | Use location only as a contextual signal; do not weaken privileged authentication |
| R-07 | Sensitive tenant or personal information enters the repository | Medium | Medium | Sanitize captures, exclude identity/session evidence, run package validation before commit |

## 7. Change record for this milestone

No tenant configuration was changed. Specifically:

- Entra ID P2 was not activated.
- Security defaults remained enabled.
- No authentication method was enabled, disabled, or retargeted.
- No custom authentication strength was created.
- No Conditional Access policy was created, changed, or deleted.
- No named location was created.
- No role assignment or user account was changed.
- No device was registered or enrolled.

## 8. Evidence handling

The six included images use descriptive, ordered filenames and contain no visible personal UPN, session ID, secret, or billing information. The source captures showing privileged assignments and the Premium-report error are excluded. Their relevant control observations are recorded above without reproducing sensitive values.

## 9. Next milestone

Milestone 2 will produce the business requirements and complete Conditional Access policy matrix. For every policy it will define:

- Business owner and security objective
- Included users, groups, roles, and target resources
- Explicit exclusions and emergency-access treatment
- Conditions and signals
- Grant and session controls
- Authentication requirement or strength
- Licensing and technical dependencies
- Report-only suitability and deployment wave
- Positive, negative, and recovery test scenarios
- Expected results, monitoring query, rollback trigger, and evidence requirement

P2 activation remains deferred until that design is ready for implementation.

## 10. Microsoft Learn references

- [Conditional Access overview](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)
- [Plan a Conditional Access deployment](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)
- [Security defaults](https://learn.microsoft.com/en-us/entra/fundamentals/security-defaults)
- [Microsoft Entra authentication overview](https://learn.microsoft.com/en-us/entra/identity/authentication/overview-authentication)
- [Authentication strengths](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)
- [Network assignment and named locations](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-assignment-network)
- [Manage emergency access accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)
- [Require device compliance with Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-device-compliance)
- [Microsoft Entra licensing](https://learn.microsoft.com/en-us/entra/fundamentals/licensing)
