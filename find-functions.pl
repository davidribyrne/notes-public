#!/usr/bin/perl
use strict;
my %args;
open (my $goodFh, '>/f/projects/ali/good');
my %primitives;
load();
main();
sub main
{
    my $text = `cat functions`;
    my $len=length($text);
    print "Read $len bytes\n";
    for my $line (split(/\n/, $text))
    {
        my $function = $line;
        $function =~ s/\@[a-zA-Z0-9_]+\s*(?:\([^\)]+\))?//g; # Remove annotations
        if ($function =~ /\((.*?)\)/)
        {
            next if $function =~ /[\<]/; # Generics may not work
            my $args = $1;
            next if ! $args;
            my $good = 1;
            my $string = 0;
            for my $arg(split(/,/, $args))
            {
                if ($arg =~ /^\s*(\S+)\s*(.+)\s*$/)
                {
                    my $type = $1;
                    my $name = $2;
                    $type =~ s/(\[.*\]|\.\.\.)//g;
                    if ($type eq 'String')
                    {
                        $string = 1;
                        $args{$name} = 1;
                    }
                    if (!exists($primitives{$type}))
                    {
                        $good = 0;
                        last;
                    }
                }
                else
                {
                    print "Failed to parse argument.\nFunction - $function\nargument - '$arg'\n\n\n";
                }
            }
            print $goodFh "$line\n" if $good && $string;
        }
    }

    open (my $argsFh, '>/f/projects/ali/args');
    for my $arg(keys (%args))
    {
        print $argsFh "$arg\n";
    }
}

sub load
{
    my @primitives = qw(boolean byte char short int long float double String);
    for my $p (@primitives)
    {
        $primitives{$p} = 1;
        my $p2 = uc(substr($p, 0, 1)) . substr($p, 1);
        $primitives{$p2} = 1;
        print $p2;
    }
}