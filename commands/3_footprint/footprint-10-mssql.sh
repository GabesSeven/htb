#!/bin/bash

###############################################################################################################
# X10THINK - HTB Academy Footprinting - Aula 14 - MSSQL (Microsoft SQL Server)
#
# Objetivo da Aula
# ----------------
# Aprender a identificar, enumerar e acessar um servidor Microsoft SQL Server (MSSQL),
# coletando o máximo de informações possíveis antes de qualquer exploração.
#
# Nesta aula aprendemos:
#
# • Identificar um servidor MSSQL
# • Descobrir hostname
# • Descobrir versão do SQL Server
# • Descobrir versão do Windows
# • Descobrir instância SQL
# • Descobrir se Named Pipes estão habilitados
# • Descobrir se DAC está habilitado
# • Descobrir databases existentes
# • Autenticar utilizando Windows Authentication
# • Utilizar o Impacket mssqlclient
# • Enumerar databases
# • Identificar databases padrão
# • Identificar databases criadas pela empresa
#
###############################################################################################################



###############################################################################################################
# PORTAS IMPORTANTES
###############################################################################################################

# MSSQL
1433/TCP

# SQL Browser
1434/UDP



###############################################################################################################
# DATABASES PADRÃO DO MSSQL
###############################################################################################################

master
model
msdb
tempdb
resource



###############################################################################################################
# O QUE CADA DATABASE FAZ
###############################################################################################################

master
# Guarda toda configuração do SQL Server
# Usuários
# Databases
# Permissões
# Configuração da instância

model
# Modelo utilizado para criar novos bancos

msdb
# Jobs
# Agendamentos
# Backups
# SQL Agent

tempdb
# Objetos temporários
# Tabelas temporárias

resource
# Objetos internos do SQL Server
# Somente leitura



###############################################################################################################
# AUTENTICAÇÃO
###############################################################################################################

# SQL Authentication

sa
usuario
senha

# Windows Authentication

DOMINIO\usuario

ou

Administrator



###############################################################################################################
# SERVIÇO PADRÃO
###############################################################################################################

NT SERVICE\MSSQLSERVER



###############################################################################################################
# CLIENTES MSSQL
###############################################################################################################

SSMS

HeidiSQL

SQLPro

SQL Server PowerShell

mssql-cli

Impacket mssqlclient.py



###############################################################################################################
# LOCALIZANDO O MSSQLCLIENT
###############################################################################################################

locate mssqlclient

# Resultado esperado

/usr/bin/impacket-mssqlclient

/usr/share/doc/python3-impacket/examples/mssqlclient.py



###############################################################################################################
# ENUMERAÇÃO INICIAL
###############################################################################################################

# Descobrir serviço MSSQL

sudo nmap -sV -p1433 $TARGET



###############################################################################################################
# ENUMERAÇÃO COMPLETA COM NSE
###############################################################################################################

sudo nmap \
--script ms-sql-info,\
ms-sql-empty-password,\
ms-sql-xp-cmdshell,\
ms-sql-config,\
ms-sql-ntlm-info,\
ms-sql-tables,\
ms-sql-hasdbaccess,\
ms-sql-dac,\
ms-sql-dump-hashes \
-sV \
-p1433 \
$TARGET



###############################################################################################################
# COMANDO UTILIZADO DURANTE O LAB
###############################################################################################################

sudo nmap -sV -sC \
--script ms-sql-info,ms-sql-ntlm-info \
-p1433 \
$TARGET



###############################################################################################################
# INFORMAÇÕES IMPORTANTES EXTRAÍDAS DO NMAP
###############################################################################################################

Hostname

ILF-SQL-01

Versão

Microsoft SQL Server 2019

Versão Windows

10.0.17763

Instância

MSSQLSERVER

Porta

1433



###############################################################################################################
# O SCRIPT ms-sql-info RETORNA
###############################################################################################################

Versão

Instância

Porta

Named Pipes

Cluster



###############################################################################################################
# O SCRIPT ms-sql-ntlm-info RETORNA
###############################################################################################################

Hostname

NetBIOS

Computer Name

Domain Name

Versão Windows



###############################################################################################################
# OUTROS SCRIPTS IMPORTANTES
###############################################################################################################

ms-sql-empty-password

# testa senha vazia

ms-sql-config

# mostra configurações

ms-sql-dac

# verifica Dedicated Admin Connection

ms-sql-hasdbaccess

# verifica databases acessíveis

ms-sql-dump-hashes

# tenta extrair hashes

ms-sql-tables

# lista tabelas

ms-sql-xp-cmdshell

# verifica se xp_cmdshell está habilitado



###############################################################################################################
# ENUMERAÇÃO COM METASPLOIT
###############################################################################################################

msfconsole

use auxiliary/scanner/mssql/mssql_ping

set RHOSTS $TARGET

run



###############################################################################################################
# CONECTANDO VIA IMPACKET
###############################################################################################################

impacket-mssqlclient backdoor@$TARGET -windows-auth



###############################################################################################################
# CREDENCIAL UTILIZADA
###############################################################################################################

Usuário

backdoor

Senha

Password1



###############################################################################################################
# O QUE O CLIENTE MOSTROU AO CONECTAR
###############################################################################################################

Encryption required

Switching to TLS

Database atual

master

Language

us_english

Servidor

ILF-SQL-01



###############################################################################################################
# LISTAR DATABASES
###############################################################################################################

SELECT name
FROM sys.databases;



###############################################################################################################
# RESULTADO OBTIDO
###############################################################################################################

master

tempdb

model

msdb

Employees



###############################################################################################################
# IDENTIFICAR APENAS DATABASES NÃO PADRÃO
###############################################################################################################

SELECT name
FROM sys.databases
WHERE name NOT IN
(
'master',
'tempdb',
'model',
'msdb'
);



###############################################################################################################
# RESULTADO
###############################################################################################################

Employees



###############################################################################################################
# TROCAR DE DATABASE
###############################################################################################################

USE Employees;



###############################################################################################################
# OBSERVAÇÃO IMPORTANTE
###############################################################################################################

# GO NÃO FUNCIONA NO mssqlclient.py

GO

# Retorna

Could not find stored procedure 'GO'



###############################################################################################################
# LISTAR TABELAS
###############################################################################################################

SELECT name
FROM sys.tables;



###############################################################################################################
# LISTAR COLUNAS
###############################################################################################################

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS;



###############################################################################################################
# LISTAR USUÁRIOS SQL
###############################################################################################################

SELECT name
FROM sys.sql_logins;



###############################################################################################################
# VER USUÁRIO LOGADO
###############################################################################################################

SELECT SYSTEM_USER;



###############################################################################################################
# VER VERSÃO
###############################################################################################################

SELECT @@VERSION;



###############################################################################################################
# VERIFICAR SE É SYSADMIN
###############################################################################################################

SELECT IS_SRVROLEMEMBER('sysadmin');



###############################################################################################################
# DESCOBRIR TAMANHO DO NOME DA DATABASE
###############################################################################################################

SELECT '[' + name + ']' AS database_name,
LEN(name) AS characters,
DATALENGTH(name) AS bytes
FROM sys.databases
WHERE database_id > 4;



###############################################################################################################
# VERIFICAR ESPAÇOS OCULTOS
###############################################################################################################

SELECT QUOTENAME(name)
FROM sys.databases
WHERE name NOT IN
(
'master',
'tempdb',
'model',
'msdb'
);



###############################################################################################################
# DATABASES PADRÃO X CUSTOMIZADAS
###############################################################################################################

Padrão

master

model

msdb

tempdb

resource

Customizadas

Employees



###############################################################################################################
# COMANDOS EXECUTADOS DURANTE O LAB
###############################################################################################################

export TARGET=10.129.230.249

sudo nmap -sV -sC \
--script ms-sql-info,ms-sql-ntlm-info \
-p1433 \
$TARGET

impacket-mssqlclient backdoor@$TARGET -windows-auth

SELECT name FROM sys.databases;

SELECT name
FROM sys.databases
WHERE name NOT IN
(
'master',
'tempdb',
'model',
'msdb'
);

USE Employees;

SELECT name
FROM sys.tables;



###############################################################################################################
# RESPOSTAS DAS QUESTÕES
###############################################################################################################

Questão 1

Hostname

ILF-SQL-01


Questão 2

Database não padrão

Employees



###############################################################################################################
# FLUXO COMPLETO UTILIZADO NA ENUMERAÇÃO
###############################################################################################################

1433 aberta

↓

Executar Nmap

↓

Descobrir

Hostname

↓

Versão SQL

↓

Versão Windows

↓

Instância SQL

↓

Named Pipes

↓

Conseguir credenciais

↓

Conectar utilizando

impacket-mssqlclient

↓

Autenticar utilizando

Windows Authentication

↓

Entrar na database master

↓

Listar todas as databases

↓

Descobrir databases padrão

↓

Identificar database criada pela empresa

↓

Entrar na database Employees

↓

Enumerar tabelas

↓

Enumerar colunas

↓

Enumerar usuários

↓

Verificar privilégios

↓

Procurar credenciais

↓

Verificar xp_cmdshell

↓

Executar comandos do Windows (caso permitido)



###############################################################################################################
# PRINCIPAIS APRENDIZADOS
###############################################################################################################

✔ MSSQL normalmente escuta na porta TCP 1433

✔ SQL Browser utiliza UDP 1434

✔ Windows Authentication é muito comum

✔ O Impacket mssqlclient.py é o cliente preferido durante pentests

✔ sys.databases equivale ao SHOW DATABASES do MySQL

✔ master é a database mais importante do SQL Server

✔ model serve como template para novas databases

✔ msdb armazena jobs e backups

✔ tempdb armazena objetos temporários

✔ Sempre diferencie databases padrão das databases criadas pela empresa

✔ A enumeração correta segue:
#
# Descobrir serviço
# ↓
# Descobrir versão
# ↓
# Descobrir hostname
# ↓
# Descobrir instância
# ↓
# Conectar
# ↓
# Listar databases
# ↓
# Encontrar databases customizadas
# ↓
# Enumerar tabelas
# ↓
# Enumerar dados
#
# Este é exatamente o fluxo utilizado em HTB Academy, CPTS, CRTP,
# CEH Practical e em pentests reais contra ambientes Windows.
###############################################################################################################