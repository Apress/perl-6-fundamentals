use v6;

# function to be tested
sub doublespeak($x) {
    say $x ~ $x;
}

use Test;
plan 1;

my class OutputCapture {
    has @!lines;
    method print(\s) {
        @!lines.push(s);
    }
    method captured() {
        @!lines.join;
    }
}

my $output = do {
    my $*OUT = OutputCapture.new;
    doublespeak(42);
    $*OUT.captured;
};

is $output, "4242\n", 'doublespeak works';

