#!/usr/bin/env perl6
sub MAIN(Int $timestamp) {
    sub formatter($o) {
        sprintf '%04d-%02d-%02d %02d:%02d:%02d',
                $o.year, $o.month,  $o.day,
                $o.hour, $o.minute, $o.second,
    }
    my $dt = DateTime.new(+$timestamp, formatter => &formatter);
    if $dt.Date.DateTime == $dt {
        say $dt.Date;
    }
    else {
        say $dt.Str;
    }
}
