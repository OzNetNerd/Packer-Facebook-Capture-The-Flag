TEMPLATE_FILENAME?='configs/cfn.yml'

.PHONY: validate
validate:
	@aws cloudformation validate-template --template-body file://${TEMPLATE_FILENAME}

.PHONY: start-ctf
start-ctf:
	@aws cloudformation create-stack --stack-name ${CFN_STACK_NAME} \
	--template-body file://${TEMPLATE_FILENAME} \
	--parameters \
	ParameterKey=Ec2KeyName,ParameterValue=${SSH_KEY_NAME} \
	ParameterKey=SingleNodeAmi,ParameterValue=${SINGLE_NODE_AMI_ID}
	@aws cloudformation wait stack-create-complete --stack-name ${CFN_STACK_NAME}; \
	GAME_ADDRESS="$(shell aws cloudformation describe-stacks --stack-name ${CFN_STACK_NAME} --query 'Stacks[0].Outputs[?OutputKey==`GameAddress`].OutputValue' --output text)"
	make get-game-address

.PHONY: update-ctf
update-ctf:
	@aws cloudformation update-stack --stack-name ${CFN_STACK_NAME} \
	--template-body file://${TEMPLATE_FILENAME} \
	--parameters \
	ParameterKey=Ec2KeyName,ParameterValue=${SSH_KEY_NAME} \
	ParameterKey=SingleNodeAmi,ParameterValue=${SINGLE_NODE_AMI_ID}
	@aws cloudformation wait stack-update-complete --stack-name ${CFN_STACK_NAME}; \
	make get-game-address

.PHONY: get-game-address
get-game-address:
	GAME_ADDRESS="$(shell aws cloudformation describe-stacks --stack-name ${CFN_STACK_NAME} --query 'Stacks[0].Outputs[?OutputKey==`GameAddress`].OutputValue' --output text)"

.PHONY: stop-ctf
stop-ctf:
	@aws cloudformation delete-stack --stack-name ${CFN_STACK_NAME}
	@aws cloudformation wait stack-delete-complete --stack-name ${CFN_STACK_NAME}