## Статы игроков

### Как указывать

В ```config/newgen_stats.json``` создаете:

```json
{
    "ваш-стат" : {
        "default": значение-по-умолчанию,
        "net-type": "тип-данных-для-Нейтрона",
        "active": true / false
    }
}
```

Для ```net-type``` типы можно найти [тут](https://xertis.github.io/Neutron-Server/api/libraries/messages.html). По умолчанию ```net-type = "uint8"``` (Можно не указывать).

Через ```active``` можно включать/отлючать статы.

>[!IMPORTANT]
>Так же можно перезаписывать ```default```или вовсе включать/отлючать статы из других контент-паков.

>[!WARNING]
>Не прописывайте ```active = false``` для ```is_dead```, ```max_hp```, ```hp```, ```max_oxygen```, ```oxygen```, ```max_hunger``` и ```hunger```. Ну пожалуйста. Иначе всё сломается.

*Все примеры можно посмотреть в ```newgen:config/newgen_stats.json```.*

[Назад](main_page.md)