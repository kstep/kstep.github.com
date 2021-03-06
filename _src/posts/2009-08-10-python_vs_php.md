title: "Python vs PHP: мама Анархия или?.."
lang: ru
date: 10 Aug 2009 00:00:00 +0300
extends: default.liquid
---
В связи с тем, что появился шанс всерьёз попробовать свои силы в Питоне, в срочном порядке перечитываю доки по оному. Долго вкуривал [фишку с метаклассами](http://www.python.org/download/releases/2.2/descrintro/#metaclasses). С одной фразой я согласен чуть более, чем полностью:

> In the past, the subject of metaclasses in Python has caused hairs to raise and even brains to explode.

Это действительно взрыв мозга. Кроме метаклассов меня в Питоне после ПХП порадовали:

  - возможность перегружать операторы типа сложения, вычитания, умножения и т.д., хотя и сделано это немного извращённо, ИМХО, по сравнению с C++ и Ruby,
  - множественное наследование,
  - нормальные свойства, к которым можно присобачивать методы-аксессоры и писать по-нормальному obj.prop = "value", а не obj.setProp("value"), как следствие возможность делать read-only свойства,
  - декораторы функций, благодаря которым язык можно расширять просто крышесносящими способами.

Однако есть вещи, которые в Питоне меня несколько напрягают, а именно:

  - необходимость явно передавать инстанс класса как первый аргумент метода (хотя в этом есть положительная сторона: его можно назвать не чётко зарезервированным именем типа $this, а в принципе как угодно, что есть + ещё одна степень свободы программиста, лишь бы она не переросла в расхлябанность и невнимательность, но это совсем другая история),
  - отсутствие нормального разграничения уровней доступа к свойствам и методам, т.е. нормальных private и protected нет (хотя private там и реализовано соглашением по именованию методов и классов — они должны начинаться на «\_\_» чтобы быть признанными приватными, но это очень просто обходиться, т.к. внутри эти методосвойства просто переименовываются в \_имяКласса\_\_имяМетодоСвойства, что порождает две проблемы: 1) в Питоне можно объявлять класс-потомок с тем же именем, что и класс предок, так что эти методы друг друга в итоге перекроют и будет кирдык, 2) приватность легко обходится прямым обращением к методам по этому хитрому имени; что же до protected, то его предлагается реализовать самому с помощью подручных средств, то есть метаклассов и декораторов... если при этом не произойдёт коллапс мозга программиста, конечно).

В общем даже после ПХП от Питона впечатления такие, что там стоит какая-то анархия. И это при том, что синтаксис языка построен так, что либо ты пишешь красиво, либо оно вообще не работает.

Итоговая мысль: Питон — воплощённая свобода программерской мысли в красивой одёжке. Но ей ещё надо научиться пользоваться, иначе рискуешь сам себе прострелить ногу. Или что похуже...
