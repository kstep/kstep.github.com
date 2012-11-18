---
title: Pearlwall
layout: page 
---
use strict;
    
    package Pearlwall;
    use base 'Exporter';
    our @EXPORT = qw(iface port net mode oneof from to filter mangle nat raw flush with by user group marked list forwarding chain record on off);
    
    my $_table = '';
    my $_dry_run = 0;
    
    BEGIN {
    
        no strict 'refs';
    
        sub apply($)
        {
            my $command = "iptables -t $Pearlwall::_table $_[0]";
            if ($Pearlwall::_dry_run)
            {
                print "$command\\n";
            }
            else
            {
                system $command;
            }
        }
    
        sub list
        {
            print "Table $Pearlwall::_table:\\n";
            apply "-v -L " . ($_[0]||'');
            print "\\n";
        }
    
        sub parse_opts
        {
            my ($opts, $pfx) = @_;
            $pfx ||= '';
            return join(" ", map { my ($a, $b) = ($pfx.$_, $opts->{$_}); $a =~ s/_/-/g; "--$a " . ($b == 1? '': $b) } keys %{$opts});
        }
    
        my %bare_actions = qw(deny DROP allow ACCEPT mask MASQUERADE);
        my %opts_actions = qw(forbid REJECT mark MARK throw REDIRECT pass SNAT);
        while (my ($name, $action) = each(%bare_actions))
        {
            *{"main::$name"} = sub { apply "$_[0] $action"; return $_[0]; };
        }
        while (my ($name, $action) = each(%opts_actions))
        {
            *{"main::$name"} = sub { my $a = pop; apply "$a $action " . parse_opts({@_}) ; return $a; };
        }
        sub record
        {
            my $filter = pop;
            my $opts = parse_opts({@_}, 'log-');
            apply "$filter LOG $opts";
            return $filter; 
        }
    
        my %chain_names = qw(input INPUT output OUTPUT forward FORWARD before_route PREROUTING after_route POSTROUTING);
        while (my ($name, $chain) = each(%chain_names))
        {
            *{"main::$name"} = sub { return @_? " -A $chain ".join(" ", @_)." -j ": " -P $chain "; };
        }
        sub chain($;$)
        {
            my $chainname = shift;
            if (@_) {
                if ($_[0]) {
                    apply "-E $chainname $_[0]"; 
                } else {
                    apply "-X $chainname";
                }
            } else {
                apply "-N $chainname";
                bless sub { return @_? " -A $chainname ".join(" ", @_)." -j ": " -P $chainname "; }, $chainname;
            }
        }
    
        foreach my $proto (qw(tcp udp udplite icmp esp ah sctp all))
        {
            *{"main::$proto"} = sub { return Pearlwall::Inversible->new(" -p $proto "), @_; };
        }
    
        sub by($)
        {
            return " --reject-with $_[0] ";
        }
        sub with($)
        {
            return Pearlwall::MarkMask->new($_[0]);
        }
    
        sub flush(;$)
        {
            apply " -F " . ($_[0]||'');
        }
    
        sub iface($)
        {
            return Pearlwall::Iface->new($_[0]);
        }
        sub mode($)
        {
            my $mode = uc(shift);
            return Pearlwall::Inversible->new(" --state $mode ", " -m state ");
        }
        sub port($)
        {
            return Pearlwall::Port->new($_[0]);
        }
        sub net($)
        {
            return Pearlwall::Network->new($_[0]);
        }
        sub user($)
        {
            return Pearlwall::Inversible->new(" --uid-owner $_[0] ", " -m owner ");
        }
        sub group($)
        {
            return Pearlwall::Inversible->new(" --gid-owner $_[0] ", " -m owner ");
        }
        sub marked($)
        {
            return Pearlwall::Inversible->new(" --mark $_[0] ", " -m mark ");
        }
    
        sub oneof(@)
        {
            return join(',', @_);
        }
    
        sub from(@)
        {
            return join " ", map { UNIVERSAL::isa($_, 'Pearlwall::Object')? $_->from(): $_ } @_;
        }
        sub to(@)
        {
            return join " ", map { UNIVERSAL::isa($_, 'Pearlwall::Object')? $_->to(): $_ } @_;
        }
    
        sub filter(&)
        {
            local $Pearlwall::_table = 'filter';
            $_[0]->();
        }
        sub mangle(&)
        {
            local $Pearlwall::_table = 'mangle';
            $_[0]->();
        }
        sub nat(&)
        {
            local $Pearlwall::_table = 'nat';
            $_[0]->();
        }
        sub raw(&)
        {
            local $Pearlwall::_table = 'raw';
            $_[0]->();
        }
    
        sub forwarding($)
        {
            open my $fh, ">", "/proc/sys/net/ipv4/ip_forward";
            print $fh 0+(!!$_[0]);
            close $fh;
        }
    
        sub on()
        {
            return 1;
        }
        sub off()
        {
            return 0;
        }
    }
    
    1;
    
    package Pearlwall::Inversible;
    
    use overload
        '!' => sub {
            $_[0]->[1] = !$_[0]->[1];
            return $_[0];
        },
        '""' => sub {
            return $_[0]->[2] . ($_[0]->[1]? '!': '') . $_[0]->[0];
        };
    
    sub new
    {
        my $class = shift;
        my $self = [ shift, 0, shift||'' ];
        bless $self, $class;
    }
    
    1;
    
    package Pearlwall::Object;
    use base 'Pearlwall::Inversible';
    
    sub from
    {
        return $_[0]->[2] . ($_[0]->[1]? '!': '') . $_[0]->_from();
    }
    
    sub to
    {
        return $_[0]->[2] . ($_[0]->[1]? '!': '') . $_[0]->_to();
    }
    
    1;
    
    package Pearlwall::Iface;
    use base 'Pearlwall::Object';
    
    sub _from
    {
        return " -i $_[0]->[0] ";
    }
    
    sub _to
    {
        return " -o $_[0]->[0] ";
    }
    
    1;
    
    package Pearlwall::Port;
    use base 'Pearlwall::Object';
    
    sub _from
    {
        return " --sport $_[0]->[0] ";
    }
    
    sub _to
    {
        return " --dport $_[0]->[0] ";
    }
    
    1;
    
    package Pearlwall::Network;
    use base 'Pearlwall::Object';
    
    sub _from
    {
        return " -s $_[0]->[0] ";
    }
    
    sub _to
    {
        return " -d  $_[0]->[0] ";
    }
    
    1;
    
    package Pearlwall::MarkMask;
    
    use overload '""' => sub {
            return "$_[0]->[1] $_[0]->[0]$_[0]->[2]";
        },
        '/' => sub {
            $_[0]->[2] = "/$_[1]";
            return $_[0];
        },
        '|' => sub {
            $_[0]->[1] = 'set-mark';
            $_[0]->[2] = "/$_[1]";
            return $_[0];
        },
        '^' => sub {
            $_[0]->[1] = 'set-xmark';
            $_[0]->[2] = "/$_[1]";
            return $_[0];
        },
        '~' => sub {
            $_[0]->[1] = 'set-xmark';
            $_[0]->[2] = "";
            return $_[0];
        },
        '&' => sub {
            $_[0]->[0] = $_[1];
            $_[0]->[1] = 'and-mark';
            $_[0]->[2] = "";
            return $_[0];
        };
    
    sub new
    {
        my $class = shift;
        my $self = [ shift, 'set-mark', '' ];
        bless $self, $class;
    }
    
    1;
    
