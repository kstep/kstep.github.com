---
title: Интеграция autofs с awesome: меню монтировния
layout: page 
---
Во-первых нам потребуется библиотека posix, т.к. иначе не проверить существования файла и его тип:
    
```lua
    assert(package.loadlib("/usr/lib/lua/5.1/posix.so", "luaopen_posix"))()
```

Ставиться она из пакета liblua5.1-posix1.

Дальше описываем такую функцию:
    
```lua
    function mounts_menu()
        local Automisc = '/etc/auto.misc'
        local Mounts = '/proc/mounts'
        local line
        
        local automisc = {}
        local stat
        for line in io.lines(Automisc) do
            if not (line:sub(1,1) == '#' or line:find("^%s*$")) then
                local dir, opts, dev = line:match("^(%S+)%s+(%S+)%s+(%S+)")
                if dev and dev:sub(1,1) == ':' then 
                    dev = dev:sub(2)
                    stat = posix.stat(dev)
                    if stat and stat.type == 'block device' then
                        automisc[dev] = dir
                    end
                end
            end
        end
    
        local mounts = {}
        local autofsdir
        for line in io.lines(Mounts) do
            local dev, dir, ft = line:match("^(%S+)%s+(%S+)%s+(%S+)")
            if ft == 'autofs' then autofsdir = dir end
            if automisc[dev] then
                mounts[dev] = dir
            end
        end
    
        local items = {}
        local dev, dir
        for dev, dir in pairs(automisc) do
            line = ("%s %s/%s\	\	%s"):format(mounts[dev] and "*" or " ", autofsdir, dir, dev)
            local func
            if mounts[dev] then
                func = function () os.execute("sudo umount "..autofsdir.."/"..dir) end
            else
                func = function () os.execute("ls "..autofsdir.."/"..dir) end
            end
    
            local item = { line, func }
            table.insert(items, item)
        end
    
        local menu = awful.menu.new({ items = items, width = 300 })
        return menu
    end
```

Возвращает она объект меню со списком доступных через autofs устройст, смонтированные устройства будут помечены звёздочкой. Использование:
    
```lua
    mounts_menu():show()
```

Работает с awesome v3.3.1-2-gd61ca1b (Bionic).

Тот же список, полученный с помощью perl:

```perl
    #!/usr/bin/perl
    
    use strict;
    
    my $AUTOMISC="/etc/auto.misc";
    my $MOUNTS="/proc/mounts";
    
    my %autofs = ();
    open FIN, '<', $AUTOMISC;
    while (<FIN>)
    {
        chomp;
        next if /^#/ or /^\\s*$/;
    
        my ($dir, $opts, $dev) = split /\\s+/;
        next unless $dev =~ /^:/;
        $dev = substr($dev, 1);
    
        next unless -b $dev;
        $autofs{$dev} = $dir;
    }
    close FIN;
    
    my %mounts = ();
    my $autofsdir;
    open FIN, '<', $MOUNTS;
    while (<FIN>)
    {
        chomp;
        my ($dev, $dir, $type) = split /\\s+/;
        $autofsdir = $dir if $type eq 'autofs';
        next unless exists $autofs{$dev};
        $mounts{$dev} = $dir;
    }
    close FIN;
    
    foreach my $dev (sort keys %autofs)
    {
        my $ismounted = exists $mounts{$dev};
        printf "%s\	%s/%s\	%s\\n", $ismounted? "*": " ", $autofsdir, $autofs{$dev}, $dev;
    }
```
