# Conditional Access Implementation Lessons Learned

## 1. Purpose

This document records the practical lessons from designing, deploying, testing, enforcing, and handing over the Microsoft Entra Conditional Access framework. It separates observed results from assumptions and identifies what should be retained or improved in a production implementation.

The conclusions apply to the isolated synthetic lab and its controlled workforce, contractor, and emergency-access populations. They are not a claim of organization-wide production readiness.

## 2. Executive reflection

The most important lesson was that Conditional Access is not simply a collection of portal settings. A defensible deployment depends on scope control, recovery access, licensing, evidence quality, staged enforcement, monitoring, and a tested rollback route.

Five Wave 1 policies were moved from design to Report-only and then to On without losing administrative access. The strongest outcome was not the number of enabled policies; it was the repeatable process used to explain why each policy existed, predict its result, test it safely, verify the tenant response, and retain an operational owner.

## 3. Lessons from planning and design

### 3.1 Licensing is an implementation dependency

The initial tenant baseline did not provide the premium Conditional Access capabilities required by the design. Entra ID P2 activation therefore became a formal prerequisite rather than an administrative detail. Standard Conditional Access requires P1, while the Identity Protection risk signals designed for CA006 and CA007 require P2. The final review also confirmed that the trial expires on 6 October 2026 with recurring billing Off.

**Lesson:** Confirm the licence edition, assignment population, renewal owner, and expiry date before approving a premium identity-control roadmap.

### 3.2 Recovery access must precede enforcement

The two cloud-only emergency identities and their exclusion group were established and tested before security defaults was replaced or any policy was enforced. Both identities were tested again before enforcement and during final assurance.

**Lesson:** Emergency access is a deployment gate, not a task to complete after a restrictive policy is enabled.

### 3.3 Business requirements must become testable policy statements

The policy matrix connected each control to a risk, target population, application scope, exclusion, dependency, expected result, monitoring signal, and rollback action. This prevented vague objectives such as "enable Zero Trust" from becoming uncontrolled tenant-wide changes.

**Lesson:** A policy is implementation-ready only when its assignments, exclusions, controls, dependencies, success criteria, owner, and rollback path are explicit.

### 3.4 Not every designed control should be deployed immediately

Five additional policy families remained design-only because their dependencies were not ready. Examples included compliant-device enforcement, risk-based access, and broader phishing-resistant authentication requirements.

**Lesson:** Deferring a control with documented prerequisites is stronger engineering than forcing an incomplete deployment for evidence coverage.

## 4. Lessons from implementation and testing

### 4.1 Report-only is essential, but it is not enforcement

Report-only results identified whether a policy would have applied without changing access. Actual behavior still required controlled enforcement tests. The CA010 device-code scenario demonstrated this distinction clearly: Report-only predicted failure, while the On-state test produced the intended block.

**Lesson:** Use Report-only to reduce uncertainty, then perform an approved enforcement test before claiming that a control blocks or grants access as designed.

### 4.2 What If predictions require observed sign-in evidence

The What If tool was valuable for confirming assignment logic, including legacy-client and device-code conditions. It did not prove that an actual authentication attempt occurred.

**Lesson:** Treat What If as configuration analysis and sign-in logs as runtime evidence. Neither should be represented as the other.

### 4.3 `Not applied` can be the correct result

CA001 did not apply to a modern browser sign-in because the policy targets legacy client conditions. Other policies correctly returned Not applied when the tested identity, resource, authentication flow, or client condition was outside their assignment.

**Lesson:** A nonapplicable result is not a policy failure when it matches the documented condition logic.

### 4.4 `Success` means the Conditional Access requirement was satisfied

A successful policy result does not always mean the user saw a new MFA prompt during that exact interaction. An existing authentication claim or session can satisfy the grant requirement. Authentication details and surrounding sign-in events are needed to interpret the result correctly.

**Lesson:** Do not equate the absence of a fresh prompt with policy failure; validate the Conditional Access result and authentication context.

### 4.5 Session controls require a deliberate browser test

The contractor persistent-browser control could not be judged only by the presence or absence of a "Stay signed in" prompt. The controlled validation used a separate browser profile, closed the session, reopened the resource, and confirmed that credentials were required again.

**Lesson:** Define the observable session behavior before testing a session control and isolate the browser state from earlier sign-ins.

### 4.6 Cloud policy results and local client errors are different evidence

The Microsoft Graph device-code test encountered local PowerShell module and listener issues during troubleshooting. The authoritative control result came from Microsoft Entra sign-in logs, which recorded error `53003` and CA010 Failure for the blocked flow.

**Lesson:** Separate client-tool execution problems from the cloud authentication decision, and use the authoritative service log to prove Conditional Access behavior.

### 4.7 Safe negative testing has boundaries

No obsolete legacy client or deliberately unprepared registration identity was introduced solely to generate a failure screenshot. The project retained What If, activity review, supported-browser nonapplication, and other safe evidence instead.

**Lesson:** Evidence collection does not justify creating unnecessary security exposure. Record a limitation when a safe, representative negative test is unavailable.

## 5. Lessons from monitoring and evidence

### 5.1 Sign-in logs and audit logs answer different questions

Sign-in logs showed whether access and Conditional Access evaluation succeeded, failed, or did not apply. Audit logs showed who changed policy configuration and whether the create or update operation succeeded. Searching for policy-update activity in sign-in logs could not provide the required change evidence.

**Lesson:** Use sign-in logs for access decisions and audit logs for configuration changes.

### 5.2 Expected interruptions must be distinguished from failures

The success review contained intermediate `50140` events associated with the Keep me signed in interruption. Successful sign-ins followed them, and they were not classified as unexpected policy failures.

**Lesson:** Interpret error codes and event sequences before escalating an interrupted sign-in as a control failure.

### 5.3 Portal filtering and ingestion delay affect validation

Activity filters, local time display, preview interfaces, and log-ingestion timing influenced what was visible during testing. Refreshes and clearly recorded time windows were necessary to avoid premature conclusions.

**Lesson:** Record the test time, log type, filter, expected resource, and expected result before reviewing evidence; allow for ingestion delay.

### 5.4 Evidence privacy must be designed into the workflow

Raw screenshots contained identities, user principal names, request identifiers, IP addresses, and location data. Public evidence was selected, cropped, or redacted while preserving the policy names, states, controls, and outcomes needed for verification.

**Lesson:** Maintain private raw evidence separately and publish only the minimum sanitized evidence required to support the claim.

## 6. What worked well

| Practice | Benefit |
| --- | --- |
| Baseline before change | Exposed licensing, recovery, device, and privilege gaps before deployment |
| Group-based pilot scope | Limited impact and made assignments auditable |
| Two tested emergency identities | Preserved independent recovery paths throughout enforcement |
| One-policy-at-a-time enforcement | Made each change attributable and individually reversible |
| What If plus real sign-in testing | Combined configuration prediction with observed runtime behavior |
| Audit review after each change | Confirmed that every policy update completed successfully |
| Sanitized named evidence | Produced a public technical repository without publishing sensitive tenant data |
| Automated repository validation | Detected missing files, broken links, invalid images, and sensitive-text patterns before upload |

## 7. What should be improved in a production implementation

| Improvement | Why it matters |
| --- | --- |
| Observe Report-only for at least the recommended production period | The shortened lab window cannot represent normal user and application behavior |
| Send sign-in and audit logs to Log Analytics | Enables durable retention, workbook analysis, alerting, and repeatable queries |
| Create alert ownership and response targets | A monitored control needs accountable triage and escalation |
| Replace routine standing Global Administrator access with PIM | Reduces permanent privilege while retaining the two emergency assignments |
| Establish a paid licence-continuity decision before expiry | Prevents premium controls and monitoring assumptions from becoming unsupported |
| Add managed-device prerequisites before CA008 | Avoids broad denial when no compliant-device population is ready |
| Validate legacy dependencies through application ownership | Prevents unsafe assumptions about protocols that may still be used by business systems |
| Use formal approvals for scope expansion | Separates technical validation from authorization to affect additional users |

## 8. Decisions carried into future IAM implementations

1. Begin with explicit scope, licensing, recovery, evidence, and rollback gates.
2. Use group-based assignments and a limited pilot before wider enforcement.
3. Keep configuration prediction, runtime testing, and change auditing as separate evidence layers.
4. Avoid manufacturing unsafe failure conditions purely for screenshots.
5. Sanitize evidence before public packaging and validate every relative link and expected file.
6. Treat privileged-role remediation as its own controlled project rather than combining it with Conditional Access rollout.
7. Preserve an operational owner and review cadence after technical deployment is complete.

## 9. Implementation summary

The implementation established a ten-policy Conditional Access framework and deployed five priority controls in a controlled Microsoft Entra lab. Business requirements, assignments, exclusions, dependencies, the emergency-access model, test criteria, and rollback conditions were documented before deployment. After P2 licensing was enabled and two cloud-only recovery identities were validated, the policies moved through Report-only assessment, applicable and nonapplicable scenario testing, and one-at-a-time enforcement. Final assurance verified management and security-information MFA, nonpersistent contractor sessions, an enforced device-code block, sign-in and audit evidence, deleted-policy state, group scope, licensing, standing privilege, evidence privacy, and operational ownership. The principal conclusion is that Conditional Access effectiveness depends as much on recovery, monitoring, evidence, and change control as it does on policy configuration.

## 10. Final conclusion

The implementation achieved its controlled-lab objective and produced defensible evidence for five enforced Conditional Access controls. It also exposed realistic operational risks: premium-licence continuity, standing privilege, incomplete device-management prerequisites, shortened observation time, and the absence of centralized Log Analytics monitoring.

Those findings are documented constraints and inputs to subsequent identity-security initiatives. The resulting evidence demonstrates a controlled engineering process rather than an unsupported claim of production-wide Zero Trust deployment.

## 11. Authoritative references

- [Plan a Conditional Access deployment](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)
- [Use report-only mode](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-report-only)
- [Conditional Access What If](https://learn.microsoft.com/en-us/entra/identity/conditional-access/what-if-tool)
- [Microsoft Entra sign-in logs](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/concept-sign-ins)
- [Microsoft Entra audit logs](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/concept-audit-logs)
- [Conditional Access insights and reporting](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-insights-reporting)
- [Manage emergency access accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)
- [Microsoft Entra licensing](https://learn.microsoft.com/en-us/entra/fundamentals/licensing)
