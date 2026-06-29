################################################################################
# MÓDULO: NETWORK ENUMERATION WITH NMAP
#
# AULAS:
# 01 - Enumeration
# 02 - Introduction to Nmap
# 03 - Host Discovery
#
# OBJETIVO
#
# Aprender a descobrir quais hosts estão ativos antes de iniciar a enumeração
# de portas, serviços e vulnerabilidades.
#
# A enumeração deve seguir um fluxo lógico:
#
#     Descobrir Hosts
#            │
#            ▼
#     Descobrir Portas
#            │
#            ▼
#     Descobrir Serviços
#            │
#            ▼
#     Descobrir Versões
#            │
#            ▼
#     Descobrir Sistema Operacional
#            │
#            ▼
#     Enumerar Serviços
#            │
#            ▼
#     Encontrar Vetores de Ataque
#
# Nunca comece procurando vulnerabilidades.
# Primeiro descubra o máximo possível sobre o alvo.
################################################################################



################################################################################
# SINTAXE BÁSICA DO NMAP
################################################################################

# Estrutura geral
nmap <TIPO_SCAN> <OPÇÕES> <ALVO>



################################################################################
# EXEMPLO DE SCAN TCP SYN
################################################################################

# Scan TCP SYN (Half Open Scan)
sudo nmap -sS localhost



################################################################################
# TIPOS DE SCAN EXISTENTES NO NMAP
################################################################################

# TCP SYN Scan
nmap -sS <IP>

# TCP Connect Scan
nmap -sT <IP>

# ACK Scan
nmap -sA <IP>

# Window Scan
nmap -sW <IP>

# Maimon Scan
nmap -sM <IP>

# UDP Scan
nmap -sU <IP>

# NULL Scan
nmap -sN <IP>

# FIN Scan
nmap -sF <IP>

# Xmas Scan
nmap -sX <IP>

# Custom TCP Flags
nmap --scanflags <FLAGS> <IP>

# Idle Scan
nmap -sI <ZombieHost> <IP>

# SCTP INIT
nmap -sY <IP>

# SCTP COOKIE ECHO
nmap -sZ <IP>

# IP Protocol Scan
nmap -sO <IP>

# FTP Bounce Scan
nmap -b <FTP_HOST> <IP>



################################################################################
# HOST DISCOVERY
#
# Descobre apenas quais máquinas estão ativas.
#
# NÃO escaneia portas.
################################################################################



################################################################################
# HOST DISCOVERY DE UMA REDE INTEIRA
################################################################################

sudo nmap 10.129.2.0/24 -sn



################################################################################
# HOST DISCOVERY DE UMA REDE E SALVAR RESULTADOS
################################################################################

sudo nmap 10.129.2.0/24 -sn -oA tnet



################################################################################
# EXTRAIR APENAS OS IPS ENCONTRADOS
################################################################################

sudo nmap 10.129.2.0/24 -sn -oA tnet | grep for | cut -d" " -f5



################################################################################
# ESCANEAR HOSTS A PARTIR DE UM ARQUIVO
################################################################################

sudo nmap -sn -iL hosts.lst



################################################################################
# ESCANEAR HOSTS A PARTIR DE UM ARQUIVO
# SALVANDO RESULTADOS
################################################################################

sudo nmap -sn -oA tnet -iL hosts.lst



################################################################################
# ESCANEAR HOSTS A PARTIR DE UM ARQUIVO
# EXTRAINDO APENAS OS IPS
################################################################################

sudo nmap -sn -oA tnet -iL hosts.lst | grep for | cut -d" " -f5



################################################################################
# ESCANEAR VÁRIOS IPS ESPECÍFICOS
################################################################################

sudo nmap -sn \
10.129.2.18 \
10.129.2.19 \
10.129.2.20



################################################################################
# ESCANEAR INTERVALO DE IPS
################################################################################

sudo nmap -sn 10.129.2.18-20



################################################################################
# ESCANEAR UM ÚNICO HOST
################################################################################

sudo nmap 10.129.2.18 -sn



################################################################################
# HOST DISCOVERY UTILIZANDO ICMP ECHO REQUEST
################################################################################

sudo nmap 10.129.2.18 -sn -PE



################################################################################
# EXIBIR TODOS OS PACOTES ENVIADOS E RECEBIDOS
################################################################################

sudo nmap 10.129.2.18 -sn -PE --packet-trace



################################################################################
# EXPLICAR POR QUE O HOST FOI CONSIDERADO VIVO
################################################################################

sudo nmap 10.129.2.18 -sn -PE --reason



################################################################################
# DESABILITAR ARP E FORÇAR ICMP
################################################################################

sudo nmap 10.129.2.18 \
-sn \
-PE \
--disable-arp-ping



################################################################################
# FORÇAR ICMP E MOSTRAR PACOTES
################################################################################

sudo nmap 10.129.2.18 \
-sn \
-PE \
--disable-arp-ping \
--packet-trace



################################################################################
# PARÂMETROS APRENDIDOS
################################################################################

# -sn
# Apenas Host Discovery.
# Não realiza Port Scan.

# -oA
# Salva o scan em:
# arquivo.nmap
# arquivo.xml
# arquivo.gnmap

# -iL
# Lê os alvos de um arquivo.

# -PE
# Utiliza ICMP Echo Request.

# --packet-trace
# Mostra todos os pacotes enviados e recebidos.

# --reason
# Explica o motivo do resultado.

# --disable-arp-ping
# Impede o uso de ARP Discovery e força ICMP.



################################################################################
# TIPOS DE HOST DISCOVERY APRENDIDOS
################################################################################

# ARP Ping
#
# Utilizado automaticamente quando o alvo está
# na mesma rede local.

# ICMP Echo Request
#
# Ping tradicional.

# ICMP Echo Reply
#
# Resposta do host.

# ARP Request
#
# Who has IP?

# ARP Reply
#
# I have this IP.



################################################################################
# COMO O NMAP DESCOBRE UM HOST
################################################################################

#
# REDE LOCAL
#
# Nmap
#   │
#   ▼
# ARP Request
#   │
#   ▼
# Host
#   │
#   ▼
# ARP Reply
#   │
#   ▼
# Host Alive
#



################################################################################
# HOST DISCOVERY VIA ICMP
################################################################################

#
# Nmap
#   │
#   ▼
# ICMP Echo Request
#   │
#   ▼
# Host
#   │
#   ▼
# ICMP Echo Reply
#   │
#   ▼
# Host Alive
#



################################################################################
# RESULTADOS POSSÍVEIS
################################################################################

#
# Host is up
#
# O host respondeu.
#

#
# Host seems down
#
# Nenhuma resposta recebida.
#

#
# Host is up, received arp-response
#
# O host respondeu via ARP.
#



################################################################################
# INFORMAÇÕES IMPORTANTES COLETADAS DURANTE O HOST DISCOVERY
################################################################################

#
# Endereço IP
#
# Endereço MAC
#
# Latência
#
# TTL
#
# Método utilizado para descoberta
# (ARP ou ICMP)
#



################################################################################
# INTERPRETAÇÃO DO TTL
################################################################################

#
# TTL ≈ 64
#
# Linux / Unix
#

#
# TTL ≈ 128
#
# Windows
#

#
# TTL ≈ 255
#
# Equipamentos de Rede
# (Cisco, Juniper, etc.)
#



################################################################################
# FLUXO CORRETO DE ENUMERAÇÃO
################################################################################

#
# Descobrir Rede
#
#        │
#        ▼
#
# Host Discovery
#
#        │
#        ▼
#
# Descobrir Hosts Ativos
#
#        │
#        ▼
#
# Port Scan
#
#        │
#        ▼
#
# Descobrir Serviços
#
#        │
#        ▼
#
# Descobrir Versões
#
#        │
#        ▼
#
# Descobrir Sistema Operacional
#
#        │
#        ▼
#
# Enumeração Manual
#
#        │
#        ▼
#
# Encontrar Vetores de Ataque
#
#        │
#        ▼
#
# Exploração
#
################################################################################