#!/usr/bin/env bash
# Seeds LocalStack with resources needed before running terraform plan/apply.
# Safe: uses fake credentials and routes to localhost:4566 only.

set -euo pipefail

LOCALSTACK_URL="http://localhost:4566"

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export AWS_CONFIG_FILE=/dev/null
export AWS_SHARED_CREDENTIALS_FILE=/dev/null

AWS="aws --endpoint-url=$LOCALSTACK_URL"

AMI_NAME="ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240101"

echo "==> Checking if mock Ubuntu AMI already exists..."
EXISTING_AMI=$($AWS ec2 describe-images \
  --owners self \
  --filters "Name=name,Values=$AMI_NAME" \
  --query "Images[0].ImageId" \
  --output text)

if [ "$EXISTING_AMI" != "None" ] && [ -n "$EXISTING_AMI" ]; then
  echo "    AMI already exists: $EXISTING_AMI — skipping registration."
  AMI_ID="$EXISTING_AMI"
else
  echo "==> Registering mock Ubuntu AMI in LocalStack..."
  AMI_ID=$($AWS ec2 register-image \
    --name "$AMI_NAME" \
    --root-device-name "/dev/sda1" \
    --architecture x86_64 \
    --virtualization-type hvm \
    --region us-east-1 \
    --query "ImageId" \
    --output text)
  echo "    AMI registered: $AMI_ID"
fi
echo ""
echo "==> Verifying registered AMIs..."
$AWS ec2 describe-images \
  --owners self \
  --query "Images[*].{ID:ImageId,Name:Name,Arch:Architecture}" \
  --output table \
  --no-cli-pager

echo "==> Checking existing EC2 instances..."
$AWS ec2 describe-instances \
  --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,State:State.Name,AMI:ImageId,Name:Tags[?Key=='Name']|[0].Value}" \
  --output table \
  --no-cli-pager

echo "==> LocalStack is ready. You can now run:"
echo "    terraform plan"
echo "    terraform plan -var instance_type=t2.large"
