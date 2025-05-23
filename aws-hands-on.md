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

<details>
<summary>Configure AWS CLI Credentials</summary>
<br />

**Objective:**
Set up your AWS CLI with Access Key, Secret Key, default region, and output format.

```sh
# Run AWS CLI configuration wizard
aws configure

# Example input prompts:
# AWS Access Key ID [****************]: new-access-key-id
# AWS Secret Access Key [****************]: new-secret-access-key
# Default region name [*******]: new-region
# Default output format [json]: json
```

**Notes:**

* Keep your Access Key and Secret Access Key confidential.
* Choose the AWS region closest to your deployment.
* `json` is the recommended default output format for easier parsing and automation.

</details>

<details>
<summary>Setup VPC, Subnet, Internet Gateway, Route Table, and Security Group using AWS CLI</summary>
<br />

Why use `10.0.0.0/24` for your VPC?

* CIDR block defines the IP address range for your VPC (Virtual Private Cloud).
* `10.0.0.0/24` means the network includes IPs from 10.0.0.0 to 10.0.0.255 (256 addresses).
* The /24 is the subnet mask, specifying how many IPs you get (here, 256).
* This range is part of the private IP address space (RFC 1918), so it’s not routable on the public internet — ideal for internal networking in AWS.
* Choosing 10.0.0.0/24 gives you a small private network to launch EC2 instances and other resources without conflicting with public IPs.

To list your VPCs with their CIDR blocks:
```sh
aws ec2 describe-vpcs --query "Vpcs[].{VpcId:VpcId, CIDR:CidrBlock}" --output table
```

### Step 1: Create a VPC

Create a new VPC with the CIDR block `10.0.0.0/24` and get the VPC ID.

```sh
aws ec2 create-vpc \
  --cidr-block 10.0.0.0/24 \
  --query Vpc.VpcId \
  --output text
```

### Step 2: List all VPCs

Check existing VPCs to verify your new VPC.

```sh
aws ec2 describe-vpcs
```

### Step 3: Create a Subnet

Create a subnet in your VPC in the availability zone `ap-northeast-1a`.

```sh
aws ec2 create-subnet \
  --vpc-id <your-vpc-id> \
  --cidr-block 10.0.0.0/24 \
  --availability-zone ap-northeast-1a \
  --query Subnet.SubnetId \
  --output text
```

### Step 4: List Subnets in your VPC

Verify the subnet created under your VPC.

```sh
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<your-vpc-id>"
```

### Step 5: Create an Internet Gateway

Create an internet gateway and get its ID.

```sh
aws ec2 create-internet-gateway \
  --query InternetGateway.InternetGatewayId \
  --output text
```

### Step 6: Attach Internet Gateway to VPC

```sh
aws ec2 attach-internet-gateway \
  --vpc-id <your-vpc-id> \
  --internet-gateway-id <your-internet-gateway-id>
```

### Step 7: Create a Route Table

Create a route table for your VPC.

```sh
aws ec2 create-route-table \
  --vpc-id <your-vpc-id> \
  --query RouteTable.RouteTableId \
  --output text
```

### Step 8: Create a Route to the Internet Gateway

Add a default route for all traffic to the internet gateway.

```sh
aws ec2 create-route \
  --route-table-id <your-route-table-id> \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id <your-internet-gateway-id>
```

### Step 9: Associate Route Table with Subnet

Associate the route table with your subnet.

```sh
aws ec2 associate-route-table \
  --route-table-id <your-route-table-id> \
  --subnet-id <your-subnet-id>
```

### Step 10: Create a Security Group

Create a security group within your VPC.

```sh
aws ec2 create-security-group \
  --group-name nodejs-app-sg \
  --description "Nodejs App Security group" \
  --vpc-id <your-vpc-id>
```

### Step 11: Authorize SSH Access

Allow inbound SSH (TCP port 22) only from your IP address.

```sh
aws ec2 authorize-security-group-ingress \
  --group-id <your-security-group-id> \
  --protocol tcp \
  --port 22 \
  --cidr 139.135.33.37/32
```
---

**Notes:**

* Replace placeholders like `<your-vpc-id>` with actual IDs from previous command outputs.
* Use your real IP address in the `authorize-security-group-ingress` command.
* Keep your AWS CLI configured with `aws configure` before running these commands.

---

### Check Available Availability Zones

List availability zones for your region.

```sh
aws ec2 describe-availability-zones \
  --region ap-northeast-1 \
  --query "AvailabilityZones[].ZoneName" \
  --output text
```

</details>

<details>
<summary>Launch EC2 Instance</summary>
<br />

**Objective:**  
Create a key pair, launch an EC2 instance with public IP, and check instance status.

```sh
# 1. Create a key pair and save it to a PEM file
aws ec2 create-key-pair \
  --key-name NodeJsAppKey \
  --query 'KeyMaterial' \
  --output text > NodeJsAppKey.pem

# 2. Set correct permissions on the PEM file
chmod 400 NodeJsAppKey.pem

# 3. Run EC2 instance with public IP
aws ec2 run-instances \
  --image-id ami-0c1638aa3xxxxxx \
  --count 1 \
  --instance-type t2.micro \
  --subnet-id subnet-001fc0b77xxxxxx \
  --key-name NodeJsAppKey \
  --security-group-ids sg-083bcd7axxxxxx \
  --associate-public-ip-address

# 4. Check instance state and public IP
aws ec2 describe-instances \
  --instance-id i-0a78744f9xxxxxxx \
  --query "Reservations[*].Instances[*].{State:State.Name,Address:PublicIpAddress}"
````

**Notes:**

* Ensure `DNS hostnames` are enabled in your VPC to get a public DNS.
* Replace the `instance-id` with the correct ID after instance launch.

</details>

<details>
  <summary>SSH into the server and install Docker</summary>

```bash
# Get the public IP address of your EC2 instance
aws ec2 describe-instances --query "Reservations[].Instances[].PublicIpAddress" --output text

# Connect to your EC2 instance
ssh -i ~/.ssh/NodeJsAppKey.pem ec2-user@54.168.49.98

# Update packages
sudo yum update -y

# Install Docker
sudo yum install docker -y

# Start Docker daemon
sudo systemctl start docker

# Switch to root user
sudo -i

# Add ec2-user to docker group to run docker without sudo
usermod -aG docker ec2-user
````

</details>



