---
layout: default
title: Блок try/finally в PHP
tags:
    - php
    - программинг
---

Несмотря на мою нелюбовь к PHP, время от времени приходится к нему возвращаться, испытывая при этом различные неудобства из-за отсутствия элементарных вещей.

С замыканиями в PHP, слава Б-гу, уже разобрались, а вот блоков `try/finally` до сих пор не видно (хотя вроде как [обещают][1] в 5.5, но до него дожить ещё надо).

Я не буду опускаться по обсуждения, нужен ли `finally`, это абсолютно пустые споры, которые ведут люди, никогда не писавшие ни на чём, кроме PHP, пытающиеся доказать превосходство своей платформы. Я же, следуя принципу «bottom-up» программирования и светлым заветам [МакКоннела][cc], реализовал свою версию блока `try/finally`.

Что я сделал, так это смешал принцип [RAII][] из С++ и использование замыканий из функционального программирования. Получился такой вот метр колючей проволоки:

{% highlight php %}
<?php
class ensure {

    public function __invokeStatic() {
        $args = func_get_args();
        $try = array_shift($args);
        return new self($try, $args);
    }

    private $state;
    private $error;
    public function __construct($try, $args) {
        try {
            $this->state = call_user_func_array($try, $args);

        } catch (Exception $e) {
            $this->error = $e;
        }
    }

    private $errorError;
    public function except($error, $callback) {
        if ($this->error and is_a($this->error, $error)) {
            $error = $this->error;
            $this->error = null;

            try {
                $callback($error);
            } catch (Exception $e) {
                $this->errorError = $e;
            }
        }

        return $this;
    }

    public function finally($callback) {
        $callback($this->state);
        $this->finish();
        return $this;
    }

    public function finish() {
        $error = false;
        if ($this->error) {
            $error = $this->error;
            $this->error = null;
        } elseif ($this->errorError) {
            $error = $this->errorError;
            $this->errorError = null;
        }

        if ($error) {
            throw $error;
        }

        return $this;
    }

    public function __destruct() {
        $this->finish();
    }
}
{% endhighlight %}

Что же мы получили в итоге? А получили мы фактически новую версию блока `try/catch/finally`, которую можно использовать вместо стандартного `try/catch`:

{% highlight php %}
<?php
ensure(function () {
    $fh = fopen("logfile.txt", "a");
    fwrite($fh, "Log data\n");
    return $fh;
})
->except('Exception', function ($e) {
    echo "Error happened: " . $e->getMessage();
})
->finally(function ($fh) {
    fclose($fh);
});
{% endhighlight %}

«Блок» `finally` будет выполнен всегда, в не зависимости от ошибок, произошедших в «блоке» `try`, «блоки» `catch` будут работать как обычно. Однако необработанные исключения, возникшие в блоках `try` и `catch`, никуда не потеряются и будут вызваны после выполнения `finally`.

Если же `finally` нет, то по идее нужно вызвать `finish()` в конце, но даже если программист забудет это сделать, то сработает принцип **RAII**, так что в худшем случае накопненные необработанные исключения выскочат в конце функции.

Кроме того с помощью этого же механизма можно передавать состояние обратки блока кода из одной функции в другую, но это уже совсем другая история.

[1]: http://habrahabr.ru/post/149314/
[cc]: http://www.stevemcconnell.com/cc.htm
[raii]: http://ru.wikipedia.org/wiki/RAII

<disqus name="kstep" />

