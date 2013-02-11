---
layout: default
title: Зачем нужно функциональное программирование? Зачем нужен Haskell?
tags:
    - переводы
    - realworldhaskell
---

### От переводчика ###

Недавно я решил всё-таки доучить Haskell, и после недолгих поисков нашёл
замечательную книгу [Real World Haskell][rwh]. Книга только на английском,
русский перевод найти не получилось. Лично мне всё равно, я английский знаю на
достаточном уровне, чтобы читать такую литературу, но уж больно книга хороша,
потому захотелось поделиться с русскоговорящей аудиторией. Кроме того в
процессе перевода лучше вникаешь в смысл текста, что тоже очень хорошо для меня
=)

Оригинал книги доступен онлайн бесплатно по лицензии [CC][license], либо под
заказ в печатном виде с Амазона или O'Reilly. Все подробности по ссылке выше.

В соответствии с лицензией я могу выложить перевод для всеобщего пользования
(при условиях бесплатности и сохранении ссылок на авторов), что я и делаю.

Все права на оригинал принадлежат авторам: **Bryan O'Sullivan, Don Stewart, and
John Goerzen**

Права на перевод оставляю за собой (см. копирайт в подвале страницы).

Перевод только начат, переведена лишь небольшая часть первой главы начерно,
текст будет вычитываться и правиться. Все пожелания и замечания можно оставлять
в комментариях к посту.

[rwh]: http://book.realworldhaskell.org/
[license]: http://creativecommons.org/licenses/by-nc/3.0/

---

## У нас к тебе предложение! ##

Haskell — очень обширный язык, и мы думаем, что его изучение даст вам очень
многое. Мы остановимся на трёх вещах (и сейчас объясним почему). Во-первых на
*новизне*: мы предлагаем рассмотреть программирование с иной очень ценной
стороны. Во-вторых на *силе языка*: мы покажем, как писать программы кратко,
быстро и надёжно. И напоследок, мы предлагаем просто *удовольствие* от
применения красивых техник программирования для решения реальных проблем.

### Новизна ###

Haskell скорее всего сильно отличается от любого известного вам языка. По
сравенению с обычным набором концепций из арсенала программиста, функциональное
программирование предлагает совершенно другой взгляд на ПО.

В Haskell-е мы отходим от кода, который модифицирует данные. Вместо этого в
центре внимания оказываются функции, принимающие неизменяемые значения на вход
и выдающие новые значения на выходе. При одних и тех же входных данных функция
возвращает один и тот же результат. Это и есть основная идея функционального
программирования.

Вместе с немодифицирующимися данными, наши программы на Haskell-е обычно не
общаются с внешним миром. Мы называем такие функции *чистыми*. Мы делаем явное
различие между чистым кодом и частями наших программ, которые читают и пишут в
файлы, работают с сетью или управляют роботами. Таким образом нам становится
легче организовать код, понять его и протестировать.

Мы отказываемся от некоторых, как кажется, фундаментальных основ, вроде цикла
`for`, встроенного в язык. У нас есть другие, более гибкие способы организации
повторяющихся задач.

Даже выражения в Haskell-е вычисляются по-другому. Мы откладываем каждое
вычисление до того момента, когда его результат действительно понадобиться:
Haskell — *ленивый* язык. *Ленивость* — не просто откладывание работы на потом,
она в корне меняет то, как пишутся программы.

### Сила языка ###

На протяжении всей книги мы покажем насколько альтернативные традиционным
языкам фичи Haskell-а мощные, гибкие и позволяют писать надёжный код. Haskell
огромное число самых передовых идей по созданию великолепных программ.

Поскольку чистый код не имеет дела с внешним миром, а данные, с которыми он
работает, никогда не изменяются, всякие неприятные сюрпризы, связанные с тем,
что один кусок кода незаметно подпортил данные, используемые другим куском
кода, очень и очень редки. Вне зависимости от контекста использования чистой
функции, она будет вести себя предсказуемо.

Чистый код проще тестировать, чем код, который общается с внешним миром. Когда
функция только отвечает на её невидимые входные данные, мы может очень просто
установить правила её поведения, которые будут всегда верными. Мы можем
автоматически протестировать и убедиться, что поведение функции сохраняется при
огромном потоке случайных входных данных, а когда наши тесты завершатся, мы
можем разрабатывать дальше. Мы по прежнему используем традиционные техники для
тестирования кода, который должен взаимодействовать с файлами, сетью или некими
экзотическими устройствами. Посколько не чистого кода в Haskell-е гораздо
меньше, чем в традиционных языках, мы более уверены в надёжности нашего ПО.

Ленивые вычисления порой дают странные эффекты. Скажем, мы хотим получить _k_
наименьших элемента из несортированного списка. В традиционном языке очевидным
подходом будет отсортировать список и взять _k_ первых элемента, но это слишком
накладно. Для эффективности нам придётся написать специальную функцию, которая
берёт эти значения из списка в один проход. Этой функции придётся поддерживать
не совсем тривиальный набор данных для отслеживания состояния перебора. В
Haskell-е подход «отсортировать-и-выбрать» работает прекрасно: благодаря
ленивости языка список будет отсортирован лишь настолько, чтобы найти _k_
минимальных элемента.

Что ещё лучше, наш код на Haskell-е, работающий так эффективно, очень краток и
использует только стандартные библиотечные функции.

{% highlight haskell %}
-- file: ch00/KMinima.hs
-- lines beginning with "--" are comments.

minima k xs = take k (sort xs)
{% endhighlight %}

---

Оригинал: <http://book.realworldhaskell.org/read/why-functional-programming-why-haskell.html>

<disqus name="kstep" />