#!/usr/bin/env bash
# ==============================================================================
# HTB ACADEMY - FOOTPRINTING
# SEÇÃO 18/21 - WINDOWS REMOTE MANAGEMENT PROTOCOLS
#
# Protocolos estudados:
#   - RDP   (Remote Desktop Protocol)
#   - WinRM (Windows Remote Management)
#   - WMI   (Windows Management Instrumentation)
#
# OBJETIVO:
#   Consolidar, em um único arquivo, os comandos utilizados na aula e o fluxo
#   completo de footprinting, identificação, validação de segurança e acesso
#   remoto autorizado em um laboratório HTB.
#
# AVISO:
#   Use somente em máquinas próprias, ambientes de laboratório, CTFs ou sistemas
#   para os quais você tenha autorização explícita.
#
# COMO USAR:
#   1. Edite as variáveis abaixo.
#   2. Execute somente as etapas compatíveis com o laboratório.
#   3. Não execute indiscriminadamente em redes reais.
#
# Exemplo:
#   chmod +x windows_remote_management_footprinting.sh
#   ./windows_remote_management_footprinting.sh
#
# Este arquivo funciona principalmente como material de estudo. Alguns comandos
# exigem interação, credenciais válidas ou execução separada.
# ==============================================================================


# ==============================================================================
# 1. VARIÁVEIS DO LABORATÓRIO
# ==============================================================================

# IP do alvo Windows.
TARGET="10.129.201.248"

# Porta padrão do RDP.
RDP_PORT="3389"

# Portas padrão do WinRM.
WINRM_HTTP_PORT="5985"
WINRM_HTTPS_PORT="5986"

# Porta inicial do RPC Endpoint Mapper, usada por WMI/DCOM.
RPC_PORT="135"

# Credenciais de exemplo usadas pela própria aula.
# Substitua apenas por credenciais válidas fornecidas pelo laboratório.
USERNAME="Cry0l1t3"
PASSWORD='P455w0rD!'

# Nome de usuário alternativo exibido no exemplo de RDP da aula.
RDP_USERNAME="cry0l1t3"

# Diretório em que a ferramenta rdp-sec-check será clonada.
RDP_SEC_CHECK_DIR="$HOME/rdp-sec-check"


# ==============================================================================
# 2. VISÃO GERAL DO FLUXO
# ==============================================================================
#
# Fluxo de trabalho utilizado na aula:
#
#   1. Identificar as portas de administração remota.
#
#      RDP:
#        3389/TCP
#        3389/UDP, em implementações modernas
#
#      WinRM:
#        5985/TCP - HTTP
#        5986/TCP - HTTPS
#
#      WMI/RPC:
#        135/TCP para iniciar a negociação
#        portas RPC dinâmicas depois da negociação
#
#   2. Executar fingerprinting com Nmap.
#
#   3. Identificar:
#        - hostname
#        - domínio ou workgroup
#        - versão/build do Windows
#        - horário do servidor
#        - NLA
#        - CredSSP
#        - TLS/RDSTLS
#        - Microsoft HTTPAPI
#
#   4. Avaliar as configurações de segurança do RDP.
#
#   5. Testar a disponibilidade do WinRM.
#
#   6. Caso existam credenciais válidas:
#        - usar xfreerdp para RDP
#        - usar evil-winrm para WinRM
#        - usar wmiexec.py para WMI
#
#   7. Confirmar a identidade da máquina executando comandos como:
#        hostname
#        whoami
#        ipconfig
#        systeminfo
#
# ==============================================================================


# ==============================================================================
# 3. TESTE BÁSICO DE CONECTIVIDADE
# ==============================================================================

# Testa se o host responde a ICMP.
# Alguns servidores bloqueiam ping; uma falha aqui não significa que o host está
# necessariamente desligado.
ping -c 4 "$TARGET"

# Verifica rapidamente as principais portas da aula.
nmap -Pn -n -p "$RDP_PORT,$WINRM_HTTP_PORT,$WINRM_HTTPS_PORT,$RPC_PORT" "$TARGET"

# Parâmetros:
#   -Pn : não depende de ping para considerar o host ativo
#   -n  : não executa resolução DNS
#   -p  : limita o scan às portas informadas


# ==============================================================================
# 4. ENUMERAÇÃO DO RDP
# ==============================================================================

# Scan completo do serviço RDP com detecção de versão, scripts padrão e todos os
# scripts NSE cujo nome começa com "rdp".
nmap -sV -sC "$TARGET" -p"$RDP_PORT" --script 'rdp*'

# Equivalente usando explicitamente --script rdp* como exibido na aula:
nmap -sV -sC "$TARGET" -p"$RDP_PORT" --script rdp\*

# Interpretação esperada:
#
#   3389/tcp open  ms-wbt-server Microsoft Terminal Services
#
#   rdp-enum-encryption:
#     CredSSP (NLA): SUCCESS
#     CredSSP with Early User Auth: SUCCESS
#     RDSTLS: SUCCESS
#
#   rdp-ntlm-info:
#     Target_Name
#     NetBIOS_Domain_Name
#     NetBIOS_Computer_Name
#     DNS_Domain_Name
#     DNS_Computer_Name
#     Product_Version
#     System_Time
#
# Informações importantes:
#   - NLA habilitado indica que o servidor exige autenticação antes de criar a
#     sessão gráfica completa.
#   - CredSSP é o mecanismo normalmente usado pelo NLA.
#   - RDSTLS indica suporte à camada TLS específica do RDP.
#   - Product_Version ajuda a estimar a versão/build do Windows.
#   - O NTLM challenge pode revelar hostname e domínio sem autenticação completa.


# ==============================================================================
# 5. ENUMERAÇÃO RDP COM SCRIPTS NSE ESPECÍFICOS
# ==============================================================================

# Enumera métodos e camadas de criptografia aceitos pelo RDP.
nmap -Pn -n -p"$RDP_PORT" --script rdp-enum-encryption "$TARGET"

# Coleta informações NTLM divulgadas durante o handshake.
nmap -Pn -n -p"$RDP_PORT" --script rdp-ntlm-info "$TARGET"

# Executa os dois scripts em uma única chamada.
nmap -Pn -n -p"$RDP_PORT" \
  --script 'rdp-enum-encryption,rdp-ntlm-info' \
  "$TARGET"


# ==============================================================================
# 6. RASTREAMENTO DE PACOTES DO RDP COM NMAP
# ==============================================================================

# Comando exibido na aula para acompanhar os pacotes enviados e recebidos.
nmap -sV -sC "$TARGET" -p"$RDP_PORT" \
  --packet-trace \
  --disable-arp-ping \
  -n

# Parâmetros:
#   --packet-trace      : mostra pacotes e eventos NSOCK gerados pelo Nmap
#   --disable-arp-ping  : não usa ARP discovery
#   -n                  : não resolve nomes
#
# Durante o rastreamento, a aula mostra o seguinte cookie:
#
#   Cookie: mstshash=nmap
#
# Esse valor denuncia que a conexão foi iniciada pelo Nmap.
# Ferramentas de EDR, IDS ou threat hunting podem procurar esse padrão.
#
# Também aparece a assinatura:
#
#   NTLMSSP
#
# O bloco NTLM pode conter:
#   - hostname
#   - NetBIOS name
#   - domínio
#   - versão do Windows
#   - timestamp
#
# Em redes endurecidas, scans ruidosos podem gerar alertas ou bloqueios.


# ==============================================================================
# 7. INSTALAÇÃO DO RDP-SEC-CHECK
# ==============================================================================

# A ferramenta rdp-sec-check é escrita em Perl e depende do módulo Encoding::BER.
#
# A aula abre o shell interativo do CPAN:
sudo cpan

# Dentro do shell do CPAN, o comando usado é:
#
#   install Encoding::BER
#
# Para instalar diretamente sem permanecer no shell interativo:
sudo cpan Encoding::BER

# Em algumas distribuições Debian/Kali, também pode existir um pacote equivalente:
# sudo apt update
# sudo apt install -y libencoding-ber-perl

# Clona a ferramenta original da Cisco CX Security.
git clone https://github.com/CiscoCXSecurity/rdp-sec-check.git "$RDP_SEC_CHECK_DIR"

# Entra no diretório clonado.
cd "$RDP_SEC_CHECK_DIR"

# Torna o script executável, caso necessário.
chmod +x rdp-sec-check.pl


# ==============================================================================
# 8. AVALIAÇÃO DA SEGURANÇA DO RDP COM RDP-SEC-CHECK
# ==============================================================================

# Executa o teste não autenticado contra a porta padrão 3389.
./rdp-sec-check.pl "$TARGET"

# Para informar uma porta diferente:
# ./rdp-sec-check.pl "$TARGET:$RDP_PORT"
#
# A ferramenta verifica suporte a:
#
#   PROTOCOL_RDP
#     Camada de segurança RDP legada.
#
#   PROTOCOL_SSL
#     Negociação TLS/SSL.
#
#   PROTOCOL_HYBRID
#     CredSSP com NLA.
#
# E métodos de criptografia legados:
#
#   ENCRYPTION_METHOD_NONE
#   ENCRYPTION_METHOD_40BIT
#   ENCRYPTION_METHOD_56BIT
#   ENCRYPTION_METHOD_128BIT
#   ENCRYPTION_METHOD_FIPS
#
# Resultado da aula:
#
#   PROTOCOL_SSL    : FALSE
#   PROTOCOL_HYBRID : TRUE
#   PROTOCOL_RDP    : FALSE
#
# Interpretação:
#
#   O servidor rejeita RDP Security legado e exige o modo híbrido com CredSSP/NLA.
#   A mensagem HYBRID_REQUIRED_BY_SERVER confirma essa exigência.


# ==============================================================================
# 9. CONEXÃO RDP COM XFREERDP
# ==============================================================================

# Comando usado na aula.
xfreerdp /u:"$RDP_USERNAME" /p:"P455w0rd!" /v:"$TARGET"

# Usando as variáveis gerais deste arquivo:
xfreerdp /u:"$USERNAME" /p:"$PASSWORD" /v:"$TARGET:$RDP_PORT"

# O xfreerdp pode exibir:
#
#   Certificate verification failure
#   self signed certificate
#   CERTIFICATE NAME MISMATCH
#
# Isso ocorre porque:
#
#   - o certificado pode ser autoassinado;
#   - a conexão foi feita por IP;
#   - o certificado foi emitido para o hostname, por exemplo ILF-SQL-01.
#
# Portanto:
#
#   endereço usado: 10.129.201.248
#   CN certificado: ILF-SQL-01
#
# Em laboratório, o usuário pode aceitar o certificado manualmente.
# Em ambiente real, valide o certificado antes de confiar nele.


# ==============================================================================
# 10. OPÇÕES ÚTEIS DO XFREERDP
# ==============================================================================

# Ignora o aviso de certificado.
# Use somente em laboratório controlado.
xfreerdp /u:"$USERNAME" /p:"$PASSWORD" /v:"$TARGET" /cert:ignore

# Define resolução da janela.
xfreerdp /u:"$USERNAME" /p:"$PASSWORD" /v:"$TARGET" \
  /size:1600x900 \
  /cert:ignore

# Usa modo de tela cheia.
xfreerdp /u:"$USERNAME" /p:"$PASSWORD" /v:"$TARGET" \
  /f \
  /cert:ignore

# Habilita compartilhamento da área de transferência.
xfreerdp /u:"$USERNAME" /p:"$PASSWORD" /v:"$TARGET" \
  +clipboard \
  /cert:ignore

# Compartilha um diretório local com a sessão remota.
# O diretório aparecerá como uma unidade redirecionada dentro do Windows.
xfreerdp /u:"$USERNAME" /p:"$PASSWORD" /v:"$TARGET" \
  /drive:share,"$PWD" \
  /cert:ignore

# Define explicitamente um domínio.
# DOMAIN="INLANEFREIGHT"
# xfreerdp /d:"$DOMAIN" /u:"$USERNAME" /p:"$PASSWORD" /v:"$TARGET"

# Formato alternativo para conta local:
# xfreerdp /u:'.\usuario' /p:'senha' /v:"$TARGET"


# ==============================================================================
# 11. COMANDOS DE VALIDAÇÃO APÓS ENTRAR POR RDP
# ==============================================================================

# Estes comandos devem ser executados dentro de CMD ou PowerShell no servidor
# remoto depois que a autenticação RDP for concluída.

# Mostra o hostname.
# hostname

# Mostra o usuário autenticado.
# whoami

# Mostra informações de rede.
# ipconfig /all

# Mostra informações detalhadas do Windows.
# systeminfo

# Mostra os grupos do usuário atual.
# whoami /groups

# Mostra privilégios do token atual.
# whoami /priv

# Mostra sessões RDP abertas.
# query user

# Mostra conexões de rede.
# netstat -ano


# ==============================================================================
# 12. ENUMERAÇÃO DO WINRM
# ==============================================================================

# Scan das portas padrão do WinRM exibido na aula.
nmap -sV -sC "$TARGET" \
  -p"$WINRM_HTTP_PORT,$WINRM_HTTPS_PORT" \
  --disable-arp-ping \
  -n

# Resultado típico:
#
#   5985/tcp open  http  Microsoft HTTPAPI httpd 2.0
#   Microsoft-HTTPAPI/2.0
#
# A porta 5985 normalmente representa WinRM sobre HTTP.
# A porta 5986 normalmente representa WinRM sobre HTTPS.


# ==============================================================================
# 13. SCRIPTS NMAP ÚTEIS PARA WINRM / HTTP
# ==============================================================================

# Coleta título HTTP e cabeçalhos do serviço.
nmap -Pn -n -sV \
  -p"$WINRM_HTTP_PORT,$WINRM_HTTPS_PORT" \
  --script 'http-title,http-headers' \
  "$TARGET"

# Testa o endpoint padrão do WS-Management.
nmap -Pn -n \
  -p"$WINRM_HTTP_PORT,$WINRM_HTTPS_PORT" \
  --script http-headers \
  --script-args 'http-headers.path=/wsman' \
  "$TARGET"

# É normal que uma requisição HTTP comum ao serviço retorne:
#
#   404 Not Found
#   405 Method Not Allowed
#
# O WinRM espera mensagens SOAP específicas no endpoint /wsman.


# ==============================================================================
# 14. TESTE DO WINRM PELO POWERSHELL
# ==============================================================================

# Estes comandos devem ser executados em PowerShell, preferencialmente em uma
# máquina Windows autorizada.

# Testa o serviço WS-Management pela configuração padrão.
# Test-WSMan -ComputerName 10.129.201.248

# Forma usando a variável PowerShell.
# $Target = "10.129.201.248"
# Test-WSMan -ComputerName $Target

# Testa usando SSL/HTTPS, normalmente na porta 5986.
# Test-WSMan -ComputerName $Target -UseSSL

# Exibe informações mais detalhadas.
# Test-WSMan -ComputerName $Target -Authentication Default

# Resultado bem-sucedido normalmente contém:
#
#   wsmid
#   ProtocolVersion
#   ProductVendor
#   ProductVersion
#
# Isso confirma que o listener WinRM está respondendo.


# ==============================================================================
# 15. ENUMERAÇÃO LOCAL DE LISTENERS WINRM NO WINDOWS
# ==============================================================================

# Comandos administrativos para serem executados em um Windows sob seu controle.

# Verifica a configuração do WinRM.
# winrm get winrm/config

# Lista listeners configurados.
# winrm enumerate winrm/config/listener

# Mostra o status do serviço.
# Get-Service WinRM

# Testa a configuração local e orienta a habilitação.
# winrm quickconfig

# Forma PowerShell equivalente.
# Enable-PSRemoting -Force

# Mostra os TrustedHosts configurados.
# Get-Item WSMan:\localhost\Client\TrustedHosts

# Define um alvo específico como TrustedHost.
# Evite "*" em ambientes reais.
# Set-Item WSMan:\localhost\Client\TrustedHosts -Value "10.129.201.248"


# ==============================================================================
# 16. INSTALAÇÃO DO EVIL-WINRM
# ==============================================================================

# Atualiza os índices de pacotes.
sudo apt update

# Instala Ruby e ferramentas básicas, caso ainda não estejam presentes.
sudo apt install -y ruby ruby-dev build-essential

# Instala o Evil-WinRM pela RubyGems.
sudo gem install evil-winrm

# Confirma a instalação.
evil-winrm --help


# ==============================================================================
# 17. CONEXÃO WINRM COM EVIL-WINRM
# ==============================================================================

# Comando usado na aula.
evil-winrm -i "$TARGET" -u "$USERNAME" -p "$PASSWORD"

# O prompt esperado após autenticação é semelhante a:
#
#   *Evil-WinRM* PS C:\Users\Cry0l1t3\Documents>
#
# Isso indica que foi aberta uma sessão PowerShell remota.


# ==============================================================================
# 18. OPÇÕES ÚTEIS DO EVIL-WINRM
# ==============================================================================

# Conecta usando HTTPS/SSL.
evil-winrm -i "$TARGET" -u "$USERNAME" -p "$PASSWORD" -S

# Informa explicitamente a porta HTTPS do WinRM.
evil-winrm -i "$TARGET" -u "$USERNAME" -p "$PASSWORD" \
  -S \
  -P "$WINRM_HTTPS_PORT"

# Usa um hash NTLM em vez de senha, quando autorizado pelo laboratório.
# NT_HASH="AAD3B435B51404EEAAD3B435B51404EE:NTLM_HASH"
# evil-winrm -i "$TARGET" -u "$USERNAME" -H "NTLM_HASH"

# Carrega scripts PowerShell locais.
# evil-winrm -i "$TARGET" -u "$USERNAME" -p "$PASSWORD" -s ./scripts

# Define um diretório local para executáveis.
# evil-winrm -i "$TARGET" -u "$USERNAME" -p "$PASSWORD" -e ./executables


# ==============================================================================
# 19. COMANDOS DE VALIDAÇÃO DENTRO DO EVIL-WINRM
# ==============================================================================

# Após obter o prompt remoto, os seguintes comandos ajudam a confirmar o acesso.

# Nome da máquina.
# hostname

# Usuário atual.
# whoami

# Informações do sistema.
# systeminfo

# Informações de rede.
# ipconfig /all

# Diretório atual.
# Get-Location

# Lista de arquivos.
# Get-ChildItem

# Informações do computador via CIM.
# Get-CimInstance Win32_OperatingSystem

# Informações do computador.
# Get-CimInstance Win32_ComputerSystem

# Serviços.
# Get-Service

# Processos.
# Get-Process

# Adaptadores e endereços de rede.
# Get-NetIPAddress

# Conexões TCP.
# Get-NetTCPConnection

# Grupos e privilégios.
# whoami /groups
# whoami /priv


# ==============================================================================
# 20. WINRS - WINDOWS REMOTE SHELL
# ==============================================================================

# O WinRS é o cliente nativo do Windows para executar comandos via WinRM.
# Execute estes exemplos em uma máquina Windows autorizada.

# Executa hostname remotamente.
# winrs -r:http://10.129.201.248:5985 -u:Cry0l1t3 -p:P455w0rD! hostname

# Abre um CMD remoto interativo.
# winrs -r:http://10.129.201.248:5985 -u:Cry0l1t3 -p:P455w0rD! cmd

# Exemplo usando HTTPS.
# winrs -r:https://10.129.201.248:5986 -u:Cry0l1t3 -p:P455w0rD! hostname


# ==============================================================================
# 21. POWERSHELL REMOTING
# ==============================================================================

# Exemplos para um Windows autorizado com WinRM habilitado.

# Solicita a credencial de forma interativa.
# $Credential = Get-Credential

# Cria uma sessão persistente.
# $Session = New-PSSession -ComputerName 10.129.201.248 -Credential $Credential

# Entra na sessão.
# Enter-PSSession -Session $Session

# Sai da sessão interativa.
# Exit-PSSession

# Remove a sessão.
# Remove-PSSession -Session $Session

# Executa um comando sem abrir sessão interativa.
# Invoke-Command -ComputerName 10.129.201.248 `
#   -Credential $Credential `
#   -ScriptBlock { hostname }

# Usando SSL:
# Enter-PSSession -ComputerName 10.129.201.248 `
#   -UseSSL `
#   -Credential $Credential


# ==============================================================================
# 22. ENUMERAÇÃO DO WMI / RPC
# ==============================================================================

# A comunicação WMI/DCOM normalmente começa na porta TCP 135.
nmap -Pn -n -sV -sC -p"$RPC_PORT" "$TARGET"

# Verifica portas relacionadas a RPC e SMB que frequentemente participam do
# funcionamento de WMI remoto.
nmap -Pn -n -sV -sC \
  -p135,139,445 \
  "$TARGET"

# Scan dos scripts NSE relacionados a MSRPC.
nmap -Pn -n \
  -p135 \
  --script 'msrpc-enum' \
  "$TARGET"

# O fluxo WMI/DCOM normalmente é:
#
#   cliente -> TCP 135
#   RPC Endpoint Mapper informa uma porta dinâmica
#   cliente -> porta RPC dinâmica
#
# Portanto, a presença apenas da porta 135 não garante que toda a comunicação WMI
# funcionará; firewall e portas dinâmicas também precisam permitir o tráfego.


# ==============================================================================
# 23. LOCALIZAÇÃO DO WMIEXEC.PY
# ==============================================================================

# Caminho usado na versão do Impacket exibida pela aula.
WMIEXEC_OLD="/usr/share/doc/python3-impacket/examples/wmiexec.py"

# Caminho comum em instalações modernas do Kali.
WMIEXEC_KALI="/usr/share/doc/python3-impacket/examples/wmiexec.py"

# Em instalações via pip/pipx, o comando pode estar diretamente no PATH:
# impacket-wmiexec


# ==============================================================================
# 24. INSTALAÇÃO DO IMPACKET
# ==============================================================================

# Instalação pelo gerenciador de pacotes do Kali/Debian.
sudo apt update
sudo apt install -y python3-impacket

# Alternativa isolada via pipx.
# sudo apt install -y pipx
# pipx install impacket

# Verifica se o comando moderno está disponível.
command -v impacket-wmiexec || true


# ==============================================================================
# 25. EXECUÇÃO REMOTA COM WMIEXEC
# ==============================================================================

# Comando exatamente no formato exibido na aula:
"$WMIEXEC_OLD" "$USERNAME":"$PASSWORD"@"$TARGET" "hostname"

# Forma moderna do comando, quando o Impacket está instalado no PATH:
impacket-wmiexec "$USERNAME":"$PASSWORD"@"$TARGET" "hostname"

# Resultado esperado no laboratório:
#
#   ILF-SQL-01
#
# Esse resultado confirma:
#   - credenciais válidas;
#   - conectividade SMB/RPC;
#   - permissão para execução remota via WMI;
#   - identidade do host.


# ==============================================================================
# 26. OUTROS COMANDOS REMOTOS COM WMIEXEC
# ==============================================================================

# Identifica o usuário do contexto remoto.
impacket-wmiexec "$USERNAME":"$PASSWORD"@"$TARGET" "whoami"

# Obtém informações de rede.
impacket-wmiexec "$USERNAME":"$PASSWORD"@"$TARGET" "ipconfig /all"

# Obtém informações do sistema.
impacket-wmiexec "$USERNAME":"$PASSWORD"@"$TARGET" "systeminfo"

# Lista privilégios.
impacket-wmiexec "$USERNAME":"$PASSWORD"@"$TARGET" "whoami /priv"

# Lista grupos.
impacket-wmiexec "$USERNAME":"$PASSWORD"@"$TARGET" "whoami /groups"

# Lista processos.
impacket-wmiexec "$USERNAME":"$PASSWORD"@"$TARGET" "tasklist"

# Lista serviços.
impacket-wmiexec "$USERNAME":"$PASSWORD"@"$TARGET" "sc query"

# Lista conexões de rede.
impacket-wmiexec "$USERNAME":"$PASSWORD"@"$TARGET" "netstat -ano"

# Abre uma shell semi-interativa quando nenhum comando é informado.
impacket-wmiexec "$USERNAME":"$PASSWORD"@"$TARGET"


# ==============================================================================
# 27. CONTA LOCAL, DOMÍNIO E FORMATOS DE AUTENTICAÇÃO
# ==============================================================================

# Conta local usando o hostname como domínio.
# HOSTNAME="ILF-SQL-01"
# impacket-wmiexec "$HOSTNAME/$USERNAME:$PASSWORD@$TARGET" "hostname"

# Conta de domínio.
# DOMAIN="INLANEFREIGHT"
# impacket-wmiexec "$DOMAIN/$USERNAME:$PASSWORD@$TARGET" "hostname"

# Hash NTLM, quando autorizado pelo laboratório.
# LM_HASH="AAD3B435B51404EEAAD3B435B51404EE"
# NT_HASH="0123456789ABCDEF0123456789ABCDEF"
# impacket-wmiexec -hashes "$LM_HASH:$NT_HASH" \
#   "$DOMAIN/$USERNAME@$TARGET" \
#   "hostname"


# ==============================================================================
# 28. INTERPRETAÇÃO COMPARATIVA DOS PROTOCOLOS
# ==============================================================================
#
# RDP
#   Porta:
#     3389/TCP e, em certos cenários, 3389/UDP
#
#   Característica:
#     Sessão gráfica completa.
#
#   Ferramentas:
#     nmap
#     rdp-sec-check
#     xfreerdp
#
#   Informações obtidas:
#     hostname
#     domínio
#     build do Windows
#     horário
#     NLA
#     CredSSP
#     TLS
#     certificado
#
#
# WinRM
#   Portas:
#     5985/TCP HTTP
#     5986/TCP HTTPS
#
#   Característica:
#     Administração e PowerShell remota.
#
#   Ferramentas:
#     nmap
#     Test-WSMan
#     winrs
#     Enter-PSSession
#     evil-winrm
#
#   Informações obtidas:
#     presença do Microsoft HTTPAPI
#     disponibilidade do endpoint WS-Man
#     possibilidade de shell PowerShell remoto
#
#
# WMI
#   Portas:
#     135/TCP inicialmente
#     portas RPC dinâmicas posteriormente
#     frequentemente depende também de SMB/TCP 445
#
#   Característica:
#     Interface de administração baseada em CIM/WBEM e RPC/DCOM.
#
#   Ferramentas:
#     nmap
#     wmiexec.py
#     impacket-wmiexec
#
#   Informações/ações:
#     execução remota
#     consulta de processos
#     serviços
#     sistema operacional
#     rede
#     hardware
#
# ==============================================================================


# ==============================================================================
# 29. FLUXO COMPLETO UTILIZADO PARA CHEGAR AOS OBJETIVOS
# ==============================================================================
#
# ETAPA 1 - DEFINIR O ALVO
#
#   TARGET=10.129.201.248
#
#
# ETAPA 2 - DESCOBRIR OS SERVIÇOS
#
#   nmap -Pn -n -p3389,5985,5986,135,445 10.129.201.248
#
# Objetivo:
#   descobrir quais mecanismos de administração remota estão expostos.
#
#
# ETAPA 3 - ENUMERAR O RDP
#
#   nmap -sV -sC 10.129.201.248 -p3389 --script rdp*
#
# Objetivo:
#   descobrir hostname, domínio, versão do Windows, horário, NLA, CredSSP e TLS.
#
#
# ETAPA 4 - INSPECIONAR O HANDSHAKE
#
#   nmap -sV -sC 10.129.201.248 -p3389 \
#     --packet-trace --disable-arp-ping -n
#
# Objetivo:
#   observar a negociação RDP, o cookie mstshash=nmap e os dados NTLMSSP.
#
#
# ETAPA 5 - VALIDAR A SEGURANÇA DO RDP
#
#   ./rdp-sec-check.pl 10.129.201.248
#
# Objetivo:
#   identificar quais protocolos e métodos de criptografia são aceitos.
#
#
# ETAPA 6 - TESTAR O RDP COM CREDENCIAIS
#
#   xfreerdp /u:cry0l1t3 /p:"P455w0rd!" /v:10.129.201.248
#
# Objetivo:
#   obter uma sessão gráfica autorizada.
#
#
# ETAPA 7 - ENUMERAR O WINRM
#
#   nmap -sV -sC 10.129.201.248 -p5985,5986 \
#     --disable-arp-ping -n
#
# Objetivo:
#   identificar Microsoft HTTPAPI e listeners WinRM.
#
#
# ETAPA 8 - TESTAR O WS-MAN
#
#   PowerShell:
#     Test-WSMan -ComputerName 10.129.201.248
#
# Objetivo:
#   confirmar que o endpoint WS-Management está respondendo.
#
#
# ETAPA 9 - TESTAR WINRM COM CREDENCIAIS
#
#   evil-winrm -i 10.129.201.248 -u Cry0l1t3 -p P455w0rD!
#
# Objetivo:
#   abrir uma sessão PowerShell remota.
#
#
# ETAPA 10 - ENUMERAR RPC/WMI
#
#   nmap -Pn -n -sV -sC -p135,445 10.129.201.248
#
# Objetivo:
#   verificar o Endpoint Mapper, SMB e pré-requisitos do WMI remoto.
#
#
# ETAPA 11 - EXECUTAR COMANDO VIA WMI
#
#   /usr/share/doc/python3-impacket/examples/wmiexec.py \
#     Cry0l1t3:"P455w0rD!"@10.129.201.248 \
#     "hostname"
#
# Objetivo:
#   confirmar credenciais, conectividade e execução remota.
#
#
# ETAPA 12 - VALIDAR O HOST
#
#   hostname
#   whoami
#   ipconfig /all
#   systeminfo
#
# Objetivo:
#   confirmar em qual máquina a sessão foi aberta, qual usuário está ativo e
#   qual é a configuração do sistema.
#
# ==============================================================================


# ==============================================================================
# 30. BLOCO RESUMIDO DE COMANDOS PRINCIPAIS
# ==============================================================================
#
# RDP:
#
# nmap -sV -sC "$TARGET" -p3389 --script rdp\*
#
# nmap -sV -sC "$TARGET" -p3389 \
#   --packet-trace \
#   --disable-arp-ping \
#   -n
#
# sudo cpan Encoding::BER
#
# git clone https://github.com/CiscoCXSecurity/rdp-sec-check.git
#
# cd rdp-sec-check
#
# ./rdp-sec-check.pl "$TARGET"
#
# xfreerdp /u:"$USERNAME" /p:"$PASSWORD" /v:"$TARGET"
#
#
# WINRM:
#
# nmap -sV -sC "$TARGET" -p5985,5986 \
#   --disable-arp-ping \
#   -n
#
# Test-WSMan -ComputerName "$TARGET"
#
# evil-winrm -i "$TARGET" -u "$USERNAME" -p "$PASSWORD"
#
#
# WMI:
#
# nmap -Pn -n -sV -sC -p135,445 "$TARGET"
#
# /usr/share/doc/python3-impacket/examples/wmiexec.py \
#   "$USERNAME":"$PASSWORD"@"$TARGET" \
#   "hostname"
#
# impacket-wmiexec "$USERNAME":"$PASSWORD"@"$TARGET" "hostname"
#
# ==============================================================================


# ==============================================================================
# 31. CHECKLIST FINAL
# ==============================================================================
#
# [ ] O host está acessível?
#
# [ ] A porta 3389 está aberta?
#
# [ ] O RDP exige NLA?
#
# [ ] CredSSP está habilitado?
#
# [ ] RDP Security legado está desabilitado?
#
# [ ] O hostname e domínio foram identificados?
#
# [ ] A versão/build do Windows foi identificada?
#
# [ ] O certificado é autoassinado?
#
# [ ] Existe incompatibilidade entre IP e CN do certificado?
#
# [ ] A porta 5985 ou 5986 está aberta?
#
# [ ] Test-WSMan retorna resposta?
#
# [ ] Evil-WinRM consegue autenticar?
#
# [ ] A porta 135 está aberta?
#
# [ ] A porta 445 está aberta?
#
# [ ] WMIexec consegue executar hostname?
#
# [ ] O acesso está autorizado pelo escopo do laboratório?
#
# ==============================================================================


echo
echo "Material carregado para o alvo: $TARGET"
echo "Este arquivo é um guia de estudo. Execute somente os comandos adequados ao laboratório."
