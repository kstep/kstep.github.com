title: "Эксперименты над Питоном"
lang: ru
date: 10 Aug 2009 00:00:00 +0300
extends: default.liquid
---
Решил несколько систематизировать знания о классах-метаклассах в Питоне, а то совсем мозги сворачиваются.

Сначала немного теории. В Питоне **всё** является объектом. Класс — это тоже объект, класс объекта «класс» называется метакласс. То есть создание класса в Питоне точно такой же процесс, как и создание инстанса класса, т.к. класс по сути является инстансом метакласса.

Как происходит создание обычного инстанса:

  1. У класса вызывается специальный метод `__new__(cls)` с объектом-классом в качестве первого и единственного параметра. Этот метод **должен** вернуть инстанс класса. <del>Причём не обязательно нашего класса, может и другого, но это более сложный и редкий случай.</del> Таким образом `__new__(cls)` — это _истинный_ конструктор инстанса и не существует способа получить инстанс класса в обход `__new__()`.
  2. На этом свежем инстансе вызывается специальный метод `__init__(inst)`, который ничего не должен возвращать, а только инициализирует свежесозданный инстанс. <del>Строго говоря он и является конструктором класса, который как правило и надо определять, но есть ситуации, когда инстанс класса определяется в обход `__init__()`, например если `__new__()` вернул инстанс какого-то другого класса, а не нашего родного, но это опять же граничный случай, я его здесь не рассматриваю.</del>

Теперь меняем в последних двух абзацах слова «класс» и «инстанс» на «метакласс» и «класс» соответственно и получаем то, как рождаются классы в Питоне.

Но это ещё не всё! Есть такой замечательный специальный метод `__call__(self, *args, **kwds)`. Если он определён для объекта, то при попытке вызвать объект вызывается именно он, то есть:

```python
obj = SomeClass()
obj("Hello!")
```

На самом деле неявно вызывает метод инстанса `obj.__call__("Hello!")`

Добавляем ещё один питонофакт: оператор создания класса в Питоне по сути является оператором вызова функции. То есть когда мы делаем:

```python
obj = SomeClass()
```

Мы на самом деле вызываем метод `SomeClass.__call__()`, который вызывает `SomeClass.__new__(SomeClass)`, а потом `SomeClass.__init__(inst)`, где inst — результат выполнения `SomeClass.__new__()`. Это означает, что:

  1. если мы похерим `SomeClass.__call__(self)`, то у нас ничего больше работать не будет, инстанс класса мы создать не сможем,
  2. в качестве «класса» мы можем использовать не только собственно класс, но и вообще любую функцию, лишь бы она возвращала инстанс какого угодно класса.

То есть мы можем вообще переопределить всю логику объектной модели Питона, и при определённой сноровке нам за это ничего не будет.

Следующий вопрос, который возникает, это откуда берётся `SomeClass.__call__()`? Ведь это метод инстанса, то есть если определить его вот так:

```python
class SomeClass(object):
	def __call__(self):
```

то мы сможем перехватить вызов инстанса этого класса — `obj()` — но не самого `SomeClass()`. То есть чтобы перехватить вызов класса как функции, надо объявить метод `__call__()` в классе класса... В метаклассе.

Дальше привожу пример тестовой программки, которую я написал как раз для выяснения (и прояснения) этой всей крышесносящей байды:

```python
#!/usr/bin/python

class MetaClass(type):
	def __new__(cls, name, bases, dicts):
		print "meta __new__"
		return super(MetaClass, cls).__new__(cls, name, bases, dicts)
	def __init__(cls, name, bases, dicts):
		print "meta __init__ called"
		super(MetaClass, cls).__init__(name, bases, dicts)
	def __call__(self):
		print "meta __call__ called"
		return super(MetaClass, self).__call__()

class TestClass(object):
	__metaclass__ = MetaClass

	def __new__(cls):
		print "__new__ called"
		return super(TestClass, cls).__new__(cls)
	def __init__(self):
		print "__init__ called"
		super(TestClass, self).__init__()
	def __call__(self):
		print "__call__ called"

print "Program start..."
print "Instantiating TestClass..."
tclass = TestClass()
print "TestClass instantiated."
print tclass
print "Finishing program..."
```

На выходе она выдаёт следующее:

    meta __new__ called
    meta __init__ called
    Program start...
    Instantiating TestClass...
    meta __call__ called
    __new__ called
    __init__ called
    TestClass instantiated.
    <__main__.TestClass object at 0xb7cd7fcc>
    Finishing program...


При этом если заблокировать вызов `super(MetaClass, self).__call__()` в методе `MetaClass.__call__()`, то получим следующую картину:

    meta __new__ called
    meta __init__ called
    Program start...
    Instantiating TestClass...
    meta __call__ called
    TestClass instantiated.
    None
    Finishing program...


То есть инстанс класса вообще не создан, но ошибки не было, т.к. метод `__call__()` класса нашего класса вернул `None`, что и было принято как корректный инстанс нашего класса.

Отсюда следуют выводы:

  1. Классы в Питоне создаются практически динамически как инстансы метаклассов ещё до запуска основной программы.
  2. Создание классов как инстансов метаклассов происходит точно так же, как создание инстансов на основе классов.
  3. Руководит созданием инстансов/классов метод `__call__()` класса/метакласса на основе которого создаётся данный инстанс/класс, так что переопределив его мы можем полностью изменить логику создания инстансов/классов как нам заблагорассудиться (хотя делать это строго не рекомендуется).
  4. Однако сделать то же самое с метаклассами уже не получится: метаметаклассов уже нет. <del>Что вполне логично, а то можно совсем с ума сойти.</del>
  5. Сразу после описания класса в структуре `class ClassName(bases): ...` вызывается `cls = MetaClass.__new__(metacls, ClassName, bases, dict)`, а потом `MetaClass.__init__(cls, ClassName, bases, dict)`, и возвращает cls<del>, который есть класс, который по сути инстанс класса MetaClass</del>. Потом при создании инстанса класса ClassName вызывается `MetaClass.__call__()`, который вызвает `inst = ClassName.__new__(cls)` и `ClassName.__init__(inst, ...)`. Или короче:
  6. `MetaClass.__new__(cls)` и `MetaClass.__init__()` вызываются сразу после описания класса, `MetaClass.__call__()` вызывается при создании инстанса класса.
  7. Метод `__new__` является статическим методом, а не методом класса, поэтому ему всегда надо явно передавать класс создаваемого инстанса в качестве первого параметра.
  8. Самым корневым классом для классов является класс `object`, самым корневым метаклассом для метаклассов является `type`, класс `object` является по сути инстансом метакласса `type`.
  9. В качестве метакласса может быть использована любая функция (или вообще любая вызываемая структура), которая на входе принимает (classname, bases, dict), а на выходе отдаёт класс.
  10. Функция — это тоже объект, у которого определён метод `__call__()`, поэтому её и можно вызывать. <del>Впрочем, метод `__call__()` это тоже функция... У попа была собака...</del>

Ссылки по теме:

  - [http://dinsdale.python.org/download/releases/2.2.3/descrintro/#metaclasses](http://dinsdale.python.org/download/releases/2.2.3/descrintro/#metaclasses)
  - [http://www.ibm.com/developerworks/linux/library/l-pymeta.html](http://www.ibm.com/developerworks/linux/library/l-pymeta.html)
  - [http://dinsdale.python.org/dev/peps/pep-0253/](http://dinsdale.python.org/dev/peps/pep-0253/) (и дальше по ПЕПам)
