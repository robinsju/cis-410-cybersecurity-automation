# Week 8 Cloud Architecture Comparison

| Dimension | On-Premise Docker (Wks 3–5) | Cloud Run (Week 8) |
| :--- | :--- | :--- |
| **Infrastructure setup** | 3 VMs created, Docker installed on each | Serverless platform managed by GCP; no VMs to manage or patch. |
| **Deployment command** | SSH → docker build → docker run | `terraform apply` or fully automated via GitHub Actions YAML workflow. |
| **TLS / HTTPS** | Not configured | Automatically provided out-of-the-box with a secure, public HTTPS URL. |
| **Scaling approach** | Manual — redeploy or add VMs | Native auto-scaling based on incoming request volume (scales down to 0 or up dynamically). |
| **Port management** | Ports 5000/5001/5002 per environment | Abstracted completely; Cloud Run listens on port 8080 internally and routes traffic seamlessly. |
| **Cost when idle** | VM running 24/7 regardless of traffic | Pay-per-request model; scales down to zero instances when idle to save costs. |
| **Rollback** | Re-deploy previous image manually | Immediate traffic-splitting and revision switching directly via the GCP Console. |
| **Secrets management** | GitHub Secrets → env vars in workflow | Integrated securely with GCP Secret Manager and IAM service account roles. |
