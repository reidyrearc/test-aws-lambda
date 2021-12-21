#Acquire the script
data "archive_file" "zip" {
    type = "zip"
    source_file = "${path.module}/code/hello_lambda.py"
    output_path = "hello_lambda.zip"
}
#Get trust policy giving the service principal lambda.amazonaws.com 
#permission to call the AWS Security Token Service AssumeRole action. 
data "aws_iam_policy_document" "policy" {
    statement {
        sid = ""
        effect = "Allow"

        principals {
            identifiers = ["lambda.amazonaws.com"]
            type = "Service"
        }

        actions = ["sts:AssumeRole"]
    }
}

#Create role and attach the trust policy to the role
resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"
    assume_role_policy = "${data.aws_iam_policy_document.policy.json}"
}

#create lambda named hello_lambda, where role is ARN of function's execution role defined above
#handler is the function entrypoint - lambda_handler
resource "aws_lambda_function" "lambda" {
    function_name = "hello_lambda"

    filename = "${data.archive_file.zip.output_path}"
    source_code_hash = "${data.archive_file.zip.output_base64sha256}"

    role = "${aws_iam_role.iam_for_lambda.arn}"
    handler = "hello_lambda.lambda_handler"
    runtime = "python3.6"

    environment {
        variables = {
            greeting = "Hello"
        }
    }

}