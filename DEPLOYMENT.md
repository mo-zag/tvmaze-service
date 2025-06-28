# AWS Deployment Plan

## Overview

This document outlines the complete deployment strategy for the TVMaze Data Ingestion Service on AWS, including all necessary services, CI/CD pipeline, and security considerations.

## AWS Services Architecture

### 1. Compute Layer

#### ECS Fargate
- **Service**: Containerized application deployment
- **Configuration**:
  - CPU: 0.5 vCPU (256 CPU units)
  - Memory: 1GB RAM
  - Desired count: 2 (for high availability)
  - Auto-scaling: 1-4 instances based on CPU utilization
- **Benefits**: Serverless, no EC2 management, automatic scaling

#### Application Load Balancer (ALB)
- **Purpose**: HTTP traffic distribution and SSL termination
- **Configuration**:
  - Target group: ECS service
  - Health check: `/up` endpoint
  - SSL certificate: ACM-managed certificate
  - Idle timeout: 60 seconds

### 2. Database Layer

#### RDS PostgreSQL
- **Instance**: db.t3.micro (development) / db.t3.small (production)
- **Storage**: 20GB GP2 SSD with auto-scaling up to 100GB
- **Multi-AZ**: Enabled for production
- **Backup**: Automated daily backups with 7-day retention
- **Maintenance window**: Sunday 3-4 AM UTC

#### ElastiCache Redis
- **Purpose**: Session storage and API response caching
- **Instance**: cache.t3.micro (development) / cache.t3.small (production)
- **Cluster mode**: Disabled (single node)
- **TTL**: 24 hours for cached responses

### 3. Storage Layer

#### S3
- **Buckets**:
  - `tvmaze-assets`: Static assets and images
  - `tvmaze-backups`: Database backups and logs
  - `tvmaze-temp`: Temporary file storage
- **Lifecycle**: Move to IA after 30 days, Glacier after 90 days

#### EFS (Optional)
- **Purpose**: Shared file storage for logs and temporary files
- **Performance mode**: General Purpose
- **Throughput mode**: Bursting

### 4. Monitoring & Observability

#### CloudWatch
- **Logs**: Application logs with 30-day retention
- **Metrics**: Custom application metrics
- **Alarms**:
  - High CPU utilization (>80%)
  - High memory utilization (>85%)
  - Database connections (>80%)
  - API error rate (>5%)
  - Response time (>2 seconds)

#### X-Ray
- **Purpose**: Distributed tracing for API requests
- **Sampling**: 10% of requests
- **Retention**: 30 days

### 5. Security Layer

#### IAM
- **ECS Task Role**: Minimal permissions for S3, RDS, ElastiCache
- **Service Role**: ECS service permissions
- **User Roles**: Developer and admin access

#### Secrets Manager
- **Stored Secrets**:
  - Database credentials
  - API keys (if needed)
  - SSL certificates
- **Rotation**: Automated 30-day rotation

#### WAF (Web Application Firewall)
- **Rules**:
  - Rate limiting: 2000 requests per 5 minutes per IP
  - SQL injection protection
  - XSS protection
  - Geographic restrictions (if needed)

#### VPC Configuration
- **Public subnets**: ALB and NAT Gateway
- **Private subnets**: ECS tasks and RDS
- **Security Groups**:
  - ALB: Allow HTTP/HTTPS from internet
  - ECS: Allow HTTP from ALB
  - RDS: Allow PostgreSQL from ECS
  - ElastiCache: Allow Redis from ECS

## CI/CD Pipeline

### GitHub Actions Workflow

```yaml
name: Deploy to AWS

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
      - name: Install dependencies
        run: bundle install
      - name: Run tests
        run: bundle exec rspec
      - name: Run linting
        run: bundle exec rubocop
      - name: Security scan
        run: bundle exec brakeman

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Build and push Docker image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: tvmaze-service
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
      
      - name: Update ECS service
        run: |
          aws ecs update-service \
            --cluster tvmaze-cluster \
            --service tvmaze-service \
            --force-new-deployment
      
      - name: Wait for deployment
        run: |
          aws ecs wait services-stable \
            --cluster tvmaze-cluster \
            --services tvmaze-service
```

### Deployment Strategy

#### Blue-Green Deployment
1. **Blue Environment**: Current production
2. **Green Environment**: New deployment
3. **Switch**: ALB target group switch
4. **Rollback**: Quick rollback to blue if issues detected

#### Canary Deployment (Optional)
1. **Phase 1**: Deploy to 10% of traffic
2. **Phase 2**: Monitor metrics for 5 minutes
3. **Phase 3**: Deploy to 50% of traffic
4. **Phase 4**: Full deployment if metrics are healthy

## Authentication & Authorization

### API Gateway (Optional Enhancement)
- **Rate Limiting**: 1000 requests per minute per API key
- **API Keys**: Managed through AWS Console
- **Usage Plans**: Different tiers (free, basic, premium)
- **Caching**: 5-minute cache for GET requests

### Cognito (If User Authentication Needed)
- **User Pool**: Email/password authentication
- **Identity Pool**: AWS resource access
- **MFA**: Optional SMS or TOTP
- **Social Login**: Google, Facebook (if needed)

### IAM Service Authentication
- **ECS Task Role**: Minimal permissions principle
- **Cross-Service**: Service-to-service authentication
- **Audit**: CloudTrail for all API calls

## Cost Optimization

### Resource Sizing
- **Development**: t3.micro instances, minimal storage
- **Production**: t3.small instances, auto-scaling
- **Database**: Start with t3.micro, scale based on usage

### Reserved Instances
- **RDS**: 1-year reserved instances for production
- **ElastiCache**: Reserved nodes for predictable workloads

### Monitoring Costs
- **CloudWatch**: Custom metrics and logs retention
- **X-Ray**: Sampling rate adjustment
- **S3**: Lifecycle policies for cost optimization

## Security Best Practices

### Network Security
- **VPC**: Private subnets for all resources
- **Security Groups**: Minimal required access
- **NACLs**: Additional network layer protection

### Data Security
- **Encryption**: At rest and in transit
- **Backups**: Encrypted automated backups
- **Secrets**: Rotated automatically

### Application Security
- **WAF**: Protection against common attacks
- **HTTPS**: SSL/TLS termination at ALB
- **Headers**: Security headers (HSTS, CSP, etc.)

## Monitoring & Alerting

### Key Metrics
- **Application**: Response time, error rate, throughput
- **Infrastructure**: CPU, memory, disk usage
- **Database**: Connections, query performance, storage
- **Business**: API usage, data ingestion success

### Alerting
- **Critical**: PagerDuty integration
- **Warning**: Email notifications
- **Info**: Slack notifications

### Dashboards
- **Operations**: Infrastructure health
- **Business**: API usage and performance
- **Security**: Access patterns and threats

## Disaster Recovery

### Backup Strategy
- **Database**: Daily automated backups + point-in-time recovery
- **Application**: Docker images in ECR
- **Configuration**: Infrastructure as Code (Terraform/CloudFormation)

### Recovery Procedures
- **RTO**: 15 minutes (database restore)
- **RPO**: 1 hour (last backup)
- **Testing**: Monthly DR drills

## Compliance & Governance

### Data Protection
- **GDPR**: Data retention and deletion policies
- **Encryption**: End-to-end encryption
- **Access Control**: Principle of least privilege

### Audit & Logging
- **CloudTrail**: All API calls logged
- **CloudWatch**: Application and access logs
- **Retention**: 7 years for compliance

## Estimated Monthly Costs

### Development Environment
- ECS Fargate: $15/month
- RDS PostgreSQL: $25/month
- ElastiCache: $15/month
- ALB: $20/month
- **Total**: ~$75/month

### Production Environment
- ECS Fargate: $60/month
- RDS PostgreSQL: $100/month
- ElastiCache: $30/month
- ALB: $20/month
- CloudWatch: $20/month
- **Total**: ~$230/month

*Note: Costs are estimates and may vary based on actual usage patterns and AWS pricing changes.* 