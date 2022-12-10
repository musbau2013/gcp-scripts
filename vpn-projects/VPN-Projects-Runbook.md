## gcloud commands to setup vpn gateways
- https://cloud.google.com/sdk/gcloud/reference/beta/compute/vpn-gateways/describe

## Cloud VPN project implementation
1. Deploying the vpn source network vpc-demo
`gcloud compute networks create vpc-demo --subnet-mode custom`
`gcloud components update`

1.1 Creating subnet1 for vpc-demo
`gcloud beta compute networks subnets create vpc-demo-subnet1 \
--network vpc-demo \
--range 10.1.1.0/24 \
--region us-central1`

1.2. Creating subnet2 for vpc-demo
gcloud beta compute networks subnets create vpc-demo-subnet2 \
--network vpc-demo --range 10.2.1.0/24 --region us-east1

1.3 Creating Firewall rules to allow internal traffic to vpc-demo

`gcloud compute firewall-rules create vpc-demo-allow-internal \
  --network vpc-demo \
  --allow tcp:0-65535,udp:0-65535,icmp \
  --source-ranges 10.0.0.0/8`

1.4 Creating firewall rule to allow port 22 and icmp

`gcloud compute firewall-rules create vpc-demo-allow-ssh-icmp \
 --network vpc-demo \
 --allow tcp:22,icmp`

2. Deploying the vpn Target network on-prem
`gcloud compute networks create on-prem --subnet-mode custom`

2.1 Creating on-prem subnet1
`gcloud beta compute networks subnets create on-prem-subnet1 \
--network on-prem --range 192.168.1.0/24 --region us-central1`

2.2 Creating onprem subnet2
gcloud beta compute networks subnets create on-prem-subnet2 \
--network on-prem --range 192.168.2.0/24 --region us-east1

2.3 Creating firewall rules to allow internal communication within on-prem network
`gcloud compute firewall-rules create on-prem-allow-internal \
  --network on-prem \
  --allow tcp:0-65535,udp:0-65535,icmp \
  --source-ranges 192.168.0.0/16`
2.4 Creating firewall rule to allow port 22 and icmp for on-prem network
`gcloud compute firewall-rules create on-prem-allow-ssh-icmp \
    --network on-prem \
    --allow tcp:22,icmp`

3.0 Defining the source(cloud) HA-VPN gateway
`gcloud beta compute vpn-gateways create vpc-demo-vpn-gw1 --network vpc-demo --region us-central1`
3.1 Defining the Target(on-prem) HA-VPN gateway
`gcloud beta compute vpn-gateways create on-prem-vpn-gw1 --network on-prem --region us-central1`

4.0 Describe details about VPN gateways
`gcloud beta compute vpn-gateways describe vpc-demo-vpn-gw1 --region us-central1`
4.1 gcloud command to list VPN gateways
`gcloud beta compute vpn-gateways list`
5.0 Creating the cloud Router for source/cloud network
`gcloud compute routers create vpc-demo-router1 \
    --region us-central1 \
    --network vpc-demo \
    --asn 65001`
## Check document here 
-  https://cloud.google.com/network-connectivity/docs/network-connectivity-center/concepts/asn-requirements

5.1 Creating the cloud Router for target/on-prem network
`gcloud compute routers create on-prem-router1 \
    --region us-central1 \
    --network on-prem \
    --asn 65002`

### Creating HA-VPN Tunnels
6.0 Creating HA-VPN-Tunnel-1 for the vpc-demo-vpn-gw1
`gcloud beta compute vpn-tunnels create vpc-demo-tunnel0 \
    --peer-gcp-gateway on-prem-vpn-gw1 \
    --region us-central1 \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router vpc-demo-router1 \
    --vpn-gateway vpc-demo-vpn-gw1 \
    --interface 0`

6.1 Creating HA-VPN-Tunnel-2 for the vpc-demo-vpn-gw1
`gcloud beta compute vpn-tunnels create vpc-demo-tunnel1 \
    --peer-gcp-gateway on-prem-vpn-gw1 \
    --region us-central1 \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router vpc-demo-router1 \
    --vpn-gateway vpc-demo-vpn-gw1 \
    --interface 1`
7.0 creating vpn-tunnel 1 for on-prem gateway - on-prem-vpn-gw1
`gcloud beta compute vpn-tunnels create on-prem-tunnel0 \
    --peer-gcp-gateway vpc-demo-vpn-gw1 \
    --region us-central1 \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router on-prem-router1 \
    --vpn-gateway on-prem-vpn-gw1 \
    --interface 0`
7.1 creating vpn-tunnel 2 for on-prem gateway - on-prem-vpn-gw1
`gcloud beta compute vpn-tunnels create on-prem-tunnel1 \
    --peer-gcp-gateway vpc-demo-vpn-gw1 \
    --region us-central1 \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router on-prem-router1 \
    --vpn-gateway on-prem-vpn-gw1 \
    --interface 1`
### Creating Border gateway protocols (BGP) for the HA-VPN
8.0 Creating BGP session interface for VPC-demo VPC, vpc-demo-tunnel0
`gcloud compute routers add-interface vpc-demo-router1 \
    --interface-name if-tunnel0-to-on-prem \
    --ip-address 169.254.0.1 \
    --mask-length 30 \
    --vpn-tunnel vpc-demo-tunnel0 \
    --region us-central1`
9.0 Adding BGP peer for vpc-demo-tunnel0
`gcloud compute routers add-bgp-peer vpc-demo-router1 \
    --peer-name bgp-on-prem-tunnel0 \
    --interface if-tunnel0-to-on-prem \
    --peer-ip-address 169.254.0.2 \
    --peer-asn 65002 \
    --region us-central1`
9.1 Creating BGP session interface for VPC-demo VPC, vpc-demo-tunnel1
`gcloud compute routers add-interface vpc-demo-router1 \
    --interface-name if-tunnel1-to-on-prem \
    --ip-address 169.254.1.1 \
    --mask-length 30 \
    --vpn-tunnel vpc-demo-tunnel1 \
    --region us-central1`

9.2 Adding BGP peer for vpc-demo-tunnel1
`gcloud compute routers add-interface vpc-demo-router1 \
    --interface-name if-tunnel1-to-on-prem \
    --ip-address 169.254.1.1 \
    --mask-length 30 \
    --vpn-tunnel vpc-demo-tunnel1 \
    --region us-central1`

9.3 Creating BGP session interface for VPC-demo VPC, on-prem-tunnel0
`gcloud compute routers add-interface on-prem-router1 \
    --interface-name if-tunnel0-to-vpc-demo \
    --ip-address 169.254.0.2 \
    --mask-length 30 \
    --vpn-tunnel on-prem-tunnel0 \
    --region us-central1`
9.4 Adding BGP peer for on-prem-tunnel0
`gcloud compute routers add-bgp-peer on-prem-router1 \
    --peer-name bgp-vpc-demo-tunnel0 \
    --interface if-tunnel0-to-vpc-demo \
    --peer-ip-address 169.254.0.1 \
    --peer-asn 65001 \
    --region us-central1`

9.5 Creating BGP session interface for VPC-demo VPC, on-prem-tunnel1
`gcloud compute routers add-interface  on-prem-router1 \
    --interface-name if-tunnel1-to-vpc-demo \
    --ip-address 169.254.1.2 \
    --mask-length 30 \
    --vpn-tunnel on-prem-tunnel1 \
    --region us-central1`
9.5 Adding BGP peer for on-prem-tunnel1
`gcloud compute routers add-bgp-peer  on-prem-router1 \
    --peer-name bgp-vpc-demo-tunnel1 \
    --interface if-tunnel1-to-vpc-demo \
    --peer-ip-address 169.254.1.1 \
    --peer-asn 65001 \
    --region us-central1`
