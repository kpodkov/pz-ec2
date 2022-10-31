# pz-ec2

Project Zomboid Server hosted on an On-Demand EC2 instance, with a GitHub Action to start the server.

# Release Process
1. Clone. Make changes in a branch.
2. Run `make plan` locally to see if everything is as expected. 
    1. ⚠ Check `Makefile` for env vars.
3. If all good, push and make a PR.

# Starting the Server

The GitHub action is configured to be triggered manually. To start it:

1. Navigate to [Actions](https://github.com/kpodkov/pz-ec2/actions) page.
2. Select the `Start Zomboid Server` workflow.
3. Run the workflow for `Branch: master`
4. The serevr IP will is printed in the log of the `Start server` step.

# Checking userdata.sh logs
Connect to the EC2:

```shell
tail -f /var/log/cloud-init-output.log
```


# Follow server logs
Connect to the EC2:

```shell
journalctl -f -u zomboid.service
```


# Terraform

Set the following secrets for the repository:

- AWS_ACCESS_KEY_ID - your AWS access key associated with an IAM user or role.
- AWS_SECRET_ACCESS_KEY - your AWS  secret key associated with the access key.
- SERVER_PASSWORD - your AWS access key associated with an IAM user or role.

_Adapted from https://github.com/wahlfeld/valheim-on-aws repository_