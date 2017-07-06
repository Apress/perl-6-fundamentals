#!/usr/bin/env perl6

multi sub MAIN(Int $timestamp) {
    sub formatter($o) {
        sprintf '%04d-%02d-%02d %02d:%02d:%02d',
                $o.year, $o.month,  $o.day,
                $o.hour, $o.minute, $o.second,
    }
    my $dt = DateTime.new(+$timestamp, :&formatter);
    if $dt.Date.DateTime == $dt {
        say $dt.Date;
    }
    else {
        say $dt.Str;
    }
}

multi sub MAIN(Str $date where { try Date.new($_) }, Str $time?) {
    my $d = Date.new($date);
    if $time {
        my ( $hour, $minute, $second ) = $time.split(':');
        say DateTime.new(date => $d, :$hour, :$minute, :$second).posix;
    }
    else {
        say $d.DateTime.posix;
    }
}

