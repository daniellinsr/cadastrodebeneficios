# Guia de Testes em Dispositivos Reais

## Visão Geral

Este guia detalha como testar o aplicativo em dispositivos reais (Android e iOS) e como conectar o app mobile ao backend local.

---

## 📱 Pré-requisitos

### Para Android
- Dispositivo Android com modo desenvolvedor habilitado
- Cabo USB
- Android Studio instalado
- ADB (Android Debug Bridge) configurado

### Para iOS
- iPhone/iPad com iOS 12+
- Mac com Xcode instalado
- Cabo USB-C ou Lightning
- Certificado de desenvolvedor Apple (gratuito ou pago)

### Para Backend Local
- Node.js instalado
- PostgreSQL configurado
- Rede Wi-Fi (dispositivo e computador na mesma rede)

---

## 🔧 Preparação do Backend

### 1. Instalar Dependências

```bash
cd backend
npm install
```

### 2. Configurar Variáveis de Ambiente

O arquivo `backend/.env` já está configurado. Verifique se as credenciais do PostgreSQL estão corretas:

```env
DB_HOST=77.37.41.41
DB_PORT=5432
DB_NAME=cadastro_db
DB_USER=cadastro_user
DB_PASSWORD=Hno@uw@q
```

### 3. Executar Migrations (se ainda não executou)

**Windows:**
```powershell
cd database
.\run_migrations.ps1
```

**Linux/Mac:**
```bash
cd database
./run_migrations.sh
```

### 4. Iniciar o Backend

```bash
cd backend
npm run dev
```

O servidor estará rodando em:
- `http://localhost:3000`
- Health check: `http://localhost:3000/health`

### 5. Descobrir o IP Local do Computador

**Windows:**
```powershell
ipconfig
# Procure por "Endereço IPv4" na seção da sua rede Wi-Fi
# Exemplo: 192.168.1.100
```

**Linux/Mac:**
```bash
ifconfig
# ou
ip addr show
# Procure por "inet" na interface wireless
# Exemplo: 192.168.1.100
```

---

## 📲 Configuração do App Mobile

### 1. Atualizar URL do Backend

Edite o arquivo `.env` na raiz do projeto Flutter:

```env
# Substituir localhost pelo IP local do computador
BACKEND_API_URL=http://192.168.1.100:3000
```

**Importante:** Use o IP do seu computador na rede local, NÃO use `localhost` ou `127.0.0.1`!

### 2. Verificar Configuração

Execute o app no emulador primeiro para verificar:

```bash
flutter run
```

Verifique nos logs se a URL está correta:
```
Backend API URL: http://192.168.1.100:3000
```

---

## 🤖 Testar em Android Real

### 1. Habilitar Modo Desenvolvedor

1. Vá em **Configurações** > **Sobre o telefone**
2. Toque 7 vezes em **Número da versão**
3. Volte e entre em **Opções do desenvolvedor**
4. Ative **Depuração USB**

### 2. Conectar o Dispositivo

1. Conecte o celular via USB ao computador
2. Autorize a depuração USB no celular
3. Verifique se o dispositivo foi detectado:

```bash
flutter devices
```

Você deve ver algo como:
```
Android SDK built for arm64 (mobile) • emulator-5554 • android-arm64 • Android 11 (API 30)
Moto G (XT1045) (mobile)            • 12345678      • android-arm   • Android 10 (API 29)
```

### 3. Executar o App

```bash
# Listar dispositivos disponíveis
flutter devices

# Executar em dispositivo específico
flutter run -d 12345678

# Ou simplesmente (Flutter escolhe automaticamente)
flutter run
```

### 4. Testar Funcionalidades

1. **Teste de Conectividade:**
   - Abra o app
   - Verifique se não há erros de conexão
   - Tente fazer login

2. **Teste de Autenticação:**
   - Faça login com email/senha
   - Faça login com Google
   - Verifique se redireciona para `/home` após login

3. **Teste de Route Guards:**
   - Sem estar logado, tente acessar `/home` manualmente
   - Deve redirecionar para `/login`
   - Logado, tente acessar `/login`
   - Deve redirecionar para `/home`

### 5. Debug via Chrome DevTools

```bash
flutter run --observatory-port=8888 --disable-service-auth-codes
```

Depois acesse: `chrome://inspect` no Chrome

---

## 🍎 Testar em iOS Real

### 1. Preparar Xcode

```bash
cd ios
pod install
cd ..
```

### 2. Abrir no Xcode

```bash
open ios/Runner.xcworkspace
```

### 3. Configurar Assinatura

1. Selecione o projeto **Runner** no navegador
2. Vá em **Signing & Capabilities**
3. Marque **Automatically manage signing**
4. Selecione seu **Team** (Apple ID gratuito ou pago)
5. Aguarde o Xcode gerar o perfil de provisionamento

### 4. Conectar o iPhone

1. Conecte o iPhone via cabo
2. Desbloqueie o iPhone
3. Confie no computador quando solicitado
4. No iPhone, vá em **Configurações** > **Geral** > **Gerenciamento de Dispositivo**
5. Confie no desenvolvedor (seu Apple ID)

### 5. Executar o App

```bash
# Listar dispositivos
flutter devices

# Executar no iPhone
flutter run -d <device-id>
```

Ou no Xcode:
1. Selecione seu iPhone no topo
2. Clique em ▶️ (Run)

### 6. Testar Funcionalidades

Mesmos testes do Android:
- Conectividade
- Autenticação
- Route Guards
- Google OAuth

---

## 🔥 Problemas Comuns

### Backend não está acessível do celular

**Causa:** Firewall bloqueando conexões

**Solução Windows:**
```powershell
# Abrir porta 3000 no firewall
New-NetFirewallRule -DisplayName "Backend Node.js" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

**Solução Linux:**
```bash
sudo ufw allow 3000/tcp
```

**Solução Mac:**
- Ir em **Preferências do Sistema** > **Segurança e Privacidade** > **Firewall**
- Clicar em **Opções do Firewall**
- Adicionar Node.js e permitir conexões

### Erro de certificado SSL no Android

**Causa:** Android não confia em certificados autoassinados

**Solução:** Use HTTP (não HTTPS) para desenvolvimento local

### Google OAuth não funciona no iOS

**Causa:** URL Scheme não configurado

**Solução:** Verifique `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.403775802042-dr9hvctbr6qfildd767us0o057m3iu3m</string>
    </array>
  </dict>
</array>
```

### Hot Reload não funciona

Execute com:
```bash
flutter run --no-fast-start
```

---

## 📊 Checklist de Testes

### Conectividade
- [ ] App conecta ao backend local
- [ ] Health check retorna status OK
- [ ] Logs mostram URL correta

### Autenticação
- [ ] Login com email/senha funciona
- [ ] Login com Google funciona
- [ ] Token é salvo no secure storage
- [ ] Logout revoga token

### Route Guards
- [ ] Usuário não logado é redirecionado para `/login` ao acessar rotas protegidas
- [ ] Usuário logado é redirecionado para `/home` ao acessar `/login`
- [ ] Rotas públicas (`/`, `/partners`) são acessíveis sem login

### Performance
- [ ] App abre em menos de 3 segundos
- [ ] Navegação é fluida (60fps)
- [ ] Sem memory leaks

### Google OAuth
- [ ] Dialog do Google abre corretamente
- [ ] Após login, token é obtido
- [ ] Usuário é criado/atualizado no banco
- [ ] Redirecionamento funciona

---

## 🧪 Testes Adicionais

### Teste de Rede Instável

Simule rede instável no celular:
1. Ative modo avião por 5 segundos
2. Desative
3. Verifique se o app se reconecta

### Teste de Token Expirado

1. No backend, altere `JWT_EXPIRES_IN=10s`
2. Faça login
3. Aguarde 10 segundos
4. Tente fazer uma requisição autenticada
5. Verifique se o refresh token funciona

### Teste de Logout

1. Faça login
2. Clique em Logout
3. Verifique se redireciona para `/login`
4. Tente acessar `/home`
5. Deve redirecionar para `/login`

---

## 📱 Dispositivos Recomendados para Teste

### Android
- **Mínimo:** Android 7.0 (API 24)
- **Recomendado:** Android 10+ (API 29+)
- **Telas:** 5" a 6.5" (resolução HD+)

### iOS
- **Mínimo:** iOS 12.0
- **Recomendado:** iOS 15+
- **Dispositivos:** iPhone 8 ou superior

---

## 🚀 Build para Produção

### Android

```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

APK estará em: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

Depois, abra no Xcode e faça o Archive.

---

## 📚 Logs e Debug

### Ver logs do backend

```bash
# Logs aparecem no terminal onde executou npm run dev
```

### Ver logs do Flutter

```bash
flutter logs
```

### Ver logs do Android (logcat)

```bash
adb logcat | grep flutter
```

### Ver logs do iOS

No Xcode: **Window** > **Devices and Simulators** > selecione dispositivo > **Open Console**

---

## ✅ Resumo

1. ✅ Backend rodando em `http://IP_LOCAL:3000`
2. ✅ `.env` do Flutter configurado com IP local
3. ✅ Firewall permite conexões na porta 3000
4. ✅ Dispositivo e computador na mesma rede Wi-Fi
5. ✅ Depuração USB habilitada (Android) ou iPhone confiável (iOS)
6. ✅ App instalado e funcionando no dispositivo

---

**Pronto! Agora você pode testar o app em dispositivos reais com o backend local! 🎉**
