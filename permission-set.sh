#!/bin/bash
 
# Configuration
INSTANCE_ARN="arn:aws:sso:::instance/ssoins-6595a2abb9c47364"
OUTPUT_FILE="aws_identity_center_report.csv"
NEXT_TOKEN=""
SERIAL_NO=1
 
# 1. Create the CSV Header
echo "S.no,Permission set,AWS managed policy,Customer managed policy,Inline policy" > $OUTPUT_FILE
 
echo "Starting export of 166 records to $OUTPUT_FILE..."
echo "This will take a few minutes. Progress will be shown below."
echo "-----------------------------------------------------------"
 
# 2. Loop to handle all 166 permission sets (pagination)
while : ; do
    if [ -z "$NEXT_TOKEN" ]; then
        RESPONSE=$(aws sso-admin list-permission-sets --instance-arn $INSTANCE_ARN --output json)
    else
        RESPONSE=$(aws sso-admin list-permission-sets --instance-arn $INSTANCE_ARN --next-token "$NEXT_TOKEN" --output json)
    fi
 
    PS_ARNS=$(echo $RESPONSE | jq -r '.PermissionSets[]')
 
    for PS_ARN in $PS_ARNS; do
        # Get Permission Set Name
        NAME=$(aws sso-admin describe-permission-set --instance-arn $INSTANCE_ARN --permission-set-arn $PS_ARN --query 'PermissionSet.Name' --output text)
        # Get AWS Managed Policies (joined by semicolon ;)
        MANAGED=$(aws sso-admin list-managed-policies-in-permission-set --instance-arn $INSTANCE_ARN --permission-set-arn $PS_ARN --query 'AttachedManagedPolicies[].Name' --output text | tr '\n' ';' | sed 's/;$//')
        # Get Customer Managed Policies (joined by semicolon ;)
        CUSTOMER=$(aws sso-admin list-customer-managed-policy-references-in-permission-set --instance-arn $INSTANCE_ARN --permission-set-arn $PS_ARN --query 'CustomerManagedPolicyReferences[].Name' --output text | tr '\n' ';' | sed 's/;$//')
        # Get Inline Policy (Cleaned: remove newlines and escape quotes for Excel compatibility)
        INLINE=$(aws sso-admin get-inline-policy-for-permission-set --instance-arn $INSTANCE_ARN --permission-set-arn $PS_ARN --query 'InlinePolicy' --output text | tr -d '\n\r' | sed 's/"/""/g')
 
        # 3. Append Row to CSV File
        echo "$SERIAL_NO,\"$NAME\",\"$MANAGED\",\"$CUSTOMER\",\"$INLINE\"" >> $OUTPUT_FILE
        echo "[$SERIAL_NO/166] Processed: $NAME"
        ((SERIAL_NO++))
    done
 
    # Check for next page
    NEXT_TOKEN=$(echo $RESPONSE | jq -r '.NextToken // empty')
    [ -z "$NEXT_TOKEN" ] && break
done
 
echo "-----------------------------------------------------------"
echo "COMPLETED: All records written to $OUTPUT_FILE"