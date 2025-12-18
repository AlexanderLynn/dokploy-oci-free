#!/bin/bash

# Add ubuntu SSH authorized keys to the root user
mkdir -p /root/.ssh
cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/
chown root:root /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Add ubuntu user to sudoers
echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# OpenSSH
apt install -y openssh-server
systemctl status sshd

# Permit root login
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart sshd

# Install Dokploy with retry (up to 3 minutes, every 15 seconds)
DOKPLOY_INSTALL_URL="https://dokploy.com/install.sh"
MAX_ATTEMPTS=12
ATTEMPT=1
until (curl -fsSL "${DOKPLOY_INSTALL_URL}" | sh); do
  if [ "${ATTEMPT}" -ge "${MAX_ATTEMPTS}" ]; then
    echo "Dokploy install failed after ${MAX_ATTEMPTS} attempts."
    exit 1
  fi
  echo "Dokploy install failed (attempt ${ATTEMPT}/${MAX_ATTEMPTS}). Retrying in 15 seconds..."
  ATTEMPT=$((ATTEMPT + 1))
  sleep 15
done

# Allow Docker Swarm traffic
ufw allow 80,443,3000,996,7946,4789,2377/tcp
ufw allow 7946,4789,2377/udp

iptables -I INPUT 1 -p tcp --dport 2377 -j ACCEPT
iptables -I INPUT 1 -p udp --dport 7946 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 7946 -j ACCEPT
iptables -I INPUT 1 -p udp --dport 4789 -j ACCEPT

# Reorder FORWARD chain rules:
# Remove the default REJECT rule (ignore error if not found)
iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited || true
# Append the REJECT rule at the end so that Docker rules can be matched first
iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited

netfilter-persistent save