title: "Дебиан-пакет для libetc"
date: 2010-03-15
extends: default.liquid
tags:
  - "lib"
  - "debian"
  - "package"
  - "libetc"
  - "xdg"
  - "preload"
---
Вот прочител про замечательную либу [libetc](http://ordiluc.net/fs/libetc/) на [welinux-е](http://welinux.ru/post/2534/). Смысл её в том, что она, будучи запрелоадена внесением пути к ней в LD_PRELOAD, редиректит запросы к каталогофайлам ~/.* (где обычно конфиги) в $XDG_CONFIG_HOME/*, таким образом обеспечивая совместимость старых прог со стандартом XDG.

Там не всё гладко с общесистемными демонами и статически слинкованными прогами (подробнее см. ссылки выше), но в результате всё равно подавляющее большинство конфигов оказывается в одном каталге ~/.config, что вполне впечатляет. В частности домашний каталог становится чище и облегчаются бекапы конфигов.

Дебиановского пакета навскидку не нашёл, потому собрал свой. LD_PRELOAD, впрочем, придётся ставить самому, например в ~/.profile:

```bash
export LD_PRELOAD=/usr/lib/libetc.so.0
```

В /etc/profile (или куда-то туда) не рекомендуется, т.к. хрен его знает, как себя может повести какой-нить демон с этой либой при прелоаде.

Пакеты собирал впервые по манулам:

  - [http://www.debian.org/doc/manuals/maint-guide/ch-start.ru.html](http://www.debian.org/doc/manuals/maint-guide/ch-start.ru.html)
  - [http://welinux.ru/post/2497/](http://welinux.ru/post/2497/)

Так что сильно не бейте, лучше укажите на ошибки.

Сами пакеты:

  - [libetc1_0.4-1_i386.deb](../../../download/66)
  - [libetc-dev_0.4-1_i386.deb](../../../download/67)

Для amd64 от [digiwhite](http://welinux.ru/user/digiwhite) ([источник](http://welinux.ru/post/2534/#cmnt45573)):

  - [libetc_0.4-1_amd64.deb](../../../download/68)
