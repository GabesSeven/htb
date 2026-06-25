################################################################################
# AULA: KNOWLEDGE CHECK
#
# Esta última aula funciona como uma prova prática do módulo.
#
# O HTB não fornece mais um walkthrough.
#
# Agora o aluno deve aplicar toda a metodologia aprendida durante o curso
# para comprometer uma máquina sozinho.
#
################################################################################


################################################################################
# METODOLOGIA COMPLETA DE RESOLUÇÃO DE UMA BOX
################################################################################

# Toda máquina deve seguir aproximadamente este fluxo.

#
# Spawn da máquina
#        │
#        ▼
# Confirmar VPN
#        │
#        ▼
# Scan rápido Nmap
#        │
#        ▼
# Scan completo Nmap
#        │
#        ▼
# Enumerar TODOS os serviços encontrados
#        │
#        ├──────────────┐
#        │              │
#        ▼              ▼
#      HTTP           SMB/FTP/SSH/etc
#        │              │
#        ▼              ▼
# WhatWeb         Enumeração específica
# Gobuster        da tecnologia
# Curl
# Nikto
# Manual
#        │
#        ▼
# Identificar tecnologias
#        │
#        ▼
# Pesquisar vulnerabilidades
#        │
#        ├── Searchsploit
#        ├── Exploit-DB
#        ├── CVE
#        ├── Google
#        └── Documentação oficial
#        │
#        ▼
# Obter Foothold
#        │
#        ▼
# Melhorar Shell (Pseudo TTY)
#        │
#        ▼
# Enumeração LOCAL
#        │
#        ├── Manual
#        ├── LinEnum
#        ├── LinPEAS
#        └── Scripts próprios
#        │
#        ▼
# Organizar evidências
#        │
#        ▼
# Formular hipóteses
#        │
#        ▼
# Escalar privilégios
#        │
#        ▼
# Obter Root
#        │
#        ▼
# Documentar toda a exploração


################################################################################
# ENUMERAÇÃO É UM PROCESSO ITERATIVO
################################################################################

# Nunca enumere apenas uma vez.

# Toda informação descoberta gera uma nova enumeração.

#
# Nmap
#      │
#      ▼
# HTTP encontrado
#      │
#      ▼
# Gobuster
#      │
#      ▼
# Novo diretório encontrado
#      │
#      ▼
# Nova aplicação encontrada
#      │
#      ▼
# Nova enumeração
#      │
#      ▼
# Novas credenciais
#      │
#      ▼
# Novo acesso
#      │
#      ▼
# Enumeração LOCAL
#      │
#      ▼
# Escalada
#

################################################################################
# PRINCIPAIS FERRAMENTAS UTILIZADAS DURANTE O MÓDULO
################################################################################

# Enumeração

# nmap
# whatweb
# gobuster
# curl

# Pesquisa

# searchsploit
# Exploit-DB
# Google
# CVE

# Pós Exploração

# python3 pty
# LinEnum
# LinPEAS

################################################################################
# MENTALIDADE DO HTB
################################################################################

# Durante qualquer máquina, sempre pensar:

#
# Enumerar
#      │
#      ▼
# Analisar
#      │
#      ▼
# Formular hipótese
#      │
#      ▼
# Testar
#      │
#      ▼
# Obter evidência
#      │
#      ▼
# Nova enumeração
#      │
#      ▼
# Exploração
#      │
#      ▼
# Escalada
#      │
#      ▼
# Documentação
#

################################################################################
# OBJETIVO FINAL DO GETTING STARTED
################################################################################

# Ao terminar este módulo o aluno deve ser capaz de:

# [ ] Conectar corretamente na VPN
# [ ] Fazer enumeração completa
# [ ] Enumerar aplicações Web
# [ ] Encontrar vulnerabilidades
# [ ] Pesquisar exploits
# [ ] Obter Foothold
# [ ] Melhorar a shell
# [ ] Fazer enumeração local
# [ ] Escalar privilégios
# [ ] Documentar toda a exploração
# [ ] Resolver uma Easy Box sem walkthrough
# [ ] Evoluir para Medium, Hard e Pro Labs

################################################################################