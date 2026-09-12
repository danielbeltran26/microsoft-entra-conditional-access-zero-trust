# Conditional Access Operations Handover Runbook

## 1. Purpose and scope

This runbook transfers the five enforced Wave 1 Conditional Access policies into a repeatable operating model. It defines ownership, monitoring, incident triage, controlled change, rollback, emergency access, licence continuity, and evidence-handling expectations.

It applies only to the controlled pilot and contractor scopes documented in the [policy matrix](../policies/Conditional-Access-Policy-Matrix.md). It does not authorize organization-wide expansion or deployment of CA002, CA003, CA006, CA007, or CA008.

## 2. Operational ownership

| Responsibility | Accountable function | Minimum operating requirement |
| --- | --- | --- |
| Policy ownership | Identity and Access Management | Maintains the control register, policy intent, scope, exclusions, and review dates |
| Policy administration | Conditional Access Administrator | Uses a least-privileged administrative role and changes one policy at a time |
| Monitoring | Security operations or Security Reader | Reviews sign-in and audit evidence without changing policy |
| Application validation | Application owner | Confirms business impact before scope expansion or exception approval |
| Emergency recovery | Independent recovery operator | Maintains and tests both cloud-only emergency identities |
| Licence ownership | Tenant or billing administrator | Tracks Conditional Access licensing and renewal decisions before expiry |

Conditional Access policies do not have a built-in owner attribute. Ownership is therefore maintained in the [operational control register](../data/m07-operational-control-register.csv).

## 3. Monitoring schedule

| Frequency | Review | Escalation condition |
| --- | --- | --- |
| After every change | Audit logs, final policy state, mapped sign-in scenario, and both recovery paths | Failed or unexplained change; unexpected scope; recovery failure |
| Daily during a change window | Conditional Access failures and interrupted sign-ins | Unexplained denial, repeated challenge, or business application impact |
| Weekly | Success and failure trends, device-code use, legacy clients, policy inventory, exclusions, and deleted policies | New dependency, unusual volume, state drift, or deleted policy |
| Monthly | Control register, deferred policies, licence status, pilot membership, and open exceptions | Expiring licence, stale exception, changed business requirement, or uncontrolled scope growth |
| At least every 90 days | Both emergency-account sign-ins, credentials, exclusions, group membership, role assignment, and monitoring | Either recovery identity fails or no longer remains independent |

The lab uses portal sign-in and audit logs. The Conditional Access Insights and Reporting workbook is not implemented in this project because no project-specific Log Analytics ingestion path was established. Production deployment should stream sign-in logs to a Log Analytics workspace and define retention, alerting, and ownership before relying on long-term trend reporting.

## 4. Sign-in triage workflow

1. Record the approximate time, affected application, client type, and user-reported outcome in the private incident record.
2. Open `entra.microsoft.com` and browse to **Entra ID > Conditional Access > Sign-in logs**.
3. Locate the event and inspect **Conditional access**, **Authentication details**, client application, authentication protocol, resource, and result.
4. Distinguish an enforced block from an intermediate sign-in event. For example, error `50140` is a Keep me signed in interruption and can appear before a successful event; it is not by itself a Conditional Access policy failure.
5. Use the What If tool to reproduce the assignment logic without changing the policy.
6. Compare the observed result with the approved policy matrix and test plan.
7. Escalate any unexplained block, exclusion, policy nonapplication, or repeated user interruption to the policy owner.
8. Keep UPNs, request IDs, correlation IDs, IP addresses, and authentication details in restricted case evidence. Publish only sanitized derivatives.

## 5. Change procedure

Before changing an enforced policy:

1. Create an approved change record containing the reason, owner, exact policy, expected outcome, test identities, observation period, and rollback trigger.
2. Reconfirm both emergency identities and keep an independent recovery session open.
3. Confirm the current policy state, group membership, exclusions, target resources, licence status, and monitoring availability.
4. Preserve the pre-change configuration and capture a sanitized baseline.
5. Change only one policy or one logical condition at a time.
6. Run the mapped positive, negative, and exclusion tests.
7. Review sign-in and audit evidence before closing the change.
8. Update the policy matrix, control register, test record, and evidence index.

No policy moves from controlled pilot scope to broad scope without a new report-only observation, user communication, application-owner acceptance, and explicit approval.

## 6. Rollback and recovery

Use the detailed [test and rollback plan](Conditional-Access-Test-and-Rollback-Plan.md) when a trigger occurs.

The standard response is:

1. Stop further changes and preserve current sessions.
2. Use the independent recovery operator if normal administration is affected.
3. Identify the last change in the audit log.
4. Return the affected policy to Report-only. Disable it only when Report-only does not restore access.
5. Confirm normal administration and affected application access.
6. Preserve private incident evidence and create a sanitized public record only when required.
7. Correct the dependency or design defect and repeat report-only validation before re-enforcement.

Deleted policies can be restored during Microsoft's 30-day soft-delete window, but deletion is not the normal rollback method.

## 7. Emergency-access operations

- Keep exactly two cloud-only emergency identities in the dedicated exclusion group.
- Retain permanent Global Administrator assignment only for the independently governed recovery identities.
- Use phishing-resistant credentials that do not depend on synchronized identity or the normal administrator path.
- Do not use the accounts for routine administration.
- Alert on sign-ins and on changes to credentials, group membership, role assignment, or exclusions.
- Test both accounts at least every 90 days and before and after high-impact Conditional Access changes.
- Treat any failed test or unexpected policy application as a stop condition.

## 8. Licence continuity

At final assurance, the Microsoft Entra ID P2 Trial was Active with 7 of 100 licences assigned, recurring billing Off, and expiration on 6 October 2026.

Before that date, the licence owner must either approve an appropriate paid licence or accept that the lab's premium capabilities are temporary. No production continuity claim is valid after licence expiry without a new licence check. Risk-based policies CA006 and CA007 remain design-only and require P2 before deployment.

Standard Conditional Access requires Entra ID P1-or-higher entitlement for the population benefiting from the policies. The recorded total of seven P2 assignments must therefore be reconciled against the actual members of every enforced scope, including all CA009 contractor members; a seat count alone is not entitlement evidence.

## 9. Accepted findings and deferred work

| Finding | Current treatment | Required next decision |
| --- | --- | --- |
| Four permanent-active Global Administrators observed | Accepted temporarily to avoid combining privileged-role redesign with enforcement | Reduce routine standing privilege in the planned PIM implementation while retaining two emergency paths |
| Shorter than recommended report-only observation | Accepted only for the isolated synthetic lab | Use at least Microsoft's recommended one-week report-only period for production planning |
| No project-specific Log Analytics workbook | Manual portal review retained | Implement ingestion, retention, workbook ownership, and alerts for production operations |
| Five policies remain design-only | No deployment claim | Satisfy each wave's prerequisites and repeat the staged process |
| P2 trial expires with recurring billing Off | Recorded operational dependency | Decide on licensing before 6 October 2026 |
| Security defaults is Off while CA002 remains design-only | Controlled Wave 1 protection is retained; tenant-wide equivalence is not claimed | Inventory all enabled identities and their effective protections before accepting or expanding the final state |
| Emergency accounts use Authenticator passkeys | Accepted as a laboratory phishing-resistant method | Use separately controlled credentials and devices for production recovery-path independence |

## 10. Handover acceptance checklist

- [x] Five Wave 1 policies are On in controlled scope.
- [x] Expected access, MFA, session, block, and nonapplication scenarios passed.
- [x] Both emergency identities completed final access tests.
- [x] Policy, pilot, contractor, recovery, and privileged-role state were reviewed.
- [x] Seven-day sign-in review found no unexpected Conditional Access failure.
- [x] Audit review found no failed or unexplained Conditional Access change.
- [x] Deleted-policy inventory is empty.
- [x] Licence status, capacity, expiry, and recurring billing were recorded.
- [x] Rollback triggers and procedures remain documented.
- [x] Known limitations and deferred policies are explicit.
- [x] Public evidence passed privacy review.

## 11. Microsoft Learn references

- [Plan a Conditional Access deployment](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)
- [Conditional Access insights and reporting](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-insights-reporting)
- [Microsoft Entra sign-in logs](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/concept-sign-ins)
- [Microsoft Entra audit logs](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/concept-audit-logs)
- [Microsoft Entra authentication error codes](https://learn.microsoft.com/en-us/entra/identity-platform/reference-error-codes)
- [Manage emergency access accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)
- [Microsoft Graph policy soft-delete resource](https://learn.microsoft.com/en-us/graph/api/resources/policydeletableitem?view=graph-rest-beta)
- [Microsoft Entra licensing](https://learn.microsoft.com/en-us/entra/fundamentals/licensing)
