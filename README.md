# 🚀 OpenRouter Agent v1.0
por Osvaldo J. Filho

## 📦 O Que Mudou?

### ✅ Versão Anterior (v1)
- IA retornava múltiplos comandos de uma vez
- Whitelist só capturava o primeiro comando
- Usuário não via output intermediário
- Difícil de troubleshoot

### ✨ Versão Nova (v2)
- **IA retorna 1 comando por vez em JSON estruturado**
- **Whitelist funciona perfeitamente**
- **Usuário vê output de cada comando**
- **IA ajusta estratégia baseada em resultados**
- **Controle total + transparência máxima**

---

## 🎯 Formato JSON da IA

A IA agora responde em JSON estruturado:

### Para Comandos:
```json
{
  "command": "ls -lah",
  "explanation": "Listar arquivos do diretório atual",
  "reason": "Necessário para verificar se o arquivo existe antes de prosseguir"
}
```

### Para Finalizar:
```json
{
  "status": "SUMMARY",
  "message": "Tarefa concluída! Foram criados 3 backups dos arquivos importantes..."
}
```

---

## 🖥️ Exemplo de Uso Completo

```bash
$ export OPENROUTER_API_KEY='sua-chave-aqui'
$ python3 openrouter_agent_v2.py

============================================================
🤖 OpenRouter AGENT - Assistente Linux Autônomo
============================================================
Modelo ativo: qwen/qwen3-coder:free (🆕 padrão)
Modo: ⚡ Um comando por vez (JSON estruturado)
Comandos: /help /clear /exit /status /resetmodel
============================================================

💬 Você > encontre todos os arquivos maiores que 100MB e mostre em ordem decrescente

🤖 IA Pensando... ⠋

============================================================
📍 Passo 1
💡 Buscar arquivos maiores que 100MB e ordenar por tamanho
❓ Necessário para identificar os maiores consumidores de espaço
============================================================

┌─ Comando:
│ find . -type f -size +100M -exec ls -lh {} \; | sort -k5 -hr
└─

❓ Executar este comando?
   [Enter] Sim  |  [n] Não  |  [a] Sempre permitir 'find'
➜ a

✓ 'find' adicionado à whitelist permanente.

⚙ Executando...

✓ ┌─ Resultado: [✓]
  │ -rw-r--r-- 1 user user 2.3G dez 10 14:23 ./backup.tar.gz
  │ -rw-r--r-- 1 user user 1.8G dez 09 10:15 ./video.mp4
  │ -rw-r--r-- 1 user user 450M dez 08 16:42 ./dataset.zip
  └─

🤖 IA Pensando... ⠋

============================================================
✅ TAREFA CONCLUÍDA (via qwen/qwen3-coder:free)
============================================================

Encontrados 3 arquivos maiores que 100MB:

1. backup.tar.gz (2.3GB) - maior arquivo
2. video.mp4 (1.8GB) 
3. dataset.zip (450MB)

Total: 4.55GB em arquivos grandes.

============================================================

💬 Você > 
```

---

## 🎨 Recursos Novos

### 1. **Exibição Estruturada**
Cada comando mostra:
- 📍 Número do passo
- 💡 Explicação clara do que faz
- ❓ Razão/justificativa
- 📦 Comando exato que será executado

### 2. **Output Sempre Visível**
```
✓ ┌─ Resultado: [✓]
  │ Arquivo copiado com sucesso
  │ Total: 1.2GB transferidos
  └─
```

### 3. **Detecção de Comandos Destrutivos**
Comandos perigosos recebem aviso especial:
```
⚠️  ATENÇÃO: Comando potencialmente DESTRUTIVO!

❓ Executar este comando?
   [Enter] Sim  |  [n] Não  |  [a] Sempre permitir 'rm'
```

**Comandos destrutivos detectados:**
- `rm`, `rmdir` (deletar)
- `dd`, `mkfs`, `fdisk` (formatar disco)
- `chmod 777` (permissões inseguras)
- `shutdown`, `reboot` (desligar sistema)
- E outros...

### 4. **Whitelist que Funciona**
Agora quando você escolhe "sempre permitir", o comando base é realmente liberado:

```
💬 Você > criar backup do projeto

Passo 1: cp -r /projeto /backup
➜ a  ← Sempre permitir 'cp'

✓ 'cp' adicionado à whitelist

Passo 2: tar -czf backup.tar.gz /backup
➜ a  ← Sempre permitir 'tar'

✓ 'tar' adicionado à whitelist

Passo 3: cp backup.tar.gz /safe-storage/
✓ Auto-permitido: 'cp'  ← Já está na whitelist!

Passo 4: rm -rf /backup
⚠️  ATENÇÃO: Comando potencialmente DESTRUTIVO!
➜ [Enter]  ← Permite uma vez, mas não adiciona à whitelist
```

### 5. **IA Adaptativa**
A IA recebe o output de cada comando e ajusta a estratégia:

```
Passo 1: ls arquivo.txt
Output: ls: cannot access 'arquivo.txt': No such file or directory

Passo 2: touch arquivo.txt
(IA percebeu que arquivo não existe e decidiu criá-lo)
```

### 6. **Limite de Iterações Ajustável**
- Padrão: 30 comandos por tarefa
- Previne loops infinitos
- Pode ser ajustado no código se necessário

---

## 📋 Comandos do Sistema

### `/help`
Mostra ajuda completa e lista whitelist

### `/status`
```
=== STATUS ===
Modelo ativo: qwen/qwen3-coder:free (✓ salvo)
Mensagens na sessão: 12
Comandos na whitelist: 5
Arquivo de sessão: SESSION.md
Arquivo de modelo: /home/user/.openrouter_model.cfg
```

### `/clear`
Limpa histórico da sessão

### `/resetmodel`
Reseta modelo para o padrão

### `/exit` ou `/quit`
Sai do programa

---

## 🔧 Casos de Uso

### Caso 1: Instalação de Software
```
💬 Você > instale o nginx e configure para iniciar automaticamente

Passo 1: apt update
Passo 2: apt install -y nginx
Passo 3: systemctl enable nginx
Passo 4: systemctl start nginx
Passo 5: systemctl status nginx
✅ SUMMARY: Nginx instalado e configurado para iniciar no boot
```

### Caso 2: Backup e Limpeza
```
💬 Você > faça backup dos logs e apague logs antigos

Passo 1: tar -czf logs_backup_$(date +%Y%m%d).tar.gz /var/log/
Passo 2: find /var/log -name "*.log" -mtime +30 -delete
⚠️  ATENÇÃO: Comando potencialmente DESTRUTIVO!
Passo 3: ls -lh logs_backup_*.tar.gz
✅ SUMMARY: Backup criado (2.3GB) e 45 logs antigos removidos
```

### Caso 3: Análise de Sistema
```
💬 Você > me mostre quais processos estão consumindo mais CPU

Passo 1: ps aux --sort=-%cpu | head -n 11
✅ SUMMARY: Top 10 processos por CPU listados. Apache consumindo 45%.
```

### Caso 4: Git Workflow
```
💬 Você > clone o projeto X, crie uma branch feature e faça commit

Passo 1: git clone https://github.com/user/projeto.git
Passo 2: cd projeto
Passo 3: git checkout -b feature/nova-funcionalidade
Passo 4: git add .
Passo 5: git commit -m "feat: implementação inicial"
Passo 6: git status
✅ SUMMARY: Projeto clonado, branch criada e commit realizado com sucesso
```

---

## 🐛 Tratamento de Erros

### Erro: JSON Inválido
```
❌ Erro: IA não retornou JSON válido.
Resposta recebida:
Let me help you with that...

(Sistema pede para IA corrigir automaticamente)
```

### Erro: Comando Vazio
```
❌ Erro: Comando vazio.
(Sistema pede para IA fornecer comando válido)
```

### Erro: Comando Falhou
```
✗ ┌─ Resultado: [✗]
  │ bash: comando-inexistente: command not found
  └─

Passo 2: (IA tenta alternativa)
```

### Erro: Timeout
```
✗ ┌─ Resultado: [✗]
  │ [⚠ Timeout: Comando excedeu 120 segundos]
  └─

(IA pode tentar versão mais rápida do comando)
```

---

## ⚙️ Configurações

### Arquivos de Configuração

**~/.openrouter.cfg**
```
ls
find
grep
git
cp
mv
```

**~/.openrouter_model.cfg**
```
qwen/qwen3-coder:free
```

**SESSION.md**
```markdown
### User:
OBJETIVO: listar arquivos

### Assistant:
{"command": "ls -la", "explanation": "..."}

### User:
Resultado da execução...
```

---

## 🎯 Vantagens vs Versão Anterior

| Aspecto | v1 (Antiga) | v2 (Nova) |
|---------|-------------|-----------|
| **Comandos por resposta** | 5-7 comandos | 1 comando |
| **Whitelist** | ❌ Só 1º comando | ✅ Todos funcionam |
| **Output visível** | ❌ Não | ✅ Sempre |
| **IA adaptativa** | ❌ Não | ✅ Sim |
| **Controle** | ⭐⭐ Baixo | ⭐⭐⭐⭐⭐ Total |
| **Transparência** | ⭐⭐⭐ Média | ⭐⭐⭐⭐⭐ Total |
| **Troubleshoot** | ⭐⭐ Difícil | ⭐⭐⭐⭐⭐ Fácil |
| **Segurança** | ⭐⭐⭐ Boa | ⭐⭐⭐⭐⭐ Excelente |

---

## 💡 Dicas de Uso

### 1. Seja Específico
✅ BOM: "encontre arquivos .log maiores que 1GB criados nos últimos 7 dias"
❌ RUIM: "limpe o sistema"

### 2. Construa Whitelist Gradualmente
Aprove comandos confiáveis com [a] para acelerar futuras execuções

### 3. Revise Comandos Destrutivos
Sempre verifique comandos com rm, dd, mkfs, etc.

### 4. Use /status Regularmente
Monitore quantos comandos foram executados

### 5. /clear Entre Tarefas
Limpe sessão ao mudar de contexto

---

## 🚀 Próximos Passos

Recursos planejados para v3:
- [ ] Modo dry-run (simular sem executar)
- [ ] Histórico visual de comandos
- [ ] Estimativa de tempo/impacto
- [ ] Rollback de operações
- [ ] Export para script bash
- [ ] Modo verbose/quiet
- [ ] Progress bar para comandos longos

---

## 📞 Suporte

**Problemas comuns:**

1. **"Erro: OPENROUTER_API_KEY não definida"**
   ```bash
   export OPENROUTER_API_KEY='sua-chave-aqui'
   ```

2. **"IA não retorna JSON válido"**
   - Alguns modelos gratuitos podem ter dificuldade
   - Tente: `/resetmodel` e teste outro modelo

3. **"Todos os modelos falharam"**
   - Verifique conexão com internet
   - Verifique validade da API key
   - Aguarde alguns minutos (rate limit)

4. **Comando trava/demora muito**
   - Timeout automático em 120 segundos
   - Use Ctrl+C para abortar
