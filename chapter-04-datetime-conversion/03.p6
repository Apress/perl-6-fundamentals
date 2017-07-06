#!/usr/bin/env perl6
sub MAIN(Int $timestamp) {
    my $dt = DateTime.new(+$timestamp);
    if $dt.hour == 0 && $dt.minute == 0 && $dt.second == 0 {
        say $dt.Date;
    }
    else {
        say $dt;
    }
}
