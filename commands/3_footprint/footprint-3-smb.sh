################################################################################
# HTB ACADEMY - FOOTPRINTING
# MÓDULO: SMB (SERVER MESSAGE BLOCK) / SAMBA / RPC ENUMERATION
#
# Autor: Gabriel Ferreira
# Documentação criada durante os estudos do HTB Academy
#
# OBJETIVO DA AULA
#
# Aprender a identificar, enumerar e explorar serviços SMB/Samba utilizando
# diversas ferramentas diferentes, entendendo quais informações cada uma
# consegue extrair.
#
# Durante um Pentest nunca devemos confiar em apenas uma ferramenta.
# Cada ferramenta consulta o servidor SMB de maneira diferente e pode retornar
# informações diferentes.
#
################################################################################


################################################################################
# PROTOCOLOS IMPORTANTES
################################################################################

# SMB (Server Message Block)
# Compartilhamento de arquivos
# Compartilhamento de impressoras
# Compartilhamento de diretórios
# Comunicação entre processos

# Samba
# Implementação SMB para Linux/Unix.

# RPC
# Remote Procedure Call.
# Permite consultar usuários, grupos, shares, domínio, permissões,
# políticas e diversas informações internas do servidor.

# NetBIOS
# Serviço antigo utilizado pelo SMBv1.

################################################################################
# PORTAS IMPORTANTES
################################################################################

# 137/tcp -> NBNS
# 138/tcp -> NetBIOS Datagram
# 139/tcp -> SMB sobre NetBIOS
# 445/tcp -> SMB direto (SMB2/SMB3)

################################################################################
# DEFINIR ALVO
################################################################################

export TARGET=10.129.X.X

################################################################################
# ETAPA 1 - DESCOBRIR O SERVIÇO SMB
################################################################################

sudo nmap -Pn -sV -sC -p139,445 $TARGET

sudo nmap -sV -sC -p139,445 $TARGET

# Objetivo
# Descobrir:
# - versão do Samba
# - SMB Signing
# - SMBv1
# - scripts NSE
# - hostname
# - horário
# - banner completo

################################################################################
# ETAPA 2 - ENUMERAR SHARES COM SMBCLIENT
################################################################################

smbclient -N -L //$TARGET

smbclient -L //$TARGET -U ""

# Resultado esperado

# Sharename
# IPC$
# print$
# home
# notes
# public
# backups
# sambashare
# etc

################################################################################
# ETAPA 3 - CONECTAR AO SHARE
################################################################################

smbclient //$TARGET/SHARE -N

# exemplo

smbclient //$TARGET/sambashare -N

################################################################################
# COMANDOS INTERNOS DO SMBCLIENT
################################################################################

help

?

ls

dir

pwd

cd pasta

lcd

get arquivo

mget *

put arquivo

mkdir pasta

rmdir pasta

rm arquivo

del arquivo

rename antigo novo

recurse ON

recurse OFF

prompt

history

volume

showconnect

listconnect

allinfo arquivo

stat arquivo

more arquivo

cat arquivo

exit

quit

################################################################################
# EXECUTAR COMANDOS LOCAIS SEM SAIR DO SMBCLIENT
################################################################################

!ls

!pwd

!cat arquivo.txt

!id

!whoami

################################################################################
# BAIXAR ARQUIVOS
################################################################################

get flag.txt

get prep-prod.txt

mget *

################################################################################
# BUSCAR FLAG
################################################################################

ls

recurse ON

ls

cd pasta

ls

get flag.txt

!cat flag.txt

################################################################################
# ETAPA 4 - ENUMERAÇÃO VIA RPC
################################################################################

rpcclient -U "" $TARGET

# senha:
# ENTER

################################################################################
# COMANDOS IMPORTANTES DO RPCCLIENT
################################################################################

srvinfo

enumdomains

querydominfo

netshareenumall

netsharegetinfo SHARE

enumdomusers

queryuser RID

querygroup RID

################################################################################
# EXEMPLOS
################################################################################

netsharegetinfo sambashare

netsharegetinfo notes

queryuser 0x3e8

queryuser 0x3e9

querygroup 0x201

################################################################################
# BRUTE FORCE DE RIDs
################################################################################

for i in $(seq 500 1100); do
rpcclient -N -U "" $TARGET \
-c "queryuser 0x$(printf '%x\n' $i)" \
| grep "User Name\|user_rid\|group_rid" && echo ""
done

################################################################################
# ETAPA 5 - SMBMAP
################################################################################

smbmap -H $TARGET

smbmap -H $TARGET -u '' -p ''

# Mostra

# Shares
# Permissões
# READ
# WRITE
# READ/WRITE

################################################################################
# ETAPA 6 - CRACKMAPEXEC
################################################################################

crackmapexec smb $TARGET --shares -u '' -p ''

# Em versões novas

nxc smb $TARGET --shares -u '' -p ''

################################################################################
# ETAPA 7 - ENUM4LINUX-NG
################################################################################

git clone https://github.com/cddmp/enum4linux-ng.git

cd enum4linux-ng

pip3 install -r requirements.txt

./enum4linux-ng.py $TARGET -A

################################################################################
# O ENUM4LINUX RETORNA
################################################################################

# NetBIOS

# Workgroup

# Hostname

# SMB Version

# SMB Signing

# SMB Dialects

# RPC

# Domain

# SID

# Usuários

# Shares

# Políticas

# Senhas

# Lockout

# Impressoras

################################################################################
# ETAPA 8 - IMPACKET
################################################################################

samrdump.py $TARGET

# versões novas

impacket-samrdump $TARGET

################################################################################
# O SAMRDUMP RETORNA
################################################################################

# usuários

# grupos

# UID

# PasswordLastSet

# LogonCount

# PasswordDoesNotExpire

################################################################################
# ENUMERAÇÃO MANUAL MAIS IMPORTANTE
################################################################################

srvinfo

enumdomains

querydominfo

netshareenumall

netsharegetinfo SHARE

enumdomusers

queryuser RID

querygroup RID

################################################################################
# RESOLUÇÃO DAS QUESTÕES DO HTB
################################################################################

###############################################################################
# QUESTÃO 1
# What version of the SMB server is running?
###############################################################################

sudo nmap -Pn -sV -sC -p139,445 $TARGET

# Procurar

# Samba smbd X.X.X

###############################################################################
# QUESTÃO 2
# Accessible Share
###############################################################################

smbclient -N -L //$TARGET

smbmap -H $TARGET

###############################################################################
# QUESTÃO 3
# Encontrar flag.txt
###############################################################################

smbclient //$TARGET/sambashare -N

ls

recurse ON

ls

get flag.txt

!cat flag.txt

###############################################################################
# QUESTÃO 4
# Descobrir domínio
###############################################################################

rpcclient -U "" $TARGET

querydominfo

enumdomains

###############################################################################
# QUESTÃO 5
# Informações detalhadas do share
###############################################################################

netshareenumall

netsharegetinfo sambashare

# observar

remark

################################################################################
# QUESTÃO 6
# Descobrir path completo
################################################################################

netsharegetinfo sambashare

# saída

path: C:\home\sambauser\

# Converter para Linux

/home/sambauser

################################################################################
# OUTRAS CONSULTAS ÚTEIS DO RPCCLIENT
################################################################################

lsaquery

lookupnames administrator

lookupnames guest

lookupnames root

lookupnames backup

lookupnames user

enumalsgroups builtin

enumalsgroups domain

enumdomgroups

getusername

getdispinfo

querydispinfo

queryusergroups RID

querygroupmem RID

queryaliasmem builtin RID

################################################################################
# NSE ÚTEIS DO NMAP PARA SMB
################################################################################

sudo nmap --script smb-os-discovery -p445 $TARGET

sudo nmap --script smb-enum-shares -p445 $TARGET

sudo nmap --script smb-enum-users -p445 $TARGET

sudo nmap --script smb-enum-domains -p445 $TARGET

sudo nmap --script smb-enum-groups -p445 $TARGET

sudo nmap --script smb-security-mode -p445 $TARGET

sudo nmap --script smb2-security-mode -p445 $TARGET

sudo nmap --script smb2-time -p445 $TARGET

sudo nmap --script smb-protocols -p445 $TARGET

sudo nmap --script smb-system-info -p445 $TARGET

################################################################################
# FLUXO COMPLETO DE ENUMERAÇÃO SMB
################################################################################

# Spawn máquina
#
#      │
#      ▼
#
# Descobrir portas
#
sudo nmap -Pn -sV -sC -p139,445 $TARGET
#
#      │
#      ▼
#
# Enumerar Shares
#
smbclient -N -L //$TARGET
#
#      │
#      ▼
#
# Confirmar permissões
#
smbmap -H $TARGET
#
#      │
#      ▼
#
# Conectar ao share
#
smbclient //$TARGET/SHARE -N
#
#      │
#      ▼
#
# Procurar arquivos
#
ls
#
recurse ON
#
ls
#
#      │
#      ▼
#
# Baixar arquivos
#
get flag.txt
#
#      │
#      ▼
#
# Ler arquivos
#
!cat flag.txt
#
#      │
#      ▼
#
# RPC Enumeration
#
rpcclient -U "" $TARGET
#
srvinfo
#
enumdomains
#
querydominfo
#
netshareenumall
#
netsharegetinfo SHARE
#
enumdomusers
#
queryuser RID
#
querygroup RID
#
#      │
#      ▼
#
# Enumeração automática
#
samrdump.py
#
enum4linux-ng
#
crackmapexec
#
smbmap
#
#      │
#      ▼
#
# Correlacionar todas as informações
#
# SMB Version
# Shares
# Usuários
# Domínio
# Permissões
# Paths
# Comentários
# Políticas
# Password Policy
#
#      │
#      ▼
#
# Responder todas as questões do HTB
#
################################################################################


################################################################################
# FERRAMENTAS UTILIZADAS NESTA AULA
################################################################################

# nmap
# smbclient
# rpcclient
# smbmap
# CrackMapExec (CME)
# NetExec (NXC)
# enum4linux-ng
# samrdump.py (Impacket)

################################################################################
# LINKS OFICIAIS DA AULA
################################################################################

# RPC
# https://www.geeksforgeeks.org/operating-systems/remote-procedure-call-rpc-in-operating-system/

# Impacket
# https://github.com/fortra/impacket

# samrdump.py
# https://github.com/fortra/impacket/blob/master/examples/samrdump.py

# SMBMap
# https://github.com/ShawnDEvans/smbmap

# CrackMapExec
# https://github.com/byt3bl33d3r/CrackMapExec

# Enum4Linux-NG
# https://github.com/cddmp/enum4linux-ng

# NBNS
# https://networkencyclopedia.com/netbios-name-server-nbns/

# WINS
# https://networkencyclopedia.com/windows-internet-name-service-wins/

# Samba smb.conf
# https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html

# Microsoft SMB
# https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smb/f210069c-7086-4dc2-885e-861d837df688

# SMB2 Specification
# https://web.archive.org/web/20240815212710/https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SMB2/%5BMS-SMB2%5D.pdf

################################################################################
# FIM DA DOCUMENTAÇÃO
################################################################################