extends: default.liquid
lang: en
date: 22 Jun 2016 15:00:00 +0300
tags: raspberry pi, archlinux, bluetooth, mpd, pulseaudio
title: "Setup MPD with wireless Bluetooth speaker on Raspberry Pi 3"
---

As I [already wrote](2016-06-13-rust-cross-compile-for-raspberry-pi.html), I replaced
my old HP Pavilion dv6000 laptop with shiny new [Raspberry Pi 3][rpi3] as a home automation server.

It happens I also own [SRS-X33][srs] — small and nifty white wireless speaker.
(Yes, I favor wireless technologies a lot.)

One of tasks my old server accomplished was home music player based on [MPD][mpd],
so I decided to reimplement the same setup on Raspberry Pi. Unfortunately [bluez 5][bluez]
supports wireless audio devices via [Pulseaudio][pulse] only.
And to just make things more complex, Pulseaudio runs on user systemd instance only,
at least without additional dances and spell casting.

To make things clear, I like to keep system as close to vanilla system packages
configuration as possible, to make things upgrade with as little effort as possible.
So all custom config file changes are concentrated in a single place (`/etc`)
and usually don't overlap with default out-of-the-box configs.

So, here's the setup I ended up with:

* **mpd.service** is running as a system service…
* and connects to **pulseaudio.service**, running under *mpd* systemd user session…
* and registered with *module-bluetooth-discover* module in **bluetooth.service** (running as a system service).

Now to the concrete commands and config files.

At first, 


[rpi3]: https://www.raspberrypi.org/products/raspberry-pi-3-model-b/
[srs]: http://www.sony.com/electronics/wireless-speakers/srs-x33
