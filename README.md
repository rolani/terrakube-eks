# Terrakube EKS Deployment

This repository provides infrastructure-as-code for deploying [Terrakube](https://terrakube.io/) on Amazon EKS (Elastic Kubernetes Service) using Terraform and Helm. Terrakube is an open-source tool for managing Terraform and OpenTofu workflows at scale.

## Architecture Overview

The deployment includes the following components:

- **Amazon EKS Cluster**: Kubernetes control plane and worker nodes
- **Terrakube**: Main application for Terraform/OpenTofu workflow management
- **NGINX Ingress Controller**: Handles external access to services
- **cert-manager**: Manages SSL/TLS certificates
- **External DNS**: Automatically manages DNS records in Route 53

## Prerequisites

Before deploying, ensure you have the following:

- **AWS Account** with appropriate permissions
- **AWS CLI** configured with your credentials
- **Terraform** >= 1.3.0
- **kubectl** for Kubernetes cluster access
- **Helm** 3.x for deploying charts
- **Domain** registered in Route 53 (for external DNS and SSL certificates)

### Required AWS Permissions

Your AWS user/role needs the following permissions:
- EKS cluster creation and management
- VPC, subnets, and security groups management
- IAM roles and policies creation
- Route 53 hosted zone management
- EC2 instance management

## Quick Start

### Option 1: Full Terraform Deployment (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/rolani/terrakube-eks.git
   cd terrakube-eks
   ```

2. **Configure EKS Cluster**
   ```bash
   cd terraform-eks

   # Review and modify variables in eks.auto.tfvars
   # Update region, availability zones, instance types, etc.

   # Initialize Terraform
   terraform init

   # Plan the deployment
   terraform plan

   # Apply the configuration
   terraform apply
   ```

3. **Configure Kubernetes Access**
   ```bash
   # Update your kubeconfig
   aws eks update-kubeconfig --region us-east-1 --name <cluster-name>

   # Verify connection
   kubectl get nodes
   ```

4. **Deploy Terrakube Components**
   ```bash
   cd ../helm-terraform

   # Review and update variables.tf with your cluster details
   # Update cluster_name, region, etc.

   # Initialize Terraform
   terraform init

   # Plan the deployment
   terraform plan

   # Apply the configuration
   terraform apply
   ```

### Option 2: Manual Deployment with Scripts

If you prefer manual deployment or already have an EKS cluster:

1. **Deploy cert-manager**
   ```bash
   cd manifests/cert-manager
   chmod +x cert-manager.sh
   ./cert-manager.sh
   ```

2. **Deploy External DNS**
   ```bash
   cd ../external-dns
   # Update ext-dns-script.sh with your cluster name and account ID
   chmod +x ext-dns-script.sh
   ./ext-dns-script.sh
   ```

3. **Deploy NGINX Ingress**
   ```bash
   cd ../nginx
   chmod +x helm_runner.sh
   ./helm_runner.sh
   ```

4. **Deploy Terrakube**
   ```bash
   cd ../terrakube
   # Update terrakube-values-new.yaml with your configuration
   chmod +x terrakube_runner.sh
   ./terrakube_runner.sh
   ```

## Configuration

### EKS Cluster Configuration

Key configuration options in `terraform-eks/eks.auto.tfvars`:

- `region`: AWS region for deployment
- `availability_zones`: List of availability zones
- `kubernetes_version`: EKS Kubernetes version (default: 1.29)
- `instance_types`: EC2 instance types for worker nodes
- `desired_size`: Number of worker nodes
- `enabled_cluster_log_types`: Control plane logging types

### Terrakube Configuration

Update `helm-terraform/terrakube-values-new.yaml` with:

- **Security Settings**:
  - `adminGroup`: Admin group for Terrakube
  - `patSecret`: Personal Access Token secret
  - `internalSecret`: Internal secret for encryption
  - `dexClientId`: Dex OAuth client ID
  - `dexIssuerUri`: Dex issuer URI

- **SSL Certificates**: Update the `caCerts` section with your certificates

- **Domain Configuration**: Configure ingress hosts and TLS settings

### DNS and SSL Configuration

1. **Route 53 Hosted Zone**: Ensure you have a hosted zone for your domain

2. **Update External DNS Policy**: In `helm-terraform/external-dns.tf`, replace `ZZZZZZZZZZZZZZZZZZZZZ` with your hosted zone ID

3. **SSL Certificates**: Configure cert-manager issuers in the manifests

## Access Terrakube

After deployment, access Terrakube through the NGINX ingress:

1. **Get the ingress URL**:
   ```bash
   kubectl get ingress -n terrakube
   ```

2. **DNS Propagation**: Wait for external-dns to create the DNS records

3. **Access the Application**: Navigate to your configured domain

## Troubleshooting

### Common Issues

1. **EKS Cluster Creation Fails**:
   - Check AWS limits and quotas
   - Verify IAM permissions
   - Ensure availability zones are available

2. **Helm Deployment Issues**:
   - Verify kubectl context: `kubectl config current-context`
   - Check pod status: `kubectl get pods -A`
   - Review logs: `kubectl logs <pod-name> -n <namespace>`

3. **DNS Issues**:
   - Verify hosted zone ID in external-dns configuration
   - Check Route 53 records propagation
   - Ensure domain delegation is correct

4. **SSL Certificate Issues**:
   - Check cert-manager pod logs
   - Verify DNS-01 challenge configuration
   - Ensure Route 53 permissions for cert-manager

### Useful Commands

```bash
# Check cluster status
kubectl get nodes
kubectl get pods -A

# Check Terrakube deployment
kubectl get pods -n terrakube
kubectl get ingress -n terrakube

# Check logs
kubectl logs -n terrakube deployment/terrakube-api
kubectl logs -n cert-manager deployment/cert-manager

# Terraform state management
terraform state list
terraform state show <resource>
```

## Security Considerations

- **Secrets Management**: The current configuration includes sample secrets. Replace with secure values for production
- **Network Security**: Review security groups and NACLs
- **IAM Permissions**: Follow principle of least privilege
- **SSL/TLS**: Ensure certificates are properly configured and rotated

## Cleanup

To destroy the infrastructure:

```bash
# Destroy Helm releases
cd helm-terraform
terraform destroy

# Destroy EKS cluster
cd ../terraform-eks
terraform destroy
```

**Note**: Some resources may need manual cleanup, especially Route 53 records and SSL certificates.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues related to:
- **Terrakube**: Visit [Terrakube GitHub](https://github.com/AzBuilder/terrakube)
- **EKS**: Check [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- **Terraform**: See [Terraform Registry](https://registry.terraform.io/)

## License

This project is licensed under the terms specified in the LICENSE file.
