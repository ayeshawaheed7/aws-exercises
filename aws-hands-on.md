<details>
<summary>Create IAM User, Group & Assign Permissions</summary>
<br />

**Objective:**
Set up a new IAM user with CLI and console access, assign group-based permissions for EC2 operations, and optionally manage policies directly for the user.

---

### Step 1: Identity Check – "Who am I?"

```sh
# Check AWS CLI config
aws configure list

# Confirm current identity
aws sts get-caller-identity
```

---

### Step 2: Create User & Group

```sh
# Create IAM user
aws iam create-user --user-name ayesha

# Create group "devops"
aws iam create-group --group-name devops

# Add user to the group
aws iam add-user-to-group --user-name ayesha --group-name devops

# Verify group membership
aws iam get-group --group-name devops
```

---

### Step 3: Attach EC2 Permissions to Group

```sh
# Find EC2 Full Access policy ARN
aws iam list-policies --query "Policies[?PolicyName=='AmazonEC2FullAccess'].Arn" --output text

# Attach policy to group
aws iam attach-group-policy \
  --group-name devops \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

# Confirm attached policies
aws iam list-attached-group-policies --group-name devops
```

---

### Step 4: Enable Console Login

```sh
# Create console login for user
aws iam create-login-profile \
  --user-name ayesha \
  --password 'xxxxxx!' \
  --password-reset-required

# Find policy ARN for "IAMUserChangePassword"
aws iam list-policies --query "Policies[?PolicyName=='IAMUserChangePassword'].Arn" --output text

# Attach policy to group (or user if needed)
aws iam attach-group-policy \
  --group-name devops \
  --policy-arn arn:aws:iam::aws:policy/IAMUserChangePassword

# Confirm attached policies
aws iam list-attached-group-policies --group-name devops
```

---

### Step 5: Enable CLI Access (Access Keys)

```sh
# Generate access key and save securely
aws iam create-access-key --user-name ayesha > key.txt
```

---

### Step 6: Switch to This User Temporarily

```sh
# Temporarily export user credentials
export AWS_ACCESS_KEY_ID=xxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxx

# Confirm identity switch
aws sts get-caller-identity
```

---

### Step 7: Move Password Change Policy from Group to User

```sh
# Detach from group
aws iam detach-group-policy \
  --group-name devops \
  --policy-arn arn:aws:iam::aws:policy/IAMUserChangePassword

# Attach directly to user
aws iam attach-user-policy \
  --user-name ayesha \
  --policy-arn arn:aws:iam::aws:policy/IAMUserChangePassword

# Confirm user policy attachment
aws iam list-attached-user-policies --user-name ayesha
```

---

</details>
