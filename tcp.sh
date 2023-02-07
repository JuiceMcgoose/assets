#!/bin/bash

# Bash script to apply iptables rules on open TCP ports for an array of IP addresses

# Define the array of IP addresses
ips=(192.168.1.1 192.168.1.2 192.168.1.3)

# Use the "awk" one-liner to get the list of listening TCP ports
ports=$(ss -tl | awk '/^LISTEN/ { split($4, a, ":"); print a[2]; }')

# Loop over the array of IP addresses
for ip in "${ips[@]}"; do
  # Apply iptables rule to block all incoming traffic to the given IP
  iptables -A INPUT -s $ip -j DROP

  # Loop over the list of listening TCP ports
  for port in $ports; do
    # Check if an iptables rule for the current IP and port already exists
    rule_exists=$(iptables -S | grep -c "^-A INPUT -s $ip -p tcp --dport $port -j ACCEPT")
    if [ $rule_exists -eq 0 ]; then
      # Apply iptables rule to allow incoming traffic to the given IP and port
      iptables -I INPUT -s $ip -p tcp --dport $port -j ACCEPT
    fi
  done
done

# Save the iptables rules
iptables-save

