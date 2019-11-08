#!/usr/bin/env python3
import requests, ipaddress, argparse

# initiate the parser
parser = argparse.ArgumentParser(description='Determine if an IP belongs to AWS CIDRs and isolate the AWS Service')
parser.add_argument("--h", default=1, help="This is the 'a' variable")

aws_cidrs = requests.get('https://ip-ranges.amazonaws.com/ip-ranges.json').json()
ip4_ranges = aws_cidrs['prefixes']
ip6_ranges = aws_cidrs['ipv6_prefixes']
#amazon_ips = [item['ip_prefix'] for item in ip_ranges if item["service"] == "AMAZON"]
#ec2_ips = [item['ip_prefix'] for item in ip_ranges if item["service"] == "EC2"]

def match_cidr(ip_addr):
	if ip_addr.version == 4:
		for ip_range in ip4_ranges:
			if ip_addr in ipaddress.ip_network(ip_range['ip_prefix']):
				print (f'The IPv{ip_addr.version} Address belongs to the CIDR {ip_range["ip_prefix"]} and assocaited with {ip_range["service"]} service in region {ip_range["region"]}')
	if ip_addr.version == 6:
		for ip_range in ip6_ranges:
			if ip_addr in ipaddress.ip_network(ip_range['ipv6_prefix']):
				print (f'The IPv{ip_addr.version} Address belongs to the CIDR {ip_range["ipv6_prefix"]} and assocaited with {ip_range["service"]} service in region {ip_range["region"]}')

ip_addr = ipaddress.ip_address('52.93.28.142')
match_cidr(ip_addr)
ip_addr = ipaddress.ip_address('52.93.28.168')
match_cidr(ip_addr)
ip_addr = ipaddress.ip_address('54.165.96.65')
match_cidr(ip_addr)
ip_addr = ipaddress.ip_address('2600:1f18:d:6200:9e50:1045:4ff7:6785')
match_cidr(ip_addr)
ip_addr = ipaddress.ip_address('35.168.0.0')
match_cidr(ip_addr)