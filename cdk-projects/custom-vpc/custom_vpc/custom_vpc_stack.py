from aws_cdk import (
    aws_ec2 as ec2,
    # Duration,
    Stack,
    # aws_sqs as sqs,
)
from constructs import Construct

class CustomVpcStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # The code that defines your stack goes here
        vpc=ec2.Vpc(
            self="Integral_vpc",
            cidr="10.20.0.0/16",
            max_azs=2,
            nat_gateways=0,
            subnet_configuration=[
                ec2.SubnetConfiguration(name="public", cidr_mask=24, subnet_type=ec2.SubnetType.PUBLIC),
                ec2.SubnetConfiguration(name="Private", cidr_mask=24, subnet_type=ec2.SubnetType.ISOLATED)
                ])

        # example resource
        # queue = sqs.Queue(
        #     self, "CustomVpcQueue",
        #     visibility_timeout=Duration.seconds(300),
        # )
