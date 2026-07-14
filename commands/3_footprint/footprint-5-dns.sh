\
#!/usr/bin/env bash

###############################################################################
# HTB Academy - Footprinting
# Aula 09 - DNS Enumeration (X10THINK)
#
# Este arquivo foi escrito como uma AULA e não apenas um cheatsheet.
#
# Em cada tópico você encontrará:
#   1. O conceito
#   2. Por que isso é importante para um Pentester
#   3. O comando
#   4. Como interpretar a saída
#   5. O próximo passo lógico
#
# Objetivo final:
# Reconstruir a infraestrutura de uma empresa apenas através do DNS.
###############################################################################

###############################################################################
# COMO UM PENTESTER PENSA
###############################################################################
#
# Recebo um domínio.
#
# Antes de pensar em exploração, preciso responder:
#
# - Quem administra esse domínio?
# - Quais servidores existem?
# - Existe infraestrutura interna?
# - Existe Active Directory?
# - Existe VPN?
# - Existe ambiente DEV?
# - Existe ambiente TEST?
# - Existe ambiente interno?
#
# O DNS costuma responder boa parte dessas perguntas.
#
# Fluxo mental:
#
# Domínio
#   |
#   +--> NS
#   +--> SOA
#   +--> MX
#   +--> TXT
#   +--> version.bind
#   +--> ANY
#   +--> AXFR
#           |
#           +--> novas zonas
#           +--> AXFR novamente
#           +--> brute force
#           +--> PTR
#           +--> documentar
#

export TARGET="10.129.42.195"
export DOMAIN="inlanefreight.htb"

###############################################################################
# ETAPA 1 - DESCOBRIR OS NAMESERVERS
###############################################################################
#
# Por quê?
# O NS revela quais servidores possuem autoridade sobre o domínio.
# Muitas vezes servidores diferentes possuem configurações diferentes.
#
# Comando:
dig NS "$DOMAIN" @"$TARGET"
#
# Esperado:
# ns.inlanefreight.htb
#
# Próximo passo:
# Consultar SOA.

###############################################################################
# ETAPA 2 - SOA
###############################################################################
#
# O SOA informa quem administra a zona e fornece o serial utilizado para
# sincronização entre servidores DNS.
#
dig SOA "$DOMAIN" @"$TARGET"

###############################################################################
# ETAPA 3 - MX
###############################################################################
#
# O MX revela a infraestrutura de e-mail.
# Pode indicar Office365, Google Workspace, Exchange, Mailgun, SES...
#
dig MX "$DOMAIN" @"$TARGET"

###############################################################################
# ETAPA 4 - TXT
###############################################################################
#
# Um dos registros mais ricos durante o Footprinting.
# Procure por:
# - SPF
# - DMARC
# - verificações Google
# - Microsoft
# - Atlassian
#
dig TXT "$DOMAIN" @"$TARGET"

###############################################################################
# ETAPA 5 - VERSION.BIND
###############################################################################
#
# Tenta descobrir a versão do servidor DNS.
# Se responder, pesquise CVEs específicas.
#
dig CH TXT version.bind @"$TARGET"

###############################################################################
# ETAPA 6 - ANY
###############################################################################
#
# Solicita tudo que o servidor aceitar divulgar.
# Nem todos os servidores modernos respondem completamente.
#
dig ANY "$DOMAIN" @"$TARGET"

###############################################################################
# ETAPA 7 - AXFR (ZONE TRANSFER)
###############################################################################
#
# O teste mais importante da aula.
#
# Um AXFR permitido pode revelar:
# - Hosts
# - VPN
# - Domain Controllers
# - Ambientes internos
# - Bancos de dados
#
dig AXFR "$DOMAIN" @"$TARGET"

###############################################################################
# ETAPA 8 - NOVAS ZONAS
###############################################################################
#
# Sempre analise a saída do AXFR.
# Encontrou "internal", "dev", "corp" ou outra zona?
# Trate-a como um novo alvo.
#
dig AXFR internal.inlanefreight.htb @"$TARGET"
dig SOA dev.inlanefreight.htb @"$TARGET"
dig AXFR dev.inlanefreight.htb @"$TARGET"

###############################################################################
# ETAPA 9 - PTR (REVERSE LOOKUP)
###############################################################################
#
# Quando possuir IPs, tente descobrir seus FQDNs.
#
dig -x 10.129.34.16 @"$TARGET"

###############################################################################
# ETAPA 10 - ENUMERAÇÃO AUTOMÁTICA
###############################################################################
#
# dnsenum
#
dnsenum --dnsserver "$TARGET" --enum "$DOMAIN"
#
# dnsrecon
#
dnsrecon -d "$DOMAIN" -n "$TARGET"

###############################################################################
# ETAPA 11 - BRUTE FORCE DE SUBDOMÍNIOS
###############################################################################
#
# Quando AXFR falhar, tente descobrir hosts por força bruta.
#
for sub in $(cat /opt/useful/seclists/Discovery/DNS/subdomains-top1million-110000.txt); do
    dig +short A "$sub.$DOMAIN" @"$TARGET"
done

###############################################################################
# MAPA MENTAL
###############################################################################
#
# Recebi um domínio
#         │
#         ▼
# Existe DNS?
#         │
#         ▼
# Descobrir NS
#         │
#         ▼
# Descobrir SOA
#         │
#         ▼
# TXT (SPF/DMARC/Cloud)
#         │
#         ▼
# MX (E-mail)
#         │
#         ▼
# Version.bind
#         │
#         ▼
# AXFR
#         │
#         ├──────── Funcionou?
#         │
#         │
#         ├──► SIM
#         │      │
#         │      ▼
#         │ Enumerar toda a infraestrutura
#         │
#         └──► NÃO
#                │
#                ▼
#         Descobrir novas zonas
#                │
#                ▼
#         Brute Force
#                │
#                ▼
#         PTR / Reverse Lookup

###############################################################################
# O QUE APRENDEMOS NO LAB
###############################################################################
#
# Q1:
# NS -> ns.inlanefreight.htb
#
# Q2:
# AXFR permitido na zona principal e na zona internal.
#
# Q3:
# dc1.internal.inlanefreight.htb -> 10.129.34.16
#
# Q4:
# A dica da HTB mostrou que nem toda wordlist possui os mesmos hosts.
# Em alguns laboratórios é necessário trocar a wordlist para encontrar
# determinados subdomínios.
#
###############################################################################
# CHECKLIST FINAL
###############################################################################
#
# [ ] NS
# [ ] SOA
# [ ] MX
# [ ] TXT
# [ ] version.bind
# [ ] ANY
# [ ] AXFR
# [ ] Novas zonas
# [ ] PTR
# [ ] dnsenum
# [ ] dnsrecon
# [ ] Brute Force
# [ ] Documentação da infraestrutura
#
###############################################################################
# DICAS DE PENTEST
###############################################################################
#
# Nunca pare no primeiro AXFR.
# Sempre teste zonas descobertas.
# Nunca utilize apenas uma wordlist.
# Documente tudo.
# O DNS normalmente é a porta de entrada para as próximas fases:
# SMB, LDAP, Kerberos, WinRM, MSSQL, HTTP e Active Directory.
###############################################################################
