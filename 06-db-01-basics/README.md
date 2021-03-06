# Домашнее задание к занятию "6.1. Типы и структура СУБД"

## Задача 1

Архитектор ПО решил проконсультироваться у вас, какой тип БД 
лучше выбрать для хранения определенных данных.

Он вам предоставил следующие типы сущностей, которые нужно будет хранить в БД:

- Электронные чеки в json виде  
  ``Документо-ориентированная, например Mongo. Не нужно обрабатывать, можно хранить целиком``
- Склады и автомобильные дороги для логистической компании  
  ``Если с дорогами - тогда графовая, "задача коммивояжера" и другая аналитика``
- Генеалогические деревья  
  ``Сетевая, можно отслеживать иерархию и тип связи между узлами ``
- Кэш идентификаторов клиентов с ограниченным временем жизни для движка аутенфикации  
  ``"Ключ-значение, которая хранит значения в памяти, например Redis - подходит по условиям``
- Отношения клиент-покупка для интернет-магазина  
  ``Реляционная SQL-база - нужны связи с разными таблицами, транзакции``

Выберите подходящие типы СУБД для каждой сущности и объясните свой выбор.

## Задача 2

Вы создали распределенное высоконагруженное приложение и хотите классифицировать его согласно 
CAP-теореме. Какой классификации по CAP-теореме соответствует ваша система, если 
(каждый пункт - это отдельная реализация вашей системы и для каждого пункта надо привести классификацию):

- Данные записываются на все узлы с задержкой до часа (асинхронная запись)  
  ``AP - узлы доступны, данные могут различаться``
- При сетевых сбоях, система может разделиться на 2 раздельных кластера  
  ``AP - то же самое, данные всегда доступны, но не гарантируется их целостность``
- Система может не прислать корректный ответ или сбросить соединение  
  ``CP - данные не всегда доступны``

А согласно PACELC-теореме, как бы вы классифицировали данные реализации?

```
1) PA/EL - если постоянная согласованность не важна, значит, может быть доступной и быстрой.  
2) Сложно сказать, неизвестно, что важнее в отсутствии разделения. PA/EL или PA/EC.  
3) CP/EC - согласование важнее доступности и задержек.
```

## Задача 3

Могут ли в одной системе сочетаться принципы BASE и ACID? Почему?  
``Не могут. При совместном доступе к данным неизбежно возникают противоречивые ситуации, каким образом
их разрешать, дает ли СУБД гарантии ACID, или нет - должно быть изначально определено.``

## Задача 4

Вам дали задачу написать системное решение, основой которого бы послужили:

- фиксация некоторых значений с временем жизни
- реакция на истечение таймаута

Вы слышали о key-value хранилище, которое имеет механизм [Pub/Sub](https://habr.com/ru/post/278237/). 
Что это за система? Какие минусы выбора данной системы?

``Redis - высокопроизводительная база данных типа key:value, может использоваться, как платформа pub/sub,
поддерживает ttl данных.  
Redis хранит данные в памяти, поэтому ограничена выделенным для этого объемом.``

---


