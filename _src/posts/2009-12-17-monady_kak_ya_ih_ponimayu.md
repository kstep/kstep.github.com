title: "Монады как я их понимаю"
lang: ru
date: 17 Dec 2009 00:00:00 +0200
extends: default.liquid
---
Проблема Хаскела (да и большинства других функциональных языков) в том, что в нём отсутствует такое понятие, как side-effect. Глобальных переменных нет как класса, а сохранять состояние между вызовами функций надо. Кроме того, будучи языком функциональным, а по сути описательным, а не императивным, функции в нём выполняются в неопределённом порядке, что поднимает ещё и задачу flow-control'а.

Вот из-за этого и пришлось вводить понятие монады. Монады нужны именно для контроля хода выполнения программы с сохранением и передачей общего состояние системы между вызовами различных функций.

В императивных языках большинство монадических операций (проход массива, контроль исключений, работа в потоком ввода-вывода) выполняется встроенными средствами языка и не требует введения понятия монады, но это не значит, что они совершенно бесполезны для императивного программиста. Как минимум знание монад расширяет сознание =), не говоря уже о том, что этот подход может рано или поздно пригодиться.

Теперь к конкретике. Монада определяет:

  1. способ хранения состояния системы между вызовами (контейнер, по сути описание класса),
  2. функцию для «подъёма» значения в монаду, по сути конструктор класса,
  3. функтор, определяющий стратегию вызова заданных функций: очерёдность и порядок передачи в них (и сбора из них) сохранённого в монаде состояния (так называемый функтор связывания, или стратегия связывания — binding), который связывает заданный инстанс монадического класса с заданной функцией, а на выходе имеет новый инстанс монадического класса. По сути он связывает инстанс монадического класса (первый свой параметр) с заданной фукнцией (второй свой параметр), при этом функции передаётся сохранённое в инстансе монадического класса значение (состояние), а результат выполнения функции должен быть приведён к тому же монадическому классу.

Пусть есть класс MonadContainer с конструктором mreturn(x). Тогда у него должен быть метод MonadContainer.mbind(func), который вызывает функцию func(x), а результатом своим либо берёт результат выполнения этой функции (тогда она должна возвращать значение с помощью MonadContainer.mreturn(x)), либо сам должен оборачивать результат выполнения func(x) в MonadContainer.mreturn() и возвращать его.

Математически получается, что монада как бы описывает некое поле значений, над которым определён заданный базовый набор действий и выполняются некоторые аксиомы:

  1. если поднять значение в монаду (и получить монадический инстанс), а затем применить стратегию связывания полученного инстанса с заданной функцией, то получим результат, эквивалентный вызову заданной функции с заданным значением в качестве параметра:

```ruby
m = MonadContainer.mreturn(123)
n1 = m.mbind do |x|
    x*2
end

n2 = MonadContainer.mreturn(123 * 2)

assert n1 == n2
```

  2. если взять инстанс монадического тип (класс) и применить к нему стратегию связывания с конструктором класса, то получим этот же инстанс:

```ruby
m = MonadContainer.mreturn(123)

n = m.mbind do |x|
    MonadContainer.mreturn(x)
end

assert m == n
```

  3. если взять монадический инстанс и применить к нему стратегию свзязываения с заданной функцией, а затем к результату ещё раз применить стратегию связывания с иной функцией, то результат будет эквивалентен вычислению первой заданной функции от изначально поднятого в монаду значения и применения к результату стратегии связывания с иной функцией:

```ruby
m = MonadContainer.mreturn(123)

n1 = m.mbind do |x|
    x*2
end.mbind do |x|
    x*3
end

n2 = m.mbind do |x|
    MonadContainer.mreturn(x*2).mbind do |x|
        x*3
    end
end

assert n1 == n2
```

С точки зрения простого программиста монада — это такой абстрактный тип данных (или класс в терминах ООП) с определённым интерфейсом, соответствующим вышеприведённым тест-кейсам.

Из 1 и 2 следует, что монадический тип должен полностью сохранять исходное значение при подъёме его в монаду (создании инстанса класса-контейнера), а применение стратегии связывания монады с конструктором монады должно приводить просто к вызову конструктора монады от сохранённого в монадическом типе значения.

Понятие монадического нуля аналогично понятию нуля в алгебре при условии что стратегия связывания аналогична умножению, то есть попытка связать монадический ноль с любой функцией приводит к получению монадического нуля. С точки зрения программиста монадический ноль — это просто пустое значение, т.е. 0 для чисел, пустая "" строка для строк или пустой массив [] для массивов.

```ruby
mz = MonadContainer.mzero
n = mz.mbind do |x|
    x*2
end

assert n == mz
```

Аддитивная монада определяет такое поле, над которым определена операция сложения, при этом любое сложение монады с монадическим нулём даёт в итоге эту монаду. Математики тут говорят о моноидах.

```ruby
mz = MonadContainer.mzero
m = MonadContainer.mreturn(123)
n = mz.mplus(m)

assert n == m
```
