################################################################################
# HTB ACADEMY - NETWORK ENUMERATION WITH NMAP
#
# AULA 07 - NMAP SCRIPTING ENGINE (NSE)
#
# Objetivo da aula:
# Aprender a utilizar o Nmap Scripting Engine (NSE) para interagir com
# serviços, enumerar informações e encontrar flags utilizando scripts.
#
# Diferente dos módulos anteriores, nesta aula o foco deixa de ser apenas
# descobrir portas abertas e passa a explorar os serviços através de scripts.
#
# Fluxo executado durante a resolução:
#
#        Descobrir portas
#               │
#               ▼
#       Descobrir versões (-sV)
#               │
#               ▼
#      Executar scripts padrão (-sC)
#               │
#               ▼
#     Identificar serviços interessantes
#               │
#               ├────────► HTTP (Apache)
#               │
#               ├────────► FTP (ProFTPD)
#               │
#               ├────────► SMB
#               │
#               ├────────► POP3
#               │
#               └────────► IMAP
#               │
#               ▼
#     Executar scripts específicos
#               │
#               ▼
#      Enumerar cada serviço
#               │
#               ▼
#      Ler banners, headers,
#      capabilities, métodos,
#      compartilhamentos,
#      arquivos robots.txt...
#               │
#               ▼
#      Encontrar a flag escondida
#
################################################################################



################################################################################
# 1) DETECÇÃO DE SERVIÇOS
#
# Descobre versões dos serviços encontrados.
################################################################################

sudo nmap -Pn -n -sV 10.129.48.213



################################################################################
# Resultado obtido
################################################################################

# 22      SSH       OpenSSH
# 80      HTTP      Apache 2.4.29
# 110     POP3      Dovecot
# 139     SMB
# 143     IMAP      Dovecot
# 445     SMB
# 31337   FTP       ProFTPD



################################################################################
# 2) EXECUTAR TODOS OS SCRIPTS PADRÃO
#
# -sC
#
# Equivale a:
#
# --script default
#
################################################################################

sudo nmap -Pn -n \
-sV \
-sC \
-p22,80,110,139,143,445,31337 \
-v \
--stats-every 10s \
10.129.48.213



################################################################################
# Resultado importante
################################################################################

# HTTP
#
# http-title
# http-methods
# http-server-header
#
# SMB
#
# smb-os-discovery
# smb-security-mode
#
# SSH
#
# ssh-hostkey
#
# POP3
#
# pop3-capabilities
#
# IMAP
#
# imap-capabilities



################################################################################
# 3) EXECUTAR TODOS OS SCRIPTS HTTP
#
# OBS:
#
# NÃO RECOMENDADO.
#
# Carrega aproximadamente 180 scripts.
#
# Demora muitos minutos.
#
################################################################################

sudo nmap -Pn -n \
-p80 \
-sV \
--script http-* \
-v \
--stats-every 10s \
10.129.48.213



################################################################################
# Aprendizado
#
# http-* executa TODOS os scripts HTTP.
#
# Muitos ficam aguardando timeout.
#
# É melhor escolher somente scripts específicos.
################################################################################



################################################################################
# 4) EXECUTAR APENAS OS PRINCIPAIS SCRIPTS HTTP
################################################################################

sudo nmap -Pn -n \
-p80 \
-sV \
--script \
http-title,\
http-server-header,\
http-methods,\
http-headers,\
http-enum,\
http-robots.txt \
10.129.48.213



################################################################################
# Resultado encontrado
#
# Apache
#
# Métodos HTTP
#
# Headers
#
# robots.txt encontrado
################################################################################



################################################################################
# 5) ENUMERAÇÃO SMB
################################################################################

sudo nmap -Pn -n \
-p139,445 \
--script smb-enum-shares,smb-enum-users,smb-ls \
--script-args smbusername=guest,smbpassword='' \
-v \
--stats-every 10s \
10.129.48.213



################################################################################
# Resultado
#
# IPC$
#
# print$
#
# Guest habilitado
################################################################################



################################################################################
# 6) LISTAR SHARES SMB
################################################################################

smbclient -L //10.129.48.213 -N



################################################################################
# Resultado
#
# IPC$
#
# print$
################################################################################



################################################################################
# 7) ACESSAR IPC$
################################################################################

smbclient //10.129.48.213/IPC$ -N



################################################################################
# Listar conteúdo
################################################################################

ls



################################################################################
# Resultado
#
# Nenhum arquivo útil.
################################################################################



################################################################################
# 8) ENUMERAÇÃO FTP
################################################################################

sudo nmap -Pn -n \
-p31337 \
-sV \
--script \
ftp-anon,\
ftp-syst,\
ftp-libopie,\
ftp-proftpd-backdoor,\
ftp-vsftpd-backdoor,\
ftp-bounce \
-v \
--stats-every 5s \
10.129.48.213



################################################################################
# Resultado importante
#
# Durante o fingerprint (-sV)
#
# Nmap enviou vários probes.
#
# Um GET retornou:
#
# 220 HTB{pr0F7pDv3r510nb4nn3r}
#
# Esta NÃO era a flag da questão.
#
# Era uma resposta do fingerprint de serviço.
################################################################################



################################################################################
# 9) ENUMERAÇÃO DO ROBOTS.TXT
#
# O http-enum indicou:
#
# /robots.txt
#
################################################################################

curl -s http://10.129.48.213/robots.txt



################################################################################
# Resultado
################################################################################

# User-agent: *
#
# Allow: /
#
# HTB{873nniuc71bu6usbs1i96as6dsv26}



################################################################################
# ESTA ERA A FLAG CORRETA DA QUESTÃO.
################################################################################



################################################################################
# OUTROS COMANDOS MENCIONADOS DURANTE A AULA
################################################################################



################################################################################
# Executar categoria inteira
################################################################################

sudo nmap TARGET --script http-*

sudo nmap TARGET --script ftp-*

sudo nmap TARGET --script smb-*

sudo nmap TARGET --script vuln

sudo nmap TARGET --script safe

sudo nmap TARGET --script discovery



################################################################################
# Executar scripts específicos
################################################################################

sudo nmap TARGET --script banner,smtp-commands

sudo nmap TARGET --script http-title,http-enum

sudo nmap TARGET --script ftp-anon,ftp-syst

sudo nmap TARGET --script smb-enum-shares,smb-os-discovery



################################################################################
# Executar scan agressivo
################################################################################

sudo nmap TARGET -A



################################################################################
# Executar categoria de vulnerabilidades
################################################################################

sudo nmap TARGET -sV --script vuln



################################################################################
# Executar somente scripts padrão
################################################################################

sudo nmap TARGET -sC



################################################################################
# Executar versão + scripts padrão
################################################################################

sudo nmap TARGET -sV -sC



################################################################################
# Verificar headers HTTP manualmente
################################################################################

curl -I http://TARGET



################################################################################
# Ler robots.txt
################################################################################

curl http://TARGET/robots.txt



################################################################################
# Acessar páginas HTTP
################################################################################

curl http://TARGET

curl http://TARGET/index.html

curl http://TARGET/robots.txt



################################################################################
# Listar compartilhamentos SMB
################################################################################

smbclient -L //TARGET -N



################################################################################
# Entrar em um compartilhamento
################################################################################

smbclient //TARGET/IPC$ -N

smbclient //TARGET/print$ -N



################################################################################
# Comandos SMB internos
################################################################################

ls

dir

cd

pwd

get arquivo

put arquivo

exit



################################################################################
# CONCEITOS APRENDIDOS
################################################################################

#
# Nmap Scripting Engine (NSE)
#
# Scripts escritos em Lua.
#
# Localização:
#
# /usr/share/nmap/scripts/
#
#
# Categorias:
#
# auth
# broadcast
# brute
# default
# discovery
# dos
# exploit
# external
# fuzzer
# intrusive
# malware
# safe
# version
# vuln
#
#
# -sC
#
# Executa categoria default.
#
#
# -A
#
# Executa:
#
# -sV
# -O
# -sC
# traceroute
#
#
# --script
#
# Permite executar:
#
# categoria inteira
#
# ou
#
# scripts específicos.
#
#
# Nem toda informação vem dos scripts.
#
# Muitas vezes o próprio -sV envia diversos probes
# (GET, HELP, OPTIONS, etc.)
#
# e identifica banners personalizados.
#
# Sempre analisar:
#
# fingerprint-strings
#
# banners
#
# headers
#
# robots.txt
#
# http-title
#
# smb-os-discovery
#
# capabilities
#
# métodos HTTP
#
################################################################################