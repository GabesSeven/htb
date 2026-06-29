################################################################################
# HTB ACADEMY - NETWORK ENUMERATION WITH NMAP
#
# AULA 08 - PERFORMANCE
#
# OBJETIVO
# --------
# Aprender a otimizar a velocidade dos scans do Nmap sem perder precisão
# desnecessariamente.
#
# Nesta aula aprendemos:
#
# - RTT (Round Trip Time)
# - initial-rtt-timeout
# - max-rtt-timeout
# - max-retries
# - min-rate
# - Timing Templates (-T0 até -T5)
#
# Conceitos importantes
# ---------------------
#
# Quanto MAIS rápido o scan:
#
#   ✔ Menor tempo
#   ✔ Mais pacotes por segundo
#   ✔ Melhor para redes internas
#
# Porém...
#
#   ✘ Pode perder hosts
#   ✘ Pode perder portas abertas
#   ✘ Pode gerar falso negativo
#   ✘ Pode disparar IDS/IPS
#
#
# Fluxo de decisão
#
#                   Scan
#                     │
#                     ▼
#        Rede desconhecida?
#             │
#      Sim ───┴──── Não
#       │              │
#       ▼              ▼
#     -T3           -T4
#       │              │
#       ▼              ▼
#  Encontrou tudo?   Rede rápida?
#       │              │
#       ▼              ▼
#     Sim            --min-rate
#       │
#       ▼
#  Enumeração
#
#
# REFERÊNCIAS OFICIAIS
#
# Performance:
# https://nmap.org/book/man-performance.html
#
# Timing Templates:
# https://nmap.org/book/performance-timing-templates.html
#
################################################################################



################################################################################
# SCAN PADRÃO
################################################################################

sudo nmap 10.129.2.0/24 -F



################################################################################
# RTT OTIMIZADO
#
# Diminui o tempo inicial de espera da resposta.
#
# Mais rápido.
#
# Pode perder hosts lentos.
################################################################################

sudo nmap 10.129.2.0/24 -F \
--initial-rtt-timeout 50ms \
--max-rtt-timeout 100ms



################################################################################
# INITIAL RTT
#
# Define quanto tempo esperar na PRIMEIRA tentativa.
################################################################################

sudo nmap IP \
--initial-rtt-timeout 50ms



################################################################################
# MAX RTT
#
# Define o tempo máximo de espera por resposta.
################################################################################

sudo nmap IP \
--max-rtt-timeout 100ms



################################################################################
# SCAN PADRÃO PARA CONTAR PORTAS
################################################################################

sudo nmap 10.129.2.0/24 -F | grep "/tcp" | wc -l



################################################################################
# MAX RETRIES
#
# Quantidade máxima de novas tentativas.
#
# Padrão:
#
# 10
#
# Zero:
#
# Não tenta novamente.
################################################################################

sudo nmap 10.129.2.0/24 -F \
--max-retries 0



################################################################################
# CONTAR PORTAS APÓS REDUZIR RETRIES
################################################################################

sudo nmap 10.129.2.0/24 -F \
--max-retries 0 \
| grep "/tcp" | wc -l



################################################################################
# SCAN PADRÃO SALVANDO RESULTADOS
################################################################################

sudo nmap 10.129.2.0/24 \
-F \
-oN tnet.default



################################################################################
# MIN RATE
#
# Número mínimo de pacotes enviados por segundo.
################################################################################

sudo nmap 10.129.2.0/24 \
-F \
-oN tnet.minrate300 \
--min-rate 300



################################################################################
# CONTAR PORTAS DO SCAN PADRÃO
################################################################################

cat tnet.default | grep "/tcp" | wc -l



################################################################################
# CONTAR PORTAS DO SCAN OTIMIZADO
################################################################################

cat tnet.minrate300 | grep "/tcp" | wc -l



################################################################################
# TIMING TEMPLATE PADRÃO
#
# T3
################################################################################

sudo nmap \
10.129.2.0/24 \
-F \
-oN tnet.default



################################################################################
# TIMING TEMPLATE INSANE
################################################################################

sudo nmap \
10.129.2.0/24 \
-F \
-oN tnet.T5 \
-T5



################################################################################
# CONTAR PORTAS ENCONTRADAS
################################################################################

cat tnet.T5 | grep "/tcp" | wc -l



################################################################################
# TIMING TEMPLATES
################################################################################

# Paranoid
-T0

# Sneaky
-T1

# Polite
-T2

# Normal (Padrão)
-T3

# Aggressive
-T4

# Insane
-T5



################################################################################
# EXEMPLOS PRÁTICOS DE TIMING
################################################################################

# Rede lenta
sudo nmap -T2 IP

# Rede desconhecida
sudo nmap -T3 IP

# HTB
sudo nmap -T4 IP

# Rede interna
sudo nmap -T5 IP



################################################################################
# EXEMPLO MUITO UTILIZADO EM HTB
################################################################################

sudo nmap \
-sC \
-sV \
-T4 \
IP



################################################################################
# SCAN COMPLETO RÁPIDO
################################################################################

sudo nmap \
-p- \
-sS \
-T4 \
IP



################################################################################
# SCAN RÁPIDO DAS 100 PORTAS
################################################################################

sudo nmap \
-F \
-T4 \
--min-rate 300 \
IP



################################################################################
# SCAN MUITO RÁPIDO EM REDE INTERNA
################################################################################

sudo nmap \
-T4 \
--min-rate 1000 \
--max-retries 1 \
IP



################################################################################
# SCAN MUITO DISCRETO
################################################################################

sudo nmap \
-sS \
-T1 \
IP



################################################################################
# COMANDOS QUE UTILIZAMOS DURANTE O MÓDULO ATÉ AGORA
#
# (TODOS OS COMANDOS IMPORTANTES ACUMULADOS)
################################################################################



################################################################################
# HOST DISCOVERY
################################################################################

sudo nmap IP -sn

sudo nmap REDE/CIDR -sn

sudo nmap -PE IP

sudo nmap -PP IP

sudo nmap -PM IP

sudo nmap -PS22,80,443 IP

sudo nmap -PA80 IP

sudo nmap -PU53 IP

sudo nmap -PR IP

sudo nmap -Pn IP

sudo nmap \
-sn \
-PE \
--packet-trace \
--disable-arp-ping \
IP



################################################################################
# ENUMERAÇÃO BÁSICA
################################################################################

sudo nmap IP

sudo nmap -Pn IP

sudo nmap -Pn -n IP

sudo nmap -Pn -n -F IP

sudo nmap -Pn -n -sS IP

sudo nmap -Pn -n -sT IP

sudo nmap -Pn -n -sU IP

sudo nmap -Pn -n -sV IP

sudo nmap -Pn -n -sC IP

sudo nmap -Pn -n -A IP

sudo nmap -Pn -n -O IP

sudo nmap -Pn -n -sV -sC IP

sudo nmap -Pn -n -p- IP

sudo nmap -Pn -n -p22,80,443 IP

sudo nmap -Pn -n --top-ports 1000 IP



################################################################################
# SCANS UTILIZADOS NOS LABS
################################################################################

sudo nmap -Pn -n -p- -sS IP

sudo nmap -Pn -n -sV -sC IP

sudo nmap -Pn -n -A IP

sudo nmap -Pn -n -O IP



################################################################################
# ENUMERAÇÃO WEB
################################################################################

sudo nmap \
-p80 \
-sV \
--script \
http-title,\
http-server-header,\
http-methods,\
http-headers,\
http-enum,\
http-robots.txt \
IP



################################################################################
# ENUMERAÇÃO FTP
################################################################################

sudo nmap \
-p21 \
-sV \
--script ftp-anon \
IP

sudo nmap \
-p21 \
--script ftp-syst \
IP

sudo nmap \
-p21 \
--script ftp-bounce \
IP

sudo nmap \
-p21 \
--script ftp-brute \
IP

sudo nmap \
-p21 \
--script ftp-libopie \
IP

sudo nmap \
-p21 \
--script ftp-proftpd-backdoor \
IP



################################################################################
# ENUMERAÇÃO SMB
################################################################################

sudo nmap \
-p445 \
--script smb-enum-shares \
IP

sudo nmap \
-p445 \
--script smb-enum-users \
IP

sudo nmap \
-p445 \
--script smb-os-discovery \
IP



################################################################################
# ENUMERAÇÃO SSH
################################################################################

sudo nmap \
-p22 \
--script ssh-auth-methods \
IP

sudo nmap \
-p22 \
--script ssh2-enum-algos \
IP



################################################################################
# NSE
################################################################################

sudo nmap \
-sC \
IP

sudo nmap \
--script default \
IP

sudo nmap \
--script vuln \
IP

sudo nmap \
--script safe \
IP

sudo nmap \
--script discovery \
IP

sudo nmap \
--script "http*" \
IP

sudo nmap \
--script-help http-title



################################################################################
# SALVANDO RESULTADOS
################################################################################

sudo nmap IP -oN resultado.nmap

sudo nmap IP -oG resultado.gnmap

sudo nmap IP -oX resultado.xml

sudo nmap IP -oA resultado



################################################################################
# FLUXO COMPLETO DE ENUMERAÇÃO UTILIZADO NO HTB
################################################################################

# 1 Descobrir hosts ativos
sudo nmap -sn REDE/CIDR

# 2 Descobrir portas rapidamente
sudo nmap -Pn -n -F -T4 IP

# 3 Descobrir serviços
sudo nmap -Pn -n -sC -sV -T4 IP

# 4 Descobrir todas as portas
sudo nmap -Pn -n -p- -sS -T4 IP

# 5 Detectar sistema operacional
sudo nmap -Pn -n -O IP

# 6 Fingerprint completo
sudo nmap -Pn -n -A IP

# 7 Executar scripts NSE específicos
sudo nmap -Pn -n --script http* IP

sudo nmap -Pn -n --script ftp-anon IP

sudo nmap -Pn -n --script smb-enum-shares IP

# 8 Identificar possíveis vetores de ataque

# HTTP
# FTP
# SMB
# SSH
# DNS
# RPC
# NFS

# 9 Pesquisar CVEs

# searchsploit
# Metasploit
# Google
# CVE Details

# 10 Exploração

# Reverse Shell
# Upload
# Exploit
# Credential Attack
# Privilege Escalation

################################################################################
# RESUMO FINAL
################################################################################

# RTT controla quanto tempo o Nmap espera por respostas.
#
# initial-rtt-timeout
# Tempo inicial de espera.
#
# max-rtt-timeout
# Tempo máximo de espera.
#
# max-retries
# Número de novas tentativas.
#
# min-rate
# Pacotes mínimos enviados por segundo.
#
# T0
# Máximo stealth.
#
# T1
# Muito discreto.
#
# T2
# Produção.
#
# T3
# Padrão.
#
# T4
# Melhor opção para HTB.
#
# T5
# Extremamente rápido.
#
# Quanto maior a velocidade:
#
# + Menor tempo
# + Mais tráfego
# + Mais chance de perder hosts
# + Mais chance de perder portas
# + Maior probabilidade de ser detectado
################################################################################