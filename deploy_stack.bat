set REGION=us-east-1
set STACK_NAME=Pila-Ubuntu22-04
set TEMPLATE_FILE=parameters.yaml
set TAGS=Name=Stack-AWS-CLI

aws cloudformation deploy ^
    --template-file "%TEMPLATE_FILE%" ^
    --stack-name "%STACK_NAME%" ^
    --region "%REGION%" ^
    --no-fail-on-empty-changeset