# Week 8 Lab Exercise — On-Premise Docker vs. Cloud Run

## Comparison Table

Fill in the Cloud Run column based on your actual experience this week.
Do not leave any row blank.

| Dimension | On-Premise Docker (Weeks 3–5) | Cloud Run (Week 8) |
|---|---|---|
| Infrastructure setup | 3 VMs created, Docker installed on each | ← fill in your observation |
| Deployment command | SSH → docker build → docker run | ← fill in your observation |
| TLS / HTTPS | Not configured | ← fill in your observation |
| Scaling approach | Manual — redeploy or add VMs | ← fill in your observation |
| Port management | Ports 5000/5001/5002 per environment | ← fill in your observation |
| Cost when idle | VM running 24/7 regardless of traffic | ← fill in your observation |
| Rollback | Re-deploy previous image manually | ← fill in your observation |
| Secrets management | GitHub Secrets → env vars in workflow | ← fill in your observation |

---

## Reflection Questions

Answer each question in 2–4 sentences based on your direct experience.

**Q1: Which approach required more manual steps from push to live URL?**
List the specific steps that were eliminated by Cloud Run.

*(your answer here)*

---

**Q2: Audit trail — which version is running?**
A security audit asks how you know which version of the code is currently running
in production. How would you answer for on-premise Docker vs. Cloud Run with
commit SHA tagging?

*(your answer here)*

---

**Q3: Security advantage of scale-to-zero**
Your on-premise VMs ran 24/7 even when no students were using the app.
Cloud Run scales to zero. What is the security advantage of scale-to-zero
beyond cost savings?

*(your answer here)*

---

**Q4: Attack surface reduction**
The OIDC workflow replaced the SSH key secrets from Weeks 3–5.
What attack surface was eliminated?

*(your answer here)*
