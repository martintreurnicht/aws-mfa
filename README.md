# AWS-MFA

[![Code Climate](https://codeclimate.com/repos/542b7941e30ba06a6101ef2b/badges/25d9c28493f8b29398d0/gpa.svg)](https://codeclimate.com/repos/542b7941e30ba06a6101ef2b/feed)

## Introduction

`aws-mfa` prepares environment variables for commands that interact with AWS. It uses [AWS STS](http://docs.aws.amazon.com/cli/latest/reference/sts/index.html) to get temporary credentials. This is necessary if you have [MFA](https://aws.amazon.com/iam/details/mfa/) enabled on your account.

The first time you run `aws-mfa` it will request the ARN for your MFA device, which you can find under the "security credentials" tab for your user in the [IAM console](https://console.aws.amazon.com/iam/home?region=us-east-1#users). Next, it will prompt you for the 6-digit code from your MFA device. For the next 12 hours, `aws-mfa` will not prompt you for anything. After 12 hours, your temporary credentials expire, so `aws-mfa` will prompt you for the 6-digit code again.

## Usage

There are two ways you can use `aws-mfa`.

### Eval

The first is to use it to alter the environment of your current shell. To do this, run `eval $(aws-mfa)`. Now any command that uses the standard AWS environment variables should work.

### Wrapper

The second is to use it to alter the environment of a single invocation of a program. `aws-mfa` tries to execute its arguments. `aws-mfa aws` would run the aws cli, `aws-mfa kitchen` would run test-kitchen, and so on. You can safely setup an alias with `alias aws=aws-mfa aws`. With the alias, if you had set up autcompletion for `aws` it will still work.
