#!/bin/bash

####################################################################################################
# HTB Academy - Footprinting
# SMTP (Simple Mail Transfer Protocol)
#
# RESUMO COMPLETO DA AULA
#
# Objetivo:
# Aprender a identificar, enumerar e explorar servidores SMTP durante um Pentest.
#
####################################################################################################





####################################################################################################
# O QUE É SMTP
####################################################################################################

#
# SMTP (Simple Mail Transfer Protocol) é o protocolo responsável
# pelo ENVIO de emails.
#
# Ele NÃO recebe emails.
#
# Receber emails é função do:
#
# POP3
# IMAP
#

#
# Fluxo do email:
#
# Usuário
#    │
#    ▼
# MUA (Outlook, Thunderbird...)
#    │
#    ▼
# MSA (Submission Agent)
#    │
#    ▼
# MTA (Postfix, Exim, Exchange...)
#    │
#    ▼
# MDA
#    │
#    ▼
# Mailbox (POP3 / IMAP)
#





####################################################################################################
# PORTAS IMPORTANTES
####################################################################################################

#
# 25/TCP
# SMTP tradicional
# Comunicação entre servidores
#

#
# 587/TCP
# Submission
# Cliente autenticado
# STARTTLS
#

#
# 465/TCP
# SMTP sobre TLS
# TLS inicia imediatamente
#





####################################################################################################
# SMTP x ESMTP
####################################################################################################

#
# HELO
#
# SMTP tradicional.
#

#
# EHLO
#
# ESMTP.
#
# Sempre utilizar EHLO.
#

#
# ESMTP adiciona:
#
# AUTH
# STARTTLS
# PIPELINING
# SIZE
# SMTPUTF8
# DSN
# CHUNKING
#





####################################################################################################
# PRINCIPAIS COMANDOS SMTP
####################################################################################################

#
# HELO
# Inicia SMTP
#

#
# EHLO
# Inicia ESMTP
#

#
# AUTH
# Autenticação
#

#
# MAIL FROM
# Define remetente
#

#
# RCPT TO
# Define destinatário
#

#
# DATA
# Inicia corpo do email
# Finaliza com "."
#

#
# VRFY
# Verifica existência de usuário
#

#
# EXPN
# Expande aliases
#

#
# RSET
# Reinicia transação
#

#
# NOOP
# Mantém conexão
#

#
# QUIT
# Fecha sessão
#





####################################################################################################
# STARTTLS
####################################################################################################

#
# SMTP originalmente transmite tudo em texto puro.
#

#
# STARTTLS converte a conexão
# para TLS.
#

#
# Fluxo:
#
# EHLO
# STARTTLS
# EHLO novamente
# AUTH
# MAIL FROM
# RCPT TO
# DATA
#





####################################################################################################
# HEADER SMTP
####################################################################################################

#
# Estrutura RFC5322:
#
# Header
#
# Linha vazia
#
# Body
#

#
# Campos importantes:
#
# From
# To
# Subject
# Date
# Message-ID
# Return-Path
# Received
#

#
# "Received"
# normalmente é o cabeçalho mais interessante
# para Footprinting.
#
# Pode revelar:
#
# IPs
# Hostnames
# Gateways
# Servidores internos
# Caminho completo do email
#





####################################################################################################
# POSTFIX
####################################################################################################

#
# Servidor SMTP mais comum em Linux.
#

#
# Arquivo principal:
#

cat /etc/postfix/main.cf

#
# Remover comentários:
#

cat /etc/postfix/main.cf | grep -v "#" | sed -r "/^\s*$/d"

#
# Configurações importantes:
#
# smtpd_banner
# myhostname
# mydestination
# mynetworks
# smtp_bind_address
# inet_protocols
# home_mailbox
#





####################################################################################################
# SPF
####################################################################################################

#
# Sender Policy Framework
#

#
# Registro TXT no DNS.
#

dig TXT dominio.com

#
# Define quais servidores
# podem enviar emails
# para determinado domínio.
#





####################################################################################################
# DKIM
####################################################################################################

#
# DomainKeys Identified Mail
#

#
# Assina criptograficamente
# o email.
#

#
# Chave pública no DNS.
#

dig TXT selector._domainkey.dominio.com





####################################################################################################
# DMARC
####################################################################################################

#
# Trabalha junto com:
#
# SPF
# DKIM
#

#
# Política:
#
# none
# quarantine
# reject
#

dig TXT _dmarc.dominio.com





####################################################################################################
# OPEN RELAY
####################################################################################################

#
# Relay
#
# Encaminhamento de emails.
#

#
# Open Relay
#
# Qualquer pessoa pode usar
# o servidor SMTP.
#

#
# Muito utilizado para:
#
# Spam
# Phishing
# Malware
#

#
# Configuração insegura:
#

#
# mynetworks = 0.0.0.0/0
#





####################################################################################################
# ENUMERAÇÃO SMTP
####################################################################################################

#
# Descobrir serviço e versão.
#

sudo nmap -Pn -sV -sC -p25 $TARGET

#
# Descobrir banner.
#

nc -nv $TARGET 25

#
# Banner encontrado:
#

#
# 220 InFreight ESMTP v2.11
#

#
# Descobrir comandos disponíveis.
#

sudo nmap -Pn -p25 \
--script smtp-commands \
$TARGET

#
# Exemplo de resposta:
#
# PIPELINING
# SIZE
# STARTTLS
# VRFY
# SMTPUTF8
# CHUNKING
#





####################################################################################################
# ENUMERAÇÃO DE USUÁRIOS
####################################################################################################

#
# Nmap:
#

sudo nmap \
-p25 \
--script smtp-enum-users \
--script-args userdb=usuarios.txt \
$TARGET

#
# Problema:
#
# Muitos falsos positivos.
#

#
# Validar manualmente:
#

nc -nv $TARGET 25

#
# Depois:
#

EHLO test.htb

VRFY robin

QUIT

#
# Melhor ferramenta:
#

smtp-user-enum \
-M VRFY \
-U usuarios.txt \
-t $TARGET \
-m 1 \
-w 20 \
-v

#
# Explicação:
#
# -M
# Método
#
# -U
# Wordlist
#
# -t
# Target
#
# -m 1
# Apenas uma conexão
#
# -w 20
# Timeout de 20 segundos
#
# -v
# Verbose
#

#
# No laboratório:
#
# Usuário encontrado:
#
# robin
#





####################################################################################################
# OPEN RELAY
####################################################################################################

sudo nmap \
-p25 \
--script smtp-open-relay \
-v \
$TARGET

#
# Testa se o servidor
# permite relay aberto.
#





####################################################################################################
# ENVIO MANUAL DE EMAIL
####################################################################################################

telnet $TARGET 25

EHLO empresa.com

MAIL FROM:<teste@empresa.com>

RCPT TO:<usuario@empresa.com>

DATA

From: teste@empresa.com

To: usuario@empresa.com

Subject: Teste

Mensagem.

.

QUIT





####################################################################################################
# OPENSSL
####################################################################################################

#
# Testar STARTTLS.
#

openssl s_client \
-connect $TARGET:25 \
-starttls smtp

#
# Porta 587.
#

openssl s_client \
-connect $TARGET:587 \
-starttls smtp

#
# Porta 465.
#

openssl s_client \
-connect $TARGET:465





####################################################################################################
# FLUXO DE ENUMERAÇÃO SMTP
####################################################################################################

#
# Descobrir porta
#

nmap

#
# ▼
#

Banner

#
# ▼
#

Versão

#
# ▼
#

smtp-commands

#
# ▼
#

EHLO

#
# ▼
#

VRFY

#
# ▼
#

smtp-user-enum

#
# ▼
#

Open Relay

#
# ▼
#

Validação Manual

#
# ▼
#

Usuário existente

#
# ▼
#

Responder laboratório
#





####################################################################################################
# RESOLUÇÃO DO LABORATÓRIO HTB
####################################################################################################

#
# 1.
#

export TARGET=10.129.70.229

#
# 2.
#

sudo nmap -Pn -sV -sC -p25 $TARGET

#
# Descoberto:
#
# Postfix smtpd
#

#
# 3.
#

nc -nv $TARGET 25

#
# Banner:
#
# InFreight ESMTP v2.11
#

#
# Questão 1:
#
# InFreight ESMTP v2.11
#

#
# 4.
#

sudo nmap \
-p25 \
--script smtp-commands \
$TARGET

#
# Descobrir:
#
# VRFY
# STARTTLS
# PIPELINING
# etc
#

#
# 5.
#

sudo nmap \
-p25 \
--script smtp-enum-users \
--script-args userdb=usuarios.txt \
$TARGET

#
# Resultado:
#
# Muitos falsos positivos.
#

#
# 6.
#

smtp-user-enum \
-M VRFY \
-U estaaqui.txt \
-t $TARGET \
-m 1 \
-w 20 \
-v

#
# Resultado:
#
# robin exists
#

#
# Questão 2:
#
# robin
#





####################################################################################################
# COMANDOS UTILIZADOS NA AULA
####################################################################################################

export TARGET=...

cat /etc/postfix/main.cf

cat /etc/postfix/main.cf | grep -v "#" | sed -r "/^\s*$/d"

sudo nmap -Pn -sV -sC -p25 $TARGET

sudo nmap -Pn -p25 --script smtp-commands $TARGET

sudo nmap -Pn -p25 --script smtp-enum-users --script-args userdb=...

sudo nmap -p25 --script smtp-open-relay -v $TARGET

nc -nv $TARGET 25

telnet $TARGET 25

smtp-user-enum -h

smtp-user-enum -M VRFY -U users.txt -t $TARGET

smtp-user-enum -M VRFY -U users.txt -t $TARGET -m 1 -w 20 -v

openssl s_client -connect $TARGET:25 -starttls smtp

openssl s_client -connect $TARGET:587 -starttls smtp

openssl s_client -connect $TARGET:465

dig TXT dominio.com

dig TXT selector._domainkey.dominio.com

dig TXT _dmarc.dominio.com

printf '\0usuario\0senha' | base64

printf 'BASE64' | base64 -d

HELO
EHLO
AUTH
MAIL FROM
RCPT TO
DATA
VRFY
EXPN
RSET
NOOP
QUIT





####################################################################################################
# RESUMO FINAL
####################################################################################################

#
# ✔ SMTP envia emails.
#
# ✔ POP3 e IMAP recebem emails.
#
# ✔ SMTP trabalha principalmente nas portas 25, 465 e 587.
#
# ✔ EHLO inicia ESMTP e revela as capacidades do servidor.
#
# ✔ STARTTLS protege a comunicação SMTP.
#
# ✔ O banner SMTP pode revelar software, hostname e versão.
#
# ✔ VRFY, EXPN e RCPT TO podem ser usados para enumerar usuários.
#
# ✔ Ferramentas automáticas podem gerar falsos positivos.
#
# ✔ smtp-user-enum é mais confiável para validar usuários SMTP.
#
# ✔ Cabeçalhos "Received" são excelentes fontes de Footprinting.
#
# ✔ SPF define quem pode enviar emails pelo domínio.
#
# ✔ DKIM garante integridade da mensagem.
#
# ✔ DMARC aplica políticas baseadas em SPF e DKIM.
#
# ✔ Open Relay é uma configuração insegura que permite envio de emails
#    por terceiros.
#
# ✔ Durante um Pentest, a sequência ideal é:
#
#    Nmap
#      ↓
#    Banner
#      ↓
#    smtp-commands
#      ↓
#    VRFY / EXPN / RCPT TO
#      ↓
#    smtp-user-enum
#      ↓
#    Teste de Open Relay
#      ↓
#    Consolidação das evidências
#
####################################################################################################
```