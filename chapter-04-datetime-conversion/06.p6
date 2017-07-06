#!/usr/bin/env perl6
sub MAIN(Int $timestamp) {
    my $dt = DateTime.new(+$timestamp, formatter => sub ($o) {
            sprintf '%04d-%02d-%02d %02d:%02d:%02d',
                    $o.year, $o.month,  $o.day,
                    $o.hour, $o.minute, $o.second,
    });
    if $dt.Date.DateTime == $dt {
        say $dt.Date;
    }
    else {
        say $dt.Str;
    }
}
