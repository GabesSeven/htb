#!/bin/bash

################################################################################
# HTB ACADEMY - FOOTPRINTING
# AULA: DOMAIN INFORMATION, CLOUD RESOURCES E STAFF OSINT
################################################################################

################################################################################
# OBJETIVO GERAL
################################################################################
# Entender a presença externa de uma empresa antes de qualquer ataque ativo.
#
# A ideia principal é:
# - Primeiro entender o alvo.
# - Depois mapear domínios, subdomínios, DNS, cloud e tecnologias.
# - Só depois pensar em enumeração ativa.
#
# Esta fase é principalmente OSINT/passiva.
################################################################################


################################################################################
# 1. DOMAIN INFORMATION
################################################################################

# Informações de domínio mostram muito mais do que apenas subdomínios.
#
# Elas podem revelar:
# - Domínios principais
# - Subdomínios
# - IPs públicos
# - Certificados SSL/TLS
# - Provedores de e-mail
# - Serviços terceiros
# - Cloud utilizada
# - Ferramentas internas
# - Possíveis tecnologias da empresa


################################################################################
# ANALISAR CERTIFICADOS COM CRT.SH
################################################################################

# crt.sh consulta logs públicos de Certificate Transparency.
# Esses logs registram certificados emitidos para domínios.
#
# Isso pode revelar subdomínios que ainda estão ativos ou já foram usados.

# Consultar certificados de um domínio em JSON
curl -s "https://crt.sh/?q=inlanefreight.com&output=json" | jq .

# Filtrar subdomínios únicos encontrados nos certificados
curl -s "https://crt.sh/?q=inlanefreight.com&output=json" \
| jq . \
| grep name \
| cut -d":" -f2 \
| grep -v "CN=" \
| cut -d'"' -f2 \
| awk '{gsub(/\\n/,"\n");}1;' \
| sort -u

# Exemplo de possíveis resultados:
# blog.inlanefreight.com
# shop.inlanefreight.com
# support.inlanefreight.com
# matomo.inlanefreight.com
# smartfactory.inlanefreight.com


################################################################################
# RESOLVER SUBDOMÍNIOS PARA IP
################################################################################

# Depois de descobrir subdomínios, verificar quais resolvem para IP.
# Isso ajuda a identificar hosts reais acessíveis.

for i in $(cat subdomainlist); do
  host "$i" | grep "has address" | cut -d" " -f1,4
done

# Exemplo:
# blog.inlanefreight.com 10.129.24.93
# www.inlanefreight.com 10.129.127.33
# matomo.inlanefreight.com 10.129.127.22


################################################################################
# GERAR LISTA DE IPS
################################################################################

# Criar uma lista apenas com IPs resolvidos.
# Essa lista pode ser usada depois em ferramentas como Shodan.

for i in $(cat subdomainlist); do
  host "$i" | grep "has address" | cut -d" " -f4 >> ip-addresses.txt
done


################################################################################
# CONSULTAR SHODAN
################################################################################

# Shodan mostra informações públicas já coletadas sobre IPs.
# Isso evita tocar diretamente no alvo durante a fase passiva.

for i in $(cat ip-addresses.txt); do
  shodan host "$i"
done

# O Shodan pode revelar:
# - Portas abertas
# - Serviços
# - Versões
# - Localização
# - Organização
# - Certificados TLS
# - Servidores HTTP/SSH/FTP/SNMP/etc.


################################################################################
# CONSULTAR REGISTROS DNS
################################################################################

# Consultar todos os registros DNS disponíveis.
dig any inlanefreight.com

# Tipos importantes:
#
# A     -> Aponta domínio/subdomínio para IP.
# MX    -> Mostra servidores de e-mail.
# NS    -> Mostra servidores DNS/autoritativos.
# TXT   -> Pode revelar verificações, SPF, DKIM, DMARC e terceiros.
# SOA   -> Informações administrativas da zona DNS.


################################################################################
# INTERPRETAR REGISTROS DNS
################################################################################

# Exemplo de registros MX:
# aspmx.l.google.com
# protection.outlook.com
#
# Possíveis conclusões:
# - Empresa usa Google Workspace/Gmail.
# - Empresa usa Microsoft 365/Outlook.
# - Pode existir Google Drive, OneDrive, SharePoint ou Azure.

# Exemplo de registros TXT:
# atlassian-domain-verification=...
# google-site-verification=...
# logmein-verification-code=...
# v=spf1 include:mailgun.org include:_spf.google.com include:spf.protection.outlook.com
#
# Possíveis conclusões:
# - Atlassian pode indicar Jira, Confluence ou Bitbucket.
# - Google pode indicar Gmail, Drive ou Workspace.
# - LogMeIn pode indicar acesso remoto centralizado.
# - Mailgun pode indicar SMTP, API de e-mail ou webhooks.
# - Outlook pode indicar Microsoft 365, OneDrive, SharePoint ou Azure.


################################################################################
# 2. CLOUD RESOURCES
################################################################################

# Empresas modernas usam cloud:
# - AWS
# - Azure
# - Google Cloud
#
# O provedor geralmente é seguro.
# O problema normalmente é configuração incorreta feita pela empresa.
#
# Exemplos comuns de exposição:
# - AWS S3 Bucket público
# - Azure Blob Storage público
# - Google Cloud Storage público
# - Backups expostos
# - PDFs, planilhas, código-fonte e chaves vazadas


################################################################################
# IDENTIFICAR CLOUD PELO DNS
################################################################################

# Durante a resolução de subdomínios, podem aparecer domínios como:
#
# s3-website-us-west-2.amazonaws.com
# blob.core.windows.net
# storage.googleapis.com
#
# Isso indica uso de armazenamento em cloud.

for i in $(cat subdomainlist); do
  host "$i" | grep "has address"
done


################################################################################
# GOOGLE DORKS PARA CLOUD
################################################################################

# Procurar arquivos públicos em AWS S3:
# intext:empresa inurl:amazonaws.com

# Procurar arquivos públicos em Azure Blob:
# intext:empresa inurl:blob.core.windows.net

# Procurar arquivos públicos em Google Cloud Storage:
# intext:empresa inurl:storage.googleapis.com

# Exemplos de arquivos que podem aparecer:
# - .pdf
# - .docx
# - .xlsx
# - .pptx
# - .zip
# - .txt
# - .json
# - .env
# - backups


################################################################################
# ANALISAR CÓDIGO-FONTE DO SITE
################################################################################

# O código-fonte de páginas pode revelar buckets e blobs.
#
# Exemplos:
# <img src="https://empresa.s3.amazonaws.com/logo.png">
# <script src="https://empresa.blob.core.windows.net/app.js">
# <link href="https://empresa.storage.googleapis.com/style.css">

# Baixar HTML da página inicial
curl -s https://exemplo.com

# Procurar referências a cloud no HTML
curl -s https://exemplo.com | grep -Ei "amazonaws|blob.core.windows.net|storage.googleapis.com"


################################################################################
# DOMAIN.GLASS
################################################################################

# Domain.glass ajuda a reunir informações sobre o domínio.
#
# Pode mostrar:
# - IPs
# - DNS
# - Certificados
# - ASN
# - Cloudflare
# - Segurança
# - Informações de SSL/TLS
#
# Se aparecer Cloudflare, isso indica camada de Gateway:
# - CDN
# - WAF
# - Proxy
# - Possível ocultação do IP real


################################################################################
# GRAYHATWARFARE
################################################################################

# GrayHatWarfare ajuda a encontrar buckets públicos.
#
# Pode pesquisar:
# - AWS S3
# - Azure Blob
# - Google Cloud Storage
#
# Estratégia:
# - Nome completo da empresa
# - Abreviações
# - Nome antigo
# - Siglas internas
# - empresa-dev
# - empresa-prod
# - empresa-backup
# - empresa-static
# - empresa-assets

# Exemplos de nomes para pesquisar manualmente:
# inlanefreight
# ilf
# inlane
# freight
# inlanefreight-dev
# inlanefreight-prod
# inlanefreight-backup


################################################################################
# ARQUIVOS CRÍTICOS EM CLOUD
################################################################################

# Arquivos perigosos que nunca devem estar públicos:
#
# id_rsa
# id_rsa.pub
# .env
# config.json
# settings.py
# database.yml
# backup.sql
# dump.sql
# users.csv
# credentials.txt
# token.json
# service-account.json
# kubeconfig
# docker-compose.yml

# Vazamento de id_rsa é gravíssimo.
# id_rsa é chave privada SSH.
# Pode permitir login sem senha em servidores confiáveis.


################################################################################
# 3. STAFF OSINT
################################################################################

# Staff OSINT é investigar informações públicas de funcionários.
#
# Fontes:
# - LinkedIn
# - Xing
# - GitHub
# - Vagas de emprego
# - Portfólios
# - Artigos técnicos
#
# Objetivo:
# - Descobrir tecnologias usadas.
# - Entender times internos.
# - Identificar linguagens, frameworks e ferramentas.
# - Criar hipóteses sobre a infraestrutura.


################################################################################
# LINKEDIN E XING
################################################################################

# Procurar perfis técnicos:
# - Software Engineer
# - Backend Developer
# - Frontend Developer
# - DevOps Engineer
# - Cloud Engineer
# - Security Engineer
# - System Administrator
# - Infrastructure Engineer
# - SRE
# - Architect

# Informações importantes:
# - Linguagens
# - Frameworks
# - Bancos
# - Cloud
# - CI/CD
# - Ferramentas de segurança
# - Ferramentas de monitoramento
# - Projetos
# - Certificações


################################################################################
# VAGAS DE EMPREGO COMO FONTE DE OSINT
################################################################################

# Vagas geralmente entregam a stack da empresa.
#
# Exemplo de habilidades citadas:
# - Java
# - C#
# - C++
# - Python
# - Ruby
# - PHP
# - Perl
# - PostgreSQL
# - MySQL
# - SQL Server
# - Oracle
# - Flask
# - Django
# - Spring
# - ASP.NET MVC
# - Docker
# - Kubernetes
# - Redis
# - Git
# - SVN
# - Mercurial
# - Perforce
# - Jira
# - Confluence
# - Bitbucket

# Interpretação:
# Se a vaga pede Django, pode existir aplicação Python/Django.
# Se pede Kubernetes, pode existir cluster.
# Se pede Atlassian, pode existir Jira, Confluence ou Bitbucket.
# Se pede Redis, pode existir cache ou fila.
# Se pede PostgreSQL, pode existir banco relacional PostgreSQL.


################################################################################
# GITHUB DE FUNCIONÁRIOS
################################################################################

# Funcionários podem publicar projetos pessoais.
# Isso ajuda a identificar:
# - Linguagens
# - Frameworks
# - Estilo de código
# - Bibliotecas
# - Padrões de configuração
#
# Mas também pode expor:
# - E-mails
# - Tokens
# - JWTs
# - API keys
# - Secrets
# - Arquivos .env
# - URLs internas

# Procurar por tecnologias mencionadas pelos funcionários.
# Exemplo:
# Se a empresa usa Django, estudar segurança em Django.

# Repositório citado na aula:
# https://github.com/boomcamp/django-security


################################################################################
# JWT
################################################################################

# JWT significa JSON Web Token.
# Normalmente é composto por:
#
# Header.Payload.Signature
#
# Pode ser analisado em:
# https://www.jwt.io/
#
# Risco:
# - JWT hardcoded em código público.
# - Secret exposto.
# - Token ainda válido.
# - Algoritmo mal configurado.
#
# Se um projeto público contém JWT ou secret, isso pode comprometer autenticação.


################################################################################
# EXEMPLO DE RACIOCÍNIO COM STAFF OSINT
################################################################################

# Perfil de funcionário:
# - Python
# - Django
# - Docker
# - AWS
# - PostgreSQL
#
# Hipóteses:
# - Aplicação backend em Django.
# - Deploy em AWS.
# - Banco PostgreSQL.
# - Containers Docker.
# - Possível uso de S3, RDS, EC2 ou ECS/EKS.

# Perfil de funcionário:
# - React
# - Kafka
# - Elastic
# - Java
#
# Hipóteses:
# - Frontend React.
# - Backend Java.
# - Mensageria Kafka.
# - Logs ou busca com Elastic.
# - Arquitetura distribuída.


################################################################################
# 4. FLUXO COMPLETO DE ENUMERAÇÃO PASSIVA
################################################################################

# Domínio principal
#   |
#   |-- Analisar site público
#   |
#   |-- Consultar certificados
#   |     |
#   |     |-- crt.sh
#   |     |-- Certificate Transparency
#   |
#   |-- Extrair subdomínios
#   |
#   |-- Resolver subdomínios para IP
#   |
#   |-- Separar infraestrutura própria de terceiros
#   |
#   |-- Consultar Shodan
#   |
#   |-- Consultar DNS
#   |     |
#   |     |-- A
#   |     |-- MX
#   |     |-- NS
#   |     |-- TXT
#   |     |-- SOA
#   |
#   |-- Identificar Cloud
#   |     |
#   |     |-- AWS S3
#   |     |-- Azure Blob
#   |     |-- Google Cloud Storage
#   |
#   |-- Procurar buckets públicos
#   |
#   |-- Procurar referências no código-fonte
#   |
#   |-- Consultar Domain.glass
#   |
#   |-- Consultar GrayHatWarfare
#   |
#   |-- Investigar funcionários
#   |     |
#   |     |-- LinkedIn
#   |     |-- Xing
#   |     |-- GitHub
#   |     |-- Vagas
#   |
#   |-- Criar hipóteses técnicas
#   |
#   |-- Planejar enumeração ativa autorizada


################################################################################
# 5. PRINCIPAIS LIÇÕES
################################################################################

# 1. Não comece atacando.
#    Primeiro entenda a empresa.
#
# 2. DNS revela muito.
#    Principalmente registros TXT, MX e NS.
#
# 3. Certificados revelam subdomínios.
#    crt.sh é essencial para Certificate Transparency.
#
# 4. Cloud mal configurada é um vetor comum.
#    Buckets públicos podem expor dados críticos.
#
# 5. Código-fonte HTML pode revelar buckets e blobs.
#    Sempre procure amazonaws, blob.core.windows.net e storage.googleapis.com.
#
# 6. Funcionários revelam tecnologias.
#    LinkedIn, Xing, GitHub e vagas mostram a stack da empresa.
#
# 7. Vagas são documentação pública da infraestrutura.
#    Linguagens, bancos, cloud, CI/CD e ferramentas aparecem claramente.
#
# 8. GitHub pode expor segredos.
#    Sempre verificar tokens, JWTs, .env, chaves e credenciais.
#
# 9. Nem todo alvo pertence à empresa.
#    Provedores terceiros precisam estar dentro do escopo.
#
# 10. OSINT cria hipóteses.
#     A enumeração ativa vem depois, sempre respeitando autorização e escopo.


################################################################################
# 6. LINKS IMPORTANTES DA AULA
################################################################################

# Certificate Transparency / Certificados
# https://crt.sh/
# https://en.wikipedia.org/wiki/Certificate_Transparency
# https://datatracker.ietf.org/doc/html/rfc6962
# https://letsencrypt.org/

# Shodan
# https://www.shodan.io/

# E-mail Security
# SPF  - https://datatracker.ietf.org/doc/html/rfc7208
# DKIM - https://datatracker.ietf.org/doc/html/rfc6376
# DMARC - https://datatracker.ietf.org/doc/html/rfc7489

# Cloud
# https://aws.amazon.com/pt/
# https://azure.microsoft.com/en-us
# https://cloud.google.com/

# Cloud OSINT
# https://domain.glass/
# https://buckets.grayhatwarfare.com/

# Serviços terceiros
# https://www.atlassian.com/
# https://www.mailgun.com/
# https://www.microsoft.com/en-us/microsoft-365/outlook/email-and-calendar-software-microsoft-outlook
# https://mail.google.com/
# https://www.logmein.com/pt
# https://www.inwx.com/en

# Staff OSINT
# https://www.linkedin.com/feed/
# https://www.xing.com/

# Django Security
# https://github.com/boomcamp/django-security

# JWT
# https://www.jwt.io/


################################################################################
# 7. RESUMO FINAL
################################################################################

# Esta parte do módulo Footprinting ensina que uma empresa pode ser entendida
# antes de qualquer scan ativo.
#
# Domínios, certificados, DNS, cloud, código-fonte, funcionários, vagas e GitHub
# formam um mapa inicial da infraestrutura.
#
# O objetivo não é invadir.
# O objetivo é entender:
#
# - O que existe.
# - Quem fornece os serviços.
# - Quais tecnologias sustentam a empresa.
# - Quais recursos podem estar expostos.
# - Onde a enumeração ativa deve começar depois.
#
# Em um pentest profissional, essa fase evita ruído, reduz risco e aumenta a
# chance de encontrar caminhos reais até o objetivo.
################################################################################