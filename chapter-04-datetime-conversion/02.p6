#!/usr/bin/env perl6
sub MAIN(Int $timestamp) {
    say DateTime.new(+$timestamp)
}
