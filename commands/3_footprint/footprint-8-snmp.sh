#!/usr/bin/env bash
#
# ==============================================================================
# HTB ACADEMY - FOOTPRINTING SNMP
# Guia completo da aula, comandos, raciocínio e fluxo de enumeração
# ==============================================================================
#
# Uso autorizado:
# Este material foi preparado para laboratório controlado do Hack The Box Academy.
# Utilize somente em ambientes próprios ou com autorização explícita.
#
# Objetivos abordados nesta aula:
#
# 1. Identificar o serviço SNMP no alvo.
# 2. Encontrar uma community string válida.
# 3. Enumerar informações gerais do sistema.
# 4. Descobrir hostname, contato administrativo e localização/descrição.
# 5. Enumerar processos, serviços, interfaces e demais objetos expostos.
# 6. Investigar scripts personalizados configurados no agente SNMP.
# 7. Obter a saída do script customizado solicitado na Question 3.
#
# Informações identificadas durante o laboratório:
#
# Community string:
#   public
#
# Sistema/hostname:
#   Linux NIX02
#   NIX02
#
# Contato administrativo:
#   devadmin <devadmin@inlanefreight.htb>
#
# Localização/descrição:
#   InFreight SNMP v0.91
#
# Versão do kernel:
#   Linux 5.4.0-90-generic x86_64
#
# ==============================================================================
# 1. VARIÁVEIS DO LABORATÓRIO
# ==============================================================================

# Defina o IP fornecido pelo HTB.
export TARGET="IP_DO_ALVO"

# Confirme o valor.
echo "$TARGET"

# Community string válida encontrada no laboratório.
export COMMUNITY="public"

# ==============================================================================
# 2. CONCEITOS ESSENCIAIS DE SNMP
# ==============================================================================
#
# SNMP normalmente utiliza:
#
# UDP/161:
#   Consultas ao agente SNMP.
#
# UDP/162:
#   Traps e notificações enviadas pelo agente.
#
# Componentes:
#
# Manager:
#   Sistema que realiza consultas SNMP.
#
# Agent:
#   Serviço executado no dispositivo monitorado.
#
# MIB:
#   Estrutura lógica que descreve objetos gerenciáveis.
#
# OID:
#   Identificador numérico de um objeto dentro da árvore MIB.
#
# Community string:
#   Funciona de forma semelhante a uma senha em SNMPv1/v2c.
#
# Versões:
#
# SNMPv1:
#   Antigo e sem criptografia.
#
# SNMPv2c:
#   Também usa community strings em texto claro.
#
# SNMPv3:
#   Pode oferecer autenticação e criptografia.
#
# ==============================================================================
# 3. DESCOBERTA INICIAL DO SERVIÇO
# ==============================================================================

# Scan UDP específico na porta SNMP.
sudo nmap -sU -p161 "$TARGET"

# Detectar versão e executar scripts padrão.
sudo nmap -sU -sV -sC -p161 "$TARGET"

# Scan mais detalhado com scripts SNMP do NSE.
sudo nmap -sU -sV -p161 --script "snmp-*" "$TARGET"

# Alguns scripts úteis podem ser chamados individualmente.
sudo nmap -sU -p161 --script snmp-info "$TARGET"
sudo nmap -sU -p161 --script snmp-sysdescr "$TARGET"
sudo nmap -sU -p161 --script snmp-processes "$TARGET"
sudo nmap -sU -p161 --script snmp-interfaces "$TARGET"
sudo nmap -sU -p161 --script snmp-netstat "$TARGET"

# Observação:
# Scan UDP pode ser lento e retornar "open|filtered".
# Uma resposta válida do snmpwalk confirma melhor o serviço.

# ==============================================================================
# 4. DESCOBERTA DE COMMUNITY STRINGS
# ==============================================================================

# Teste manual da community padrão "public".
snmpwalk -v2c -c public "$TARGET" .1.3.6.1.2.1.1

# Versão SNMPv1, caso v2c não responda.
snmpwalk -v1 -c public "$TARGET" .1.3.6.1.2.1.1

# Teste de outras communities comuns.
snmpwalk -v2c -c private "$TARGET" .1.3.6.1.2.1.1
snmpwalk -v2c -c manager "$TARGET" .1.3.6.1.2.1.1
snmpwalk -v2c -c community "$TARGET" .1.3.6.1.2.1.1

# ------------------------------------------------------------------------------
# onesixtyone
# ------------------------------------------------------------------------------

# O onesixtyone testa rapidamente communities SNMP.
# -c: arquivo com communities
# -i: arquivo com alvos

# Exemplo com uma lista local.
onesixtyone -c /usr/share/seclists/Discovery/SNMP/snmp.txt "$TARGET"

# Criar lista manual.
cat > communities.txt << 'EOF'
public
private
manager
community
admin
monitor
monitoring
secret
EOF

# Testar a lista.
onesixtyone -c communities.txt "$TARGET"

# Criar arquivo de alvo.
echo "$TARGET" > targets.txt

# Testar communities contra os alvos do arquivo.
onesixtyone -c communities.txt -i targets.txt

# Community confirmada no laboratório:
#   public

# ==============================================================================
# 5. ENUMERAÇÃO DO GRUPO SYSTEM
# ==============================================================================

# O grupo system contém as informações mais importantes para iniciar o trabalho.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.1

# Usar OIDs numéricas na saída.
# -On evita depender das MIBs instaladas localmente.
snmpwalk -v2c -c "$COMMUNITY" -On "$TARGET" .1.3.6.1.2.1.1

# Objetos específicos do grupo system.

# sysDescr:
# Descrição do sistema operacional e kernel.
snmpget -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.1.1.0

# sysObjectID:
# Identificador do tipo de agente/dispositivo.
snmpget -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.1.2.0

# sysUpTime:
# Tempo de atividade do agente/sistema.
snmpget -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.1.3.0

# sysContact:
# Contato administrativo.
snmpget -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.1.4.0

# sysName:
# Hostname.
snmpget -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.1.5.0

# sysLocation:
# Localização ou descrição definida pelo administrador.
snmpget -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.1.6.0

# sysServices:
# Camadas de serviço oferecidas pelo host.
snmpget -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.1.7.0

# Resultados encontrados:
#
# sysDescr:
#   Linux NIX02 5.4.0-90-generic #101-Ubuntu SMP Fri Oct 15 20:00:55 UTC 2021 x86_64
#
# sysContact:
#   devadmin <devadmin@inlanefreight.htb>
#
# sysName:
#   NIX02
#
# sysLocation:
#   InFreight SNMP v0.91
#
# Esses dados resolveram as perguntas iniciais do exercício.

# ==============================================================================
# 6. DUMP COMPLETO DA ÁRVORE SNMP
# ==============================================================================

# Enumerar tudo o que a community permite visualizar.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .

# Usar representação numérica para impedir erros de resolução de MIB.
snmpwalk -v2c -c "$COMMUNITY" -On "$TARGET" .1

# Salvar toda a enumeração em arquivo.
snmpwalk -v2c -c "$COMMUNITY" -On "$TARGET" .1 > snmp_all.txt

# Versão sem -On.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" . > snmp.txt

# Pesquisar informações relevantes no dump.
grep -Ei "flag|HTB|password|passwd|secret|token|key|user|admin" snmp_all.txt

# Pesquisar scripts customizados e extensões.
grep -Ei "extend|nsExtend|script|command|output|8072|2021" snmp_all.txt

# Mostrar números das linhas encontradas.
grep -nEi "flag|HTB|extend|script|command|output|nsExtend|logmatch" snmp_all.txt

# Extrair apenas valores textuais.
grep -E 'STRING:|Hex-STRING:|INTEGER:' snmp_all.txt

# ==============================================================================
# 7. ENUMERAÇÃO DE INTERFACES E REDE
# ==============================================================================

# Tabela de interfaces.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.2.2

# Nomes/descrições das interfaces.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.2.2.1.2

# Endereços IP.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.4.20

# Tabela ARP.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.4.22

# Tabela de rotas IPv4.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.4.21

# Tabela TCP.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.6.13

# Tabela UDP.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.7.5

# O dump mostrou, entre outros dados:
#
# Interface loopback:
#   lo
#
# Interface de rede:
#   VMware VMXNET3 Ethernet Controller
#
# IP do alvo:
#   10.129.x.x
#
# Gateway:
#   10.129.0.1
#
# Observação:
# Os endereços mudam quando a instância do HTB é reiniciada.

# ==============================================================================
# 8. ENUMERAÇÃO DE PROCESSOS E SOFTWARE
# ==============================================================================

# HOST-RESOURCES-MIB - processos em execução.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.25.4.2.1.2

# Caminhos dos executáveis.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.25.4.2.1.4

# Argumentos de execução.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.25.4.2.1.5

# Tabela completa de processos.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.25.4.2

# Softwares instalados.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.2.1.25.6.3.1.2

# Informações observadas em enumerações anteriores incluíram serviços como:
#
#   mysqld
#   named
#   dovecot
#   postfix
#   snmpd
#
# Esses serviços ajudam a inferir a função do servidor e possíveis vetores
# adicionais de enumeração.

# ==============================================================================
# 9. BRAA
# ==============================================================================

# braa realiza consultas SNMP em massa.
#
# Formato:
#   community@host:oid

# Consultar a árvore system.
braa public@"$TARGET":.1.3.6.1.2.1.1.*

# Consultar sysDescr.
braa public@"$TARGET":.1.3.6.1.2.1.1.1.0

# Consultar sysName.
braa public@"$TARGET":.1.3.6.1.2.1.1.5.0

# Consultar sysContact.
braa public@"$TARGET":.1.3.6.1.2.1.1.4.0

# Consultar sysLocation.
braa public@"$TARGET":.1.3.6.1.2.1.1.6.0

# ==============================================================================
# 10. INVESTIGAÇÃO DO SCRIPT CUSTOMIZADO - QUESTION 3
# ==============================================================================
#
# Enunciado:
#
#   "Enumerate the custom script that is running on the system and submit
#    its output as the answer."
#
# A primeira hipótese foi que o script estivesse configurado por meio do
# NET-SNMP extend.
#
# ------------------------------------------------------------------------------
# Tentativa usando nomes simbólicos das MIBs
# ------------------------------------------------------------------------------

# Este comando foi tentado:
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" \
NET-SNMP-EXTEND-MIB::nsExtendOutputFull

# Erro recebido:
#
#   NET-SNMP-EXTEND-MIB::nsExtendOutputFull: Unknown Object Identifier
#
# Causa:
#
# O cliente local não possuía a MIB necessária ou não conseguiu carregá-la.
# O erro não significava necessariamente que o alvo não tinha o objeto.
#
# Correção:
#
# Utilizar OIDs numéricas com -On, sem depender das MIBs locais.

# ------------------------------------------------------------------------------
# Tentativas na árvore privada Net-SNMP
# ------------------------------------------------------------------------------

# Árvore geral da empresa Net-SNMP.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.4.1.8072

# Árvore normalmente usada pelo NET-SNMP-EXTEND-MIB.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.4.1.8072.1.3

# Filtrar possíveis resultados.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.4.1.8072 |
grep -Ei "flag|extend|command|output|string"

# A saída mostrou nomes de módulos e tabelas, como:
#
#   nsExtendNumEntries
#   nsExtendConfigTable
#   nsExtendOut1Table
#   nsExtendOut2Table
#
# Porém não revelou imediatamente uma instância de script ou sua saída.
#
# Parte significativa do resultado pertencia ao nsModuleTable, isto é,
# inventário de módulos internos carregados, e não à saída do script desejado.

# ------------------------------------------------------------------------------
# Tentativas na UCD-SNMP-MIB
# ------------------------------------------------------------------------------

# Tabela antiga de extensões UCD-SNMP.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.4.1.2021.8

# Resultado:
#   No Such Object available on this agent at this OID

# Processos monitorados pela UCD-SNMP.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.4.1.2021.2

# Resultado:
#   No Such Object available on this agent at this OID

# Arquivos monitorados.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.4.1.2021.15

# Resultado:
#   No Such Object available on this agent at this OID

# Logmatch.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.4.1.2021.16

# Resultado obtido:
#
#   .1.3.6.1.4.1.2021.16.1.0 = INTEGER: 250
#
# Isso mostrou que havia pelo menos um objeto exposto nessa árvore,
# mas o resultado não era ainda a saída do script.

# Subárvores tentadas.
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.4.1.2021.16.2
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.4.1.2021.16.2.1
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.4.1.2021.16.2.1.101
snmpwalk -v2c -c "$COMMUNITY" "$TARGET" .1.3.6.1.4.1.2021.16.2.1.102

# ------------------------------------------------------------------------------
# Dump numérico completo
# ------------------------------------------------------------------------------

# A etapa decisiva de investigação foi gerar a árvore numérica completa.
snmpwalk -v2c -c "$COMMUNITY" -On "$TARGET" .1

# Salvar para análise.
snmpwalk -v2c -c "$COMMUNITY" -On "$TARGET" .1 > snmp_numeric.txt

# Filtrar palavras relacionadas ao script.
grep -nEi "nsExtend|extend|script|command|output|2021\.16|8072" snmp_numeric.txt

# O dump revelou referências aos módulos:
#
#   nsExtendNumEntries
#   nsExtendConfigTable
#   nsExtendOut1Table
#   nsExtendOut2Table
#
# Também revelou referências sob:
#
#   .1.3.6.1.2.1.25.1.7
#
# Portanto, o próximo passo de enumeração foi consultar diretamente esse ramo.

# ------------------------------------------------------------------------------
# Ramo HOST-RESOURCES-MIB associado às extensões
# ------------------------------------------------------------------------------

# Enumerar o ramo completo.
snmpwalk -v2c -c "$COMMUNITY" -On "$TARGET" .1.3.6.1.2.1.25.1.7

# Consultar a tabela de saída principal.
snmpwalk -v2c -c "$COMMUNITY" -On "$TARGET" \
.1.3.6.1.2.1.25.1.7.1.3

# Consultar a tabela de saída completa/multilinha.
snmpwalk -v2c -c "$COMMUNITY" -On "$TARGET" \
.1.3.6.1.2.1.25.1.7.1.4

# Filtrar apenas valores úteis.
snmpwalk -v2c -c "$COMMUNITY" -On "$TARGET" \
.1.3.6.1.2.1.25.1.7 |
grep -Ei 'STRING|INTEGER|Hex-STRING'

# Comando considerado mais provável para revelar a resposta:
snmpwalk -v2c -c "$COMMUNITY" -On "$TARGET" \
.1.3.6.1.2.1.25.1.7.1.3

# A resposta da Question 3 deve ser o conteúdo retornado pelo script,
# e não somente o nome do script.
#
# Se a tabela retornar várias linhas, comparar:
#
#   .1.3.6.1.2.1.25.1.7.1.3
#   .1.3.6.1.2.1.25.1.7.1.4
#
# e submeter o valor textual produzido pelo script.

# ==============================================================================
# 11. COMANDOS DE DIAGNÓSTICO PARA ERROS DE MIB
# ==============================================================================

# Sempre que houver:
#
#   Unknown Object Identifier
#   Cannot find module
#   Cannot adopt OID
#
# usar -On e OIDs numéricas.
snmpwalk -v2c -c "$COMMUNITY" -On "$TARGET" .1

# Desabilitar nomes simbólicos explicitamente.
snmpwalk -v2c -c "$COMMUNITY" -On "$TARGET" .1.3.6.1.4.1.8072

# Ver arquivos de configuração do Net-SNMP local.
cat /etc/snmp/snmp.conf 2>/dev/null

# Ver diretórios de MIBs disponíveis.
find /usr/share/snmp/mibs -maxdepth 2 -type f 2>/dev/null | head -100

# Pacotes que podem ser úteis em distribuições Debian/Ubuntu:
#
# sudo apt update
# sudo apt install snmp snmp-mibs-downloader
#
# Em laboratório HTB, normalmente é mais rápido utilizar OIDs numéricas
# do que tentar corrigir todas as MIBs locais.

# ==============================================================================
# 12. FLUXO COMPLETO DE ATAQUE/ENUMERAÇÃO USADO
# ==============================================================================
#
# ETAPA 1 - Identificar SNMP:
#
#   sudo nmap -sU -sV -sC -p161 "$TARGET"
#
# Resultado esperado:
#   UDP/161 acessível ou open|filtered com respostas SNMP.
#
# ------------------------------------------------------------------------------
# ETAPA 2 - Descobrir community:
#
#   onesixtyone -c communities.txt "$TARGET"
#
# ou:
#
#   snmpwalk -v2c -c public "$TARGET" .1.3.6.1.2.1.1
#
# Resultado:
#   public
#
# ------------------------------------------------------------------------------
# ETAPA 3 - Enumerar informações básicas:
#
#   snmpwalk -v2c -c public "$TARGET" .1.3.6.1.2.1.1
#
# Informações obtidas:
#
#   Hostname: NIX02
#   Contato: devadmin <devadmin@inlanefreight.htb>
#   Localização: InFreight SNMP v0.91
#   Kernel: Linux 5.4.0-90-generic
#
# ------------------------------------------------------------------------------
# ETAPA 4 - Expandir enumeração:
#
#   snmpwalk -v2c -c public -On "$TARGET" .1
#
# Objetivo:
#   Ver tudo o que a community pública consegue acessar.
#
# ------------------------------------------------------------------------------
# ETAPA 5 - Investigar processos e rede:
#
#   snmpwalk -v2c -c public "$TARGET" .1.3.6.1.2.1.25.4.2
#   snmpwalk -v2c -c public "$TARGET" .1.3.6.1.2.1.2.2
#   snmpwalk -v2c -c public "$TARGET" .1.3.6.1.2.1.4.20
#   snmpwalk -v2c -c public "$TARGET" .1.3.6.1.2.1.4.21
#
# Objetivo:
#   Identificar serviços, interfaces, IPs, rotas e funções do servidor.
#
# ------------------------------------------------------------------------------
# ETAPA 6 - Procurar script customizado:
#
# Primeira tentativa:
#
#   snmpwalk -v2c -c public "$TARGET" \
#   NET-SNMP-EXTEND-MIB::nsExtendOutputFull
#
# Problema:
#   MIB simbólica indisponível localmente.
#
# Correção:
#
#   snmpwalk -v2c -c public -On "$TARGET" .1
#
# ------------------------------------------------------------------------------
# ETAPA 7 - Investigar árvores privadas:
#
#   .1.3.6.1.4.1.8072
#   .1.3.6.1.4.1.8072.1.3
#   .1.3.6.1.4.1.2021.8
#   .1.3.6.1.4.1.2021.16
#
# O ramo 8072 mostrou metadados de módulos, mas não a saída imediatamente.
#
# ------------------------------------------------------------------------------
# ETAPA 8 - Localizar referências às tabelas extend no dump:
#
#   grep -nEi "nsExtend|extend|script|command|output" snmp_numeric.txt
#
# Foram identificadas referências a:
#
#   nsExtendConfigTable
#   nsExtendOut1Table
#   nsExtendOut2Table
#
# ------------------------------------------------------------------------------
# ETAPA 9 - Consultar diretamente o ramo associado:
#
#   snmpwalk -v2c -c public -On "$TARGET" \
#   .1.3.6.1.2.1.25.1.7
#
# Depois:
#
#   snmpwalk -v2c -c public -On "$TARGET" \
#   .1.3.6.1.2.1.25.1.7.1.3
#
# E:
#
#   snmpwalk -v2c -c public -On "$TARGET" \
#   .1.3.6.1.2.1.25.1.7.1.4
#
# Objetivo final:
#   Obter a saída textual do script customizado e submetê-la na Question 3.
#
# ==============================================================================
# 13. CHECKLIST RÁPIDO PARA FUTUROS LABORATÓRIOS SNMP
# ==============================================================================

# 1. Confirmar alvo.
echo "$TARGET"

# 2. Scan UDP.
sudo nmap -sU -sV -sC -p161 "$TARGET"

# 3. Encontrar community.
onesixtyone -c communities.txt "$TARGET"

# 4. Grupo system.
snmpwalk -v2c -c public -On "$TARGET" .1.3.6.1.2.1.1

# 5. Dump completo.
snmpwalk -v2c -c public -On "$TARGET" .1 > snmp_all.txt

# 6. Procurar credenciais, flags e scripts.
grep -nEi \
"HTB|flag|pass|secret|token|key|extend|script|command|output" \
snmp_all.txt

# 7. Processos.
snmpwalk -v2c -c public -On "$TARGET" .1.3.6.1.2.1.25.4.2

# 8. Softwares instalados.
snmpwalk -v2c -c public -On "$TARGET" .1.3.6.1.2.1.25.6.3

# 9. Interfaces, IPs e rotas.
snmpwalk -v2c -c public -On "$TARGET" .1.3.6.1.2.1.2.2
snmpwalk -v2c -c public -On "$TARGET" .1.3.6.1.2.1.4.20
snmpwalk -v2c -c public -On "$TARGET" .1.3.6.1.2.1.4.21

# 10. Net-SNMP extend.
snmpwalk -v2c -c public -On "$TARGET" .1.3.6.1.4.1.8072.1.3

# 11. Ramo observado neste laboratório.
snmpwalk -v2c -c public -On "$TARGET" .1.3.6.1.2.1.25.1.7

# ==============================================================================
# 14. RESUMO DAS LIÇÕES PRINCIPAIS
# ==============================================================================
#
# 1. Uma community string fraca como "public" pode revelar grande quantidade
#    de informações internas.
#
# 2. O grupo system deve ser sempre o primeiro ramo consultado.
#
# 3. OIDs numéricas são fundamentais quando as MIBs locais estão ausentes.
#
# 4. "Unknown Object Identifier" pode ser problema do cliente local, não do alvo.
#
# 5. Um dump completo seguido de grep é uma estratégia eficaz quando a árvore
#    exata é desconhecida.
#
# 6. Nem toda ocorrência de "nsExtend" representa uma instância de script;
#    algumas pertencem somente ao inventário de módulos internos.
#
# 7. É necessário diferenciar:
#
#    - descrição de uma tabela;
#    - configuração de uma extensão;
#    - nome do script;
#    - comando executado;
#    - saída produzida.
#
# 8. Na Question 3, o HTB pede a saída do script customizado, não apenas seu nome.
#
# 9. A enumeração deve seguir um fluxo:
#
#    descoberta -> community -> system -> dump -> filtros -> subárvores -> saída.
#
# ==============================================================================
# FIM
# ==============================================================================
