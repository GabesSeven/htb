###############################################################
# HTB ACADEMY - GETTING STARTED
# COMANDOS E FLUXO COMPLETO UTILIZADO
###############################################################

###############################################################
# VPN
###############################################################

# Conectar à VPN do HTB
sudo openvpn user.ovpn

# Verificar se a interface VPN (tun0) foi criada
ifconfig

# Alternativa moderna
ip a

# Verificar rotas da VPN
netstat -rn

# Alternativa moderna
ip route

###############################################################
# SSH
###############################################################

# Conectar remotamente utilizando usuário e senha
ssh usuario@IP

# Exemplo
ssh Bob@10.10.10.10

# Conectar utilizando chave privada
ssh -i id_rsa usuario@IP

# Exemplo
ssh -i id_rsa bob@10.129.1.5

###############################################################
# NETCAT
###############################################################

# Banner grabbing em uma porta
nc IP PORTA

# Exemplo
nc 10.10.10.10 22

# Listener para receber conexões
nc -lvnp 4444

###############################################################
# TMUX
###############################################################

# Instalar tmux
sudo apt install tmux -y

# Iniciar tmux
tmux

# Nova janela
# CTRL+B C

# Trocar janela
# CTRL+B 0
# CTRL+B 1
# CTRL+B 2

# Dividir verticalmente
# CTRL+B %

# Dividir horizontalmente
# CTRL+B "

# Trocar painéis
# CTRL+B + Setas

###############################################################
# VIM
###############################################################

# Abrir arquivo
vim arquivo.txt

# Abrir hosts
vim /etc/hosts

# Entrar em modo inserção
# i

# Voltar para modo normal
# ESC

# Cortar caractere
# x

# Cortar palavra
# dw

# Cortar linha
# dd

# Copiar palavra
# yw

# Copiar linha
# yy

# Colar
# p

# Ir para linha 1
# :1

# Salvar
# :w

# Sair
# :q

# Sair sem salvar
# :q!

# Salvar e sair
# :wq

###############################################################
# ENUMERAÇÃO WEB - EXERCÍCIO HTB
###############################################################

###############################################################
# PASSO 1 - ENUMERAÇÃO INICIAL
###############################################################

# Visualizar página e headers detalhados
curl -v http://154.57.164.80:30565

# Descoberta:
# Apache/2.4.41 (Ubuntu)

###############################################################
# PASSO 2 - ANALISAR HEADERS
###############################################################

curl -I http://154.57.164.80:30565

# Descoberta:
# HTTP/1.1 200 OK
# Apache/2.4.41

###############################################################
# PASSO 3 - ENUMERAR ROBOTS.TXT
###############################################################

# Primeira tentativa (somente headers)
curl -I http://154.57.164.80:30565/robots.txt

# Segunda tentativa (conteúdo)
curl http://154.57.164.80:30565/robots.txt

# Descoberta:
# User-agent: *
# Disallow: /admin-login-page.php

###############################################################
# PASSO 4 - VERIFICAR SITEMAP
###############################################################

curl -I http://154.57.164.80:30565/sitemap.xml

# Resultado:
# 404 Not Found

###############################################################
# PASSO 5 - PROCURAR COMENTÁRIOS HTML
###############################################################

curl -s http://154.57.164.80:30565 | grep '<!--'

# Resultado:
# Nenhum comentário encontrado na página principal

###############################################################
# PASSO 6 - ENUMERAÇÃO DE DIRETÓRIOS
###############################################################

# Primeira tentativa (erro de caminho)
gobuster dir -u http://154.57.164.80:30565 -w /usr/share/wordlist/dirb/common.txt -q

# Caminho correto
gobuster dir -u http://154.57.164.80:30565 -w /usr/share/wordlists/dirb/common.txt -q

# Descobertas:
# /robots.txt
# /wordpress
# /index.php

###############################################################
# PASSO 7 - INVESTIGAR WORDPRESS
###############################################################

curl http://154.57.164.80:30565/wordpress/

# Descoberta:
# WordPress Installation
# WordPress versão 5.6.2

###############################################################
# PASSO 8 - ENUMERAR WORDPRESS
###############################################################

gobuster dir \
-u http://154.57.164.80:30565/wordpress \
-w /usr/share/wordlists/dirb/common.txt

# Descobertas:
# /css
# /index.php

###############################################################
# PASSO 9 - INVESTIGAR INDEX
###############################################################

curl http://154.57.164.80:30565/index.php

# Resultado:
# Página principal do blog

###############################################################
# PASSO 10 - INVESTIGAR PÁGINA OCULTA
###############################################################

curl http://154.57.164.80:30565/admin-login-page.php

# Descoberta:
# Página de login administrativa

###############################################################
# PASSO 11 - ANALISAR CÓDIGO FONTE
###############################################################

# Comentário encontrado:

# <!-- TODO: remove test credentials admin:password123 -->

###############################################################
# PASSO 12 - CREDENCIAIS DESCOBERTAS
###############################################################

# Usuário:
admin

# Senha:
password123

###############################################################
# PASSO 13 - LOGIN VIA CURL
###############################################################

curl -d \
"username=admin&password=password123" \
http://154.57.164.80:30565/admin-login-page.php

# Seguindo redirecionamentos

curl -L \
-d "username=admin&password=password123" \
http://154.57.164.80:30565/admin-login-page.php

###############################################################
# TÉCNICAS APRENDIDAS
###############################################################

# Banner Grabbing
nc IP PORTA
curl -v

# Enumeração de Headers
curl -I

# Enumeração de Robots
curl robots.txt

# Enumeração de Diretórios
gobuster dir

# Enumeração de WordPress
curl /wordpress
gobuster em /wordpress

# Source Code Review
curl
grep

# Credential Discovery
# Encontrar senhas em comentários HTML

###############################################################
# FLUXO COMPLETO DO ATAQUE
###############################################################

# Página Principal
curl -v http://154.57.164.80:30565

# Robots.txt
curl http://154.57.164.80:30565/robots.txt

# Descoberta:
# /admin-login-page.php

# Enumeração de Diretórios
gobuster dir \
-u http://154.57.164.80:30565 \
-w /usr/share/wordlists/dirb/common.txt

# Descoberta:
# /wordpress

# Enumeração WordPress
curl http://154.57.164.80:30565/wordpress/

# Página Administrativa
curl http://154.57.164.80:30565/admin-login-page.php

# Descoberta:
# admin:password123

# Login
curl -L \
-d "username=admin&password=password123" \
http://154.57.164.80:30565/admin-login-page.php

# Objetivo:
# Obter a Flag

###############################################################
# PORTAS IMPORTANTES MENCIONADAS
###############################################################

# 20/21  FTP
# 22     SSH
# 23     Telnet
# 25     SMTP
# 53     DNS
# 80     HTTP
# 88     Kerberos
# 110    POP3
# 135    RPC
# 139    NetBIOS
# 143    IMAP
# 161    SNMP
# 389    LDAP
# 443    HTTPS
# 445    SMB
# 636    LDAPS
# 1433   MSSQL
# 3306   MySQL
# 3389   RDP
# 5432   PostgreSQL
# 5985   WinRM
# 5986   WinRM SSL

###############################################################
# FIM DO MÓDULO
###############################################################