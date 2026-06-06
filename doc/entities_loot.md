# Лут сущностей

Лут выпадает с сущностей при их смерти.

Чтобы добавить лут для сущности, добавьте в список components в entities/your_entity.json такой объект на примере newgen:entities/bear.json:

```json
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
}
```

### item - *id предмета с указанием контент-пака*

### min & max - *минимально и максимально возможное количество предметов*

[Назад](main_page.md)