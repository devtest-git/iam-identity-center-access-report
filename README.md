# AWS IAM Identity Center (SSO) Assignments Export Tool

This PowerShell script extracts **AWS IAM Identity Center (SSO) account assignments** across all AWS Organizations accounts and exports them into a CSV file.

It helps in auditing:
- Permission Set assignments
- Users and Groups access across accounts
- AWS SSO / IAM Identity Center governance

---

## 🚀 What This Script Does

The script:

- Retrieves all AWS Organizations accounts
- Fetches IAM Identity Center instance details
- Lists all Permission Sets provisioned to each account
- Extracts account assignments (Users & Groups)
- Resolves principal names from Identity Store
- Handles deleted users/groups safely
- Exports everything into a CSV file

---

## 📊 Output

Generates a CSV file (default: `SSO-Assignments.csv`) with:

| Column | Description |
|--------|-------------|
| AccountName | AWS Account Name |
| PermissionSet | IAM Identity Center Permission Set |
| Principal | User or Group Name |
| Type | USER or GROUP |

---

## ⚙️ Parameters

| Parameter | Description | Default |
|----------|-------------|--------|
| `OutputFile` | Output CSV file name | `SSO-Assignments.csv` |
| `ProfileName` | AWS CLI named profile | (empty) |
| `Region` | AWS region for IAM Identity Center | `ap-south-1` |

---

## 🧰 Prerequisites

### 1. AWS PowerShell Modules
Install required modules:

```powershell
Install-Module AWS.Tools.Installer -Force
Install-AWSToolsModule AWS.Tools.IdentityStore, AWS.Tools.SSOAdmin, AWS.Tools.Organizations -Force
```

---

### 2. AWS Permissions Required

The IAM role/user must have:

- `organizations:ListAccounts`
- `sso-admin:ListPermissionSets`
- `sso-admin:ListAccountAssignments`
- `sso-admin:DescribePermissionSet`
- `identitystore:DescribeUser`
- `identitystore:DescribeGroup`

---

### 3. AWS CLI Profile (Optional)

If using a profile:

```powershell
Set-AWSCredential -ProfileName my-profile
```

---

## 🚀 Usage

### Run with default settings:

```powershell
.\script.ps1
```

---

### Specify output file:

```powershell
.\script.ps1 -OutputFile "assignments.csv"
```

---

### Use AWS profile:

```powershell
.\script.ps1 -ProfileName "dev-profile"
```

---

### Set region:

```powershell
.\script.ps1 -Region "ap-south-1"
```

---

## 🧠 How It Works

### Step 1: Fetch AWS Accounts
Uses AWS Organizations to list all accounts.

### Step 2: Get IAM Identity Center Instance
Retrieves:
- Instance ARN
- Identity Store ID

### Step 3: Loop Through Accounts
For each AWS account:
- Fetch permission sets
- Fetch assignments per permission set

### Step 4: Resolve Principals
- Converts User IDs → usernames
- Converts Group IDs → group names
- Handles deleted users/groups gracefully

### Step 5: Export Results
Saves all data into a structured CSV file.

---

## ⚠️ Error Handling

The script handles:

- Deleted users → marked as `DELETED_USER_<id>`
- Deleted groups → marked as `DELETED_GROUP_<id>`
- API failures → marked as `ERROR_*`

---

## 🎯 Use Cases

- AWS IAM Identity Center audit
- Security compliance reporting
- Access review (who has access to what account)
- Permission set governance
- Enterprise IAM visibility

---

## 📁 Output Example

```
AccountName,PermissionSet,Principal,Type
Prod-Account,AdminAccess,john.doe,USER
Dev-Account,ReadOnly,dev-team,GROUP
```
