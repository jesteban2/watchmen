# How to use the AWS OpsWorks for Chef Automate Starter Kit

The AWS OpsWorks for Chef Automate Starter Kit is a zip file that starts you out with a simple example of a Chef repository.  The example repository is configured to work with an AWS OpsWorks for Chef Automate server. The repository includes a directory with an example cookbook that configures an *nginx web server* with a static HTML page, and a [`Policyfile.rb`](Policyfile.rb) file that defines the configuration to apply to nodes. It is recommended that you store this repository in a version control system such as Git, and treat it like source code.

This repository includes a [*site-cookbooks*](site-cookbooks/) folder, which contains the [`opsworks-webserver`](site-cookbooks/opsworks-webserver) cookbook, a "wrapper cookbook" that depends on the `nginx` cookbook from the [Chef Supermarket](https://supermarket.chef.io/cookbooks/nginx) website.

## Content of the Starter Kit

* [`site-cookbooks/`](site-cookbooks/) - Cookbooks that you create. Includes the OpsWorks web server example cookbook.
* [`Policyfile.rb`](Policyfile.rb) - Defines the cookbooks, dependencies, and attributes that become the policy for nodes.
* [`userdata.sh`](userdata.sh) and [`userdata.ps1`](userdata.ps1) - You can use `userdata` files to associate nodes automatically after provisioning a Chef Automate server. [`userdata.sh`](userdata.sh) is for bootstrapping Linux-based nodes, and [`userdata.ps1`](userdata.ps1) is for Windows-based nodes.
* [`.chef`](.chef/) is a hidden directory that contains a knife configuration file (knife.rb) and a secret authentication key (private.pem).
  * [`.chef/knife.rb`](.chef/knife.rb)
  * [`.chef/private.pem`](.chef/private.pem)
* [`.chef/ca_certs`](.chef/ca_certs) is a directory in [`.chef`](.chef/) that contains the certificate authorities (CAs) trusted by the Chef `knife` utility.  If you're using a server with a custom domain, you might need to add the PEM certificate of the root CA that signed your server's certificate chain, or your server PEM certificate if it is self-signed.

## Configuration

The [`knife.rb`](.chef/knife.rb) file is configured so that knife operations run against the AWS OpsWorks-managed Chef Automate server.

To get started, download and install the [Chef DK](https://downloads.chef.io/chef-dk). After installation, use the Chef `knife` utility to manage the Chef Automate server. For more information, see the [Chef documentation for knife](https://docs.chef.io/knife.html).

### Configure Knife to work with your custom certificate

You can skip this section if your custom certificate is signed by a root CA that is trusted by your operating system. Otherwise, you need to configure Knife to trust your Chef Automate server SSL certificate, as described in the following steps.

1. Run the command `knife ssl check`. If the results are similar to the following, you can skip the rest of this procedure.
    ```
    Connecting to host my-chef-automate-server.my-corp.com:443
    Successfully verified certificates from 'my-chef-automate-server.my-corp.com'
    ```

2. If you get an error message similar to the following, go on to step 3.
    ```
    Connecting to host my-chef-automate-server.my-corp.com:443
    ERROR: The SSL certificate of my-chef-automate-server.my-corp.com could not be verified.
    ...
    ```

3. Run `knife ssl fetch` to trust the certificates of your OpsWorks for Chef Automate server. Alternatively, you can manually copy the root CA PEM-formatted certificate of your server to the directory that is the value of `trusted_certs_dir` shown in the output of `knife ssl check`. By default, this directory is in `.chef/ca_certs/` in the Starter Kit. Your output should resemble the following:
   ```
    WARNING: Certificates from my-chef-automate-server.my-corp.com will be fetched and placed in your trusted_cert
    directory (/Users/username/starterkit/.chef/../.chef/ca_certs).

    Knife has no means to verify these are the correct certificates. You should
    verify the authenticity of these certificates after downloading.

    Adding certificate for my-chef-automate-server in /Users/users/starterkit/.chef/../.chef/ca_certs/servv-aqtswxu20swzkjgz.crt
    Adding certificate for MyCorp_Root_CA in /Users/users/starterkit/.chef/../.chef/ca_certs/MyCorp_Root_CA.crt
   ```

4. Run `knife ssl check` again. Your output should resemble the following:
   ```
    Connecting to host my-chef-automate-server.my-corp.com:443
    Successfully verified certificates from 'my-chef-automate-server.my-corp.com'
   ```
Now you can use Knife with your Chef Automate server.

# Quick-start example

In this example, you learn how to use Chef to provision a node. The following instructions install the chef-client agent that is configured to run every 30 minutes, the [`opsworks-webserver`](site-cookbooks/opsworks-webserver) cookbook, and the `Audit` cookbook to run compliance checks on your node.

## Cookbooks

A cookbook is a Chef concept that defines your configurations as code. We use cookbooks to specify the desired configuration of nodes. For this example, we use three cookbooks to configure a Chef managed node with nginx installed, and to set up continuous Chef Compliance scans by using the `Audit` cookbook.

### Chef Client cookbook

The `chef-client` cookbook configures the Chef client agent software on each node that you connect to your Chef server. To learn more about this cookbook, see [Chef Client Cookbook](https://supermarket.chef.io/cookbooks/chef-client) in the Chef Supermarket.

### opsworks-webserver Cookbook

The [`opsworks-webserver`](site-cookbooks/opsworks-webserver) cookbook includes a static HTML website, and depends on/wraps the [`nginx`](https://supermarket.chef.io/cookbooks/nginx) cookbook provided by the Chef community's [Chef Supermarket](https://supermarket.chef.io/cookbooks/nginx). There, you can download the `nginx` cookbook to install and configure the popular nginx web server. You can overwrite configurations and customize existing cookbooks (like nginx) by wrapping them in your own custom cookbook (like the [`opsworks-webserver`](site-cookbooks/opsworks-webserver) wrapper cookbook). To overwrite attributes, you specify your desired values in the [`attributes/default.rb`](site-cookbooks/opsworks-webserver/attributes/default.rb) file.

## Using Policyfile.rb to manage your cookbooks

`Policyfile.rb` lets you specify the names and versions of cookbooks and recipes that you want to apply to your environment [(learn more)](https://docs.chef.io/policyfile.html). `Policyfile.rb` manages your cookbooks and their dependencies. It downloads a cookbook into local storage. The Starter Kit contains a [`Policyfile.rb`](Policyfile.rb) that sets up an nginx web server, and Chef Compliance by using the `audit` Cookbook.

* Use a text editor to open the [`Policyfile.rb`](Policyfile.rb) and review the cookbooks that we use in this example. By following this guide, you install the `chef-client` cookbook, the [`opsworks-webserver`](site-cookbooks/opsworks-webserver) wrapper cookbook that depends on nginx, and the `audit` cookbook for compliance scans. Your `Policyfile.rb` specifies the following run-list:

```
run_list  'chef-client', 'opsworks-webserver', 'audit'
```

It also references cookbooks from [Chef's supermarket](https://supermarket.chef.io/), and the [`opsworks-webserver`](site-cookbooks/opsworks-webserver) cookbook that is included in this Starter Kit:

```
# Specify a custom source for a single cookbook
cookbook 'opsworks-webserver', path: 'site-cookbooks/opsworks-webserver'
```

## Chef Compliance with the Audit cookbook (Optional)

With [Chef Compliance](https://www.chef.io/solutions/compliance/), you can validate that your nodes are compliant against specified profiles (for example, profiles from the [Center for Internet Security, or CIS](https://www.cisecurity.org/)). In our example, we use the Audit cookbook to specify the profile, and run a compliance check in every Chef client run. The Audit cookbook is required and configured in the [`Policyfile.rb`](Policyfile.rb) file.

### Prepare your AWS OpsWorks for Chef Automate server for compliance

Your AWS OpsWorks for Chef Automate server comes with over 100 ready-to-use profiles. To make them available for compliance scans, install them by using the Chef Automate dashboard. Sign in to your Chef Automate dashboard, and choose **Asset Store -> Available**. To install a profile, choose the profile (for example, the *DevSec SSH Baseline* profile), and then choose **Get**.

The Audit cookbook downloads specified profiles from the Chef Automate server, and reports the result of compliance scans on every `chef-client` run.

OpsWorks for Chef Automate creates an admin user by default. You can create your own user (for example, a user that manages only your compliance profiles) and create new profiles for that user. For more information, see the [Chef Users](https://docs.chef.io/delivery_users_and_roles.html) documentation.  After you install profiles, they are shown in the **Profiles** tab of the Chef Automate dashboard.

The [`Policyfile.rb`](Policyfile.rb) in your Starter Kit shows that the Audit cookbook specifies the `ssh-baseline` profile.

```
# Define audit cookbook attributes
default['audit']['reporter'] = 'chef-server-automate'
default['audit']['profiles']['DevSec SSH Baseline']['compliance'] = 'admin/ssh-baseline'
```

## Installing and uploading cookbooks

1. Download and install the cookbooks listed in Policyfile.rb.

`chef install`

1. Push the policy `opsworks-demo`, as defined in [`Policyfile.rb`](Policyfile.rb), to your server.

`chef push opsworks-demo`

1. Verify the installation of your policy. Run the following command.

`chef show-policy`

The results should resemble the following:

```
opsworks-demo-webserver
=======================
* opsworks-demo:  ec0fe46314
```


## Attaching and configuring your first node

AWS OpsWorks for Chef Automate bootstraps nodes through a userdata script that handles the authorization of nodes, and executes your first Chef run. To connect your first node to the AWS OpsWorks for Chef Automate server, use the **`userdata.sh`** script that is included in this Starter Kit. It uses the AWS OpsWorks `AssociateNode` API to connect a node to your server.

### Set up IAM authorization

Before you get started, create an AWS Identity and Access Management (IAM) role to use as your EC2 instance profile. The following AWS CLI command launches an AWS CloudFormation stack that creates an IAM role for you named `myOpsWorksChefAutomateInstanceprofile`.

```
aws cloudformation --region <region> create-stack \
--stack-name myOpsWorksChefAutomateInstanceprofile \
--template-url https://s3.amazonaws.com/opsworks-cm-us-east-1-prod-default-assets/misc/opsworks-cm-nodes-roles.yaml \
--capabilities CAPABILITY_IAM
```

### Specify your node policy
The userdata is ready to use for the `opsworks-demo` policy you uploaded in the preceding section. Edit the `JSON_ATTRIBUTES` section to use a different policy in your **`userdata.sh`** script.

```
if [ -z $RUN_LIST ]; then
  (cat <<-JSON
    {
      "name": "${NODE_NAME}",
      "chef_environment": "${NODE_ENVIRONMENT}",
      "policy_name": "opsworks-demo-webserver",
      "policy_group": "opsworks-demo"
    }
JSON
) | sed 's/: ""/: null/g' > /etc/chef/client-attributes.json
fi
```

**Important:**  Remember, your policy must be pushed to the server with the `chef push` command in the preceding section before you can reference it in your userdata.

### Specify the URL of your Chef Automate server root certificate authority (CA)
If your server is using a custom domain and certificate, you might need to edit the ROOT_CA_URL variable with a public URL that you can use to get the root CA PEM-formatted certificate of your server. The following AWS CLI commands upload your root CA to an S3 bucket, and generate a pre-signed URL that you can use for one hour.
1. Upload the root CA PEM-formatted certificate to S3.
```
aws s3 cp [ROOT_CA_PEM_FILE_PATH] s3://[YOUR_BUCKET_NAME]/
```
2. Generate a pre-signed URL that you can use for one hour to download the root CA.
```
aws s3 presign s3://[YOUR_BUCKET_NAME]/[ROOT_CA_PEM_FILE_NAME] --expires-in 3600
```
3. Edit the variable `ROOT_CA_URL` in the userdata script with the value of the pre-signed URL.

### Connect your first node

The easiest way to create a new node is to use the [Amazon EC2 Launch Wizard](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/launching-instance.html). Choose an Amazon Linux AMI. In Step 3: **Configure Instance Details**, choose `myOpsWorksChefAutomateInstanceprofile` as your IAM role. In the **Advanced Details** section of the launch wizard, upload the **[`userdata.sh`](userdata.sh)** script.

You don't have to change anything for Step 4 and 5. Proceed to Step 6.

In Step 6, choose the appropriate rules to open ports. For example, open port numbers 443 and 80 for a web server.

Choose **Review**, and then choose **Launch** to proceed to the final Step 7. When your new node starts, it executes the `RUN_LIST` section of your **[`userdata.sh`](userdata.sh)** script.

For more information, see the [AWS OpsWorks for Chef Automate user guide](https://docs.aws.amazon.com/opsworks/latest/userguide/opscm-unattend-assoc.html).

### Alternative: Attach an Amazon EC2 instance to the Chef Automate server using knife bootstrap

1. Bootstrap a new Amazon EC2 instance.

```
knife bootstrap <IP address or public DNS name of the Amazon EC2 instance> \
        --identity-file <path to your ssh key file> \
        --ssh-user ec2-user \
        --sudo \
        --node-name <chef node name> \
        --policy-group opsworks-demo \
        --policy-name opsworks-demo-webserver
```

For example:

```
knife bootstrap ec2-1-234-56-789.<region>.compute.amazonaws.com \
        --ssh-user ec2-user \
        --identity-file ~/.ssh/id_rsa.pem \
        --sudo \
        --node-name opsworks-demo-webserver \
        --policy-group opsworks-demo \
        --policy-name opsworks-demo-webserver
```

1. Show the new node.

```
knife node show <instance name>
```

It might be more convenient to use the Chef Automate dashboard. The link to your dashboard is in the format https://*your_server_name*-*random*.*region*.opsworks-cm.io. In the Chef Automate dashboard, you can view your nodes, their configuration, and compliance evaluation results.

## Making your first node compliant

When you follow the preceding example, you see compliance violations in the Chef Automate dashboard's Compliance tab, because the *DevSec SSH Baseline* profile's security expectations are not yet met. The DevSec Hardening Framework (a community-powered project) provides cookbooks to fix these violations.

Do the following to meet security requirements for the *DevSec SSH Baseline* profile.

1. Using a text editor, append the `ssh-hardening` cookbook to the run list of your Policyfile.rb. Your Policyfile.rb's run_list should match the following:

```
run_list  'chef-client', 'opsworks-webserver', 'audit', **'ssh-hardening'**
```

2. Update [`Policyfile.rb`](Policyfile.rb), and push it to your Chef Automate server.

```
chef update Policyfile.rb
chef push opsworks-demo
```

3. Nodes that are associated with the `opsworks-demo` policy update the run list automatically, and apply the `ssh-hardening` cookbook on the next `chef-client` run.

Because you are using the `chef-client` cookbook, your node checks in at regular intervals (by default, every 30 minutes). On the next check-in, the `ssh-hardening` cookbook runs, and helps improve node security to meet the *DevSec SSH Baseline* profile's standards.

## Learn more about configuration management with Chef Automate

Visit the [Learn Chef tutorial](https://learn.chef.io/tutorials/manage-a-node/opsworks/) website and the [AWS OpsWorks for Chef Automate documentation](https://docs.aws.amazon.com/opsworks/latest/userguide/welcome_opscm.html) to learn more about using AWS OpsWorks for Chef Automate.

## Learn more about Compliance with Chef Automate

Visit the [Learn Compliance](https://learn.chef.io/tracks/integrated-compliance#/) and [Learn Compliance Automation](https://learn.chef.io/tracks/compliance-automation#/) websites to learn more about using Compliance in Chef Automate.
