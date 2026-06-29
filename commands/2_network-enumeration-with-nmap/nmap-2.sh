################################################################################
# HTB ACADEMY
# MÓDULO: NETWORK ENUMERATION WITH NMAP
#
# AULA:
#   - Host and Port Scanning
#   - Saving the Results
#
# OBJETIVO DA AULA
#
# Aprender como o Nmap realiza a enumeração de portas TCP e UDP,
# compreender os diferentes estados das portas, identificar serviços,
# versões e sistema operacional, além de salvar corretamente todos os
# resultados para documentação e futuras análises.
#
# METODOLOGIA PROFISSIONAL
#
# Descoberta de Hosts
#        │
#        ▼
# Scan TCP Inicial
#        │
#        ▼
# Scan TCP Completo
#        │
#        ▼
# Scan UDP (quando necessário)
#        │
#        ▼
# Descoberta de Versões
#        │
#        ▼
# Enumeração dos Serviços
#        │
#        ▼
# Descoberta do Sistema Operacional
#        │
#        ▼
# Execução de Scripts NSE
#        │
#        ▼
# Documentação e Relatório
################################################################################


################################################################################
# 1. DESCOBRIR HOSTS VIVOS
################################################################################

# Ping Scan
sudo nmap -sn 10.10.10.0/24

# Ping Scan utilizando ICMP Echo
sudo nmap -sn -PE 10.10.10.5

# Ping Scan mostrando todos os pacotes enviados
sudo nmap -sn -PE --packet-trace 10.10.10.5

# Ping Scan desabilitando ARP
sudo nmap -sn -PE --disable-arp-ping 10.10.10.5

# Ping Scan completo para análise do protocolo
sudo nmap -sn -PE --packet-trace --disable-arp-ping 10.10.10.5


################################################################################
# 2. SCAN TCP PADRÃO
################################################################################

# O Nmap executa automaticamente SYN Scan quando executado como root
sudo nmap 10.10.10.5

# TCP Connect Scan (caso não seja root)
nmap 10.10.10.5

# SYN Scan explícito
sudo nmap -sS 10.10.10.5

# TCP Connect explícito
sudo nmap -sT 10.10.10.5


################################################################################
# 3. SCAN DAS PORTAS MAIS COMUNS
################################################################################

# Top 10 portas TCP
sudo nmap --top-ports=10 10.10.10.5

# Top 100 portas
sudo nmap -F 10.10.10.5

# Top 1000 portas (padrão)
sudo nmap 10.10.10.5


################################################################################
# 4. SCAN DE PORTAS ESPECÍFICAS
################################################################################

# Porta única
sudo nmap -p 22 10.10.10.5

# Diversas portas
sudo nmap -p 22,25,80,139,445 10.10.10.5

# Intervalo de portas
sudo nmap -p 20-100 10.10.10.5

# Todas as portas TCP
sudo nmap -p- 10.10.10.5


################################################################################
# 5. OPÇÕES IMPORTANTES UTILIZADAS DURANTE A ENUMERAÇÃO
################################################################################

# Não realizar ICMP Ping
-Pn

# Não resolver DNS
-n

# Não utilizar ARP
--disable-arp-ping

# Mostrar motivo do estado da porta
--reason

# Mostrar todos os pacotes enviados e recebidos
--packet-trace

# Limitar quantidade de tentativas
--max-retries 2

# Aumentar verbosidade
-v
-vv
-vvv


################################################################################
# 6. ANALISANDO O FUNCIONAMENTO DO TCP
################################################################################

# Visualizar handshake TCP completo
sudo nmap -p 22 \
-Pn \
-n \
--disable-arp-ping \
--packet-trace \
10.10.10.5

# TCP Connect mostrando handshake completo
sudo nmap \
-sT \
-p 443 \
-Pn \
-n \
--disable-arp-ping \
--reason \
--packet-trace \
10.10.10.5


################################################################################
# 7. ANALISANDO FIREWALLS
################################################################################

# Porta filtrada (DROP)
sudo nmap \
-p 139 \
-Pn \
-n \
--disable-arp-ping \
--packet-trace \
10.10.10.5

# Porta filtrada (REJECT)
sudo nmap \
-p 445 \
-Pn \
-n \
--disable-arp-ping \
--packet-trace \
10.10.10.5


################################################################################
# 8. SCAN UDP
################################################################################

# UDP Top 100
sudo nmap -F -sU 10.10.10.5

# UDP porta específica
sudo nmap \
-sU \
-p 137 \
-Pn \
-n \
--disable-arp-ping \
--packet-trace \
--reason \
10.10.10.5

# Porta UDP fechada
sudo nmap \
-sU \
-p 100 \
-Pn \
-n \
--disable-arp-ping \
--packet-trace \
--reason \
10.10.10.5

# Porta UDP open|filtered
sudo nmap \
-sU \
-p 138 \
-Pn \
-n \
--disable-arp-ping \
--packet-trace \
--reason \
10.10.10.5


################################################################################
# 9. ENUMERAÇÃO DE SERVIÇOS
################################################################################

# Descobrir versões
sudo nmap -sV 10.10.10.5

# Descobrir versões em porta específica
sudo nmap \
-sV \
-p 445 \
-Pn \
-n \
--disable-arp-ping \
--reason \
--packet-trace \
10.10.10.5


################################################################################
# 10. ENUMERAÇÃO COMPLETA UTILIZADA EM PENTEST
################################################################################

# Scan rápido
sudo nmap \
-Pn \
-n \
-sS \
-F \
10.10.10.5

# Scan completo TCP
sudo nmap \
-Pn \
-n \
-sS \
-p- \
10.10.10.5

# Descobrir versões
sudo nmap \
-Pn \
-n \
-sV \
10.10.10.5

# Scripts padrão
sudo nmap \
-Pn \
-n \
-sC \
10.10.10.5

# Sistema Operacional
sudo nmap \
-Pn \
-n \
-O \
10.10.10.5

# Scan agressivo
sudo nmap \
-Pn \
-n \
-A \
10.10.10.5


################################################################################
# 11. SALVANDO RESULTADOS
################################################################################

# Salvar saída normal
sudo nmap \
10.10.10.5 \
-oN scan.nmap

# Salvar saída grepável
sudo nmap \
10.10.10.5 \
-oG scan.gnmap

# Salvar XML
sudo nmap \
10.10.10.5 \
-oX scan.xml

# Salvar todos os formatos
sudo nmap \
10.10.10.5 \
-oA scan

# Scan completo salvando tudo
sudo nmap \
-Pn \
-n \
-sS \
-p- \
-oA full_tcp \
10.10.10.5

# Enumeração de versões salvando tudo
sudo nmap \
-Pn \
-n \
-sV \
-oA services \
10.10.10.5

# Scan agressivo salvando tudo
sudo nmap \
-Pn \
-n \
-A \
-oA aggressive \
10.10.10.5


################################################################################
# 12. VISUALIZANDO ARQUIVOS GERADOS
################################################################################

# Listar arquivos
ls

# Ler saída normal
cat scan.nmap

# Ler saída grepável
cat scan.gnmap

# Ler XML
cat scan.xml


################################################################################
# 13. CONVERSÃO XML PARA HTML
################################################################################

# Converter XML em HTML
xsltproc scan.xml -o scan.html

# Abrir relatório HTML
firefox scan.html

# Alternativas
xdg-open scan.html
google-chrome scan.html


################################################################################
# 14. EXEMPLOS DE GREP SOBRE O ARQUIVO GNMAP
################################################################################

# Procurar SSH
grep ssh scan.gnmap

# Procurar HTTP
grep http scan.gnmap

# Procurar SMB
grep microsoft-ds scan.gnmap

# Mostrar apenas portas abertas
grep "/open/" scan.gnmap

# Mostrar apenas hosts vivos
grep "Status: Up" scan.gnmap

# Extrair portas
awk -F"Ports: " '{print $2}' scan.gnmap

# Cortar informações
cut -d':' -f2 scan.gnmap


################################################################################
# 15. ORGANIZAÇÃO PROFISSIONAL DOS SCANS
################################################################################

# Criar estrutura
mkdir -p scans/{host_discovery,tcp,udp,services,nse,reports}

# Salvar scan TCP
sudo nmap -Pn -n -p- -oA scans/tcp/full_tcp 10.10.10.5

# Salvar enumeração de serviços
sudo nmap -Pn -n -sV -oA scans/services/services 10.10.10.5

# Salvar scripts NSE
sudo nmap -Pn -n -sC -oA scans/nse/default_scripts 10.10.10.5

# Salvar scan agressivo
sudo nmap -Pn -n -A -oA scans/reports/aggressive 10.10.10.5


################################################################################
# 16. FLUXO COMPLETO DE ENUMERAÇÃO UTILIZADO NAS AULAS
################################################################################

# 1. Descobrir hosts
sudo nmap -sn 10.10.10.0/24

# 2. Confirmar host
sudo nmap -sn -PE --packet-trace --disable-arp-ping 10.10.10.5

# 3. Scan rápido
sudo nmap -Pn -n -F 10.10.10.5

# 4. Scan Top Ports
sudo nmap --top-ports=10 10.10.10.5

# 5. Scan completo TCP
sudo nmap -Pn -n -p- -sS -oA full_tcp 10.10.10.5

# 6. Scan UDP
sudo nmap -Pn -n -sU -F -oA udp_scan 10.10.10.5

# 7. Descobrir versões
sudo nmap -Pn -n -sV -oA service_versions 10.10.10.5

# 8. Executar scripts NSE
sudo nmap -Pn -n -sC -oA default_scripts 10.10.10.5

# 9. Descobrir sistema operacional
sudo nmap -Pn -n -O -oA os_detection 10.10.10.5

# 10. Scan agressivo para consolidação
sudo nmap -Pn -n -A -oA final_scan 10.10.10.5

# 11. Gerar relatório HTML
xsltproc final_scan.xml -o final_scan.html


################################################################################
# CONHECIMENTOS IMPORTANTES FIXADOS NESTAS AULAS
#
# • Descoberta de hosts
# • Estados das portas TCP
# • Open
# • Closed
# • Filtered
# • Open|Filtered
# • Closed|Filtered
# • Unfiltered
# • SYN Scan
# • TCP Connect Scan
# • UDP Scan
# • Version Detection
# • Packet Trace
# • DNS Resolution
# • ARP Discovery
# • Firewall DROP
# • Firewall REJECT
# • Service Enumeration
# • Saving Results
# • Grepable Output
# • XML Output
# • HTML Report
# • Organização profissional de evidências
################################################################################