title: "Как использовать emacs"
lang: ru
date: 30 Jun 2009 00:00:00 +0300
extends: default.liquid
---
First, you need to remember where emacs is, using the rm (remember) command:

    rm -f `which emacs`

Next, you need to tell the system that you want to use emacs in visual mode:

    alias emacs=vi

Now, you're all set to use emacs! To edit a file, just type

    emacs filename

I hope this information has been useful.
