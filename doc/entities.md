# Сущности New Generation

newgen предоставляет несколько компонентов для сущностей.

## newgen:characteristics_manager

Этот компонент самый главный для работы сущностей. Он управляет всем, что связано с характеристиками.

Можно указать любые характеристики сущности из списка: health, max_health, oxygen, max_oxygen, crushing_damage_protection, piercing_damage_protection, slashing_damage_protection.

**Требуется почти во всех остальных компонентах.**

## newgen:oxygen_system

Этот компонент отвечает за дыхание под водой.

**Требует для работы newgen:health_system и newgen:swimming_system**

## newgen:health_system

Этот компонент отвечает за здоровье и смерть сущности.

## newgen:swimming_system

Этот компонент позволяет плавать сущностям, находящимся под управлением игрока.

**Не требует для работы newgen:characteristics_manager**

## newgen:loot

Этот компонент позволяет добавлять лут, который выпадет после смерти сущности.

Лут указывается в таблице args

**Требует для работы newgen:health_system**

## Пример массива components из newgen:entities/bear.json:

```json
"components": [
    "core:pathfinding",
    {
        "name": "core:mob",
        "args": {
            "jump_force": 8.0,
            "movement_speed": 130
        }
    },
    {
        "name": "newgen:characteristics_manager",
        "args": {
            "health": 8,
            "max_health": 8
        }
    },
    {
        "name": "newgen:loot",
        "args": {
            "loot_table": [
                {   
                    "item": "newgen:fur_cape",
                    "min": 1,
                    "max": 2
                },
                {
                    "item": "newgen:bear_meat",
                    "min": 2,
                    "max": 5
                }
            ]
                    
        }
    },
    "newgen:swimming_system",
    "newgen:health_system",
    "newgen:oxygen_system",
    "newgen:bear"
]
```

**Чтобы компоненты работали корректно, необходимо добавлять их в правильном порядке: *newgen:characteristics_manager и newgen:swimming_system > newgen:health_system > newgen:oxygen_system и newgen:loot***

[Назад](main_page.md)