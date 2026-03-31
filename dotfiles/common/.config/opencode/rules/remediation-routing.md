# Remediation Routing Rules

When reviewer or tester finds same-scope issues:

1. route the task back to the original coder scope
2. preserve the original write-set boundary
3. include the exact failing checks or findings
4. require the coder to respond only to the scoped remediation items

Escalate instead of routing when:
- the fix needs a larger write set
- the fix changes approved behavior or public interfaces
- the failure is environment-blocked and cannot be reproduced safely
