# terraform-lambda-metric-Cloudwatch-Alarm
Terraform code for the **Cloudwatch Alarm** resources.

Assuming the **Lambda function** and metric filters has already been created in the architecture, this is the terraform code to create the alarm.

A ```.tfvars``` file should also included with the following code:

```ruby
lambda_function_name        = "monitored-function-name"
target_lambda_function_name = "target-function-name"
alarm_email                 = "your-email@example.com"
```

It will not be included due to the ```gitignore``` as good practice.
