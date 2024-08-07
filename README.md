Provisions:

- vpc
- 1 subnet for public networking
- internet gateway
- 1 route table for public subnet
- ingress/egress rules to control traffic between ec2 instance
- security group rules to accept ssh and http connections
- ec2 instance

It deploys simple nginx server - just go to the public url of the EC2 instance.

It is mainly used for testing.
