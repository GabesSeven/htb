####################################################################################################
# HTB ACADEMY - FOOTPRINTING - MYSQL
# PARTE 4 - CHEATSHEET PROFISSIONAL, METODOLOGIA E RESUMO FINAL
#
# Objetivo desta parte
# --------------------
# Esta parte reúne todo o conhecimento da aula em um guia rápido de consulta.
#
# O foco é criar uma metodologia reutilizável para qualquer Pentest ou CTF
# envolvendo MySQL.
#
# Ao terminar esta parte você terá:
#
# ✓ Fluxo completo de enumeração
# ✓ Todos os comandos importantes
# ✓ Checklist de Pentest
# ✓ Fluxograma mental
# ✓ Erros comuns
# ✓ Comandos SQL essenciais
# ✓ Sequência utilizada no laboratório
#
####################################################################################################



====================================================================================================
METODOLOGIA COMPLETA DE ENUMERAÇÃO MYSQL
====================================================================================================


Descobrir Host

        │

        ▼

Encontrar Porta 3306

        │

        ▼

Descobrir versão

        │

        ▼

Executar scripts NSE

        │

        ▼

Validar manualmente

        │

        ▼

Obter credenciais

        │

        ▼

Conectar ao Banco

        │

        ▼

Listar Bancos

        │

        ▼

Selecionar Banco

        │

        ▼

Listar Tabelas

        │

        ▼

Listar Colunas

        │

        ▼

Visualizar Registros

        │

        ▼

Pesquisar Informação

        │

        ▼

Responder Objetivo



####################################################################################################
# FASE 1 - DESCOBERTA DO SERVIÇO
####################################################################################################


Criar variável

export TARGET=10.129.71.246



Verificar variável

echo "$TARGET"



Verificar porta

nmap -Pn -p3306 "$TARGET"



Descobrir versão

sudo nmap -Pn -sV -p3306 "$TARGET"



Scripts padrão

sudo nmap -Pn -sV -sC -p3306 "$TARGET"



Scripts MySQL

sudo nmap -Pn -sV -p3306 --script "mysql-*" "$TARGET"



####################################################################################################
# FASE 2 - IDENTIFICAÇÃO
####################################################################################################


Objetivos

✓ Porta

✓ Versão

✓ Plugin

✓ Recursos

✓ Credenciais

✓ Possíveis vulnerabilidades



Informações encontradas no laboratório

Porta

3306


Versão

MySQL 8.0.27


Plugin

caching_sha2_password


Protocol

10


Status

Autocommit



####################################################################################################
# FASE 3 - CONEXÃO
####################################################################################################


Conectar

mysql --skip-ssl -u robin -p -h "$TARGET"



Senha

robin



Após conectar

Welcome to the MariaDB Monitor



####################################################################################################
# FASE 4 - ENUMERAÇÃO DOS BANCOS
####################################################################################################


SHOW DATABASES;



Resultado


customers

information_schema

mysql

performance_schema

sys



Banco alvo

customers



####################################################################################################
# FASE 5 - ENTRAR NO BANCO
####################################################################################################


USE customers;



Nunca esquecer

Banco ≠ Tabela



####################################################################################################
# FASE 6 - ENUMERAR TABELAS
####################################################################################################


SHOW TABLES;



Resultado

myTable



####################################################################################################
# FASE 7 - ENUMERAR COLUNAS
####################################################################################################


SHOW COLUMNS FROM myTable;



ou

DESCRIBE myTable;



Resultado

id

name

email

country

postalZip

city

address

pan

cvv



####################################################################################################
# FASE 8 - ENUMERAR DADOS
####################################################################################################


Mostrar tudo

SELECT *
FROM myTable;



Mostrar poucos registros

SELECT *
FROM myTable
LIMIT 10;



Pesquisar cliente

SELECT *
FROM myTable
WHERE name='Otto Lang';



Mostrar somente email

SELECT email
FROM myTable
WHERE name='Otto Lang';



####################################################################################################
# COMANDOS SQL MAIS IMPORTANTES
####################################################################################################


SHOW DATABASES;

Lista Bancos.



USE banco;

Seleciona Banco.



SHOW TABLES;

Lista tabelas.



SHOW COLUMNS FROM tabela;

Lista colunas.



DESCRIBE tabela;

Descreve estrutura.



SELECT *

Seleciona tudo.



FROM

Tabela utilizada.



WHERE

Filtra registros.



LIKE

Busca parcial.



LIMIT

Limita resultados.



####################################################################################################
# CONSULTAS MAIS UTILIZADAS DURANTE PENTEST
####################################################################################################


Versão

SELECT VERSION();



Banco atual

SELECT DATABASE();



Usuário conectado

SELECT USER();



Usuário efetivo

SELECT CURRENT_USER();



Hostname

SELECT @@hostname;



Porta

SELECT @@port;



Diretório dos Bancos

SELECT @@datadir;



Mostrar variáveis

SHOW VARIABLES;



Mostrar privilégios

SHOW GRANTS;



####################################################################################################
# INFORMATION_SCHEMA
####################################################################################################


Muito utilizado em SQL Injection.


Descobrir tabelas

SELECT table_name
FROM information_schema.tables;



Descobrir colunas

SELECT table_name,column_name
FROM information_schema.columns;



Descobrir tabelas com email

SELECT table_name,column_name
FROM information_schema.columns
WHERE column_name LIKE '%email%';



####################################################################################################
# ERROS ENCONTRADOS DURANTE O LAB
####################################################################################################


Erro

Too many connections


Causa

mysql-brute abriu milhares de conexões.


Solução

Resetar alvo.



------------------------------------------------------------


Erro

Unknown variable ssl-mode


Causa

Cliente MariaDB.


Solução

Utilizar

--skip-ssl



------------------------------------------------------------


Erro

Table customers.customers doesn't exist


Causa

Banco confundido com tabela.


Solução

SHOW TABLES



------------------------------------------------------------


Erro

SELETC


Causa

Erro de digitação.


Solução

SELECT



####################################################################################################
# CHECKLIST DE ENUMERAÇÃO MYSQL
####################################################################################################


[ ] Descobrir porta

[ ] Descobrir versão

[ ] Descobrir plugin

[ ] Descobrir protocolo

[ ] Validar informações

[ ] Conectar

[ ] Listar bancos

[ ] Selecionar banco

[ ] Listar tabelas

[ ] Listar colunas

[ ] Entender estrutura

[ ] Localizar registros

[ ] Extrair informação



####################################################################################################
# FLUXO MENTAL
####################################################################################################


Servidor

↓

3306

↓

MySQL

↓

Versão

↓

Credenciais

↓

Conexão

↓

SHOW DATABASES

↓

USE

↓

SHOW TABLES

↓

SHOW COLUMNS

↓

SELECT

↓

WHERE

↓

Resultado



####################################################################################################
# RESUMO DA QUESTÃO 1
####################################################################################################


Objetivo

Descobrir versão.


Ferramenta

Nmap


Comando

sudo nmap -Pn -sV -p3306 "$TARGET"



Resposta

MySQL 8.0.27



####################################################################################################
# RESUMO DA QUESTÃO 2
####################################################################################################


Objetivo

Encontrar email de Otto Lang.


Fluxo

Conectar

↓

SHOW DATABASES

↓

USE customers

↓

SHOW TABLES

↓

myTable

↓

SHOW COLUMNS

↓

name

↓

email

↓

SELECT

↓

Responder HTB



####################################################################################################
# TODOS OS COMANDOS IMPORTANTES DA AULA
####################################################################################################


##############################
# SISTEMA
##############################

export TARGET=10.129.71.246

echo "$TARGET"

sudo apt update

sudo apt install mysql-server -y

sudo apt install default-mysql-client -y

mysql --version



##############################
# NMAP
##############################

nmap -Pn -p3306 "$TARGET"

sudo nmap -Pn -sV -p3306 "$TARGET"

sudo nmap -Pn -sV -sC -p3306 "$TARGET"

sudo nmap -Pn -sV -p3306 --script "mysql-*"



##############################
# MYSQL CLIENT
##############################

mysql -u robin -p -h "$TARGET"

mysql --skip-ssl -u robin -p -h "$TARGET"



##############################
# MYSQL
##############################

SHOW DATABASES;

USE customers;

SHOW TABLES;

SHOW COLUMNS FROM myTable;

DESCRIBE myTable;

SELECT * FROM myTable;

SELECT * FROM myTable LIMIT 10;

SELECT * FROM myTable
WHERE name='Otto Lang';

SELECT email FROM myTable
WHERE name='Otto Lang';

SELECT VERSION();

SELECT DATABASE();

SELECT USER();

SELECT CURRENT_USER();

SHOW GRANTS;



####################################################################################################
# PRINCIPAIS LIÇÕES DA AULA
####################################################################################################


✓ MySQL normalmente utiliza TCP 3306.

✓ Nem todo serviço identificado pelo Nmap está correto.

✓ Scripts NSE podem gerar falsos positivos.

✓ Sempre validar manualmente.

✓ Nunca executar brute force sem necessidade.

✓ SHOW DATABASES é o primeiro comando após conectar.

✓ Banco e tabela são conceitos diferentes.

✓ SHOW TABLES mostra apenas as tabelas do banco atual.

✓ SHOW COLUMNS permite entender completamente a estrutura.

✓ SELECT recupera dados.

✓ WHERE filtra registros.

✓ LIKE faz buscas parciais.

✓ LIMIT reduz a quantidade de resultados.

✓ O processo correto de enumeração é sempre:

Servidor

↓

Banco

↓

Tabela

↓

Coluna

↓

Registro

↓

Informação desejada



####################################################################################################
# CONCLUSÃO GERAL DA AULA MYSQL
####################################################################################################

Ao concluir esta aula você aprendeu:

✓ Como funciona um servidor MySQL.

✓ Como aplicações Web armazenam informações.

✓ Como descobrir um servidor MySQL durante um Pentest.

✓ Como identificar sua versão.

✓ Como interpretar scripts NSE.

✓ Como validar manualmente as descobertas.

✓ Como conectar utilizando credenciais válidas.

✓ Como navegar por bancos de dados.

✓ Como enumerar tabelas.

✓ Como descobrir colunas.

✓ Como consultar registros.

✓ Como localizar informações específicas.

✓ Como resolver completamente o laboratório do HTB.

Este fluxo é exatamente a metodologia utilizada por Pentesters durante a fase
de Footprinting e Enumeration quando encontram um serviço MySQL exposto.

####################################################################################################
# FIM DA PARTE 4
####################################################################################################