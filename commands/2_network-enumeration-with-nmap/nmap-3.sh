################################################################################
# HTB ACADEMY - NETWORK ENUMERATION WITH NMAP
#
# MÓDULO:
# Service Enumeration
#
# OBJETIVO DA AULA
#
# Aprender a:
#
# 1. Enumerar TODOS os serviços do alvo
# 2. Descobrir versões dos serviços
# 3. Fazer Banner Grabbing
# 4. Entender como o Nmap identifica serviços
# 5. Aprender quando utilizar enumeração manual
# 6. Encontrar informações que o Nmap pode não mostrar
# 7. Descobrir a flag utilizando Banner Grabbing
#
################################################################################


################################################################################
# METODOLOGIA UTILIZADA NESTA AULA
################################################################################

#
# Descobrir Host
#       │
#       ▼
# Descobrir Portas
#       │
#       ▼
# Descobrir Serviços
#       │
#       ▼
# Descobrir Versões
#       │
#       ▼
# Enumerar Manualmente
#       │
#       ▼
# Banner Grabbing
#       │
#       ▼
# Encontrar Informações Extras
#       │
#       ▼
# Encontrar Flag
#


################################################################################
# ETAPA 1
#
# ENUMERAR TODAS AS PORTAS TCP
################################################################################

sudo nmap -Pn -n -p- -sS 10.129.48.213

#
# -Pn
# Não faz Host Discovery
#
# -n
# Não resolve DNS
#
# -p-
# Escaneia TODAS as portas TCP (1-65535)
#
# -sS
# SYN Scan (Half Open Scan)
#
# Resultado encontrado:
#
# 22
# 80
# 110
# 139
# 143
# 445
# 31337
#


################################################################################
# ETAPA 2
#
# ENUMERAR SERVIÇOS E VERSÕES
################################################################################

sudo nmap -Pn -n -sV 10.129.48.213

#
# -sV
#
# Service Version Detection
#
# O Nmap realiza Banner Grabbing
# ou Fingerprint Detection
#
# Resultado:
#
# 22      OpenSSH
# 80      Apache
# 110     Dovecot POP3
# 139     Samba
# 143     Dovecot IMAP
# 445     Samba
# 31337   ProFTPD
#


################################################################################
# COMANDO ENSINADO NA AULA
#
# ESCANEAR TODAS AS PORTAS + VERSÕES
################################################################################

sudo nmap TARGET -p- -sV


################################################################################
# COMANDO ENSINADO NA AULA
#
# MOSTRAR STATUS DO SCAN A CADA 5 SEGUNDOS
################################################################################

sudo nmap TARGET -p- -sV --stats-every=5s

#
# Durante scans demorados
#
# Exibe:
#
# %
# Tempo restante
# ETC
#


################################################################################
# COMANDO ENSINADO NA AULA
#
# VERBOSE
################################################################################

sudo nmap TARGET -p- -sV -v

#
# Mostra imediatamente
#
# Discovered open port ...
#


################################################################################
# COMANDO ENSINADO NA AULA
#
# MAIS VERBOSE
################################################################################

sudo nmap TARGET -p- -sV -vv


################################################################################
# COMANDO ENSINADO NA AULA
#
# ACOMPANHAR O SCAN
################################################################################

#
# Durante um scan
#
# Apertar:
#
# SPACE
#
# O Nmap mostra:
#
# %
# elapsed
# ETC
#


################################################################################
# COMANDO ENSINADO NA AULA
#
# PACKET TRACE
################################################################################

sudo nmap TARGET -Pn -n -sV --disable-arp-ping --packet-trace

#
# Mostra
#
# SYN
# SYN ACK
# ACK
# Banner
#


################################################################################
# COMANDO ENSINADO NA AULA
#
# CAPTURAR PACOTES
################################################################################

sudo tcpdump -i eth0 host SEU_IP and TARGET

#
# Captura:
#
# SYN
# SYN ACK
# ACK
# PSH ACK
# ACK
#


################################################################################
# COMANDO ENSINADO NA AULA
#
# BANNER GRABBING SMTP
################################################################################

nc -nv TARGET 25

#
# Lê banner SMTP
#


################################################################################
# COMANDO ENSINADO NA AULA
#
# BANNER GRABBING FTP
################################################################################

nc -nv TARGET 21


################################################################################
# COMANDO ENSINADO NA AULA
#
# BANNER GRABBING IMAP
################################################################################

nc -nv TARGET 143


################################################################################
# COMANDO ENSINADO NA AULA
#
# BANNER GRABBING POP3
################################################################################

nc -nv TARGET 110


################################################################################
# COMANDO ENSINADO NA AULA
#
# CONECTAR FTP
################################################################################

ftp TARGET


################################################################################
# COMANDO UTILIZADO DURANTE O LAB
#
# TESTAR O HTTP
################################################################################

curl http://10.129.48.213

#
# Resultado:
#
# Apache2 Ubuntu Default Page
#
# Conclusão:
#
# Página padrão
#
# Não contém a flag.
#


################################################################################
# COMANDO UTILIZADO DURANTE O LAB
#
# CONECTAR AO FTP
################################################################################

ftp 10.129.48.213 31337

#
# Resultado:
#
# 220 HTB{pr0F7pDv3r510nb4nn3r}
#
# A flag estava no Banner.
#


################################################################################
# OUTRO MÉTODO POSSÍVEL
#
# BANNER VIA NETCAT
################################################################################

nc -nv 10.129.48.213 31337


################################################################################
# OUTRO MÉTODO POSSÍVEL
#
# BANNER VIA TELNET
################################################################################

telnet 10.129.48.213 31337


################################################################################
# ENUMERAÇÃO HTTP
################################################################################

curl http://TARGET

curl -I http://TARGET

wget -qO- http://TARGET


################################################################################
# ENUMERAÇÃO FTP
################################################################################

ftp TARGET

anonymous

anonymous

ls

dir

pwd

cd

get arquivo

put arquivo

bye


################################################################################
# ENUMERAÇÃO POP3
################################################################################

nc -nv TARGET 110


################################################################################
# ENUMERAÇÃO IMAP
################################################################################

nc -nv TARGET 143


################################################################################
# ENUMERAÇÃO SMB
################################################################################

smbclient -L //TARGET -N

smbclient //TARGET/SHARE -N


################################################################################
# COMO O NMAP DESCOBRE A VERSÃO
################################################################################

#
# MÉTODO 1
#
# Banner Grabbing
#
# Serviço envia:
#
# 220 Postfix Ubuntu
#
# O Nmap interpreta.
#
################################################################################

#
# MÉTODO 2
#
# Fingerprint Detection
#
# Nmap envia diversos pacotes
#
# Compara respostas
#
# Banco de Assinaturas
#
# Descobre serviço.
#


################################################################################
# TCP HANDSHAKE APRENDIDO NA AULA
################################################################################

#
# Cliente
#
# SYN
#
# Servidor
#
# SYN ACK
#
# Cliente
#
# ACK
#
# Conexão estabelecida
#
# Servidor
#
# PSH ACK
#
# Banner
#
# Cliente
#
# ACK
#


################################################################################
# RACIOCÍNIO UTILIZADO PARA RESOLVER O LAB
################################################################################

#
# Questão:
#
# Enumerate all ports and their services.
#
# One of the services contains the flag.
#
#
# Linha de raciocínio:
#
# Descobrir portas
#
# ↓
#
# Descobrir serviços
#
# ↓
#
# Qual serviço merece enumeração?
#
# ↓
#
# HTTP
#
# ↓
#
# Página padrão
#
# ↓
#
# Nada encontrado
#
# ↓
#
# Próximo serviço
#
# FTP
#
# ↓
#
# Conectar
#
# ↓
#
# Banner recebido imediatamente
#
# ↓
#
# 220 HTB{pr0F7pDv3r510nb4nn3r}
#
# ↓
#
# Flag encontrada
#


################################################################################
# O QUE APRENDEMOS NESTA AULA
################################################################################

#
# Nem toda informação aparece no Nmap.
#
# Sempre realizar enumeração manual.
#
# Banner Grabbing pode revelar:
#
# • Sistema Operacional
# • Versão exata
# • Hostname
# • Software
# • Mensagens customizadas
# • Credenciais
# • Flags (como neste laboratório)
#
# O fluxo correto é:
#
# Descobrir portas
#
# ↓
#
# Descobrir serviços
#
# ↓
#
# Descobrir versões
#
# ↓
#
# Conectar manualmente
#
# ↓
#
# Enumerar serviço
#
# ↓
#
# Obter informações adicionais
#
# ↓
#
# Procurar vulnerabilidades
#
# ↓
#
# Explorar
#
################################################################################


################################################################################
# FLAG DA AULA
################################################################################

# HTB{pr0F7pDv3r510nb4nn3r}

################################################################################