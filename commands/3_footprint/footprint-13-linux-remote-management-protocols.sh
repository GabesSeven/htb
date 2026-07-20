#!/usr/bin/env bash
#
# ==============================================================================
# HTB ACADEMY - FOOTPRINTING
# SECTION 17 - LINUX REMOTE MANAGEMENT PROTOCOLS
#
# GUIA COMPLETO DE COMANDOS, ENUMERAÇÃO E FLUXO DE TESTE
#
# Serviços abordados:
#   - SSH / OpenSSH
#   - Rsync
#   - Berkeley R-Services
#
# Uso autorizado:
#   Execute estes comandos apenas em laboratórios, CTFs, máquinas próprias ou
#   ambientes nos quais você tenha autorização explícita para realizar testes.
#
# Este arquivo foi escrito como material de aula. Muitos comandos estão
# comentados para evitar execução acidental. Remova o caractere "#" apenas
# quando estiver em um ambiente autorizado e souber exatamente o que está
# testando.
# ==============================================================================


# ==============================================================================
# 0. PREPARAÇÃO DO AMBIENTE
# ==============================================================================

# Defina o endereço IP ou hostname do alvo autorizado.
#
# Exemplo:
# TARGET="10.129.14.132"

TARGET="10.129.14.132"

# Portas padrão estudadas nesta aula:
#
# SSH:
#   22/TCP
#
# Rsync daemon:
#   873/TCP
#
# R-Services:
#   512/TCP - rexec
#   513/TCP - rlogin
#   514/TCP - rsh / rcp

SSH_PORT="22"
RSYNC_PORT="873"
REXEC_PORT="512"
RLOGIN_PORT="513"
RSH_PORT="514"

# Cria uma pasta local para armazenar resultados e arquivos coletados.
mkdir -p linux_remote_management_results
cd linux_remote_management_results || exit 1

# Registra a data do teste.
date | tee test_started.txt


# ==============================================================================
# 1. DESCOBERTA INICIAL DAS PORTAS
# ==============================================================================

# O primeiro objetivo é descobrir se SSH, Rsync ou R-Services estão acessíveis.
#
# -sV:
#   solicita detecção de versão do serviço.
#
# -p:
#   limita a análise às portas relevantes para esta aula.
#
# -Pn:
#   ignora a descoberta por ping e trata o host como ativo.
#
# --reason:
#   mostra por que o Nmap classificou a porta como aberta, fechada ou filtrada.
#
# -oA:
#   salva o resultado nos formatos normal, grepable e XML.

# sudo nmap -Pn -sV --reason \
#   -p 22,873,512,513,514 \
#   "$TARGET" \
#   -oA initial_remote_management_scan

# Uma varredura mais agressiva pode coletar:
#
# - versão do serviço;
# - scripts NSE padrão;
# - sistema operacional aproximado;
# - traceroute.
#
# Use somente quando apropriado, pois gera mais tráfego.

# sudo nmap -Pn -sC -sV -O \
#   -p 22,873,512,513,514 \
#   "$TARGET" \
#   -oA detailed_remote_management_scan


# ==============================================================================
# 2. SSH - SECURE SHELL
# ==============================================================================

# ------------------------------------------------------------------------------
# 2.1 Entendendo o objetivo
# ------------------------------------------------------------------------------

# O SSH normalmente utiliza a porta TCP 22 e pode ser usado para:
#
# - abrir um shell remoto;
# - executar comandos remotamente;
# - transferir arquivos;
# - realizar encaminhamento de portas;
# - criar túneis;
# - utilizar SFTP;
# - utilizar autenticação por senha ou chaves.
#
# Durante o footprinting, queremos descobrir:
#
# 1. Se a porta SSH está aberta.
# 2. Qual é o banner apresentado.
# 3. Qual software e versão estão em uso.
# 4. Quais algoritmos criptográficos são aceitos.
# 5. Quais métodos de autenticação estão disponíveis.
# 6. Se as credenciais obtidas em outros serviços podem ser reutilizadas.
# 7. Se há configurações inseguras ou software obsoleto.


# ------------------------------------------------------------------------------
# 2.2 Varredura específica do SSH
# ------------------------------------------------------------------------------

# Detecta a versão do serviço SSH.

# sudo nmap -Pn -sV -p "$SSH_PORT" "$TARGET" -oN ssh_version_scan.txt

# Executa scripts padrão do Nmap contra o SSH.

# sudo nmap -Pn -sC -sV -p "$SSH_PORT" "$TARGET" -oN ssh_default_scripts.txt

# Scripts NSE úteis para footprinting SSH:
#
# ssh2-enum-algos:
#   lista algoritmos de troca de chaves, criptografia, MAC e compressão.
#
# ssh-hostkey:
#   coleta as chaves públicas do host e seus fingerprints.
#
# ssh-auth-methods:
#   tenta identificar métodos de autenticação disponíveis para um usuário.
#
# Observação:
#   ssh-auth-methods normalmente exige que um nome de usuário seja informado.

# sudo nmap -Pn -p "$SSH_PORT" \
#   --script ssh2-enum-algos,ssh-hostkey \
#   "$TARGET" \
#   -oN ssh_nse_enumeration.txt

# Exemplo com usuário conhecido ou provável:
#
# USERNAME="cry0l1t3"

# sudo nmap -Pn -p "$SSH_PORT" \
#   --script ssh-auth-methods \
#   --script-args="ssh.user=$USERNAME" \
#   "$TARGET" \
#   -oN ssh_auth_methods_nmap.txt


# ------------------------------------------------------------------------------
# 2.3 Coleta manual do banner SSH
# ------------------------------------------------------------------------------

# O banner pode revelar:
#
# - versão do protocolo SSH;
# - implementação do servidor;
# - versão do OpenSSH;
# - distribuição Linux;
# - revisão específica do pacote.
#
# Exemplo de banner:
#
# SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.3
#
# Interpretação:
#
# SSH-2.0:
#   servidor aceita protocolo SSH versão 2.
#
# OpenSSH:
#   implementação utilizada.
#
# 8.2p1:
#   versão do OpenSSH.
#
# Ubuntu-4ubuntu0.3:
#   revisão do pacote da distribuição.

# Coleta do banner com Netcat.
#
# O timeout impede que o terminal fique preso indefinidamente.

# timeout 5 nc -nv "$TARGET" "$SSH_PORT" | tee ssh_banner_nc.txt

# Outra forma usando Bash e /dev/tcp.

# timeout 5 bash -c \
#   "exec 3<>/dev/tcp/$TARGET/$SSH_PORT; head -n 1 <&3" \
#   | tee ssh_banner_dev_tcp.txt


# ------------------------------------------------------------------------------
# 2.4 Conexão SSH em modo verboso
# ------------------------------------------------------------------------------

# O modo verboso mostra detalhes do processo de conexão:
#
# - arquivos de configuração lidos;
# - resolução do hostname;
# - conexão TCP;
# - banner remoto;
# - troca de chaves;
# - chave pública do servidor;
# - algoritmos selecionados;
# - métodos de autenticação aceitos.
#
# Níveis:
#
# -v:
#   verbosidade básica.
#
# -vv:
#   verbosidade intermediária.
#
# -vvv:
#   verbosidade máxima.

USERNAME="cry0l1t3"

# ssh -v "$USERNAME@$TARGET"

# ssh -vv "$USERNAME@$TARGET"

# ssh -vvv "$USERNAME@$TARGET"

# Salva stdout e stderr em arquivo para análise.
#
# O "2>&1" é importante porque muitas mensagens de debug do SSH são enviadas
# para stderr.

# ssh -vvv "$USERNAME@$TARGET" 2>&1 | tee ssh_verbose_connection.txt


# ------------------------------------------------------------------------------
# 2.5 Identificando métodos de autenticação
# ------------------------------------------------------------------------------

# Uma saída típica pode mostrar:
#
# Authentications that can continue:
# publickey,password,keyboard-interactive
#
# Isso informa que o servidor aceita:
#
# - autenticação por chave pública;
# - autenticação por senha;
# - autenticação interativa via teclado/PAM.
#
# Essa informação ajuda a decidir o próximo teste autorizado.

# Executa a conexão sem permitir prompt interativo prolongado.
#
# PreferredAuthentications=none:
#   solicita que o cliente não priorize senha ou chave.
#
# BatchMode=yes:
#   evita prompts interativos.
#
# NumberOfPasswordPrompts=0:
#   não solicita senha.
#
# ConnectTimeout=5:
#   limita o tempo de conexão.

# ssh -vv \
#   -o PreferredAuthentications=none \
#   -o BatchMode=yes \
#   -o NumberOfPasswordPrompts=0 \
#   -o ConnectTimeout=5 \
#   "$USERNAME@$TARGET" \
#   2>&1 | tee ssh_authentication_methods.txt


# ------------------------------------------------------------------------------
# 2.6 Forçando autenticação por senha
# ------------------------------------------------------------------------------

# Este comando é útil quando o cliente tenta primeiro diversas chaves locais e
# você deseja confirmar explicitamente o comportamento da autenticação por senha.
#
# PreferredAuthentications=password:
#   coloca password como método preferido.
#
# PubkeyAuthentication=no:
#   impede tentativa de autenticação por chave pública.
#
# NumberOfPasswordPrompts=1:
#   limita a uma tentativa interativa.

# ssh -v \
#   -o PreferredAuthentications=password \
#   -o PubkeyAuthentication=no \
#   -o NumberOfPasswordPrompts=1 \
#   "$USERNAME@$TARGET"


# ------------------------------------------------------------------------------
# 2.7 Conectando em uma porta SSH não padrão
# ------------------------------------------------------------------------------

# Caso a varredura encontre SSH em outra porta:

NON_STANDARD_SSH_PORT="2222"

# ssh -p "$NON_STANDARD_SSH_PORT" "$USERNAME@$TARGET"

# Em modo verboso:

# ssh -vvv -p "$NON_STANDARD_SSH_PORT" "$USERNAME@$TARGET"


# ------------------------------------------------------------------------------
# 2.8 Executando um comando remoto via SSH
# ------------------------------------------------------------------------------

# Após possuir credenciais válidas, é possível executar um comando sem abrir
# um shell interativo.
#
# Exemplo seguro de reconhecimento pós-autenticação:
#
# - whoami:
#   mostra o usuário autenticado.
#
# - hostname:
#   mostra o hostname.
#
# - id:
#   mostra UID, GID e grupos.
#
# - uname -a:
#   mostra informações do kernel.

# ssh "$USERNAME@$TARGET" 'whoami; hostname; id; uname -a'


# ------------------------------------------------------------------------------
# 2.9 Autenticação por chave pública
# ------------------------------------------------------------------------------

# Gera um novo par de chaves ED25519.
#
# -t ed25519:
#   algoritmo moderno.
#
# -a 100:
#   aumenta o custo da derivação da passphrase.
#
# -f:
#   define o arquivo de saída.
#
# Use uma passphrase forte quando a chave for real.

# ssh-keygen -t ed25519 -a 100 -f ./htb_ed25519

# Arquivos gerados:
#
# htb_ed25519:
#   chave privada.
#
# htb_ed25519.pub:
#   chave pública.

# Mostra a chave pública.

# cat ./htb_ed25519.pub

# Exibe o fingerprint da chave pública.

# ssh-keygen -lf ./htb_ed25519.pub

# Copia a chave pública para o servidor, caso você já possua acesso autorizado
# por senha.

# ssh-copy-id -i ./htb_ed25519.pub "$USERNAME@$TARGET"

# Conecta utilizando uma chave privada específica.

# ssh -i ./htb_ed25519 "$USERNAME@$TARGET"

# Corrige permissões de uma chave privada coletada em laboratório.
#
# OpenSSH normalmente recusa chaves privadas muito permissivas.

# chmod 600 ./id_rsa

# Conecta usando uma chave RSA coletada de forma autorizada.

# ssh -i ./id_rsa "$USERNAME@$TARGET"

# Para uma porta não padrão:

# ssh -i ./id_rsa -p "$NON_STANDARD_SSH_PORT" "$USERNAME@$TARGET"


# ------------------------------------------------------------------------------
# 2.10 Arquivos SSH importantes
# ------------------------------------------------------------------------------

# Configuração global do servidor OpenSSH:
#
# /etc/ssh/sshd_config
#
# Configurações adicionais podem ser incluídas de:
#
# /etc/ssh/sshd_config.d/*.conf
#
# Configuração do cliente:
#
# /etc/ssh/ssh_config
#
# Configuração por usuário:
#
# ~/.ssh/config
#
# Chaves públicas autorizadas:
#
# ~/.ssh/authorized_keys
#
# Chaves privadas comuns:
#
# ~/.ssh/id_rsa
# ~/.ssh/id_ed25519
# ~/.ssh/id_ecdsa
#
# Chaves públicas correspondentes:
#
# ~/.ssh/id_rsa.pub
# ~/.ssh/id_ed25519.pub
#
# Hosts conhecidos:
#
# ~/.ssh/known_hosts

# Visualização da configuração ativa não comentada do servidor.
#
# grep -v "#":
#   remove linhas que contêm comentários.
#
# sed -r '/^\s*$/d':
#   remove linhas em branco.

# cat /etc/ssh/sshd_config \
#   | grep -v "#" \
#   | sed -r '/^\s*$/d'

# Forma mais robusta de ignorar somente comentários completos e linhas vazias:

# grep -Ev '^\s*(#|$)' /etc/ssh/sshd_config

# Procura diretivas consideradas relevantes ou potencialmente inseguras.

# grep -Ei \
#   '^(PasswordAuthentication|PermitEmptyPasswords|PermitRootLogin|Protocol|X11Forwarding|AllowTcpForwarding|PermitTunnel|DebianBanner|PubkeyAuthentication|UsePAM|AllowUsers|AllowGroups)' \
#   /etc/ssh/sshd_config

# Mostra a configuração efetiva processada pelo sshd.
#
# Esse comando deve ser executado no próprio servidor autorizado.
#
# Ele considera valores padrão e includes, sendo geralmente mais preciso que
# apenas ler o arquivo.

# sudo sshd -T

# Filtra apenas opções relevantes.

# sudo sshd -T | grep -Ei \
#   'passwordauthentication|permitemptypasswords|permitrootlogin|x11forwarding|allowtcpforwarding|permittunnel|pubkeyauthentication|usepam'


# ------------------------------------------------------------------------------
# 2.11 Configurações perigosas explicadas
# ------------------------------------------------------------------------------

# PasswordAuthentication yes
#
# Permite autenticação por senha.
# Risco:
#   senha fraca, reutilização de senha, password spraying ou brute force.
#
# PermitEmptyPasswords yes
#
# Permite contas sem senha, se elas existirem no sistema.
#
# PermitRootLogin yes
#
# Permite autenticação direta como root.
# Isso aumenta o impacto de uma credencial comprometida.
#
# Protocol 1
#
# Habilita SSH versão 1, legado e inseguro.
#
# X11Forwarding yes
#
# Permite encaminhamento de aplicações gráficas X11.
# Pode ampliar a superfície de ataque e geralmente não é necessário em servidores.
#
# AllowTcpForwarding yes
#
# Permite encaminhamento de portas TCP.
# É legítimo, mas pode ser abusado para pivoting após o comprometimento.
#
# PermitTunnel yes
#
# Permite tunelamento de rede.
#
# DebianBanner yes
#
# Pode revelar informações extras sobre o pacote/distribuição.


# ------------------------------------------------------------------------------
# 2.12 Auditoria do SSH com ssh-audit
# ------------------------------------------------------------------------------

# Clona o projeto oficial ssh-audit.

# git clone https://github.com/jtesta/ssh-audit.git

# Entra no diretório.

# cd ssh-audit

# Executa a auditoria contra o alvo.

# ./ssh-audit.py "$TARGET"

# Alternativamente, algumas versões utilizam um executável sem extensão:

# ./ssh-audit "$TARGET"

# Para uma porta não padrão:

# ./ssh-audit.py -p "$NON_STANDARD_SSH_PORT" "$TARGET"

# Salva o resultado.

# ./ssh-audit.py "$TARGET" | tee ../ssh_audit_report.txt

# O ssh-audit pode revelar:
#
# - banner;
# - software e versão;
# - compatibilidade;
# - compressão;
# - algoritmos de troca de chave;
# - algoritmos de host key;
# - cifras;
# - MACs;
# - recomendações de endurecimento;
# - algoritmos obsoletos;
# - vulnerabilidades conhecidas em certas versões.


# ------------------------------------------------------------------------------
# 2.13 Pesquisa local por versão e vulnerabilidades
# ------------------------------------------------------------------------------

# Depois de identificar a versão, registre-a e procure referências em fontes
# confiáveis.
#
# Exemplo de pesquisa local no Searchsploit:

OPENSSH_VERSION="8.2p1"

# searchsploit "OpenSSH $OPENSSH_VERSION"

# Pesquisa genérica:

# searchsploit OpenSSH

# Atualiza o banco do Searchsploit, se instalado via Exploit-DB.

# searchsploit -u

# Observação importante:
#
# Um banner antigo não prova que o servidor é vulnerável.
# Distribuições Linux frequentemente aplicam patches de segurança sem alterar
# integralmente a versão exibida no banner.
#
# Sempre correlacione:
#
# - versão do upstream;
# - versão do pacote da distribuição;
# - patches/backports;
# - configuração;
# - pré-condições da vulnerabilidade.


# ------------------------------------------------------------------------------
# 2.14 CVE-2020-14145
# ------------------------------------------------------------------------------

# A aula cita a CVE-2020-14145.
#
# Ela se relaciona a um cenário de man-in-the-middle envolvendo a primeira
# conexão e o uso de certas opções de algoritmo/host key em clientes OpenSSH.
#
# Pontos importantes:
#
# - não é simplesmente um "exploit remoto para obter root";
# - depende de condições específicas;
# - reforça a importância de verificar fingerprints de host keys;
# - o usuário não deve aceitar cegamente uma chave de servidor desconhecida.
#
# Para visualizar a chave do host antes de se conectar:

# ssh-keyscan -p "$SSH_PORT" "$TARGET" 2>/dev/null | tee ssh_host_keys.txt

# Gera fingerprints das chaves coletadas.

# ssh-keyscan -p "$SSH_PORT" "$TARGET" 2>/dev/null \
#   | ssh-keygen -lf -

# Coleta tipos específicos de chave.

# ssh-keyscan -t rsa,ecdsa,ed25519 \
#   -p "$SSH_PORT" \
#   "$TARGET" \
#   2>/dev/null \
#   | tee ssh_host_keys_all.txt


# ------------------------------------------------------------------------------
# 2.15 Teste autorizado de credenciais reutilizadas
# ------------------------------------------------------------------------------

# Em um pentest, credenciais podem ter sido obtidas de:
#
# - FTP;
# - SMB;
# - banco de dados;
# - arquivo de configuração;
# - backup;
# - Rsync;
# - vazamento interno;
# - secrets.yaml;
# - chave privada exposta.
#
# Antes de qualquer teste, confirme que as credenciais e o alvo estão dentro
# do escopo autorizado.
#
# Teste manual de uma credencial:

# ssh \
#   -o PreferredAuthentications=password \
#   -o PubkeyAuthentication=no \
#   "$USERNAME@$TARGET"

# Para automação controlada de uma única senha em laboratório, o sshpass pode
# ser usado, embora não seja recomendado para ambientes reais por expor a senha
# na linha de comando ou no ambiente.

# PASSWORD='Password1'

# sshpass -p "$PASSWORD" ssh \
#   -o StrictHostKeyChecking=no \
#   -o PreferredAuthentications=password \
#   -o PubkeyAuthentication=no \
#   "$USERNAME@$TARGET" \
#   'whoami; hostname; id'

# Evite ataques massivos ou indiscriminados.
# Use listas pequenas, limites de tentativas e autorização explícita.


# ------------------------------------------------------------------------------
# 2.16 Transferência de arquivos com SCP e SFTP
# ------------------------------------------------------------------------------

# Copia um arquivo local para o servidor.

# scp ./arquivo.txt "$USERNAME@$TARGET:/tmp/arquivo.txt"

# Copia um arquivo remoto para a máquina local.

# scp "$USERNAME@$TARGET:/etc/hostname" ./hostname_remote.txt

# Porta SSH não padrão:

# scp -P "$NON_STANDARD_SSH_PORT" \
#   "$USERNAME@$TARGET:/etc/hostname" \
#   ./hostname_remote.txt

# Abre uma sessão SFTP.

# sftp "$USERNAME@$TARGET"

# Dentro do SFTP:
#
# pwd
# lpwd
# ls
# lls
# get arquivo
# put arquivo
# exit


# ------------------------------------------------------------------------------
# 2.17 Encaminhamento de portas SSH
# ------------------------------------------------------------------------------

# Esta aula menciona que SSH pode ser utilizado para port forwarding.
#
# Os exemplos abaixo são apenas para laboratório autorizado.
#
# Encaminhamento local:
#
# Abre a porta local 8080 e encaminha para 127.0.0.1:80 do ponto de vista
# do servidor SSH.

# ssh -L 8080:127.0.0.1:80 "$USERNAME@$TARGET"

# Encaminhamento remoto:
#
# Solicita que o servidor SSH abra a porta 9000 e encaminhe para a porta
# local 8000.

# ssh -R 9000:127.0.0.1:8000 "$USERNAME@$TARGET"

# Proxy SOCKS dinâmico:
#
# Abre um proxy SOCKS local na porta 1080.

# ssh -D 1080 "$USERNAME@$TARGET"

# -N:
#   não executa comando remoto.
#
# -f:
#   envia o processo para segundo plano após autenticar.

# ssh -N -f -D 1080 "$USERNAME@$TARGET"


# ==============================================================================
# 3. RSYNC
# ==============================================================================

# ------------------------------------------------------------------------------
# 3.1 Entendendo o objetivo
# ------------------------------------------------------------------------------

# Rsync é utilizado para:
#
# - backups;
# - espelhamento;
# - replicação;
# - sincronização de diretórios;
# - cópia local ou remota.
#
# Ele pode funcionar:
#
# 1. Como daemon próprio, normalmente na porta TCP 873.
# 2. Sobre SSH.
#
# No modo daemon, o servidor expõe "módulos".
#
# Um módulo funciona de forma semelhante a um compartilhamento nomeado.
#
# Objetivos do footprinting:
#
# - identificar se a porta 873 está aberta;
# - descobrir a versão do protocolo;
# - listar módulos;
# - verificar se o módulo aceita acesso anônimo;
# - enumerar diretórios e arquivos;
# - localizar backups, chaves SSH e arquivos de segredos;
# - baixar somente o necessário para análise.


# ------------------------------------------------------------------------------
# 3.2 Varredura específica do Rsync
# ------------------------------------------------------------------------------

# Detecção simples de versão.

# sudo nmap -Pn -sV -p "$RSYNC_PORT" "$TARGET" -oN rsync_version_scan.txt

# Scripts NSE úteis:
#
# rsync-list-modules:
#   tenta listar módulos disponibilizados pelo daemon.

# sudo nmap -Pn -p "$RSYNC_PORT" \
#   --script rsync-list-modules \
#   "$TARGET" \
#   -oN rsync_modules_nmap.txt


# ------------------------------------------------------------------------------
# 3.3 Coleta manual do banner/protocolo Rsync
# ------------------------------------------------------------------------------

# Conecta ao daemon Rsync usando Netcat.

# nc -nv "$TARGET" "$RSYNC_PORT"

# Uma resposta típica:
#
# @RSYNCD: 31.0
#
# Isso indica a versão do protocolo Rsync.
#
# Para solicitar a lista de módulos manualmente, envie:
#
# #list
#
# Em modo interativo:
#
# nc -nv "$TARGET" 873
# #list

# Forma automatizada:

# printf '#list\n' \
#   | nc -nv "$TARGET" "$RSYNC_PORT" \
#   | tee rsync_module_list_nc.txt

# Algumas implementações esperam primeiro o banner do cliente.
#
# Exemplo:

# {
#   printf '@RSYNCD: 31.0\n'
#   printf '#list\n'
# } | nc -nv "$TARGET" "$RSYNC_PORT" \
#   | tee rsync_module_list_protocol.txt


# ------------------------------------------------------------------------------
# 3.4 Listando módulos com o cliente Rsync
# ------------------------------------------------------------------------------

# O cliente rsync pode listar módulos diretamente.

# rsync "rsync://$TARGET/"

# Forma equivalente:

# rsync --list-only "rsync://$TARGET/"

# Salva o resultado:

# rsync --list-only "rsync://$TARGET/" \
#   | tee rsync_modules.txt

# Exemplo de resposta:
#
# dev             Dev Tools
# backup          Backup Files
# public          Public Share


# ------------------------------------------------------------------------------
# 3.5 Enumerando um módulo aberto
# ------------------------------------------------------------------------------

RSYNC_MODULE="dev"

# Lista o conteúdo do módulo sem baixar arquivos.
#
# -a:
#   modo archive; preserva vários atributos.
#
# -v:
#   verbose.
#
# --list-only:
#   apenas lista o conteúdo.

# rsync -av --list-only \
#   "rsync://$TARGET/$RSYNC_MODULE" \
#   | tee "rsync_${RSYNC_MODULE}_listing.txt"

# Adiciona barra no final para deixar explícito que estamos listando o conteúdo
# interno do módulo.

# rsync -av --list-only \
#   "rsync://$TARGET/$RSYNC_MODULE/"


# ------------------------------------------------------------------------------
# 3.6 Enumeração recursiva
# ------------------------------------------------------------------------------

# Dependendo da versão e configuração, a listagem pode mostrar subdiretórios.
#
# Para obter uma listagem recursiva:

# rsync -av --recursive --list-only \
#   "rsync://$TARGET/$RSYNC_MODULE/" \
#   | tee "rsync_${RSYNC_MODULE}_recursive_listing.txt"

# Apenas nomes:

# rsync -r --list-only \
#   "rsync://$TARGET/$RSYNC_MODULE/"


# ------------------------------------------------------------------------------
# 3.7 Baixando um módulo
# ------------------------------------------------------------------------------

# Cria um diretório de destino.

mkdir -p "rsync_download_$RSYNC_MODULE"

# Baixa todo o conteúdo do módulo.
#
# A barra final na origem significa:
#   copie o conteúdo do módulo para o diretório local.
#
# Sem a barra, o comportamento de criação do diretório pode mudar.

# rsync -av \
#   "rsync://$TARGET/$RSYNC_MODULE/" \
#   "rsync_download_$RSYNC_MODULE/"

# Exibe progresso humano-legível.

# rsync -avh --progress \
#   "rsync://$TARGET/$RSYNC_MODULE/" \
#   "rsync_download_$RSYNC_MODULE/"


# ------------------------------------------------------------------------------
# 3.8 Baixando apenas um arquivo específico
# ------------------------------------------------------------------------------

# Exemplo: secrets.yaml

# rsync -av \
#   "rsync://$TARGET/$RSYNC_MODULE/secrets.yaml" \
#   ./secrets.yaml

# Exemplo: build.sh

# rsync -av \
#   "rsync://$TARGET/$RSYNC_MODULE/build.sh" \
#   ./build.sh


# ------------------------------------------------------------------------------
# 3.9 Baixando um diretório .ssh
# ------------------------------------------------------------------------------

# Diretórios .ssh são extremamente importantes porque podem conter:
#
# - chaves privadas;
# - authorized_keys;
# - known_hosts;
# - config;
# - fingerprints e hosts internos.
#
# Baixe somente dentro do escopo autorizado.

mkdir -p rsync_ssh_directory

# rsync -av \
#   "rsync://$TARGET/$RSYNC_MODULE/.ssh/" \
#   ./rsync_ssh_directory/

# Depois da coleta, liste os arquivos e permissões.

# find ./rsync_ssh_directory \
#   -maxdepth 3 \
#   -printf '%M %u %g %s %TY-%Tm-%Td %TH:%TM %p\n'

# Procura nomes de arquivos interessantes.

# find ./rsync_ssh_directory \
#   -type f \
#   \( \
#     -name 'id_rsa' \
#     -o -name 'id_ed25519' \
#     -o -name 'id_ecdsa' \
#     -o -name 'authorized_keys' \
#     -o -name 'known_hosts' \
#     -o -name 'config' \
#   \) \
#   -print


# ------------------------------------------------------------------------------
# 3.10 Analisando arquivos coletados
# ------------------------------------------------------------------------------

# Lista todos os arquivos.

# find "rsync_download_$RSYNC_MODULE" -type f -print

# Procura strings que podem indicar segredos.
#
# Atenção:
#   resultados podem conter dados sensíveis.
#   armazene-os e trate-os conforme as regras do pentest.

# grep -RniE \
#   'password|passwd|secret|token|api[_-]?key|private[_-]?key|username|user|ssh|database|db_' \
#   "rsync_download_$RSYNC_MODULE"

# Identifica chaves privadas PEM/OpenSSH.

# grep -RnlE \
#   'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY' \
#   "rsync_download_$RSYNC_MODULE"

# Procura arquivos YAML, JSON, INI, ENV, CONF e scripts.

# find "rsync_download_$RSYNC_MODULE" \
#   -type f \
#   \( \
#     -iname '*.yaml' \
#     -o -iname '*.yml' \
#     -o -iname '*.json' \
#     -o -iname '*.ini' \
#     -o -iname '*.env' \
#     -o -iname '*.conf' \
#     -o -iname '*.config' \
#     -o -iname '*.sh' \
#   \) \
#   -print

# Mostra o tipo de cada arquivo.

# find "rsync_download_$RSYNC_MODULE" \
#   -type f \
#   -exec file {} \;


# ------------------------------------------------------------------------------
# 3.11 Rsync protegido por senha
# ------------------------------------------------------------------------------

# Alguns módulos exigem autenticação.
#
# O cliente pode solicitar:
#
# Password:
#
# Usuário no URL:

RSYNC_USER="backup"

# rsync -av --list-only \
#   "rsync://$RSYNC_USER@$TARGET/$RSYNC_MODULE/"

# A variável RSYNC_PASSWORD evita o prompt, mas pode expor o segredo para
# processos/ambiente. Use apenas em laboratório controlado.

# export RSYNC_PASSWORD='Password1'

# rsync -av --list-only \
#   "rsync://$RSYNC_USER@$TARGET/$RSYNC_MODULE/"

# Limpa a variável depois do teste.

# unset RSYNC_PASSWORD

# Forma mais segura: arquivo de senha com permissão 600.

# printf '%s\n' 'Password1' > rsync_password.txt
# chmod 600 rsync_password.txt

# rsync -av --list-only \
#   --password-file=rsync_password.txt \
#   "rsync://$RSYNC_USER@$TARGET/$RSYNC_MODULE/"


# ------------------------------------------------------------------------------
# 3.12 Rsync sobre SSH
# ------------------------------------------------------------------------------

# Quando Rsync utiliza SSH, a porta 873 pode nem estar aberta.
#
# A sintaxe se parece com uma cópia remota SSH.
#
# Lista diretório remoto sobre SSH:

REMOTE_PATH="/var/backups/"

# rsync -av --list-only \
#   -e ssh \
#   "$USERNAME@$TARGET:$REMOTE_PATH"

# Baixa um diretório remoto usando SSH:

mkdir -p rsync_over_ssh_download

# rsync -avh --progress \
#   -e ssh \
#   "$USERNAME@$TARGET:$REMOTE_PATH" \
#   ./rsync_over_ssh_download/

# SSH em porta não padrão:

# rsync -avh --progress \
#   -e "ssh -p $NON_STANDARD_SSH_PORT" \
#   "$USERNAME@$TARGET:$REMOTE_PATH" \
#   ./rsync_over_ssh_download/

# Utilizando uma chave privada:

# rsync -avh --progress \
#   -e "ssh -i ./id_rsa -p $NON_STANDARD_SSH_PORT" \
#   "$USERNAME@$TARGET:$REMOTE_PATH" \
#   ./rsync_over_ssh_download/


# ------------------------------------------------------------------------------
# 3.13 Fluxo de abuso autorizado do Rsync
# ------------------------------------------------------------------------------

# O fluxo típico estudado nesta aula é:
#
# 1. Nmap identifica 873/TCP aberto.
# 2. Banner indica protocolo Rsync.
# 3. #list ou rsync://IP/ revela módulos.
# 4. --list-only revela arquivos.
# 5. O pentester encontra:
#      - secrets.yaml;
#      - backup;
#      - arquivos .env;
#      - diretório .ssh;
#      - chaves privadas;
#      - configurações.
# 6. O conteúdo é baixado para análise.
# 7. Credenciais ou chaves encontradas são testadas somente contra serviços
#    e usuários dentro do escopo.
# 8. Uma chave privada encontrada pode permitir acesso SSH, caso:
#      - corresponda a uma chave autorizada;
#      - não esteja protegida ou a passphrase seja conhecida;
#      - o usuário correto seja identificado;
#      - o servidor aceite autenticação por chave.


# ==============================================================================
# 4. BERKELEY R-SERVICES
# ==============================================================================

# ------------------------------------------------------------------------------
# 4.1 Entendendo os serviços
# ------------------------------------------------------------------------------

# R-Services são protocolos legados de administração remota Unix.
#
# Principais comandos:
#
# rcp:
#   cópia remota de arquivos.
#
# rsh:
#   execução de shell/comandos remotos.
#
# rexec:
#   execução remota autenticada.
#
# rlogin:
#   login remoto.
#
# rwho:
#   lista usuários/sessões divulgadas na rede.
#
# rusers:
#   consulta informações detalhadas de usuários conectados.
#
# Portas:
#
# 512/TCP:
#   rexec.
#
# 513/TCP:
#   rlogin.
#
# 514/TCP:
#   rsh / rcp.
#
# Os protocolos são inseguros porque:
#
# - podem transmitir dados sem criptografia;
# - dependem de confiança entre hosts;
# - podem confiar em hostname/IP;
# - podem ser burlados por configurações perigosas em hosts.equiv ou .rhosts;
# - são vulneráveis a sniffing e MITM em redes não confiáveis.


# ------------------------------------------------------------------------------
# 4.2 Varredura dos R-Services
# ------------------------------------------------------------------------------

# Varredura de versão.

# sudo nmap -Pn -sV \
#   -p "$REXEC_PORT,$RLOGIN_PORT,$RSH_PORT" \
#   "$TARGET" \
#   -oN rservices_version_scan.txt

# Varredura com scripts padrão.

# sudo nmap -Pn -sC -sV \
#   -p 512,513,514 \
#   "$TARGET" \
#   -oN rservices_default_scripts.txt

# Uma resposta típica pode ser:
#
# 512/tcp open  exec?
# 513/tcp open  login?
# 514/tcp open  tcpwrapped
#
# O ponto de interrogação indica que o Nmap não confirmou completamente
# o serviço, mas encontrou comportamento compatível.


# ------------------------------------------------------------------------------
# 4.3 Testes básicos de conectividade
# ------------------------------------------------------------------------------

# Testa se as portas aceitam conexão TCP.

# nc -nv "$TARGET" 512

# nc -nv "$TARGET" 513

# nc -nv "$TARGET" 514

# Forma não interativa com timeout:

# timeout 5 nc -nv "$TARGET" 512

# timeout 5 nc -nv "$TARGET" 513

# timeout 5 nc -nv "$TARGET" 514


# ------------------------------------------------------------------------------
# 4.4 Arquivos de confiança
# ------------------------------------------------------------------------------

# /etc/hosts.equiv
#
# Arquivo global de relações de confiança.
# Pode conceder acesso para usuários/hosts confiáveis.
#
# ~/.rhosts
#
# Arquivo por usuário.
# Define quais usuários/hosts podem acessar aquela conta usando r-commands.
#
# Exemplos conceituais:
#
# hostname username
#
# ou:
#
# username hostname
#
# A ordem exata pode variar conforme a implementação/documentação; por isso,
# valide sempre no ambiente e na página de manual correspondente.
#
# O caractere "+" é especialmente perigoso porque pode atuar como wildcard.
#
# Exemplo extremamente inseguro:
#
# + +
#
# Isso pode significar confiança ampla em qualquer host e qualquer usuário.


# ------------------------------------------------------------------------------
# 4.5 Verificando arquivos de confiança localmente
# ------------------------------------------------------------------------------

# Estes comandos devem ser executados somente em uma máquina que você administra
# ou após obter acesso autorizado.

# cat /etc/hosts.equiv

# cat ~/.rhosts

# Lista permissões e proprietário.

# ls -la /etc/hosts.equiv ~/.rhosts 2>/dev/null

# Procura arquivos .rhosts no sistema.
#
# Pode exigir privilégios para acessar certos diretórios.

# find /home /root \
#   -name '.rhosts' \
#   -type f \
#   -ls \
#   2>/dev/null

# Procura wildcards perigosos.

# grep -RniE '^\s*\+\s+\+|^\s*\+' \
#   /etc/hosts.equiv \
#   /home/*/.rhosts \
#   /root/.rhosts \
#   2>/dev/null


# ------------------------------------------------------------------------------
# 4.6 Login com rlogin
# ------------------------------------------------------------------------------

# Sintaxe apresentada na aula:

RLOGIN_USER="htb-student"

# rlogin "$TARGET" -l "$RLOGIN_USER"

# Outra sintaxe aceita por algumas implementações:

# rlogin -l "$RLOGIN_USER" "$TARGET"

# Se a relação de confiança estiver incorretamente configurada, o usuário pode
# entrar sem fornecer senha.
#
# Após o login, comandos básicos de validação:
#
# whoami
# hostname
# id
# uname -a
# pwd


# ------------------------------------------------------------------------------
# 4.7 Execução remota com rsh
# ------------------------------------------------------------------------------

# rsh pode executar um comando remoto se a relação de confiança permitir.
#
# Exemplo:

# rsh "$TARGET" -l "$RLOGIN_USER" 'whoami; hostname; id'

# Algumas implementações usam a opção em outra posição:

# rsh -l "$RLOGIN_USER" "$TARGET" 'whoami; hostname; id'

# Abrir um shell remoto:

# rsh "$TARGET" -l "$RLOGIN_USER"


# ------------------------------------------------------------------------------
# 4.8 Cópia remota com rcp
# ------------------------------------------------------------------------------

# Copia arquivo local para o host remoto.

# rcp ./arquivo.txt "$RLOGIN_USER@$TARGET:/tmp/arquivo.txt"

# Copia arquivo remoto para a máquina local.

# rcp "$RLOGIN_USER@$TARGET:/etc/hostname" ./hostname_rservice.txt

# Copia diretório recursivamente, se suportado.

# rcp -r \
#   "$RLOGIN_USER@$TARGET:/home/$RLOGIN_USER/diretorio" \
#   ./diretorio_copiado


# ------------------------------------------------------------------------------
# 4.9 Execução com rexec
# ------------------------------------------------------------------------------

# A disponibilidade e a sintaxe do cliente rexec variam por distribuição.
#
# Em algumas implementações:

# rexec "$TARGET" -l "$RLOGIN_USER" 'whoami'

# Outras ferramentas podem solicitar usuário e senha.
#
# Como rexec é legado e pode transmitir credenciais sem criptografia, não use
# em redes não confiáveis e não reutilize credenciais reais.


# ------------------------------------------------------------------------------
# 4.10 Enumerando sessões com rwho
# ------------------------------------------------------------------------------

# rwho exibe usuários divulgados pelo serviço rwhod na rede local.

# rwho

# Exemplo de saída:
#
# root            web01:pts/0        Dec  2 21:34
# htb-student     workstn01:tty1     Dec  2 19:57  2:25
#
# Informações úteis:
#
# - nomes de usuários;
# - host no qual estão conectados;
# - terminal;
# - horário da sessão;
# - possível atividade.
#
# Esses nomes podem alimentar a lista de usuários para outros testes autorizados.


# ------------------------------------------------------------------------------
# 4.11 Enumerando usuários com rusers
# ------------------------------------------------------------------------------

# Consulta informações detalhadas do host.

# rusers -al "$TARGET"

# Opções:
#
# -a:
#   exibe todos os usuários.
#
# -l:
#   formato longo/detalhado.
#
# Uma saída típica pode mostrar:
#
# - username;
# - host;
# - console ou TTY;
# - data/hora do login;
# - tempo de inatividade;
# - host de origem.


# ------------------------------------------------------------------------------
# 4.12 Verificação de tráfego R-Services
# ------------------------------------------------------------------------------

# Como esses protocolos são legados e podem transmitir informações em texto
# claro, em um laboratório autorizado você pode observar o tráfego.
#
# Captura das portas TCP 512, 513 e 514:

# sudo tcpdump -i any \
#   'tcp port 512 or tcp port 513 or tcp port 514' \
#   -nn -A

# Captura relacionada ao rwho/rwhod, que pode utilizar UDP 513:

# sudo tcpdump -i any \
#   'udp port 513' \
#   -nn -A

# Salva a captura em PCAP:

# sudo tcpdump -i any \
#   '(tcp port 512 or tcp port 513 or tcp port 514 or udp port 513)' \
#   -nn \
#   -w rservices_traffic.pcap


# ------------------------------------------------------------------------------
# 4.13 Fluxo de abuso autorizado dos R-Services
# ------------------------------------------------------------------------------

# 1. Nmap identifica 512, 513 ou 514 abertas.
# 2. O pentester confirma o serviço.
# 3. Nomes de usuários são obtidos de:
#      - rwho;
#      - rusers;
#      - outros serviços;
#      - arquivos;
#      - enumeração anterior.
# 4. É testado rlogin ou rsh com um usuário autorizado.
# 5. Uma relação de confiança mal configurada pode permitir acesso sem senha.
# 6. Após o acesso, são verificados:
#      - identidade do usuário;
#      - hostname;
#      - grupos;
#      - arquivos .rhosts;
#      - /etc/hosts.equiv;
#      - outros hosts confiáveis.
# 7. O pentester documenta o risco:
#      - autenticação baseada em confiança;
#      - transmissão sem criptografia;
#      - spoofing/MITM;
#      - movimentação lateral;
#      - execução de comandos sem senha.


# ==============================================================================
# 5. FLUXO COMPLETO DA AULA
# ==============================================================================

# O fluxo completo desta seção pode ser resumido assim:
#
# ETAPA 1 - Definir o alvo autorizado
#
# TARGET="10.129.x.x"
#
# ETAPA 2 - Descobrir portas
#
# sudo nmap -Pn -sV -p 22,873,512,513,514 "$TARGET"
#
# ETAPA 3 - Separar por serviço
#
# SSH:
#   22/TCP
#
# Rsync:
#   873/TCP
#
# R-Services:
#   512/513/514 TCP
#
# ETAPA 4 - SSH
#
# 4.1 Coletar banner:
#
# timeout 5 nc -nv "$TARGET" 22
#
# 4.2 Coletar versão e algoritmos:
#
# sudo nmap -Pn -p22 --script ssh2-enum-algos,ssh-hostkey "$TARGET"
#
# 4.3 Ver métodos de autenticação:
#
# ssh -vv usuario@"$TARGET"
#
# 4.4 Forçar senha para verificar o fluxo:
#
# ssh -o PreferredAuthentications=password \
#     -o PubkeyAuthentication=no \
#     usuario@"$TARGET"
#
# 4.5 Auditar algoritmos:
#
# ./ssh-audit.py "$TARGET"
#
# 4.6 Correlacionar versão com:
#
# - advisories oficiais;
# - CVEs;
# - versão do pacote;
# - patches da distribuição;
# - configuração efetiva.
#
# 4.7 Testar, de forma autorizada, credenciais/chaves obtidas em outros serviços.
#
# ETAPA 5 - RSYNC
#
# 5.1 Confirmar serviço:
#
# sudo nmap -Pn -sV -p873 "$TARGET"
#
# 5.2 Listar módulos:
#
# printf '#list\n' | nc -nv "$TARGET" 873
#
# ou:
#
# rsync --list-only "rsync://$TARGET/"
#
# 5.3 Listar conteúdo do módulo:
#
# rsync -av --list-only "rsync://$TARGET/dev/"
#
# 5.4 Procurar:
#
# - .ssh;
# - id_rsa;
# - id_ed25519;
# - authorized_keys;
# - secrets.yaml;
# - arquivos .env;
# - backups;
# - scripts;
# - configurações.
#
# 5.5 Baixar conteúdo:
#
# rsync -av "rsync://$TARGET/dev/" ./dev/
#
# 5.6 Analisar localmente:
#
# find ./dev -type f -print
#
# grep -RniE 'password|secret|token|key|user' ./dev
#
# 5.7 Testar somente credenciais/chaves dentro do escopo.
#
# ETAPA 6 - R-SERVICES
#
# 6.1 Identificar portas:
#
# sudo nmap -Pn -sV -p512,513,514 "$TARGET"
#
# 6.2 Enumerar usuários/sessões:
#
# rwho
#
# rusers -al "$TARGET"
#
# 6.3 Testar relação de confiança:
#
# rlogin "$TARGET" -l usuario
#
# ou:
#
# rsh "$TARGET" -l usuario 'whoami; hostname; id'
#
# 6.4 Após acesso autorizado, verificar:
#
# cat /etc/hosts.equiv
#
# cat ~/.rhosts
#
# 6.5 Registrar riscos:
#
# - acesso sem senha;
# - wildcard "+";
# - confiança indevida em host/usuário;
# - dados em texto claro;
# - possibilidade de execução remota;
# - movimentação lateral.


# ==============================================================================
# 6. COMANDOS CONSOLIDADOS PARA MEMORIZAÇÃO
# ==============================================================================

# ------------------------------------------------------------------------------
# NMAP
# ------------------------------------------------------------------------------

# sudo nmap -Pn -sV -p22 "$TARGET"

# sudo nmap -Pn -p22 \
#   --script ssh2-enum-algos,ssh-hostkey \
#   "$TARGET"

# sudo nmap -Pn -p22 \
#   --script ssh-auth-methods \
#   --script-args="ssh.user=$USERNAME" \
#   "$TARGET"

# sudo nmap -Pn -sV -p873 "$TARGET"

# sudo nmap -Pn -p873 \
#   --script rsync-list-modules \
#   "$TARGET"

# sudo nmap -Pn -sV -p512,513,514 "$TARGET"


# ------------------------------------------------------------------------------
# SSH
# ------------------------------------------------------------------------------

# timeout 5 nc -nv "$TARGET" 22

# ssh -v "$USERNAME@$TARGET"

# ssh -vvv "$USERNAME@$TARGET" 2>&1 | tee ssh_verbose.txt

# ssh \
#   -o PreferredAuthentications=password \
#   -o PubkeyAuthentication=no \
#   "$USERNAME@$TARGET"

# ssh -p 2222 "$USERNAME@$TARGET"

# ssh-keyscan "$TARGET"

# ssh-keyscan -t rsa,ecdsa,ed25519 "$TARGET"

# ssh-keyscan "$TARGET" | ssh-keygen -lf -

# git clone https://github.com/jtesta/ssh-audit.git

# cd ssh-audit

# ./ssh-audit.py "$TARGET"

# ssh-keygen -t ed25519 -a 100 -f ./htb_ed25519

# ssh-copy-id -i ./htb_ed25519.pub "$USERNAME@$TARGET"

# chmod 600 ./id_rsa

# ssh -i ./id_rsa "$USERNAME@$TARGET"

# ssh "$USERNAME@$TARGET" 'whoami; hostname; id; uname -a'

# scp "$USERNAME@$TARGET:/etc/hostname" ./hostname.txt

# sftp "$USERNAME@$TARGET"


# ------------------------------------------------------------------------------
# CONFIGURAÇÃO SSH
# ------------------------------------------------------------------------------

# cat /etc/ssh/sshd_config \
#   | grep -v "#" \
#   | sed -r '/^\s*$/d'

# grep -Ev '^\s*(#|$)' /etc/ssh/sshd_config

# sudo sshd -T

# sudo sshd -T | grep -Ei \
#   'passwordauthentication|permitemptypasswords|permitrootlogin|x11forwarding|allowtcpforwarding|permittunnel'


# ------------------------------------------------------------------------------
# RSYNC
# ------------------------------------------------------------------------------

# nc -nv "$TARGET" 873

# printf '#list\n' | nc -nv "$TARGET" 873

# rsync --list-only "rsync://$TARGET/"

# rsync -av --list-only "rsync://$TARGET/$RSYNC_MODULE/"

# rsync -av --recursive --list-only \
#   "rsync://$TARGET/$RSYNC_MODULE/"

# rsync -av \
#   "rsync://$TARGET/$RSYNC_MODULE/" \
#   "./rsync_download_$RSYNC_MODULE/"

# rsync -av \
#   "rsync://$TARGET/$RSYNC_MODULE/secrets.yaml" \
#   ./secrets.yaml

# rsync -av \
#   "rsync://$TARGET/$RSYNC_MODULE/.ssh/" \
#   ./rsync_ssh_directory/

# rsync -av --list-only \
#   "rsync://$RSYNC_USER@$TARGET/$RSYNC_MODULE/"

# rsync -av --list-only \
#   --password-file=rsync_password.txt \
#   "rsync://$RSYNC_USER@$TARGET/$RSYNC_MODULE/"

# rsync -av \
#   -e ssh \
#   "$USERNAME@$TARGET:/var/backups/" \
#   ./rsync_over_ssh_download/

# rsync -av \
#   -e "ssh -p 2222" \
#   "$USERNAME@$TARGET:/var/backups/" \
#   ./rsync_over_ssh_download/


# ------------------------------------------------------------------------------
# ANÁLISE DOS ARQUIVOS RSYNC
# ------------------------------------------------------------------------------

# find "./rsync_download_$RSYNC_MODULE" -type f -print

# grep -RniE \
#   'password|passwd|secret|token|api[_-]?key|private[_-]?key|username|user|ssh|database|db_' \
#   "./rsync_download_$RSYNC_MODULE"

# grep -RnlE \
#   'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY' \
#   "./rsync_download_$RSYNC_MODULE"


# ------------------------------------------------------------------------------
# R-SERVICES
# ------------------------------------------------------------------------------

# nc -nv "$TARGET" 512

# nc -nv "$TARGET" 513

# nc -nv "$TARGET" 514

# rlogin "$TARGET" -l "$RLOGIN_USER"

# rsh "$TARGET" -l "$RLOGIN_USER" 'whoami; hostname; id'

# rcp "$RLOGIN_USER@$TARGET:/etc/hostname" ./hostname_rservice.txt

# rwho

# rusers -al "$TARGET"

# cat /etc/hosts.equiv

# cat ~/.rhosts

# find /home /root -name '.rhosts' -type f -ls 2>/dev/null

# sudo tcpdump -i any \
#   '(tcp port 512 or tcp port 513 or tcp port 514 or udp port 513)' \
#   -nn -A


# ==============================================================================
# 7. O QUE DEVE SER DOCUMENTADO NO RELATÓRIO
# ==============================================================================

# Para cada serviço, registre:
#
# 1. IP do alvo.
# 2. Porta.
# 3. Estado da porta.
# 4. Serviço detectado.
# 5. Versão e banner.
# 6. Evidência do comando executado.
# 7. Métodos de autenticação.
# 8. Algoritmos fracos ou legados.
# 9. Módulos Rsync expostos.
# 10. Arquivos sensíveis acessíveis.
# 11. Relações de confiança R-Services.
# 12. Contas afetadas.
# 13. Impacto.
# 14. Probabilidade.
# 15. Recomendação de correção.
#
# Exemplos de recomendações:
#
# SSH:
#
# - desabilitar SSH versão 1;
# - desabilitar login direto de root;
# - desabilitar senhas quando possível;
# - utilizar chaves modernas;
# - exigir MFA onde aplicável;
# - limitar usuários e origens;
# - desabilitar X11Forwarding se desnecessário;
# - limitar AllowTcpForwarding;
# - remover algoritmos obsoletos;
# - manter OpenSSH e pacotes atualizados.
#
# Rsync:
#
# - não expor a porta 873 publicamente;
# - restringir módulos por IP;
# - exigir autenticação;
# - aplicar princípio do menor privilégio;
# - remover chaves e segredos de compartilhamentos;
# - utilizar SSH para transporte;
# - impedir escrita anônima;
# - revisar permissões.
#
# R-Services:
#
# - desabilitar completamente rlogin, rsh, rexec e rcp;
# - migrar para SSH/SCP/SFTP;
# - remover entradas de hosts.equiv e .rhosts;
# - nunca utilizar "+ +";
# - bloquear portas 512, 513 e 514;
# - monitorar protocolos legados;
# - revisar confiança entre hosts.


# ==============================================================================
# 8. FINAL DA AULA
# ==============================================================================

echo
echo "Material carregado."
echo "Alvo configurado: $TARGET"
echo
echo "Este arquivo funciona como roteiro de estudo."
echo "Os comandos permanecem comentados para evitar execução acidental."
echo "Execute apenas em laboratório ou ambiente explicitamente autorizado."