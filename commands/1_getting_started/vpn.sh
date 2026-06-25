#!/bin/bash

################################################################################
# HTB - VPN TROUBLESHOOTING
# MÓDULO: Common Pitfalls
#
# OBJETIVO
#
# Verificar rapidamente se o ambiente local está preparado para acessar
# os laboratórios do Hack The Box antes de iniciar qualquer pentest.
#
# Fluxo:
#
# Conectar VPN
#        ↓
# Verificar interface tun0
#        ↓
# Confirmar rota
#        ↓
# Testar Gateway
#        ↓
# Testar comunicação com alvo
#
################################################################################


################################################################################
# Conectar na VPN do HTB
################################################################################

sudo openvpn htb.ovpn


################################################################################
# Verificar se a interface VPN foi criada
################################################################################

ip -4 a show tun0


################################################################################
# Método moderno para visualizar as rotas
################################################################################

ip route


################################################################################
# Método utilizado na aula
################################################################################

netstat -rn


################################################################################
# Confirmar comunicação com o Gateway da VPN
################################################################################

ping -c 4 10.10.14.1


################################################################################
# Confirmar comunicação com a máquina alvo
################################################################################

ping -c 4 IP


################################################################################
# Descobrir seu endereço VPN (LHOST)
#
# Exemplo:
# inet 10.10.14.25/23
#
# Este IP será utilizado em:
#
# nc
# Metasploit
# Reverse Shell
#
################################################################################

ip -4 a show tun0


################################################################################
# Gerar nova chave SSH
#
# Utilizado caso existam problemas de autenticação SSH
################################################################################

ssh-keygen


################################################################################
# Estrutura padrão criada
#
# ~/.ssh/id_rsa
# ~/.ssh/id_rsa.pub
#
################################################################################



################################################################################
# Fluxo completo de troubleshooting
################################################################################

#
# openvpn htb.ovpn
#        │
#        ▼
# Initialization Sequence Completed
#        │
#        ▼
# ip -4 a show tun0
#        │
#        ▼
# Recebeu IP VPN?
#        │
#        ├── NÃO → Reconectar VPN
#        │
#        └── SIM
#              │
#              ▼
# ip route
#              │
#              ▼
# Existe rota para 10.129.0.0/16?
#              │
#              ├── NÃO → VPN com problema
#              │
#              └── SIM
#                    │
#                    ▼
# ping 10.10.14.1
#                    │
#                    ▼
# Gateway responde?
#                    │
#                    ├── NÃO → Problema de VPN
#                    │
#                    └── SIM
#                          │
#                          ▼
# ping IP
#                          │
#                          ▼
# Máquina acessível
#                          │
#                          ▼
# Iniciar enumeração
#
################################################################################



################################################################################
# Problemas comuns (sem comandos)
################################################################################

#
# ✓ Não conectar a VPN em dois dispositivos ao mesmo tempo.
#
# ✓ Escolher o servidor VPN mais próximo da sua localização.
#
# ✓ Desativar o proxy do Burp/FoxyProxy ao terminar os testes.
#
# ✓ Confirmar que o LHOST utilizado nas Reverse Shells é o IP da interface tun0.
#
################################################################################