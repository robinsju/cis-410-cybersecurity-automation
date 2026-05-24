# Week 8 Cloud Architecture Comparison

## Step 2: Comparison Table

| Dimension | On-Premise Docker (Wks 3–5) | Cloud Run (Week 8) |
| :--- | :--- | :--- |
| **Infrastructure setup** | 3 VMs created, Docker installed on each | Serverless. Google handles the OS and hardware completely.|
| **Deployment command** | SSH → docker build → docker run | Automated via `terraform apply` or GitHub Actions. |
| **TLS / HTTPS** | Not configured | Built-in out of the box. Google automatically provisions a valid SSL/TLS certificate and provides a secure `https://` URL. |
| **Scaling approach** | Manual — redeploy or add VMs | Built-in automatically with a public HTTPS URL.|
| **Port management** | Ports 5000/5001/5002 per environment | Abstracted away. Cloud Run routes traffic to port 8080. |
| **Cost when idle** | VM running 24/7 regardless of traffic | Pay-per-request. Zero traffic means zero cost. |
| **Rollback** | Re-deploy previous image manually | Instant. Switch tags or split traffic in the GCP Console.|
| **Secrets management** | GitHub Secrets → env vars in workflow | Handled securely via GCP Secret Manager and IAM roles.
|
# lots of help from Gemini to understand the observations and the answers below.
Reflection Questions
Q1: Which approach required more manual steps from push to live URL? List the specific steps that were eliminated by Cloud Run.

Answer: Definitely the on-premise Docker setup. Cloud Run completely eliminated the need to manually SSH into individual VMs, rebuild images on each box, and manually run docker commands to map ports.

Q2: A security audit asks how you know which version of the code is currently running in production. How would you answer for on-premise Docker vs. Cloud Run with commit SHA tagging?

Answer: For on-premise, I’d have to check each VM manually to see what container ID is running, which easily leads to configuration drift. With Cloud Run, every deployment creates an immutable version tagged directly with the unique GitHub commit SHA, giving a clear paper trail from code to production.


Q3: Your on-premise VMs run 24/7 even when no students are using the app. Cloud Run scales to zero. What is the security advantage of scale-to-zero beyond cost savings?

Answer: When an app scales to zero, there is no active code running and no open ports waiting for traffic. This completely removes the attack surface during off-hours, meaning there is literally nothing online for a hacker to scan or attack.

Q4: The OIDC workflow replaced the SSH key secrets from Weeks 3–5. What attack surface was eliminated?

Answer: It eliminated long-lived, static credentials. Instead of keeping permanent SSH keys saved in GitHub secrets (which can be leaked or stolen), OIDC uses short-lived tokens that automatically expire after a few minutes, meaning there is no static key for an attacker to steal.