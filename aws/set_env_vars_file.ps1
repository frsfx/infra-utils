# Creates a file that when sourced will set environment variables that are
# commonly needed on CloudFormation EC2 initialization
#
# Usage:
#   set_env_vars.ps1 -StackId arn:aws:cloudformation:us-east-1:237179673806:stack/SC-237179673806-pp-skslwogrplibk/4c472ab0-573f-11ea-8cef-0abf94ca9997
#
# Note: assumes the following are installed through choco:
# jq: https://chocolatey.org/packages/jq
# awscli: https://chocolatey.org/packages/awscli

# Get vars from flag or env var
Param(
    [String]$StackId = $env:STACK_ID
)
if(-not($StackId)) { Throw "-StackId is required" }

Function SetEnvVars() {
  $EC2_INSTANCE_IDENTITY_DOC_URI = "http://169.254.169.254/latest/dynamic/instance-identity/document"
  $AWS_REGION = (Invoke-WebRequest -Uri $EC2_INSTANCE_IDENTITY_DOC_URI -UseBasicParsing).Content | jq .region -r
  $EC2_METADATA_URI = "http://169.254.169.254/latest/meta-data"
  $EC2_INSTANCE_ID = (Invoke-WebRequest -Uri $EC2_METADATA_URI/instance-id -UseBasicParsing).Content
  $ROOT_DISK_ID = & aws.exe ec2 describe-volumes `
    --region $AWS_REGION `
    --filters Name=attachment.instance-id,Values=$EC2_INSTANCE_ID `
    --query Volumes[].VolumeId --out text
  $EC2_INSTANCE_TAGS = & aws.exe --region $AWS_REGION `
    ec2 describe-tags `
    --filters Name=resource-id,Values=$EC2_INSTANCE_ID

  Function ExtractTagValue([String] $KeyName) {
    $EC2_INSTANCE_TAGS | jq -j --arg KEYNAME "$KeyName" '.Tags[] | select(.Key == $KEYNAME).Value '
  }

  $DEPARTMENT = ExtractTagValue -KeyName Department
  $PROJECT = ExtractTagValue -KeyName Project
  $PROVISIONING_PRINCIPAL_ARN = ExtractTagValue -KeyName 'aws:servicecatalog:provisioningPrincipalArn'
  $OWNER_EMAIL = $PROVISIONING_PRINCIPAL_ARN -replace '.*\/'

  $FileString = @"
    `$env:AWS_REGION` = "$AWS_REGION"
    `$env:EC2_INSTANCE_ID` = "$EC2_INSTANCE_ID"
    `$env:ROOT_DISK_ID` = "$ROOT_DISK_ID"
    `$env:DEPARTMENT` = "$DEPARTMENT"
    `$env:PROJECT` = "$PROJECT"
    `$env:OWNER_EMAIL` = "$OWNER_EMAIL"
    `$env:STACK_ID` = "$StackId"
"@
  Set-Content -Path C:\scripts\instance_env_vars.ps1 -Value $FileString

}

$env:Path += ";$env:ProgramFiles\Amazon\AWSCLIV2"
$env:Path += ";C:\ProgramData\chocolatey\lib\jq\tools"

SetEnvVars