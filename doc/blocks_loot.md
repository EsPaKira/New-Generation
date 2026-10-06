# Лут блоков

NewGen добавяляет возможность указать уникальный лут блока для каждого инструмента

## Как указать

В файле блока (на примере из newgen:blocks/base/leaves.json):

```json
"newgen:loot": {
    "default" /*аналогичен base:loot*/: [
        {
            "item": "newgen:stick",
            "min": 1,
            "max": 2
        }
    ],
    "newgen:axe" /*tag инструмента*/: [
        {
            "item": "base:leaves.item",
            "count": 1
        }
    ]
}
```

Tag'и инструментов из NewGen: ```newgen:axe```, ```newgen:pickaxe```, ```newgen:shovel```.

### Можно указать свой tag или добавить tag для уже имеющихся предметов - ```PACK_ID:name```

[Назад](main_page.md)
