title: "Developers"
lang: en
date: 15 Jun 2011 00:00:00 +0300
extends: default.liquid
source: http://sokol-egor.blogspot.com.by/2009/12/blog-post.html
tags: humor, translation
comments: true
---
Any Russian developer after reading the new code for a couple of minutes will rise from his seat and yell, telling to himself: "We need to rewrite all this f**king code!" Then he will turn doubtful at the second thought of the time, this rewriting can take, and he will spend the rest of day, trying to convince himself it won't take too long. Just take some time to refactor this and that and he will have a nice and logically correct code.

The next morning Russian, fresh and content, will report to his manager: he needs a day to rewrite all the code. Yes, just a day and no more. Two days max if take into account all risks. The manager will give him a week, and six months later the task will be resolved. Until another Russian developer sees the code.

Meanwhile, in four other cubicles, four Chinese developers don't stop working for a minute. They manage to come to office earlier than Russian developer, leave office later and do about one-third of Russian developer's work. These fantastic four men don't write any new code for a long-long time, they just maintain old code, written by Indian developer and rewritten twice by two Russian developers. Bugs not just live there, no. There is their sweet nest. This nest replicates itself all the time, using best Chinese development method of code reuse - copy-and-paste. This way bugs crawl in all directions via static variables and variables passed by reference (Chinese developer can't resist the inconvenience of not being able to change external variables, passed into his function from modules, written by Russian developer).

When Russian developer remembers about this Chinese function, he loses the gift of English-speaking and starts to talk a strange mix of Russian and Chinese. He already rewritten this module, Chinese developers work on, in his daydreams, but he has no time to make this dream come true. Chinese developers have serious bugs in their to-do list, and managers know it and hurry them up all the time. Chinese developers pass these bugs to each other because they know: if they try to fix them, new even more severe bugs will appear. And they are right about it. There is only one man, who can tell how and where a static variable changes its value — the Indian developer. But he is in deep meditation.

That's why when all the four employees get fired... And who can be fired else, anyway? The Russian developer has not rewritten his module yet, Indian developer — the most valuable man in the company — takes very little attention to the project, but when he does, everybody understand — nobody knows software architecture better than he does. So, when four Chinese developers got fired, their code can take one of two fates. The first one — it's passed to Russian developers and will be rewritten. The second one — it will go to Canadian developer.

Oh, Canadian developer is a special case. Not giving a minute for doubt he will rush into attack like a White Knight, trying to track down and kill mighty Chinese Bug. This Bug lives in the module for three years, and Chinese developers already reported it fixed for four times (one time for each of developer), but it always comes back, like a Batman to his Gotham City. So, Canadian developer will do the thing, Chinese developers couldn't do for many years. Using his trustworthy debugger, he will track down the place, where the static variable got its value of -1 instead of correct 0 and will create a new variable with correct value by this place. The bug will die in this battle.

But the win will come with a great price. All project will crash, including module just rewritten by the Russian developer. This fact will put Russian developer into a deep depression for two days and after this time, he will make a very predictable conclusion: the overall design was incorrect, and *everything* must be rewritten from scratch. We need a week to accomplish this task. Yes, just a week, no more.

Brave Canadian developer will rush in, trying to fix everything, but everything will get worse (but who can tell it will?) All this hustle will make Indian developer leave his meditation, and he will give genius decision — branch the code out. According to him, the company will support two versions of the product: the one working with the Bug, and the other one crashing without the Bug. As this plan is proposed, the Russian developer will break his ruler over the table and swear at his wife at home, but won't say a word in opposition at the meeting.

Fortunately, it doesn't bother company's profit, because the product is sold well anyway. That's why managers are so content and don't stop telling developers, they are chosen as they are the best of the best. And they have already proven this fact, as they release their product at least sometimes.
