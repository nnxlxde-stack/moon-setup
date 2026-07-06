# moon-setup

[![Docs](https://img.shields.io/badge/docs-GitHub%20Pages-5865F2?style=flat-square)](https://nnxlxde-stack.github.io/moon-lang/#quickstart)

Скрипты установки экосистемы Moon: toolchain, расширение VS Code/Cursor, проверка окружения.

## Быстрая установка

### Windows (PowerShell)

| Действие | Команда |
|----------|---------|
| **Установка** | `irm .../install-all.ps1 \| iex` |
| **TUI-менеджер** | `irm .../moon-manage.ps1 \| iex` |
| **Обновление** | `irm .../update-all.ps1 \| iex` |
| **Удаление** | `irm .../uninstall-all.ps1 \| iex` |

```powershell
irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/install-all.ps1 | iex
irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/moon-manage.ps1 | iex
irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/update-all.ps1 | iex
irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/uninstall-all.ps1 | iex
```

### moon-manage — интерактивное меню

```
[1] Install all       [5] Install / update extension
[2] Update all        [6] Uninstall extension
[3] Uninstall all     [7] Verify
[4] Install moon only [8] Exit
```

Показывает статус: moon.exe, версия, запущенные редакторы, установленное расширение.

### Редакторы

Расширение ставится в **VS Code**, **VS Code Insiders** или **Cursor** — CLI ищется автоматически. Если найдено несколько редакторов, скрипт предложит выбор.

**Закройте редактор перед установкой расширения.** Если он запущен, скрипт предложит подождать или покажет команду:

```powershell
code-insiders --install-extension "C:\Users\...\vscode-moon-0.3.2.vsix"
```

Локальный запуск с выбором редактора:

```powershell
git clone https://github.com/nnxlxde-stack/moon-setup.git
cd moon-setup
.\install-all.ps1 -Editor code-insiders
.\moon-manage.ps1 -Editor code-insiders
.\install-all.ps1 -SkipVscode   # только moon, без расширения
```

Через `irm | iex` параметры не передаются — при нескольких редакторах появится интерактивный выбор.

### Что устанавливается

Путь: `%APPDATA%\Moon`

| Путь | Содержимое |
|------|------------|
| `bin\moon.exe` | CLI из [moon-lang Releases](https://github.com/nnxlxde-stack/moon-lang/releases/latest) |
| `runtime\bin\` | Swift runtime DLLs (без отдельной установки Swift) |
| `stdlib\` | Стандартная библиотека Moon |

Добавляет `bin` и `runtime\bin` в **PATH пользователя**, переменную `MOON_STDLIB`. Перезапустите терминал / VS Code.

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
| `moon-manage.ps1` | Интерактивное меню: установка, обновление, удаление |
| `install-all.ps1` | Установка moon + расширение |
| `update-all.ps1` | Обновление moon + расширение |
| `uninstall-all.ps1` | Удаление moon + расширение |
| `scripts/install-moon.ps1` | Только toolchain |
| `scripts/install-vscode.ps1` | Только расширение |
| `scripts/update-moon.ps1` | Обновить toolchain |
| `scripts/update-vscode.ps1` | Обновить расширение |
| `scripts/uninstall-moon.ps1` | Удалить `%APPDATA%\Moon` и PATH |
| `scripts/uninstall-vscode.ps1` | Удалить расширение |
| `scripts/verify.ps1` | `moon version`, проверка расширения |

## Требования

- Windows 10+
- VS Code / Cursor с CLI в PATH (для расширения; опционально)

## Документация

[nnxlxde-stack.github.io/moon-lang](https://nnxlxde-stack.github.io/moon-lang/) — полная документация языка и экосистемы.

## Экосистема

| Репозиторий | Роль |
|-------------|------|
| [moon-lang](https://github.com/nnxlxde-stack/moon-lang) | Интерпретатор |
| [moon-vscode](https://github.com/nnxlxde-stack/moon-vscode) | Расширение |
| [moon-pkg](https://github.com/nnxlxde-stack/moon-pkg) | Пакеты |

## Лицензия

MIT