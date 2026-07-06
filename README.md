# moon-setup

Скрипты установки экосистемы Moon: toolchain, расширение VS Code, проверка окружения.

## Быстрая установка

### Windows (PowerShell)

**Установка:**

```powershell
irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/install-all.ps1 | iex
```

**Обновление:**

```powershell
irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/update-all.ps1 | iex
```

**Удаление:**

```powershell
irm https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/uninstall-all.ps1 | iex
```

Расширение ставится в **VS Code**, **VS Code Insiders** или **Cursor** - CLI ищется автоматически (`code`, `code-insiders`, `cursor`). Если найдено несколько редакторов, скрипт предложит выбор. Явный выбор:

```powershell
# после git clone:
.\install-all.ps1 -Editor code-insiders

# только moon, без расширения:
.\install-all.ps1 -SkipVscode
```

Через `irm | iex` параметры не передаются — при нескольких редакторах появится интерактивный выбор.

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
| `install-all.ps1` | Установка moon + расширение VS Code |
| `update-all.ps1` | Обновление moon + расширение |
| `uninstall-all.ps1` | Удаление moon + расширение |
| `scripts/install-moon.ps1` | Только toolchain (exe, runtime, stdlib) |
| `scripts/install-vscode.ps1` | Только расширение из GitHub Releases |
| `scripts/update-moon.ps1` | Обновить toolchain |
| `scripts/update-vscode.ps1` | Обновить расширение |
| `scripts/uninstall-moon.ps1` | Удалить `%APPDATA%\Moon` и PATH |
| `scripts/uninstall-vscode.ps1` | Удалить расширение из редактора |
| `scripts/verify.ps1` | `moon version`, проверка расширения |

## Требования

- Windows 10+
- VS Code / Cursor с CLI в PATH (для расширения; опционально)

## Экосистема

| Репозиторий | Роль |
|-------------|------|
| [moon-lang](https://github.com/nnxlxde-stack/moon-lang) | Интерпретатор |
| [moon-vscode](https://github.com/nnxlxde-stack/moon-vscode) | Расширение |
| [moon-pkg](https://github.com/nnxlxde-stack/moon-pkg) | Пакеты |

## Лицензия

MIT