title: Кросс-компиляция Rust под Raspberry Pi в ArchLinux
lang: ru
tags: raspberry pi, rust, cross-compilation
extends: default.liquid
date: 13 Jun 2016 00:46:00 +0300
excerpt: |
    Намедни мне наконец-то приехала Raspberry Pi 3 на замену старому гудящему ноутбуку в качестве домашнего сервера.
    Поскольку вся серверная автоматизация была мной переписана на Rust, встала задача собрать всё это чудо
    под ARM. В качестве системы по-умолчанию у меня везде используется ArchLinux, Raspberry Pi не стала исключением.
---

Намедни мне наконец-то приехала [Raspberry Pi 3][rpi] на замену старому гудящему ноутбуку в качестве домашнего сервера.
Поскольку вся серверная автоматизация была мной [переписана на Rust][scripts], встала задача собрать всё это чудо
под ARM. В качестве системы по-умолчанию у меня везде используется [ArchLinux][arch], Raspberry Pi [не стала исключением][armarch].

[rpi]: https://www.raspberrypi.org/products/raspberry-pi-3-model-b/
[scripts]: https://github.com/kstep/rust-scripts
[arch]: https://www.archlinux.org/
[armarch]: https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3

Нагружать слабую малинку компиляцией под себя же я не стал, соответственно компилировать решено было на моём ноутбуке
(с арчем, само собой). Я перепробовал следующие способы:

* [Кросс-компиляция со средой в докере][1] — не взлетело, сборка контейнера постоянно валилась по самым разным причинам:
  то сеть отваливалась, то память кончалась. В итоге забил.
* [По мануалу][2] с [той же репы][3] — слишком искусственно, не хотелось ставить пакеты без PKGBUILD-ов и возиться
  со своими PKGBUILD-ами.
* В QEMU с [помощью эмуляции ARMv7][qemu] — ядро, похоже, протухло и устарело. При попытке загрузить с ним система
  в панике висла (`Attempted to kill init!`). Собирать это ядро ручками мне совсем не улыбалось, тем более что оригинальный
  сайт со всеми инструкциями давно умер (https://xecdesign.com/downloads/linux-qemu/kernel-qemu).
* [С помощью скрипта для ArchLinux][4] — и вот тут пошло повеселее. Этот способ сработал, хоть и было пару нюансов по ходу дела.

[1]: https://github.com/Ogeon/rust-on-raspberry-pi/blob/master/DOCKER.md
[2]: https://github.com/Ogeon/rust-on-raspberry-pi/blob/master/MANUAL.md
[3]: https://github.com/Ogeon/rust-on-raspberry-pi
[4]: https://github.com/tavianator/arch-rpi-cross
[qemu]: https://github.com/dhruvvyas90/qemu-rpi-kernel

Во-первых, многие пакеты (в частности разные GCC) подписаны PGP-ключами разработчиков. Проблема в том, что yaourt требует, чтобы
публичные части этих ключей были в локальном брелке пользователя и помеченные как доверенные, иначе ставить что-либо он отказывается.
И он прав. Можно было бы во всех PKGBUILD-ах вручную убрать PGP-сигнатуры, но пакетов очень много, можно подзадолбаться, да и не правильно
это, прямо скажем. В итоге я просто добавил нужные ключи себе в брелок и подписал их:

```bash
gpg --recv-keys 25EF0A436C2A4AFF
gpg --lsign 25EF0A436C2A4AFF

gpg --recv-keys 38DBBDC86092693E
gpg --lsign 38DBBDC86092693E

gpg --recv-keys 79BE3E4300411886
gpg --lsign 79BE3E4300411886
```

Возможно, что когда вы будете ставить эти пакеты, разработчики поменяют ключи, так что у вас сигнатуры будут отличаться.
Мне же понадобилось поставить именно эти ключики.

После этого всё поставилось как по маслу, только нужно было отвечать «да» на вопросы о замене пакетов по ходу установки
(`gcc-stage1` заменяется `gcc-stage2`, а тот, в свою очередь, заменяется `gcc`).

Во-вторых, мне понадобились дополнительные библиотеки под ARM, в частности libssl и libz, которые вместе с GCC не собираются.
Можно было бы их с сырцов собрать под ARM вручную, но я просто тупо скопировал все `*.so` и `*.a` файлы из `/usr/lib` самого
Raspberry Pi в мой тулчейн в `/usr/arm-linux-gnueabihf/lib` и закрыл этот вопрос.

В-третьих, нужно было настроить Cargo. Это просто, надо только в `~/.cargo/config` добавить такие строки:

```toml
[target.armv7-unknown-linux-gnueabihf]
linker = "arm-linux-gnueabihf-gcc"
ar = "arm-linux-gnueabihf-ar"

[target.arm-unknown-linux-gnueabihf]
linker = "arm-linux-gnueabihf-gcc"
ar = "arm-linux-gnueabihf-ar"
```

В принципе достаточно было бы описать конфиг только для `armv7-unknown-linux-gnueabihf`, потому что я пользовался только этим таргетом,
но я решил сделать всё основательно и на совесть.

В-четвёртых, надо поставить растовские таргет и тулчейн для ARMv7. Сделать это с [rustup][] до обидного просто:

```bash
rustup toolchain install stable-arm-unknown-linux-gnueabihf
rustup target add armv7-unknown-linux-gnueabihf
```

[rustup]: https://github.com/rust-lang-nursery/rustup.rs

Следующие грабли, на которые я наступил: в установленном этим способом тулчейне нет файла `arm-linux-gnueabihf-cc`,
а Rust в процессе компиляции нативных библиотек (вроде `openssl`, которая требуется куче пакетов) требует вызова `cc`.
Я решил эту проблему созданием симлинки:

```bash
cd /usr/bin
sudo ln -s arm-linux-gnueabihf-gcc arm-linux-gnueabihf-cc
```

После всех этих плясок я упёрся в такую ошибку:

```text
$ cd ~/git/scripts
$ cargo build --release --target armv7-unknown-linux-gnueabihf
   Compiling bitflags v0.5.0
   Compiling bitflags v0.4.0
   Compiling encoding_index_tests v0.1.4
   Compiling unicode-normalization v0.1.2
   Compiling num-traits v0.1.32
   ...

Build failed, waiting for other jobs to finish...
error: failed to run custom build command for `rust-crypto v0.2.35`
Process didn't exit successfully: `/home/kstep/git/scripts/target/debug/build/rust-crypto-ee392cda555c7573/build-script-build` (exit code: 101)
--- stdout
TARGET = Some("armv7-unknown-linux-gnueabihf")
OPT_LEVEL = Some("0")
PROFILE = Some("debug")
TARGET = Some("armv7-unknown-linux-gnueabihf")
debug=true opt-level=0
TARGET = Some("armv7-unknown-linux-gnueabihf")
HOST = Some("x86_64-unknown-linux-gnu")
CFLAGS_armv7-unknown-linux-gnueabihf = None
CFLAGS_armv7_unknown_linux_gnueabihf = None
TARGET_CFLAGS = None
CFLAGS = None
running: "cc" "-O0" "-ffunction-sections" "-fdata-sections" "-g" "-fPIC" "-march=armv7-a" "-o" "/home/kstep/git/scripts/target/armv7-unknown-linux-gnueabihf/de
bug/build/rust-crypto-ee392cda555c7573/out/src/util_helpers.o" "-c" "src/util_helpers.c"
ExitStatus(ExitStatus(256))


command did not execute successfully, got: exit code: 1



--- stderr
src/util_helpers.c:1:0: error: bad value (armv7-a) for -march= switch
 // Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or

thread '<main>' panicked at 'explicit panic', /home/kstep/.cargo/registry/src/github.com-88ac128001ac3a9a/gcc-0.3.27/src/lib.rs:834
note: Run with `RUST_BACKTRACE=1` for a backtrace.
```

Эта сволочь пытается вызвать не тот `cc`. Что ж, пришлось подсказать:

```text
$ CC=/usr/bin/arm-linux-gnueabihf-cc cargo build --release --target armv7-unknown-linux-gnueabihf
   Compiling xdg-basedir v1.0.0
   Compiling bitflags v0.3.3
   Compiling rust-crypto v0.2.35
   Compiling syntex_syntax v0.31.0
   ...
   Compiling scripts v0.0.1 (file:///home/kstep/git/scripts)
```

Ура! It's alive!

После этого «скрипты» были скопированы из `target/armv7-unknown-linux-gnueabihf/release` на мою новенькую малинку и заработали с ходу.

Занавес.


