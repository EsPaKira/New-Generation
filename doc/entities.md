# Сущности New Generation

newgen предоставляет несколько компонентов для сущностей.

## newgen:characteristics_manager

Этот компонент самый главный для работы сущностей. Он управляет всем, что связано с характеристиками.

> [!WARNING]
> Обязателен в использовании со всеми остальными компонентами.

Можно указать любые характеристики сущности из списка: health, max_health, oxygen, max_oxygen, hunger, max_hunger, crushing_damage_protection, piercing_damage_protection, slashing_damage_protection.

**Требуется почти во всех остальных компонентах.**

## newgen:oxygen_system

Этот компонент отвечает за дыхание под водой.

**Требует для работы newgen:health_system и newgen:swimming_system**

## newgen:health_system

Этот компонент отвечает за здоровье и смерть сущности.

## newgen:hunger_system

Этот компонент отвечает за голод сущности (рекомендуется использовать только для сущности игрока).

## newgen:swimming_system

Этот компонент позволяет плавать сущностям, находящимся под управлением игрока. Если сущность (не обязательно сущность игрока) должна задыхаться под водой, то необходимо использовать этот компонент.

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

>[!IMPORTANT]
> *Чтобы компоненты работали корректно, необходимо добавлять их в правильном порядке:*
> newgen:characteristics_manager, newgen:swimming_system, newgen:hunger_system и newgen:loot > newgen:health_system > newgen:oxygen_system

[Назад](main_page.md)