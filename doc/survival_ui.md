# Кастомизация интерфейса

## Как указывать

В ```ваш_пак:config/newgen/main.json``` создаете объект.

### Доступные ключи

```survival-ui``` - Можно указать собственный входной файл (адрес - пак:путь_без_.lua) для интерфейса (открывается при включенном режиме выживания).

Пример из ```newgen:config/newgen.main.json``` - ```"survival-ui": "newgen:client/survival_ui"```

Шаблон для файла:

```lua
local module = {}


function module.start()

end

function module.open_survival_hud()

end

function module.close_survival_hud()

end

function module.update()

end
```

```start``` вызывается 1 раз при открытии HUD.

```update``` вызывается каждый on_hud_render, когда включен режим выживания.

### Замена отдельных элементов в базовом UI

Будет расширяться в будущем.

### Меню смерти

В ```death-menu``` просто указать XML-файл (Например: ```"newgen:death_menu"``` без .xml).

### Боковая панель

Та самая панель, которая появляется слева от инвентаря. *Будет добавлено позже*

[Назад](main_page.md)
