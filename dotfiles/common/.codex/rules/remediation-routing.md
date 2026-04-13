# Remediation Routing Rules

When reviewer or tester finds same-scope issues:

1. route the task back to the main-thread implementation scope
2. preserve the approved scope boundary
3. include the exact failing checks or findings
4. require the implementation owner to respond only to the scoped remediation items

Escalate instead of routing when:
- the fix needs a larger write set
- the fix changes approved behavior or public interfaces
- the failure is environment-blocked and cannot be reproduced safely
