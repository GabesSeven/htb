#!/bin/bash

###############################################################################################################
# HTB ACADEMY - FOOTPRINTING
#
# IMAP / POP3 - RESUMO FINAL ESSENCIAL
#
# Este arquivo sintetiza as partes 1, 2 e 3 da aula.
#
# Conteúdo:
#
# - conceitos essenciais;
# - portas e serviços;
# - enumeração com Nmap;
# - análise de certificados;
# - banners;
# - acesso ao IMAP e POP3;
# - leitura das mensagens;
# - busca por flags e e-mails;
# - fluxo usado para atingir os objetivos do laboratório.
#
# USO AUTORIZADO SOMENTE:
#
# - HTB Academy;
# - CTFs;
# - laboratórios próprios;
# - ambientes com autorização explícita.
#
###############################################################################################################


###############################################################################################################
# 1. CONCEITOS PRINCIPAIS
###############################################################################################################

# SMTP:
#
# - envia mensagens;
# - normalmente utiliza as portas 25, 465 e 587.
#
# IMAP:
#
# - lê e gerencia mensagens diretamente no servidor;
# - mantém sincronização entre dispositivos;
# - suporta caixas, buscas, cabeçalhos e partes MIME.
#
# POP3:
#
# - baixa mensagens do servidor;
# - possui menos recursos;
# - pode remover mensagens após o download, dependendo da configuração.
#
# Resumo:
#
# SMTP -> envio
# IMAP -> gerenciamento remoto
# POP3 -> download


###############################################################################################################
# 2. PORTAS IMPORTANTES
###############################################################################################################

# 110/tcp -> POP3
# 143/tcp -> IMAP
# 993/tcp -> IMAPS, TLS implícito
# 995/tcp -> POP3S, TLS implícito
#
# STARTTLS:
#
# IMAP -> porta 143
# POP3 -> porta 110


###############################################################################################################
# 3. DOVECOT
###############################################################################################################

# Dovecot é um servidor IMAP e POP3 muito utilizado em sistemas Linux.
#
# Pode operar junto com:
#
# - Postfix;
# - Exim;
# - Sendmail.
#
# Arquivos relevantes:
#
# /etc/dovecot/dovecot.conf
# /etc/dovecot/conf.d/10-auth.conf
# /etc/dovecot/conf.d/10-mail.conf
# /etc/dovecot/conf.d/10-master.conf
# /etc/dovecot/conf.d/10-ssl.conf
# /etc/dovecot/conf.d/20-imap.conf
# /etc/dovecot/conf.d/20-pop3.conf
#
# Configurações inseguras ou excessivamente verbosas podem revelar:
#
# - usuários;
# - métodos de autenticação;
# - tentativas de login;
# - senhas;
# - erros internos.


###############################################################################################################
# 4. CONFIGURANDO O ALVO
###############################################################################################################

# Atualize sempre que o HTB gerar uma nova máquina.

export TARGET="10.129.42.195"

echo "$TARGET"


###############################################################################################################
# 5. ENUMERAÇÃO PRINCIPAL
###############################################################################################################

sudo nmap -Pn -sV -sC -p110,143,993,995 "$TARGET"

# Parâmetros:
#
# -Pn -> considera o host ativo;
# -sV -> detecta versões;
# -sC -> executa scripts NSE padrão;
# -p  -> define as portas.
#
# Resultados importantes encontrados:
#
# - Dovecot IMAP;
# - Dovecot POP3;
# - certificado TLS;
# - organização;
# - FQDN;
# - capacidades dos serviços.


###############################################################################################################
# 6. SALVANDO O SCAN
###############################################################################################################

sudo nmap -Pn -sV -sC -p110,143,993,995 "$TARGET" \
  -oN nmap_imap_pop3.txt

sudo nmap -Pn -sV -sC -p110,143,993,995 "$TARGET" \
  -oA imap_pop3_scan


###############################################################################################################
# 7. SCRIPTS NSE ÚTEIS
###############################################################################################################

sudo nmap -Pn -p143,993 \
  --script imap-capabilities \
  "$TARGET"

sudo nmap -Pn -p110,995 \
  --script pop3-capabilities \
  "$TARGET"

sudo nmap -Pn -p993,995 \
  --script ssl-cert \
  "$TARGET"

sudo nmap -Pn -p993,995 \
  --script ssl-enum-ciphers \
  "$TARGET"


###############################################################################################################
# 8. INFORMAÇÕES OBTIDAS PELO CERTIFICADO
###############################################################################################################

# O certificado revelou:
#
# Organização:
#
# InlaneFreight Ltd
#
# FQDN:
#
# dev.inlanefreight.htb
#
# Unidade organizacional:
#
# DevOps Department
#
# Contato técnico:
#
# cto.dev@dev.inlanefreight.htb
#
# Atenção:
#
# O endereço cto.dev@dev.inlanefreight.htb pertence ao certificado.
# Ele não foi aceito como o e-mail administrativo solicitado pelo laboratório.


###############################################################################################################
# 9. ANALISANDO O CERTIFICADO IMAPS
###############################################################################################################

openssl s_client -connect "$TARGET:993"

openssl s_client -connect "$TARGET:993" -quiet

openssl s_client \
  -connect "$TARGET:993" \
  -servername dev.inlanefreight.htb


###############################################################################################################
# 10. ANALISANDO O CERTIFICADO POP3S
###############################################################################################################

openssl s_client -connect "$TARGET:995"

openssl s_client -connect "$TARGET:995" -quiet

openssl s_client \
  -connect "$TARGET:995" \
  -servername dev.inlanefreight.htb


###############################################################################################################
# 11. EXTRAINDO O CERTIFICADO
###############################################################################################################

openssl s_client \
  -connect "$TARGET:995" \
  -showcerts </dev/null 2>/dev/null \
  | openssl x509 -outform PEM > pop3_certificate.pem

openssl x509 \
  -in pop3_certificate.pem \
  -subject \
  -issuer \
  -dates \
  -noout

openssl x509 \
  -in pop3_certificate.pem \
  -text \
  -noout


###############################################################################################################
# 12. FILTRANDO INFORMAÇÕES
###############################################################################################################

grep -Ei \
  "commonName|organizationName|stateOrProvinceName|countryName" \
  nmap_imap_pop3.txt

openssl x509 \
  -in pop3_certificate.pem \
  -text \
  -noout \
  | grep -Eio \
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'


###############################################################################################################
# 13. ENUMERAÇÃO DO BANNER POP3
###############################################################################################################

nc "$TARGET" 110

nc -nv "$TARGET" 110

telnet "$TARGET" 110

openssl s_client -connect "$TARGET:995" -quiet

# Banner confirmado:
#
# +OK InFreight POP3 v9.188
#
# Versão customizada:
#
# InFreight POP3 v9.188


###############################################################################################################
# 14. ACESSO POP3
###############################################################################################################

# Conexão sem TLS:

nc "$TARGET" 110

# Digite dentro da sessão:
#
# USER robin
# PASS robin
# CAPA
# STAT
# LIST
# RETR 1
# RETR 2
# RETR 3
# QUIT


###############################################################################################################
# 15. ACESSO POP3S
###############################################################################################################

openssl s_client -connect "$TARGET:995" -quiet

# Digite dentro da sessão:
#
# USER robin
# PASS robin
# CAPA
# STAT
# LIST
# RETR 1
# QUIT


###############################################################################################################
# 16. POP3 COM STARTTLS
###############################################################################################################

openssl s_client \
  -connect "$TARGET:110" \
  -starttls pop3 \
  -quiet


###############################################################################################################
# 17. ACESSO AO IMAP COM CURL
###############################################################################################################

curl -k \
  "imaps://$TARGET" \
  --user "robin:robin"

curl -k \
  "imaps://$TARGET" \
  --user "robin:robin" \
  -v

# -k:
#
# ignora a validação do certificado autoassinado.
#
# -v:
#
# exibe conexão, TLS, comandos e respostas do servidor.


###############################################################################################################
# 18. SALVANDO A ENUMERAÇÃO DO CURL
###############################################################################################################

curl -k \
  "imaps://$TARGET" \
  --user "robin:robin" \
  -v 2>&1 \
  | tee curl_imap_verbose.txt

grep -Eo \
  'HTB\{[^}]+\}' \
  curl_imap_verbose.txt

grep -Eio \
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' \
  curl_imap_verbose.txt \
  | sort -u


###############################################################################################################
# 19. CONEXÃO MANUAL AO IMAP
###############################################################################################################

openssl s_client -connect "$TARGET:993" -quiet

# Os próximos comandos devem ser digitados dentro da sessão OpenSSL.
#
# A letra "a" é a tag do comando IMAP.


###############################################################################################################
# 20. SEQUÊNCIA IMAP ESSENCIAL
###############################################################################################################

# a CAPABILITY
# a LOGIN robin robin
# a ID NIL
# a LIST "" "*"
# a LSUB "" "*"
# a NAMESPACE
# a EXAMINE INBOX
# a STATUS INBOX (MESSAGES RECENT UNSEEN UIDNEXT UIDVALIDITY)
# a SEARCH ALL
# a FETCH 1:* BODY.PEEK[HEADER.FIELDS (FROM TO CC REPLY-TO SUBJECT DATE)]
# a FETCH 1:* BODY.PEEK[]
# a LOGOUT


###############################################################################################################
# 21. EXPLICAÇÃO DOS COMANDOS IMAP
###############################################################################################################

# CAPABILITY:
#
# mostra os recursos suportados.
#
# LOGIN:
#
# autentica no serviço.
#
# ID:
#
# pode revelar informações adicionais do servidor.
#
# LIST:
#
# lista todas as caixas.
#
# LSUB:
#
# lista caixas inscritas.
#
# NAMESPACE:
#
# mostra a organização lógica das caixas.
#
# EXAMINE:
#
# abre a caixa em modo somente leitura.
#
# STATUS:
#
# mostra quantidade e estado das mensagens.
#
# SEARCH:
#
# procura mensagens.
#
# FETCH:
#
# recupera cabeçalhos, corpo e metadados.
#
# LOGOUT:
#
# encerra a sessão.


###############################################################################################################
# 22. BUSCAS IMPORTANTES NO IMAP
###############################################################################################################

# a SEARCH ALL
# a SEARCH UNSEEN
# a SEARCH SEEN
# a SEARCH SUBJECT "admin"
# a SEARCH FROM "admin"
# a SEARCH TO "admin"
# a SEARCH CC "admin"
# a SEARCH BODY "HTB"
# a SEARCH BODY "HTB{"
# a SEARCH TEXT "admin"
# a SEARCH TEXT "administrator"
# a SEARCH TEXT "password"
# a SEARCH TEXT "inlanefreight.htb"


###############################################################################################################
# 23. LEITURA DAS MENSAGENS
###############################################################################################################

# Mensagem específica:
#
# a FETCH 1 BODY[]
#
# Todas as mensagens:
#
# a FETCH 1:* BODY[]
#
# Sem marcar como lidas:
#
# a FETCH 1:* BODY.PEEK[]
#
# Somente cabeçalhos:
#
# a FETCH 1:* BODY[HEADER]
#
# Cabeçalhos mais importantes:
#
# a FETCH 1:* BODY.PEEK[HEADER.FIELDS (FROM TO CC REPLY-TO SUBJECT DATE)]
#
# Somente o texto:
#
# a FETCH 1:* BODY[TEXT]
#
# Estrutura MIME:
#
# a FETCH 1:* BODYSTRUCTURE


###############################################################################################################
# 24. ENUMERANDO OUTRAS PASTAS
###############################################################################################################

# Primeiro:
#
# a LIST "" "*"
#
# Para cada pasta encontrada:
#
# a EXAMINE Important
# a SEARCH ALL
# a FETCH 1:* BODY.PEEK[]
#
# Pastas comuns:
#
# INBOX
# Important
# Sent
# Drafts
# Trash
# Archive
# Spam
# Admin
# Backup
# Projects


###############################################################################################################
# 25. IMAP COM STARTTLS
###############################################################################################################

openssl s_client \
  -connect "$TARGET:143" \
  -starttls imap \
  -quiet

# Depois:
#
# a LOGIN robin robin
# a LIST "" "*"
# a EXAMINE INBOX
# a SEARCH ALL
# a FETCH 1:* BODY.PEEK[]
# a LOGOUT


###############################################################################################################
# 26. CURL PARA CAIXAS E MENSAGENS
###############################################################################################################

curl -k \
  "imaps://$TARGET/INBOX" \
  --user "robin:robin"

curl -k \
  "imaps://$TARGET/Important" \
  --user "robin:robin"

curl -k \
  "imaps://$TARGET/INBOX;MAILINDEX=1" \
  --user "robin:robin"

curl -k \
  "imaps://$TARGET/INBOX;MAILINDEX=1" \
  --user "robin:robin" \
  -o email_1.eml

cat email_1.eml

grep -Eo \
  'HTB\{[^}]+\}' \
  email_1.eml


###############################################################################################################
# 27. BAIXANDO VÁRIAS MENSAGENS
###############################################################################################################

mkdir -p emails

for id in 1 2 3 4 5; do
  curl -ks \
    "imaps://$TARGET/INBOX;MAILINDEX=$id" \
    --user "robin:robin" \
    -o "emails/inbox_${id}.eml"
done

grep -RhoE \
  'HTB\{[^}]+\}' \
  emails/ \
  | sort -u

grep -RhoEi \
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' \
  emails/ \
  | sort -u

grep -RniE \
  'admin|administrator|password|credential' \
  emails/


###############################################################################################################
# 28. SALVANDO UMA SESSÃO INTERATIVA
###############################################################################################################

script -q imap_session.log

openssl s_client -connect "$TARGET:993" -quiet

# Execute os comandos IMAP.
#
# Encerre:
#
# a LOGOUT
#
# Depois saia do shell gravado:

exit

grep -Eo \
  'HTB\{[^}]+\}' \
  imap_session.log \
  | sort -u

grep -Eio \
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' \
  imap_session.log \
  | sort -u


###############################################################################################################
# 29. FLUXO COMPLETO USADO NO LABORATÓRIO
###############################################################################################################

# 1. Definir o IP na variável TARGET.
#
# 2. Escanear 110, 143, 993 e 995.
#
# 3. Identificar Dovecot IMAP e POP3.
#
# 4. Analisar o certificado TLS.
#
# 5. Extrair:
#
#    - organização;
#    - FQDN;
#    - unidade organizacional;
#    - contato técnico.
#
# 6. Conectar ao POP3 e obter o banner customizado.
#
# 7. Reutilizar as credenciais obtidas anteriormente:
#
#    robin:robin
#
# 8. Acessar o IMAP com cURL ou OpenSSL.
#
# 9. Listar todas as caixas.
#
# 10. Abrir cada caixa em modo somente leitura.
#
# 11. Pesquisar todas as mensagens.
#
# 12. Ler cabeçalhos e corpos.
#
# 13. Procurar:
#
#    - HTB{...};
#    - admin;
#    - administrator;
#    - endereços de e-mail;
#    - credenciais;
#    - nomes internos.
#
# 14. Diferenciar o e-mail do certificado do verdadeiro e-mail administrativo.


###############################################################################################################
# 30. RESULTADOS CONFIRMADOS
###############################################################################################################

# Organização:
#
# InlaneFreight Ltd
#
# FQDN:
#
# dev.inlanefreight.htb
#
# Versão customizada POP3:
#
# InFreight POP3 v9.188
#
# Contato presente no certificado:
#
# cto.dev@dev.inlanefreight.htb
#
# Observação:
#
# Esse contato não era a resposta correta para o e-mail administrativo.


###############################################################################################################
# 31. COMANDOS QUE DEVEM SER EVITADOS
###############################################################################################################

# IMAP:
#
# a CREATE "INBOX"
# a DELETE "INBOX"
# a RENAME "ToRead" "Important"
# a STORE 1 +FLAGS (\Deleted)
# a EXPUNGE
#
# POP3:
#
# DELE 1
#
# Esses comandos alteram ou excluem dados.
#
# Não são necessários para esta enumeração.


###############################################################################################################
# 32. RESUMO OPERACIONAL
###############################################################################################################

# Scan:

sudo nmap -Pn -sV -sC -p110,143,993,995 "$TARGET"

# Certificado IMAPS:

openssl s_client -connect "$TARGET:993" -quiet

# Certificado e banner POP3S:

openssl s_client -connect "$TARGET:995" -quiet

# Banner POP3:

nc "$TARGET" 110

# Enumeração IMAP com cURL:

curl -k \
  "imaps://$TARGET" \
  --user "robin:robin" \
  -v

# Sessão manual:

openssl s_client -connect "$TARGET:993" -quiet

# Dentro da sessão:

# a LOGIN robin robin
# a LIST "" "*"
# a EXAMINE INBOX
# a SEARCH ALL
# a FETCH 1:* BODY.PEEK[]
# a LOGOUT


###############################################################################################################
# 33. REFERÊNCIAS
###############################################################################################################

# Dovecot:
#
# https://doc.dovecot.org/2.4.1/core/config/service.html
#
# https://doc.dovecot.org/2.4.1/core/summaries/settings.html
#
# Nmap:
#
# https://nmap.org/book/man.html
#
# OpenSSL:
#
# https://docs.openssl.org/
#
# cURL:
#
# https://curl.se/docs/
#
# IMAP:
#
# RFC 3501
#
# POP3:
#
# RFC 1939


###############################################################################################################
# FIM
###############################################################################################################
