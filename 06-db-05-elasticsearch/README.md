# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.  


Dockerfile:  
```
FROM centos:7

RUN yum update -y && yum install -y wget && yum install -y perl-Digest-SHA

WORKDIR /tmp

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.2-linux-x86_64.tar.gz && \
 wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.2-linux-x86_64.tar.gz.sha512 && \
 shasum -a 512 -c elasticsearch-7.16.2-linux-x86_64.tar.gz.sha512 && \
 tar -C /usr/share -xzf elasticsearch-7.16.2-linux-x86_64.tar.gz

RUN echo "node.name: netology_test" >> /usr/share/elasticsearch-7.16.2/config/elasticsearch.yml && \
 echo "network.host: 0.0.0.0" >> /usr/share/elasticsearch-7.16.2/config/elasticsearch.yml && \
 echo "path.data: /var/lib" >> /usr/share/elasticsearch-7.16.2/config/elasticsearch.yml && \
 echo "discovery.type: single-node" >> /usr/share/elasticsearch-7.16.2/config/elasticsearch.yml &&\
 adduser elasticsearch && \
 mkdir /var/lib/nodes && \
 chown elasticsearch -R /usr/share/elasticsearch-7.16.2/ && \
 chown elasticsearch -R /var/lib/nodes/ && \
 usermod -aG root elasticsearch

USER elasticsearch

EXPOSE 9200

CMD /usr/share/elasticsearch-7.16.2/bin/elasticsearch
```  

Ссылка на образ: https://hub.docker.com/repository/docker/mikhail762/test65 

```json
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "1hlGDVXYRXWjzbfYltfF6w",
  "version" : {
    "number" : "7.16.2",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "2b937c44140b6559905130a8650c64dbd0879cfb",
    "build_date" : "2021-12-18T19:42:46.604893745Z",
    "build_snapshot" : false,
    "lucene_version" : "8.10.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.  


Индексы:
```json
green  open .geoip_databases idffIMG6ShWF9XAwfWUIRQ 1 0 43 0 40.1mb 40.1mb
green  open ind-1            3uX1MDxfSXib9qDltEk9tw 1 0  0 0   226b   226b
yellow open ind-3            hN9CDwuNRE-Xllh3kyayEQ 4 2  0 0   904b   904b
yellow open ind-2            BuCh7i7_Rr6f_IDEmojRpA 2 1  0 0   452b   452b
```  

Статус 'yellow' у индексов 2 и 3 потому, что объявлено больше реплик, чем существует нод.  

Состояние кластера:  
```json
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.
  
```json
vagrant@vagrant:~/test65$ curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch-7.16.2/snapshots"
  }
}'
{
  "acknowledged" : true
}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.  

```commandline
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases idffIMG6ShWF9XAwfWUIRQ   1   0         43            0     40.1mb         40.1mb
green  open   test             p5NixfJZQISwrwDRQWBdyw   1   0          0            0       226b           226b
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.  

```commandline
total 60
drwxr-xr-x 3 elasticsearch elasticsearch  4096 Jan  6 10:20 .
drwxr-xr-x 1 elasticsearch root           4096 Jan  6 09:33 ..
-rw-r--r-- 1 elasticsearch elasticsearch  1421 Jan  6 10:20 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Jan  6 10:20 index.latest
drwxr-xr-x 6 elasticsearch elasticsearch  4096 Jan  6 10:20 indices
-rw-r--r-- 1 elasticsearch elasticsearch 29163 Jan  6 10:20 meta-Qf-QCcdlROOFL1pcltmh6w.dat
-rw-r--r-- 1 elasticsearch elasticsearch   708 Jan  6 10:20 snap-Qf-QCcdlROOFL1pcltmh6w.dat

```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.  

```commandline
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases idffIMG6ShWF9XAwfWUIRQ   1   0         43            0     40.1mb         40.1mb
green  open   test-2           VHhu6dbDT0KOTTN7-qxKxA   1   0          0            0       226b           226b
```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее.   

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.  

```json
vagrant@vagrant:~/test65$ curl -X POST "localhost:9200/_snapshot/netology_backup/snapshot1/_restore?pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "test"
}'
{
  "accepted" : true
}
vagrant@vagrant:~/test65$ curl 'localhost:9200/_cat/indices?v&pretty'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases idffIMG6ShWF9XAwfWUIRQ   1   0         43            0     40.1mb         40.1mb
green  open   test-2           VHhu6dbDT0KOTTN7-qxKxA   1   0          0            0       226b           226b
green  open   test             gX9XxtzASQ6TaqL_CIkS1A   1   0          0            0       226b           226b

```

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
