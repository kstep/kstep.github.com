title: "Текущая ревизия/ветка git и svn в командной строке zsh"
date: 08 Jul 2009 00:00:00 +0300
extends: default.liquid
---
```bash
function vcs_head()
{
if [[ -d ./.svn ]]; then
    svn info | awk -v FS=": " '/URL:/ { url=$2 } /Repository Root:/ { baseurl=$2 } /Revision:/ { rev=$2 } END { branch = substr(url, length(baseurl) + 2); if (match(branch, /^(trunk|branches\\/[^\\/]+|tags\\/[^\\/]+)/) > 0) { branch = substr(branch, RSTART, RLENGTH) "-"; } else { branch = "" }; print "@" branch "r" rev }'
else
    gitref=`(git symbolic-ref HEAD || git rev-parse --short HEAD) 2> /dev/null | sed -e 's#refs/heads/##'`
    [[ -n $gitref ]] && echo -n "@$gitref"
fi
}

export PROMPT=$'%{\\e[1;32m%}%n@%{\\e[1;34m%}%m:%{\\e[1;35m%}%l%{\\e[1;31m%}%5(~.<.)%4~%{\\e[0;36m%}`vcs_head`%{\\e[0m%}%{\\e[1;36m%}%# %{\\e[0m%}'
```

Таким образом если мы в svn-чекауте то нам показывается текущая ветка и ревизия, а если в репозитории git-а, то показывается либо наша ветка/тег, либо (в случае отделённой ветки) хеш последнего коммита.
