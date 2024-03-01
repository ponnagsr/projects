---------------------------Terraform Project---------------------------------------------

#Created a VPC(Virtual Private Cloud)

#Created a Public Subnet(by connecting the subnet to internet via internet gateway)

#Connected the subnet by routing the traffic to internet gateway

#Used routetable to route the traffic from Subent-->Internet gateway----> Internet\

#Created a security group and allowed SSH and HTTP traffic through 22 & 80 ports.

#Created an EC2 instance in the given configuration.

#Using file provisioner copied the application file from the local to remote path(EC2 instance)

#Using remote-exec provisioner installed necessary packages and deployed the application.
