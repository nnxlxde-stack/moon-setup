# moon-setup

Скрипты установки экосистемы Moon: toolchain, расширение VS Code, проверка окружения.

## Быстрая установка

### Windows (PowerShell) — рекомендуется

```powershell
irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/install-all.ps1 | iex
```

Устанавливает в `%APPDATA%\Moon`:

| Путь | Содержимое |
|------|------------|
| `bin\moon.exe` | CLI из [moon-lang Releases](https://github.com/nnxlxde-stack/moon-lang/releases/latest) |
| `runtime\bin\` | Swift runtime DLLs (без отдельной установки Swift) |
| `stdlib\` | Стандартная библиотека Moon |

Добавляет `bin` и `runtime\bin` в **PATH пользователя**. Перезапустите терминал / VS Code.

### Локальный запуск

```powershell
git clone https://github.com/nnxlxde-stack/moon-setup.git
cd moon-setup
.\install-all.ps1
```

### macOS / Linux

```bash
git clone https://github.com/nnxlxde-stack/moon-setup.git
cd moon-setup
chmod +x install-all.sh scripts/*.sh
./install-all.sh
```

## Скрипты

| Скрипт | Описание |
|--------|----------|
| `install-all` | moon-lang + VS Code extension |
| `scripts/install-moon` | Клонирование и `swift build` moon-lang |
| `scripts/install-vscode` | Скачивание `.vsix` из GitHub Releases |
| `scripts/verify` | `moon version`, проверка расширения |

## Требования

- Git
- Swift 6.3+
- VS Code / Cursor с CLI `code` (для расширения)

## Экосистема

| Репозиторий | Роль |
|-------------|------|
| [moon-lang](https://github.com/nnxlxde-stack/moon-lang) | Интерпретатор |
| [moon-vscode](https://github.com/nnxlxde-stack/moon-vscode) | Расширение |
| [moon-pkg](https://github.com/nnxlxde-stack/moon-pkg) | Пакеты |

## Лицензия

MIT