set REGION=us-east-1
set STACK_NAME=Pila-Ubuntu22-04

aws cloudformation delete-stack ^
    --stack-name "%STACK_NAME%" ^
    --region "%REGION%"