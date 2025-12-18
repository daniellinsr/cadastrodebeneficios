# Script PowerShell para Captura Automática de Telas
# Sistema de Cadastro de Benefícios v1.0

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Captura de Telas - Manual v1.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se app está rodando
Write-Host "1. Verificando se o app está rodando..." -ForegroundColor Yellow
$response = try { Invoke-WebRequest -Uri "http://localhost:8080" -Method Head -TimeoutSec 5 -ErrorAction SilentlyContinue } catch { $null }

if ($null -eq $response) {
    Write-Host "   ❌ App não está rodando em http://localhost:8080" -ForegroundColor Red
    Write-Host "   Execute: flutter run -d chrome --web-port 8080" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "   ✅ App rodando em http://localhost:8080" -ForegroundColor Green
}

# Criar diretório de imagens
$imagesPath = Join-Path $PSScriptRoot "images"
if (-not (Test-Path $imagesPath)) {
    New-Item -ItemType Directory -Path $imagesPath | Out-Null
    Write-Host "   ✅ Diretório de imagens criado" -ForegroundColor Green
}

Write-Host ""
Write-Host "2. Preparando para capturas..." -ForegroundColor Yellow
Write-Host ""

# Lista de telas para capturar
$screens = @(
    @{
        Name = "landing_page"
        Title = "Landing Page (Tela Inicial)"
        URL = "http://localhost:8080/#/"
        Instructions = "Capture a tela inicial completa com logo, botões e cards de benefícios"
        Wait = 3
    },
    @{
        Name = "login_page"
        Title = "Tela de Login"
        URL = "http://localhost:8080/#/login"
        Instructions = "Capture a tela de login com campos Email, Senha e botões"
        Wait = 2
    },
    @{
        Name = "registration_intro"
        Title = "Cadastro - Introdução"
        URL = "http://localhost:8080/#/register"
        Instructions = "Capture a tela com botões 'Continuar com Google' e 'Cadastrar com Email'"
        Wait = 2
    },
    @{
        Name = "registration_identification"
        Title = "Cadastro - Identificação"
        URL = "http://localhost:8080/#/register/identification"
        Instructions = "Capture a tela com campos: Nome, Email, Telefone, CPF, Data de Nascimento"
        Wait = 2
    },
    @{
        Name = "registration_address"
        Title = "Cadastro - Endereço"
        URL = "http://localhost:8080/#/register/address"
        Instructions = "Capture a tela com campos de endereço (CEP, Rua, Número, etc.)"
        Wait = 2
    },
    @{
        Name = "registration_password"
        Title = "Cadastro - Senha"
        URL = "http://localhost:8080/#/register/password"
        Instructions = "Capture a tela com campos de Senha e Confirmar Senha + indicador de força"
        Wait = 2
    },
    @{
        Name = "email_verification"
        Title = "Verificação de Email"
        URL = "http://localhost:8080/#/verify-email"
        Instructions = "Capture a tela com 6 campos para código de verificação"
        Wait = 2
    },
    @{
        Name = "profile_page"
        Title = "Perfil do Usuário"
        URL = "http://localhost:8080/#/profile"
        Instructions = "Capture a tela de perfil com dados do usuário"
        Wait = 2
    }
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INSTRUÇÕES DE CAPTURA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para cada tela, você precisará:" -ForegroundColor White
Write-Host "  1. Aguardar o Chrome abrir a URL" -ForegroundColor Gray
Write-Host "  2. Pressionar Win+Shift+S para capturar" -ForegroundColor Gray
Write-Host "  3. Selecionar a área da tela" -ForegroundColor Gray
Write-Host "  4. A imagem irá para o clipboard" -ForegroundColor Gray
Write-Host "  5. Colar (Ctrl+V) quando solicitado" -ForegroundColor Gray
Write-Host ""
Write-Host "Pressione ENTER para começar..." -ForegroundColor Yellow
Read-Host

$captured = 0
$total = $screens.Count

foreach ($screen in $screens) {
    $captured++

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  [$captured/$total] $($screen.Title)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "📱 Abrindo: $($screen.URL)" -ForegroundColor Yellow
    Start-Process "chrome.exe" $screen.URL

    Write-Host "⏳ Aguardando $($screen.Wait) segundos para carregar..." -ForegroundColor Yellow
    Start-Sleep -Seconds $screen.Wait

    Write-Host ""
    Write-Host "📸 INSTRUÇÕES:" -ForegroundColor Green
    Write-Host "   $($screen.Instructions)" -ForegroundColor White
    Write-Host ""
    Write-Host "➡️  Passos:" -ForegroundColor Cyan
    Write-Host "   1. Pressione Win+Shift+S" -ForegroundColor Gray
    Write-Host "   2. Selecione a área da tela" -ForegroundColor Gray
    Write-Host "   3. Pressione ENTER aqui quando capturar" -ForegroundColor Gray
    Write-Host ""

    Read-Host "Pressione ENTER após capturar"

    # Salvar do clipboard
    $imagePath = Join-Path $imagesPath "$($screen.Name).png"

    Write-Host "💾 Salvando imagem..." -ForegroundColor Yellow

    # PowerShell para salvar do clipboard
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $img = [System.Windows.Forms.Clipboard]::GetImage()

    if ($null -ne $img) {
        $img.Save($imagePath, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Host "   ✅ Salvo: $($screen.Name).png" -ForegroundColor Green

        # Verificar tamanho
        $fileSize = (Get-Item $imagePath).Length / 1MB
        Write-Host "   📊 Tamanho: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Gray
    } else {
        Write-Host "   ⚠️  Nenhuma imagem no clipboard. Pulando..." -ForegroundColor Yellow
        Write-Host "   💡 Você pode capturar manualmente depois" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "Pressione ENTER para próxima tela..." -ForegroundColor Yellow
    Read-Host
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ✅ CAPTURAS CONCLUÍDAS!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar imagens capturadas
Write-Host "📊 Resumo das capturas:" -ForegroundColor Yellow
Write-Host ""

$totalCaptured = 0
foreach ($screen in $screens) {
    $imagePath = Join-Path $imagesPath "$($screen.Name).png"
    if (Test-Path $imagePath) {
        $fileSize = (Get-Item $imagePath).Length / 1KB
        Write-Host "   ✅ $($screen.Name).png ($([math]::Round($fileSize, 0)) KB)" -ForegroundColor Green
        $totalCaptured++
    } else {
        Write-Host "   ❌ $($screen.Name).png (FALTANDO)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Total capturado: $totalCaptured de $total telas" -ForegroundColor Cyan
Write-Host ""

if ($totalCaptured -eq $total) {
    Write-Host "🎉 Todas as telas foram capturadas com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximo passo: Converter o manual para PDF" -ForegroundColor Yellow
    Write-Host "Execute: pandoc MANUAL_USUARIO_v1.0.md -o MANUAL_USUARIO_v1.0.pdf" -ForegroundColor Gray
} else {
    Write-Host "⚠️  Algumas telas não foram capturadas." -ForegroundColor Yellow
    Write-Host "Você pode capturá-las manualmente depois." -ForegroundColor Gray
}

Write-Host ""
Write-Host "Imagens salvas em: $imagesPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pressione ENTER para sair..." -ForegroundColor Gray
Read-Host
