# Генерация лута в хранилищах

Генерация лута в хранилищах доступна для любого блока, имеющего инвентарь.

Для добавления своего лута в папке blocks_loot создайте json-файл, который называется так же, как и ваш блок.

*Так же в своем контент-паке можно дополнять уже существующие файлы из newgen*

Шаблон для json-файла лута:

```json
[
    {
        "item": "newgen:flax_fiber",
        "min": 2,
        "max": 8,
        "max-slots": 3
    },
    {
        "item": "newgen:stindle",
        "min": 0,
        "max": 1
    }, ...
]
```

### item - *id предмета с указанием контент-пака*

### min & max - *минимально и максимально возможное количество предметов*

### max-slots - *максимальное количество слотов, на которые могут распространиться предметы*
*Работает только если сгенерировалось больше 1 предмета*


## Скрипт для блока-хранилища

Пример из scripts/bag.lua:

```lua
function on_interact(x, y, z, pid)
    if block.get_variant(x, y, z) == 0 then
        local GL = require "generate_loot"
        GL.generate_loot(inventory.get_block(x, y, z), "bag")
    end

    hud.open_block(x, y, z)
    hud.open_permanent("newgen:player_button")
    block.set_variant(x, y, z, 1) -- делает недоступным генерацию лута после открытия
    return true
end

function on_placed(x, y, z)
    block.set_variant(x, y, z, 1) -- делает недоступным генерацю лута после установки
end
```

В GL.generate_loot() вторым аргументом передается название json-файла из blocks_loot.

*Рекомендую полностью копировать пример кода.*

[Назад](main_page.md)