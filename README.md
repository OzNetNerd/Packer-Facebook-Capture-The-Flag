# About

Create and deploy immutable [FBCTF servers.](https://github.com/facebook/fbctf)

The scripts in this repo perform two tasks:
1. Create immutable images using Packer (see [Build](#Build)).
2. Deploy the immutable images using CloudFormation (see [Deploy](#Deploy)).

Each directory (`single-node` and `multi-node`) contain `build` and `deploy` sub directories. As explained in the subsequent sections of this page, a  `Makefile` exists within each of these subdirectories. This file is used to execute the corresponding task.

To get started, you must [Build](#Build) your image(s) and then [Deploy](#Deploy) them.  


# Build

1. Set up your AWS credentials in one of the following ways:
	1. Set the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_DEFAULT_REGION` environment variables.
	2. Create an [AWS Named Profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html). You will need to configure a default profile or set the `AWS_DEFAULT_PROFILE` environment variable.

2. Download Packer:

    ```
    cd /tmp
    wget https://releases.hashicorp.com/packer/1.4.1/packer_1.4.1_linux_amd64.zip
    unzip packer_1.4.1_linux_amd64.zip
    sudo mv packer /usr/bin
    ```        

3. Navigate to the build directory which pertains to the node(s) you want (i.e `single-node/build` or `multi-node/build`) and execute the build command:

    ```
    cd multi-node/build
    make build-all
    ```
    
    **Note:** If you run the multi-node build and the mysql node fails with the following error: `Build 'amazon-ebs' errored: Script exited with non-zero exit status: 100.Allowed exit codes are: [0]` - continue to re-run the build until it is successful:
    
    ```
    make build-mysql
    ```

# Deploy

1. Retrieve the AMI ID from the Packer output, or from the AWS console.

2. Navigate to the deploy directory which pertains to the node(s) you want (i.e `single-node/build` or `multi-node/build`) and execute the deploy command:

    ```
    cd single-node/deploy
    make \
    SINGLE_NODE_AMI_ID="<AMI_ID>" \
    CFN_STACK_NAME="SingleCTFNode" \
    SSH_KEY_NAME="<key_path>" \
    start-ctf
    ```
    
    or

    ```
    cd multi-node/deploy
    make \
    MYSQL_AMI_ID="<AMI_ID>" \
    MEMCACHED_AMI_ID="<AMI_ID>" \
    HHVM_AMI_ID="<AMI_ID>" \
    NGINX_AMI_ID="<AMI_ID>" \
    CFN_STACK_NAME="<AMI_ID>" \
    SSH_KEY_NAME="<key_path>" \
    start-ctf
    ```

3. (Optional) [Reset password.](https://github.com/facebook/fbctf/wiki/FAQ#how-do-i-reset-the-admin-password-for-the-platform)
	
	**Note:** The below command is for Single Node deployments only. See the [SSH Tunnel](#SSH-Tunnel) section for Multi Node deployment instructions.
	
	```
	ssh ubuntu@<public_ip> -i ~/.ssh/<key_path>
	cd fbctf/
	source ./extra/lib.sh
	set_password <new_password> ctf ctf fbctf $PWD
	```

4. When done, stop the game:

	```
	make CFN_STACK_NAME="SingleCTFNode" stop-ctf
	```
	
	or
	
	```
	make CFN_STACK_NAME="MultiCTFNodes" stop-ctf
	```

## Multiple Deployments

To run multiple deployments simultaneously, simply run the deployment command multiple times using unique `CFN_STACK_NAME` variables. Using an existing stack name will result in a CloudFormation execution error.

## Resources

Each deployment creates:
* 1 x VPC
* 2 x Subnets
* 1 x Internet Gateway
* 2 x Security Groups
* 1 x EIP
* 1 to 4 Instances (default: t2.large)

# Multi-Node Additional Notes
## SSH Tunnel

To change the `admin` password, you must SSH to the MySQL server. As it does not have a public IP address, you must tunnel to it through the Nginx server. All of the commands you need are provided below:

```
cat >> ~/.ssh/config << EOF
Host nginx-server
  User ubuntu
  HostName <nginx-server-ip>
  IdentityFile <key_path>

Host mysql-server
  User ubuntu
  Hostname 10.0.0.103
  IdentityFile <key_path>
  ForwardAgent yes
  ProxyCommand ssh nginx-server -W %h:%p
EOF

ssh mysql-server
cd fbctf/
source ./extra/lib.sh
set_password <new_password> ctf ctf fbctf $PWD
```
 

## Internal Addressing

When running a multi-node setup, the servers are addressed in the following manner:

* MySQL: 10.0.0.103
* Memcached: 10.0.0.102
* HHVM: 10.0.0.101
* Nginx: DHCP