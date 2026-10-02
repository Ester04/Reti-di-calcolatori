#Each node in the network needs some parameters for operation
#• IP address
#• NetMask
#• DNS server address
#• Gateway address

@h1
ip link set dev eth0 up # activate eth0 interface
arping -0Bi eth0 # generate arp requests
#ARPING 255.255.255.255
#Timeout
#Timeout
@h2
ip link set dev eth0 up # activate eth0 interface
tcpdump -ni eth0 arp # sniff arp traffic on eth0
#tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
#listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
#15:45:20.071611 ARP, Request who-has 255.255.255.255 tell 0.0.0.0, length 215:45:21.080772 ARP, Request who-has 255.255.255.255 tell 0.0.0.0, length 2Note: Use tcpdump -e to view also MAC addresses

@h2
ip addr add dev eth0 192.168.1.2 # Configure eth0 interface
@h1
arping -0i eth0 192.168.1.2 # Test if h2 answers to ARP queries
#42 bytes from 02:04:06:0f:47:dc (192.168.1.2): index=0 time=1.011 sec
@h2
tcpdump -ni eth0 arp 
#tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
#listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
#08:04:55.933331 ARP, Request who-has 192.168.1.2 tell 0.0.0.0, length 28
#08:04:55.933365 ARP, Reply 192.168.1.2 is-at 02:04:06:0f:47:dc, length 28



#CONFIGURING NETWORK INTERFACES CON IL FILE /etc/network/interfaces
iface <iface> inet <mode>
#mode can be
 #   • dhcp: automatic interface initialization with the dhcp protocol
 #   • loopback: local interface (127.0.0.1)
 #   • static: additional parameters to configure the interface
#Static configuration of an interface
 #   • address: IP address of the interface (e.g., 192.168.X.Y) – can also use CIDR 
 #     notation to include netmask (e.g., 192.168.X.Y/24)
 #   • netmask: (e.g., 255.255.255.0)
 #   • network: network address (e.g., 192.168.X.0)
 #   • broadcast: broadcast address (e.g., 192.168.X.255)
 #   • gateway: default gateway, to be used if the network configuration requires it

#ESEMPIO DI CONFIGURAZIONE STATICO DI UN INTERFACCIA
#Configuration file /etc/network/interfaces
auto eth0
iface eth0 inet static
address 192.168.1.1
netmask 255.255.255.0
network 192.168.1.0
broadcast 192.168.1.255
gateway 192.168.1.254

#To activate the interface by configuring it using configuration files, use the ifup and
ifdown <iface> #Turns off the interface
ifup <iface> #Turns on the interface

#Examples
ifdown eth0
ifup eth0
ifdown eth0 && ifup eth0
ifdown -a && ifup -a #-a option to act on all configured interfaces
#NOTE: If there are errors in the configuration files, the ifup command will fail



#CHECKING THE CONFIGURATION OF AN INTERFACE
ifconfig [-a] [<iface>] # -a mostra anche le inattive, senza nulla solo le attive, <iface> una specifica
ip addr show [dev <iface>] # Show the configuration of the specified interface, or all interfaces if none specified
#NOTA: ip addr show is the recommended
#To check the status of an interface, do not check the configuration file!

#CHECKING CONNECTIVITY
ping [-c <count>] <IP address> # Send ICMP echo requests to the specified IP address, with an optional count of requests to send
ping <hostname> # Send ICMP echo requests to the specified hostname, which will be resolved to an IP address
arping -i <iface> <IP address> # Send ARP requests to the specified IP address on the specified interface

#Tabelle
arp # Display the ARP table, which shows the mapping of IP addresses to MAC addresses on the local network
ip neigh # Display the neighbor table, which shows the mapping of IP addresses to MAC addresses on the local network, similar to the arp command
#Note: ip neigh is the recommended command

#IMPORTANTE
#If something doesn’t work:
#   • Do not check immediatly the interfaces configuration file
#   • Use appropriate commands to check the system status
#   • Only if we understand what status we are in we can figure out what went wrong

#RESTARTING NETWORK SERVICES
service networking restart # Restart network services (Debian/Ubuntu)
systemctl restart network # Restart network services (Red Hat/CentOS)

#ASSEGNO NOME A INDIRIZZO IP
#To assign a hostname to an IP address, edit the /etc/hosts file and add
<IP address> <hostname>
#Example:
192.168.1.1 h1


#CONFIGURARE INTERFACCE SENZA FILE DI CONFIGURAZIONE (meglio usare i file di configurazione)
ip addr {add,change,replace} dev <iface> <ip-address> #La differenza tra add, change e replace è che add aggiunge un indirizzo, change cambia un indirizzo esistente e replace sostituisce un indirizzo esistente o lo aggiunge se non esiste

#Enable network interface
ifconfig <iface> up
ip link set dev <iface> up
#Disable network interface
ifconfig <iface> down
ip link set dev <iface> down
#Disable and deconfigure network interface
ifconfig <iface> 0 down
ip addr del <address> dev <iface>



#In general, when a host has more than one interface connected to the same
#Ethernet broadcast domain (cioè lo stesso switch), it is often preferable
#to set more restrictive rules regarding the management of the ARP protocol
@h1
sysctl -w net.ipv4.conf.all.arp_announce=0 # Announce only local IP addresses
sysctl -w net.ipv4.conf.all.arp_ignore=1 # Ignore ARP requests for IP addresses not configured on the interface
#NOTA: Queste regole servono per evitare che un host risponda a richieste ARP per indirizzi IP che non sono configurati sulle sue interfacce,
#riducendo così il rischio di conflitti di indirizzi IP e migliorando la sicurezza della rete.



#-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  



#VLANs
#Le Virtual LANs consentono di creare reti locali virtuali separate all'interno di una stessa infrastruttura fisica.
#Segmentano il traffico di rete: migliorando la sicurezza e ottimizzando l'utilizzo delle risorse di rete.

#Access link: usato per connettere un singolo dispositivo a una VLAN specifica. Tutto il traffico proveniente da questo link appartiene a quella VLAN.
#Trunk link: usato per trasportare traffico di più VLAN tra switch o tra switch e router. I frame trasportati su un trunk link contengono informazioni sulla VLAN
#Hybrid link: combina le caratteristiche di access e trunk link, permettendo di trasportare traffico di più VLAN ma anche di connettere dispositivi che non supportano il tagging VLAN.


#Trunk VLAN in Linux
ip link add link <physical_if> <vlan_if> type vlan id <vlan_id> # Create a VLAN interface on a physical interface
ip link del <vlan_if> # Delete a VLAN interface
grep <VID> /proc/net/vlan/<vlan_if> #Check the VLAN interface configuration (mostra le informazioni relative alla VLAN specificata)
#Note: the interface created with the previous commands will be temporary, cioè sarà rimosso dopo un reboot. Però può avere un nome proprio (vlan_if)

#esempio:
ip link add link eth0 pippo type vlan id 10
grep VID /proc/net/vlan/pippo
#pippo VID: 10 REORDER_HDR: 1 dev->priv_flags: 1

#Permanente: modificare il file /etc/network/interfaces aggiungendo le seguenti righe:
auto <physical_if>.<vlan_id>
iface <physical_if>.<vlan_id> inet static
    address <ip_address>
    netmask <netmask>
    gateway <ip_addr_gateway>



# Main vde_switch commands we will use
#   - port: port management
#   - vlan: VLAN management
#   - hash: Management of the switch's hash table
# If unsure "help <cmd_name>" command is your friend!

#Configuring VLANs on VDE switch
vlan/create <vlan_number> # Create a new VLAN with the specified number
port/setvlan <port_number> <vlan_number> # Assign a port to a specific VLAN (untagged = 1 vlan)
vlan/addport <vlan_number> <port_number> # Add a port to an existing VLAN (tagged = + vlan) 

#Altri esempi di comandi per la gestione delle VLAN su un VDE switch:
vlan/delete <vlan_number> # Delete a VLAN with the specified number
port/remove <port_number> <vlan_number> # Remove a port from a specific VLAN
vlan/print # Print the current VLAN configuration and the ports assigned to each VLAN (trunk se tagged, access se untagged)
hash/print # Print the current hash table of the switch, showing MAC address to port mappings



#-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  



#ROUTING
#Per comunicare con reti diverse

#ip forwording:
sysctl net.ipv4.ip_forward #Check if IP forwarding is enabled (1) or disabled (0)
sysctl -w net.ipv4.ip_forward=1 #Enable IP forwarding (temporary, will be reset after reboot)


#ATTIVA ROUTING TRA LE INTERFACCE DI UN HOST
#To make it PERMANENT, edit /etc/sysctl.conf and set:
net.ipv4.ip_forward=1

#restart networking service to apply changes oppure:
sysctl -p /etc/sysctl.conf # Apply changes from sysctl.conf without restarting networking service

#CONTROLLO DELLA TABELLA DI ROUTING
route -n # DISPLAY the routing table in numeric format (IP addresses instead of hostnames)
ip route show # DISPLAY the routing table using the ip command (recommended)

#CONFIGURAZIONE
#To an host
ip route add <ip/32> via <gwaddr> #Add a route to a specific IP address via a gateway
ip route add <ip/32> dev <ethX> #In some cases you need to specify the interface

#To a subnet
ip route add <subnet>/<mask> via <gwaddr> #Add a route to a specific subnet via a gateway

#Default route
ip route add default via <gwaddr> #Add a default route via a gateway    

#PERMANENTEƒ
#Act on the interface stanzas in /etc/network/interfaces:
#Example
iface eth0 inet static
    address 192.168.1.1
    netmask 255.255.255.0
    gateway 192.168.1.254
    post-up ip route add 192.168.2.0/24 via 192.168.1.253 #Add a route to the specific subnet via a gateway


#ESEMPIO COMPLETO NON-permanente (h2 fa routing tra le due reti):
#Enable IP Forwarding
@H2: sysctl -w net.ipv4.ip_forward=1
#Host-based routing
@H1: ip route add 192.168.2.1/32 via 192.168.1.254
@H3: ip route add 192.168.1.1/32 via 192.168.2.254
#Subnet-based routing
@H1: ip route add 192.168.2.0/24 via 192.168.1.254
@H3: ip route add 192.168.1.0/24 via 192.168.2.254
#Default gateway
@H1: ip route add default via 192.168.1.254
@H3: ip route add default via 192.168.2.254


#NOTA: On GW you should not use the default gateway rule



#-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  


#DHCP: Protocollo di configurazione dinamica dell'host
#Statically managing configurations on each node is problematic: rischio conflitti e dispendioso a livello di tempo.
#Quindi usiamo una configurazione dinamica: un nodo si connette e non sa come configurarsi --> invia una richiesta al server DHCP --> il server risponde

#NOTA:
#• There must be only one DHCP server on the network
#• The server machine must be reachable at H2N level from every node in the network


#ESEMPIO con host3 con MAC fisso e host1 e host2 con pooled address + server
#CONFIGURAZIONE
@server
#File /etc/network/interfaces:
auto eth0
iface eth0 inet static
    address 192.168.1.254 #deve avere ip fisso

@host1@host2
#File /etc/network/interfaces:
auto eth0
iface eth0 inet dhcp


@host3
#File /etc/network/interfaces:
auto eth0
iface eth0 inet dhcp
    hwaddress ether 02:04:06:11:22:33 #OUI 02:04:06 is used by marionnet


@server
#File /etc/dnsmasq.conf
no-resolv # don't look for other nameservers
read-ethers # read /etc/ethers file
interface=eth0 # network interface for DHCP
domain=reti.org # network domain name
# Some DHCP options:
dhcp-option=3,192.168.1.254 #3 = default GW
#Or: dhcp-option=option:router,192.168.1.254
dhcp-option=6,192.168.1.254 #6 = DNS server
#Or: dhcp-option=option:dns-server,192.168.1.254
dhcp-range=192.168.1.10,192.168.1.15,1h # dhcp range (min-max IP), include lease time
dhcp-host=02:04:06:11:22:33,host3,192.168.1.3,1h # static config, not /etc/ethers + /etc/hosts
address=/www.hackerz.com/192.168.1.1 # override address (can also use /etc/hosts: 192.168.1.1 www.hackerz.com)

#File /etc/ethers (solo se non si usa dhcp-host in /etc/dnsmasq.conf)
02:04:06:11:22:33 192.168.1.3

#File /etc/hosts (solo se non si usa dhcp-host in /etc/dnsmasq.conf)
192.168.1.254 server server.reti.org
192.168.1.3 host3 host3.reti.org

#Terminale
systemctl enable dnsmasq #Start the server at power on
service dnsmasq start #Launch the server
------------------

#TESTING
@host1@host2@host3
ip addr show dev eth0 #Check IP address
ip route show dev eth0 #Check routing rules

@server
#tcpdump -ni eth0 udp port 67 or udp port 68 #Monitor DHCP traffic on eth0 (NON NECESSARIO)
cat /etc/resolv.conf #Check if the DNS server is configured (should contain the IP address of the server)
nslookup host3 #Resolve the hostname host3
nslookup client3.reti.org #Resolve the hostname client3.reti.org
nslookup www.hackerz.com #Resolve the hostname www.hackerz.com
------------------



#SERVER SU LAN DIVERSA: Usiamo un relay agent (DHCP relay agent) per inoltrare le richieste DHCP tra reti diverse
#Il relay agent riceve le richieste DHCP dai client e le inoltra al server DHCP, e viceversa.

#ESEMPIO
#• Server: DHCP and DNS server
#• Relay: DHCP relay and gateway
#• Client1, Client2: client with pooled addresses
#• Client3: client with fixed address
#N.B. Clients uguali a prima


#CONFIGURAZIONE
@client1@client2@client3
#Unchanged from previous example

@server
#File /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.168.2.254
    post-up ip route add 192.168.1.0/24 via 192.168.2.1


@relay
#File /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.168.1.254
auto eth1
iface eth1 inet static
    address 192.168.2.1

#File /etc/sysctl.conf
net.ipv4.ip_forward=1 #Enable IP forwarding

#File /etc/dnsmasq.conf
port=0 # Disable DNS server functionality
interface=eth0
dhcp-relay=192.168.1.254,192.168.2.254,eth1 # Syntax: dhcp-relay=<local address>,<server address>,[<interface>]
# 1. The local address on the subnet where clients are (giaddr)
# 2. The IP of the actual DHCP server
# 3. The interface used to reach that server

#Terminale
systemctl enable dnsmasq 
service dnsmasq starts


@server
#File /etc/dnsmasq.conf
no-resolv
interface=eth0
domain=reti.org
dhcp-option=option:router,192.168.1.254 # Gateway is Relay
dhcp-option=option:dns-server,192.168.2.254 # DNS server is Server
dhcp-range=192.168.1.10,192.168.1.15,1h #1h = lease time, il range rappresenta gli indirizzi che il server può assegnare ai client
dhcp-host=02:04:06:11:22:33,client3,192.168.1.3,1h #dhcp-host serve a assegnare un indirizzo IP statico a un client specifico in base al suo indirizzo MAC. In questo caso, il client con l'indirizzo MAC 02:04:06:11:22:33 riceverà sempre l'indirizzo IP. 

#Terminale
systemctl enable dnsmasq 
service dnsmasq start
------------------

#TESTING: uguale a prima, ma con relay agent in mezzo (volendo: tcpdump -ni eth0 udp port 67 or udp port 68)
------------------


#TANTE NETWORK E RELAY AGENT
#ESEMPIO: 2 reti con 2 relay agent e 1 server DHCP
#• Server: DHCP and DNS server
#• Relay1, Relay2: DHCP relay and gateway
#• Client1, Client2: client with pooled addresses

#N.B. Molti cambiamenti sono minimi, ci concentriamo solo su DHCP server
@server
#File /etc/dnsmasq.conf
no-resolv
interface=eth0
domain=reti.org
# Configuration for subnet 1
dhcp-range=set:subnet1,192.168.1.10,192.168.1.15,255.255.255.0,12h #A differenza di prima viene definito un tag per ogni subnet
dhcp-option=tag:subnet1,option:router,192.168.1.254 #riusiamo il tag definito per le altre opzioni
# Configuration for subnet 2
dhcp-range=set:subnet2,192.168.2.10,192.168.2.15,255.255.255.0,12h #Sempre con tag
dhcp-option=tag:subnet2,option:router,192.168.2.254
# Common DNs server
dhcp-option=option:dns-server,192.168.2.254
#+ altre opzioni uguali a prima (dhcp-host, address, ecc.)

#Testing e altre configurazioni uguali a prima
------------------



#-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  



#TRAFFIC SHAPING: Limitare la banda disponibile per un host o una rete.
#Può essere implementato a livello di host o a livello di switch/router.

#Usi principali:
#• Priorità del traffico (es. VoIP, streaming video)
#• Minimizzazione della latenza
#• Gestione della larghezza di banda
#• Equità tra i diversi servizi

#Usa slide



#-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  




#IPTABLES: is a command-line application that runs in userspace. Works at kernel level.
#Through iptables it is possible to write access control rules and to associate them
#to one of the hooks made available by netfilter


#Netfilter hooks:
1. NF_IP_PREROUTING: #intercepts packets received from a NIC BEFORE the routing logic
#(Destination NAT)
2. NF_IP_LOCAL_IN: #intercepts all packets received by local processes AFTER the routing logic
#(personal firewall)
3. NF_IP_FORWARD: #intercepts all packets forwarded by the device 
#(enterprise firewall)
4. NF_IP_POSTROUTING: #intercepts all packets that are exiting through a network interface
#(Source NAT)
5. NF_IP_LOCAL_OUT: #intercepts all packets sent by local processes BEFORE the routing logic
#(personal firewall)

#Netfilter actions:
• NF_ACCEPT: #the packet continues its journey through the kernel as if nothing happened
• NF_DROP: #the packet is destroyed (it does not exist in the kernel anymore, the associated data structures are deallocated)
• NF_STOLEN: #it “kidnaps” the packet and makes it available for arbitrary manipulations that will happen in kernel space
• NF_QUEUE: #it “kidnaps” the packet and makes it available for arbitrary manipulations that will happen in user space
• NF_REPEAT: #it makes the packet transit again in the same hook

#It is possible to act on 5 different tables, ma ne usiamo solo 2:
• FILTER: #for implementing firewall rules. It operates on:
#NF_IP_LOCAL_IN, NF_IP_LOCAL_OUT, NF_IP_FORWARD 
#→ Default chains: INPUT, OUTPUT, FORWARD
• NAT: #for implementing Source NAT, Masquerading, Destination NAT (port forwarding). It operates on:
#NF_IP_PREROUTING, NNF_IP_LOCAL_OUT, NF_IP_POSTROUTING
#→ Default chains: PREROUTING, OUTPUT, POSTROUTING

#N.B. Chain is a sequence of rules that are applied to packets. Each chain is associated with a specific hook in the kernel.

#   Default-chain    Netfilter-hook
#    INPUT           NF_IP_LOCAL_IN
#    OUTPUT          NF_IP_LOCAL_OUT
#    FORWARD         NF_IP_FORWARD
#    PREROUTING      NF IP_PREROUTING
#    POSTROUTING     NF_IP_POSTROUTING



#   FILTERING

#Each chain has its DEFAULT policy. It can be set by using the option -P.
iptables [-t <table>] -P <chain> {ACCEPT|DROP}

#Note: if -t <table> is omitted, iptables works on the default filter table.

#Example: 
iptables -t filter -P INPUT DROP #set a default DROP policy on the INPUT chain of the FILTER table
iptables -t filter -P FORWARD ACCEPT #set a default ACCEPT policy on the FORWARD chain of the FILTER table
#Equivalent:  iptables -P FORWARD ACCEPT



#GENERIC (per pacchetto specifico) structure of a filtering rule:
iptables [-t <table>] -A <chain> <matching criteria> -j <action>

#-A <chain> #Append the rule to the end of the specified chain
#<matching criteria> #Specifica le condizioni che deve avere un pacchetto per applicargli l'azione associata alla regola 
                    #Es. -s <source IP>, -d <destination IP>, -p <protocol>, --sport <source port>, --dport <destination port>
#-j <action> #Specifica l'azione da applicare al pacchetto

<action>:
- ACCEPT: #the packet is accepted and continues its journey through the kernel
- DROP: #the packet is dropped and does not continue its journey through the kernel
- REJECT: #the packet is dropped and an ICMP error message is sent to the sender
- QUEUE: #the packet is sent to user space for further processing
- LOG: #the packet information is logged, then will be analyzed by following rules (if any)
- chain-created-by-user: #the packet is sent to a user-defined chain (used like action) for further processing

#Examples of simple static rules:
iptables -t filter -A INPUT -s 192.168.1.0/24 -j DROP   #Drop all packets coming from the network
iptables -t filter -A FORWARD -p tcp -i eth+ -d 192.168.1.0/24 --dport 80 -j ACCEPT  #Allow all TCP packets coming from any interface and destined to the network on port 80 (HTTP)
iptables -t filter -A INPUT -p icmp -s !192.168.1.0/16 --icmp-type echo-request -j DROP  #Drop all ICMP echo-request packets coming from any source except the network



#State module: allows to create rules that take into account the state of the connection to which the packet belongs.
# - NEW: the packet is starting a new connection (e.g., a TCP packet with the SYN flag set)
# - ESTABLISHED: the packet belongs to an already established connection (e.g., a TCP packet with the ACK flag set)
# - RELATED: the packet is starting a new connection, but it is related to an already established connection (e.g., FTP data connection)

#Examples of dynamic rules:
#Manage all network traffic related to active FTP.
#Management of the control connection (similar rules are sufficient for all protocols that use a single TCP connection)
iptables -t filter -A FORWARD -p tcp --dport ftp -m state --state NEW,ESTABLISHED -j ACCEPT     #Accept all TCP packets destined to the FTP port (21) that are either starting a new connection or belong to an already established connection
iptables -t filter -A FORWARD -p tcp --sport ftp -m state --state ESTABLISHED -j ACCEPT     #Accept all TCP packets coming from the FTP port (21) that belong to an already established connection
#Management of the data transfer connection
iptables -t filter -A FORWARD -p tcp --sport ftp-data -m state --state RELATED,ESTABLISHED -j ACCEPT    #Accept all TCP packets coming from the FTP data port (20) that are either starting a new connection related or belong to an already established connection
iptables -t filter -A FORWARD -p tcp --dport ftp-data -m state --state ESTABLISHED -j ACCEPT        #Accept all TCP packets destined to the FTP data port (20) that belong to an already established connection


#Let us consider the module limit: used to limit the rate of packets that match a rule. It is useful to prevent DoS attacks or to limit the rate of certain types of traffic.
#Example: limit the rate of ICMP packets to 4 per minute with a burst of 3.
iptables -t filter -A FORWARD -i eth+ -p icmp -m limit --limit 4/minute --limit-burst 3 -j ACCEPT
#If there is no other rules accepting additional ICMP packets, and if the default policy is DROP, other ICMP packets are dropped.



#user-created chains
#In all tables it is possible to define new chains (option -N)

#Esempi:
iptables -t filter -N catena_tcp    #Create a new chain called catena_tcp in the filter table
iptables -t filter -A FORWARD -p tcp -j catena_tcp  #Append a rule to the FORWARD chain of the filter table that sends all TCP packets to the catena_tcp chain for further processing
iptables -t filter -N internet_to_lan1  #Create a new chain called internet_to_lan1 in the filter table
iptables -t filter -A FORWARD -i eth1 -o eth2 -j internet_to_lan1   #Append a rule to the FORWARD chain of the filter table that sends all packets coming from eth1 and going to eth2 to the internet_to_lan1 chain for further processing


#UTILI (esempi):
iptables -t filter -L #List all rules in the filter table
iptables -t filter -L -v #List all rules in the filter table with additional information
iptables -t filter -D FORWARD 2 #Delete the second rule in the FORWARD chain of the filter table
iptables -t filter -F FORWARD #Remove all rules in the FORWARD chain of the filter table
iptables -t NAT -F #Remove all rules in the NAT table
iptables -t filter -X catena_tcp #Elimina la catena catena_tcp dalla tabella filter (la catena non deve contenere regole al suo interno).

#N.B. La differenza tra -D e -F è che -D elimina una regola specifica, mentre -F elimina tutte le regole di una catena specifica.
#Inoltre, -X elimina una catena creata dall'utente, ma solo se è vuota (non contiene regole).



#   NAT

#Actions for NAT:
- SNAT: #Source NAT, used to change the source IP address of packets leaving the network (e.g., for internet access)
- DNAT: #Destination NAT, used to change the destination IP address of packets entering the network (e.g., for port forwarding)
- MASQUERADE: #A special case of SNAT, used when the external IP address is dynamic (e.g., for internet access with a dynamic IP address)
- REDIRECT: #Used to redirect packets to a different port on the same machine (e.g., for transparent proxying)

#Example:
+ SNAT
#Small organization with private network and an Internet-facing router/firewall. 
#The firewall has two interfaces:
#• eth0, connected to the Internet with a public IP address
#• eth1, connected to the LAN with a private (non-routable) IP address

iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 155.185.54.185 
#This rule changes the source IP address of packets leaving the LAN through eth0 to the public IP address of the firewall (155.185.54.185)
#Every connection started by a private host is remapped on a free port number of the firewall.


+ MASQUERADE
#If the firewall has a dynamic public IP address, we can use MASQUERADE instead of SNAT:

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#This rule changes the source IP address of packets leaving the LAN through eth0 to the current public IP address of the firewall,
#which is automatically detected by the MASQUERADE target.


+ DNAT
#Let us assume that the private host 192.168.1.1 runs a Web server listening on port 80.
#We can make it reachable from the Internet with the following rule:
iptables -nat -A PREROUTING -p tcp -d 155.185.54.185 --dport 80 -j DNAT --to-destination 192.168.1.1

#Let us assume that on 192.168.1.1 we run a Web proxy on port 8080, and we want
#to redirect all outgoing connections generated by private hosts to this Web proxy.
#We can use the following rule:
iptables -t nat -A PREROUTING -p tcp -d 155.185.54.185 --dport 80 -j DNAT --to-destination 192.168.1.1:8080

#La porta 80 del firewall è aperta, ma il traffico viene reindirizzato alla porta 8080 del proxy.
#In questo modo, tutti i pacchetti destinati alla porta 80 del firewall vengono intercettati e reindirizzati al proxy, che può filtrare o modificare il traffico prima di inoltrarlo alla destinazione finale.




#Packet marking
#It is possible to associate a mark to a network packet, so other rules can use the mark in their packet description.
#The mark is a 32-bit value that can be set and read by the kernel and user-space applications.
iptables -t mangle -A PREROUTING -p tcp -i eth0 -j MARK --set-mark <mark>

#Altri usi: modificare gli header
iptables -t mangle -A OUTPUT - p tcp -dport 3045 -j TOS --tos <tos> #Set the TOS field of the IP header to a specific value for packets destined to port 3045
iptables -t mangle -A POSTROUTING -p tcp -j TCPMSS --clamp-mss-to-pmtu #Adjust the TCP MSS (Maximum Segment Size) of packets to the path MTU (Maximum Transmission Unit) to avoid fragmentation



IMPORTANT: iptables rules are not persistent across reboots. 
#To save the current iptables configuration:
iptables-save > iptables-config
#To restore a saved configuration:
iptables-restore < iptables-config

#Conviene salvare le regole frequentemente