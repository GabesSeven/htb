```bash
#!/bin/bash

################################################################################
# HTB - GETTING STARTED
# DOCUMENTAÇÃO FINAL
#
# AULAS:
# - Getting Help
# - Next Steps
#
# OBJETIVO:
#
# Organizar os próximos passos depois de finalizar o módulo Getting Started
# do Hack The Box Academy.
#
# A ideia principal é:
#
# 1. Continuar praticando em Boxes e Challenges
# 2. Pedir ajuda da forma correta
# 3. Ajudar outras pessoas sem dar spoiler
# 4. Documentar walkthroughs
# 5. Continuar estudando módulos da Academy
# 6. Construir portfólio profissional em Segurança da Informação
#
################################################################################


################################################################################
# LINKS OFICIAIS DO HACK THE BOX
################################################################################

# Central de ajuda oficial do HTB
# Usar para problemas com VPN, PwnBox, Academy, Labs, assinatura e suporte.
https://help.hackthebox.com/en/

# Fórum oficial do HTB
# Usar para discutir máquinas, desafios, módulos e buscar dicas sem spoiler.
https://forum.hackthebox.com/

# Regras oficiais da plataforma
# Ler antes de publicar walkthroughs, pedir ajuda ou responder outras pessoas.
https://help.hackthebox.com/en/articles/12325897-hack-the-box-platform-rules


################################################################################
# AULA: GETTING HELP
################################################################################

# Quando ficar preso em uma máquina, NÃO pedir a resposta pronta.
# O correto é pedir uma dica pequena, sem spoiler.

# Pergunta ruim:
# "Não consigo fazer a máquina, alguém ajuda?"

# Pergunta boa:
# "Estou preso na etapa de User.
# Já rodei nmap, gobuster e encontrei o painel web.
# Consegui login, mas não sei onde o upload está sendo salvo.
# Alguém pode dar uma dica sem spoiler?"

# Sempre informar:
# 1. Em qual etapa está preso: user, root, foothold, enumeração etc.
# 2. Quais comandos e ferramentas já usou.
# 3. Onde exatamente está falhando.
# 4. O que já tentou para resolver.

# Ao responder outras pessoas:
# - Não entregar credenciais.
# - Não entregar exploit completo.
# - Não entregar flag.
# - Não passar walkthrough de máquina ativa.
# - Dar apenas uma direção.
# - Compartilhar documentação útil.


################################################################################
# FLUXO PARA PEDIR AJUDA
################################################################################

# Travou na máquina
#        │
#        ▼
# Revisar suas próprias anotações
#        │
#        ▼
# Fazer nova enumeração
#        │
#        ▼
# Pesquisar documentação e recursos externos
#        │
#        ▼
# Ver fórum oficial do HTB
#        │
#        ▼
# Ver Discord/comunidade
#        │
#        ▼
# Formular pergunta detalhada
#        │
#        ▼
# Receber uma dica
#        │
#        ▼
# Continuar investigando sozinho


################################################################################
# RECURSOS ÚTEIS PARA PESQUISA
################################################################################

# GTFOBins
# Técnicas de abuso de binários Linux para escalação de privilégio.
https://gtfobins.github.io/

# PayloadsAllTheThings
# Coleção de payloads para várias vulnerabilidades.
https://github.com/swisskyrepo/PayloadsAllTheThings

# LOLBAS
# Técnicas de abuso de binários Windows.
https://lolbas-project.github.io/

# Exploit Database
# Base pública de exploits.
https://www.exploit-db.com/

# NVD
# Base oficial de vulnerabilidades da NIST.
https://nvd.nist.gov/


################################################################################
# AULA: NEXT STEPS
################################################################################

# Depois de terminar o módulo Getting Started, o HTB recomenda seguir uma
# trilha prática de evolução.

# O objetivo NÃO é apenas conseguir flags.
# O objetivo é desenvolver raciocínio de pentest:
#
# - Enumerar
# - Formular hipóteses
# - Explorar
# - Validar
# - Escalar privilégio
# - Documentar
# - Explicar tecnicamente


################################################################################
# PASSO 1 - ROOTAR UMA BOX EASY APOSENTADA
################################################################################

# Escolher uma máquina aposentada de nível Easy.
# Máquinas aposentadas permitem consultar writeups oficiais com assinatura VIP.

# Estratégia recomendada:
# 1. Assistir um walkthrough.
# 2. Entender a lógica.
# 3. Tentar repetir sem seguir passo a passo.
# 4. Consultar novamente apenas se travar.

# Objetivo:
# Criar memória muscular nos comandos e no fluxo de exploração.


################################################################################
# PASSO 2 - COMPLETAR UMA BOX MEDIUM APOSENTADA
################################################################################

# Depois de algumas Easy, subir para uma Medium.
# Máquinas Medium normalmente exigem:
#
# - Mais enumeração
# - Mais pesquisa
# - Mais leitura de código
# - Mais exploração manual
# - Mais conhecimento de serviços
# - Mais atenção na escalação de privilégio

# Objetivo:
# Sair do básico e começar a lidar com cenários menos óbvios.


################################################################################
# PASSO 3 - ROOTAR A PRIMEIRA BOX LIVE
################################################################################

# Depois de 5 a 10 máquinas Easy/Medium aposentadas,
# tentar a primeira máquina ativa.

# Recomendação:
# Escolher uma Easy Live com dificuldade 1 a 3 de 10.

# Diferença:
# Em máquina Live, você não deve usar walkthrough.
# Você depende da sua própria enumeração e raciocínio.

# Isso é mais difícil, mas é onde o aprendizado real cresce.


################################################################################
# PASSO 4 - CONTINUAR ESTUDANDO ACADEMY MODULES
################################################################################

# Boxes ensinam pela prática.
# Academy Modules ensinam de forma guiada.

# Os dois são importantes.

# Se uma box envolver um assunto que você não domina,
# volte para a Academy e estude o módulo relacionado.

# Exemplos:
#
# - Web Enumeration
# - File Transfers
# - Shells
# - Privilege Escalation
# - Active Directory
# - SQL Injection
# - Linux Fundamentals
# - Windows Fundamentals
# - Password Attacks


################################################################################
# PASSO 5 - MONTAR UMA LISTA TO-DO
################################################################################

# Criar uma lista de módulos e máquinas para estudar.

# Exemplo:
#
# [ ] Rootar 1 Easy aposentada
# [ ] Rootar 3 Easy aposentadas
# [ ] Rootar 1 Medium aposentada
# [ ] Fazer 1 Easy Live
# [ ] Fazer 1 Challenge Easy
# [ ] Publicar 1 walkthrough de máquina aposentada
# [ ] Completar módulo de Privilege Escalation
# [ ] Completar módulo de Web Enumeration


################################################################################
# PASSO 6 - AJUDAR A COMUNIDADE
################################################################################

# Depois de resolver uma máquina, voltar ao fórum ou Discord e ajudar outros.

# Forma correta:
# - Dar dicas pequenas
# - Fazer perguntas que guiem o raciocínio
# - Compartilhar recursos
# - Não entregar spoilers

# Isso melhora:
# - Seu aprendizado
# - Sua reputação
# - Seu networking
# - Seu perfil profissional


################################################################################
# PASSO 7 - PUBLICAR WALKTHROUGH DE BOX APOSENTADA
################################################################################

# Documentar cada máquina resolvida.

# Sua documentação deve conter:
#
# - Nome da máquina
# - IP
# - Enumeração inicial
# - Serviços encontrados
# - Versões
# - Caminhos web encontrados
# - Credenciais encontradas
# - Exploração
# - Shell obtida
# - Enumeração local
# - Vetor de escalação
# - Root
# - Lições aprendidas

# Importante:
# Não publicar walkthrough de máquina ativa.
# Publicar apenas quando a máquina estiver aposentada.


################################################################################
# FLUXO PROFISSIONAL DE ESTUDO HTB
################################################################################

# Getting Started
#        │
#        ▼
# Retired Easy Box
#        │
#        ▼
# Mais Retired Easy Boxes
#        │
#        ▼
# Retired Medium Box
#        │
#        ▼
# Easy Live Box
#        │
#        ▼
# Medium Live Box
#        │
#        ▼
# Challenges
#        │
#        ▼
# Academy Modules
#        │
#        ▼
# Tracks
#        │
#        ▼
# Pro Labs
#        │
#        ▼
# Portfólio profissional


################################################################################
# CHECKLIST DE EVOLUÇÃO
################################################################################

# [ ] Rootar uma Retired Easy Box
# [ ] Rootar várias Retired Easy Boxes
# [ ] Rootar uma Retired Medium Box
# [ ] Rootar uma Active Easy Box
# [ ] Completar um Easy Challenge
# [ ] Publicar walkthrough de uma Retired Box
# [ ] Completar módulos ofensivos da Academy
# [ ] Rootar Medium/Hard Live Boxes
# [ ] Completar uma Track
# [ ] Participar de Battlegrounds
# [ ] Completar um Pro Lab


################################################################################
# MENTALIDADE FINAL
################################################################################

# O HTB não é sobre copiar comandos.
# É sobre aprender metodologia.

# Metodologia:
#
# 1. Enumerar tudo
# 2. Anotar tudo
# 3. Testar hipóteses
# 4. Confirmar evidências
# 5. Explorar com consciência
# 6. Escalar privilégio
# 7. Documentar
# 8. Explicar o que aconteceu
# 9. Repetir em novas máquinas

# Frase principal da aula:
#
# "The moment we stop learning, we stop growing."
#
# Tradução:
#
# "No momento em que paramos de aprender, paramos de crescer."


################################################################################
# PADRÃO PARA SEU GIT HTB
################################################################################

# Para cada máquina, salvar:
#
# 01_enum.sh
# 02_web_enum.sh
# 03_exploit.sh
# 04_privesc.sh
# 05_notes.sh
# README.md

# Para cada aula, salvar:
#
# aula_nome.sh
#
# Com:
# - Comentários explicativos
# - Comandos usados
# - Fluxo da técnica
# - Observações importantes
# - Lições aprendidas

################################################################################
```
