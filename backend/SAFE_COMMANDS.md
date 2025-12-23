# 🛡️ Comandos Seguros para Servidor Compartilhado

## ⚠️ ATENÇÃO

Este servidor hospeda **MÚLTIPLAS APLICAÇÕES**. Use APENAS os comandos listados neste arquivo para evitar afetar outras aplicações.

## 📍 Diretório da Aplicação

```bash
cd /opt/apps/cadastro/cadastrodebeneficios
```

## ✅ Comandos SEGUROS (use estes)

### Ver logs do cadastro-beneficios
```bash
docker-compose logs -f backend
docker-compose logs --tail=100 backend
```

### Ver status do cadastro-beneficios
```bash
docker-compose ps backend
```

### Parar o cadastro-beneficios
```bash
docker-compose stop backend
```

### Iniciar o cadastro-beneficios
```bash
docker-compose start backend
```

### Reiniciar o cadastro-beneficios
```bash
docker-compose restart backend
```

### Reconstruir o cadastro-beneficios
```bash
docker-compose stop backend
docker-compose rm -f backend
docker-compose build --no-cache backend
docker-compose up -d backend
```

### Ver apenas a imagem do cadastro-beneficios
```bash
docker images | grep cadastrodebeneficios
```

### Ver apenas o container do cadastro-beneficios
```bash
docker ps | grep cadastro-beneficios
docker ps -a | grep cadastro-beneficios
```

### Entrar no container do cadastro-beneficios
```bash
docker-compose exec backend sh
```

### Ver uso de recursos do cadastro-beneficios
```bash
docker stats cadastro-beneficios-backend
```

### Remover APENAS a imagem antiga do cadastro-beneficios
```bash
# Liste primeiro
docker images | grep cadastrodebeneficios

# Remova especificamente
docker rmi cadastrodebeneficios-backend:latest
```

## ❌ Comandos PERIGOSOS (NÃO use)

### ❌ Para TODOS os containers do servidor
```bash
docker stop $(docker ps -q)  # NÃO USE!
docker-compose down  # NÃO USE sem especificar serviço!
```

### ❌ Remove TODAS as imagens não utilizadas
```bash
docker image prune -a  # NÃO USE!
docker system prune -a  # NÃO USE!
```

### ❌ Para TODOS os containers do docker-compose
```bash
docker-compose stop  # NÃO USE sem especificar serviço!
docker-compose down  # NÃO USE sem especificar serviço!
```

### ❌ Remove TODOS os volumes
```bash
docker volume prune  # NÃO USE!
```

## 🔍 Comandos de Diagnóstico SEGUROS

### Ver todos os containers (apenas visualizar)
```bash
docker ps -a
```

### Ver todas as imagens (apenas visualizar)
```bash
docker images
```

### Ver uso de disco (apenas visualizar)
```bash
docker system df
```

### Ver redes (apenas visualizar)
```bash
docker network ls
```

### Ver recursos do servidor
```bash
df -h  # Espaço em disco
free -h  # Memória
top  # CPU e processos
htop  # Melhor visualização (se instalado)
```

## 📊 Monitoramento Específico

### Health check da aplicação
```bash
curl http://localhost:3002/health
```

### Verificar conectividade com banco
```bash
docker-compose exec backend sh -c "node -e \"require('pg').Pool({host:process.env.DB_HOST,port:process.env.DB_PORT,user:process.env.DB_USER,password:process.env.DB_PASSWORD,database:process.env.DB_NAME}).query('SELECT NOW()').then(r=>console.log('DB OK',r.rows[0])).catch(e=>console.error('DB ERROR',e))\""
```

### Ver variáveis de ambiente (sem mostrar senhas)
```bash
docker-compose exec backend env | grep -v PASSWORD | grep -v SECRET | grep -v PASS
```

## 🔄 Workflow Completo de Atualização SEGURO

```bash
# 1. Conectar ao servidor
ssh root@77.37.41.41

# 2. Ir para o diretório
cd /opt/apps/cadastro/cadastrodebeneficios

# 3. Fazer backup do .env (opcional mas recomendado)
cp .env .env.backup

# 4. Verificar se há novos arquivos (após scp)
ls -la

# 5. Parar APENAS o container do cadastro
docker-compose stop backend

# 6. Remover container antigo
docker-compose rm -f backend

# 7. Construir nova imagem
docker-compose build --no-cache backend

# 8. Iniciar novo container
docker-compose up -d backend

# 9. Aguardar alguns segundos
sleep 5

# 10. Verificar se está rodando
docker-compose ps backend

# 11. Ver logs
docker-compose logs --tail=50 backend

# 12. Testar health check
curl http://localhost:3002/health

# 13. Se tudo OK, remover imagem antiga (opcional)
# docker images | grep cadastrodebeneficios
# docker rmi <OLD_IMAGE_ID>
```

## 🆘 Troubleshooting SEGURO

### Container não inicia?
```bash
# Ver logs completos
docker-compose logs backend

# Ver últimas 200 linhas
docker-compose logs --tail=200 backend

# Verificar se a porta está ocupada
sudo lsof -i :3002
sudo netstat -tulpn | grep 3002
```

### Limpar espaço em disco (com cuidado)
```bash
# Ver espaço usado
docker system df

# Limpar APENAS logs do cadastro-beneficios
docker-compose logs backend --tail=0

# Remover APENAS imagens antigas do cadastro-beneficios
docker images | grep cadastrodebeneficios
# Anote o IMAGE ID das antigas e remova:
docker rmi <IMAGE_ID_ANTIGA>
```

### Verificar se outras aplicações estão OK
```bash
# Ver todos os containers rodando
docker ps

# Devem estar todos com status "Up"
# Se algum outro container estiver "Exited", NÃO foi você que derrubou!
```

## 📝 Checklist de Segurança

Antes de executar qualquer comando, pergunte:

- [ ] Este comando afeta APENAS o container `cadastro-beneficios-backend`?
- [ ] Especifiquei o serviço `backend` no comando docker-compose?
- [ ] Não estou usando comandos com `$(docker ps -q)` ou `-a` que afetam tudo?
- [ ] Não estou usando `prune` sem filtros específicos?
- [ ] Verifiquei que estou no diretório correto `/opt/apps/cadastro/cadastrodebeneficios`?

## 🔐 Boas Práticas

1. **Sempre especifique o serviço**: `docker-compose logs backend` ✅ não `docker-compose logs` ❌
2. **Use comandos read-only primeiro**: `docker ps`, `docker images`, `docker logs`
3. **Faça backup antes de mudanças**: `cp .env .env.backup`
4. **Teste em horários de baixo uso**: Se possível, faça deploy fora de horário de pico
5. **Monitore outras aplicações**: Após mudanças, verifique `docker ps` para garantir que tudo continua rodando
6. **Mantenha logs**: Sempre salve logs antes de fazer mudanças: `docker-compose logs backend > backup-logs.txt`

## 🎯 Comandos Mais Usados (Resumo)

```bash
# Ir para diretório
cd /opt/apps/cadastro/cadastrodebeneficios

# Ver logs
docker-compose logs -f backend

# Reiniciar
docker-compose restart backend

# Atualizar
docker-compose stop backend && \
docker-compose rm -f backend && \
docker-compose build --no-cache backend && \
docker-compose up -d backend

# Verificar
docker-compose ps backend
curl http://localhost:3002/health
```
