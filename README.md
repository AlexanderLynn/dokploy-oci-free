# Dokploy on OCI Free Tier

Deploy [Dokploy](https://dokploy.com) on Oracle Cloud Infrastructure using the Always Free tier.

## Features

- **1 Main instance** with Dokploy installed (port 3000 exposed)
- **N Worker instances** distributed across availability domains
- **Cloudflare Tunnels support** — optionally keep ports 80/443 closed
- **Free tier compliant** — 50GB boot volumes, 1 OCPU, 6GB RAM per instance

## Prerequisites

1. OCI account with Always Free tier
2. Terraform >= 1.5
3. OCI CLI configured (`~/.oci/config`)
4. Ubuntu 24.04 LTS Minimal image OCID for your region

## Quick Start

1. Clone this repository
2. Copy `terraform.tfvars.example` to `terraform.tfvars`
3. Fill in your values
4. Run:

```bash
terraform init
terraform plan
terraform apply
```

5. Access Dokploy at `http://<main_public_ip>:3000`

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `compartment_id` | OCI compartment OCID | *required* |
| `source_image_id` | Ubuntu 24.04 LTS Minimal image OCID | *required* |
| `availability_domain_main` | AD for main instance | *required* |
| `availability_domain_workers` | List of ADs for workers (round-robin) | *required* |
| `num_worker_instances` | Number of worker instances | `1` |
| `use_cloudflare_tunnels` | If true, ports 80/443 stay closed | `false` |
| `instance_shape` | Compute shape | `VM.Standard.A1.Flex` |
| `ocpus` | OCPUs per instance | `1` |
| `memory_in_gbs` | Memory per instance (GB) | `6` |
| `boot_volume_size_gb` | Boot volume size (GB) | `50` |

## Free Tier Limits

- **Compute**: 4 OCPUs and 24 GB RAM total across all A1.Flex instances
- **Storage**: 200 GB total boot volume
- **Network**: 10 TB outbound data transfer per month

With defaults (1 OCPU, 6 GB, 50 GB disk), you can run up to **4 instances**.

## Outputs

- `dokploy_main_public_ip` — Main instance IP
- `dokploy_dashboard_url` — Dokploy web UI URL
- `dokploy_worker_public_ips` — List of worker IPs

## Adding Workers to Swarm

After deployment, SSH into the main instance and get the swarm join token:

```bash
docker swarm join-token worker
```

Then SSH into each worker and run the join command.

## License

MIT
