@echo off
chcp 65001 >nul
echo ========================================
echo   Gerador de PDF - Manual v1.0
echo ========================================
echo.

echo Verificando Pandoc...
where pandoc >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Pandoc não encontrado!
    echo.
    echo Por favor, instale o Pandoc:
    echo https://pandoc.org/installing.html
    echo.
    echo Após instalar, execute este script novamente.
    pause
    exit /b 1
)

echo ✅ Pandoc encontrado!
echo.

echo Gerando PDF com ilustrações...
echo.

pandoc MANUAL_USUARIO_v1.0.md ^
    -o MANUAL_USUARIO_v1.0.pdf ^
    --toc ^
    --toc-depth=3 ^
    --pdf-engine=xelatex ^
    -V geometry:margin=1in ^
    -V documentclass=report ^
    -V papersize=a4 ^
    -V fontsize=11pt ^
    -V mainfont="Arial" ^
    -V monofont="Courier New" ^
    --highlight-style=tango ^
    --metadata title="Manual do Usuário" ^
    --metadata subtitle="Sistema de Cadastro de Benefícios v1.0" ^
    --metadata author="Equipe de Desenvolvimento" ^
    --metadata date="Dezembro 2025"

if %errorlevel% equ 0 (
    echo.
    echo ✅ PDF gerado com sucesso!
    echo.
    echo 📄 Arquivo: MANUAL_USUARIO_v1.0.pdf
    echo 📁 Local: %CD%
    echo.
    echo Abrindo PDF...
    start MANUAL_USUARIO_v1.0.pdf
) else (
    echo.
    echo ❌ Erro ao gerar PDF
    echo.
    echo Tente instalar MiKTeX (LaTeX):
    echo https://miktex.org/download
)

echo.
pause
