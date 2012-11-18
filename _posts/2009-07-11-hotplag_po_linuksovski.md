---
title: Хотплаг по линуксовски
layout: page 
---
Купил [Wacom Bamboo](http://www.wacom.eu/index2.asp?lang=ru&pid=220) (всегда мечтал о маленьком планшетике чтоб можно было быстро набросать заметку-рисунок и наконец-то избавиться от стопки бумаги на столе). Установка на мою Дебиань была очень проста:

  1. Поставить пару пакетов: 
    
    $ sudo apt-get install wacom-tools xserver-xorg-input-wacom

  2. Настроить иксы в /etc/X11/xorg.conf: 
    
    Section "ServerLayout"
        Identifier     "Layout0"
        Screen      0  "Screen0"
        InputDevice    "Keyboard0" "CoreKeyboard"
        InputDevice    "Mouse0" "CorePointer"
    
    	InputDevice "stylus" "SendCoreEvents"
    	InputDevice "eraser" "SendCoreEvents"
    	InputDevice "pad" "SendCoreEvents"
    EndSection
    
    Section "InputDevice"
    	Driver "wacom"
    	Identifier "stylus"
    	Option "Device" "/dev/input/wacom"
    	Option "Type" "stylus"
    	Option "USB" "on"
    	Option "PressCurve" "0,0,100,100"
    EndSection
    
    Section "InputDevice"
    	Driver "wacom"
    	Identifier "eraser"
    	Option "Device" "/dev/input/wacom"
    	Option "Type" "eraser"
    	Option "USB" "on"
    EndSection
    
    Section "InputDevice"
    	Driver "wacom"
    	Identifier "pad"
    	Option "Device" "/dev/input/wacom"
    	Option "Type" "pad"
    	Option "Mode" "relative"
    	Option "USB" "on"
    EndSection
    

  3. Настроить GIMP в Правка > Параметры > Устройтва ввода > Настроить дополнительные устройства ввода...

И всё вроде бы заработало... Но только если втыкать его **до** того, как запустились Иксы. Если воткнуть (или перевоткнуть, или погрузить комп в сон и разбудить) при уже работающих Иксах, то планшет начинает работать как вульгарная мышь. Хотплаг не обнаружен :( Но, как оказалось, он есть! Но чисто линуксовский. Решение [было найдено](http://linuxwacom.sourceforge.net/index.php/faq#HOTPLUG):

> [X Intput Device Hotplug](http://wiki.x.org/wiki/XInputHotplug) is not fullly supported at Xorg yet. But, Wacom X driver has implemented a workaround for those who have to unplug/replug the tablet while X is running. To make your tablet work without restarting X server, please switch your virtual terminals after replug your tablet. That is, press Ctrl + Alt + F1 together then release them (screen turns to console); and press Ctrl + Alt + F7 together then release them (screen returns back to normal).

Вот так вот: перевоткнул планшет, переключился на консоль и обратно, и получил полноценный хотплаг планшета в абсолютный режим.
