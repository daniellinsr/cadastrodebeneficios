# Estágio de build
FROM node:18-alpine AS builder

WORKDIR /app

# Copiar package.json e package-lock.json
COPY package*.json ./

# Instalar dependências
RUN npm ci --only=production

# Copiar código fonte
COPY . .

# Build da aplicação TypeScript
RUN npm run build

# Estágio de produção
FROM node:18-alpine

WORKDIR /app

# Copiar dependências do estágio de build
COPY --from=builder /app/node_modules ./node_modules

# Copiar código compilado
COPY --from=builder /app/dist ./dist

# Copiar package.json
COPY package*.json ./

# Criar usuário não-root para segurança
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Mudar ownership dos arquivos
RUN chown -R nodejs:nodejs /app

# Usar usuário não-root
USER nodejs

# Expor porta 3002
EXPOSE 3002

# Comando para iniciar a aplicação
CMD ["node", "dist/server.js"]
