my $*SCHEDULER = ThreadPoolScheduler.new(:max_threads(3));

sub pi-approx($iterations) {
    my $inside = 0;
    for 1..$iterations {
        my $x = 1.rand;
        my $y = 1.rand;
        $inside++ if $x * $x + $y * $y <= 1;
    }
    return ($inside / $iterations) * 4;
}
my @approximations = (1..1000).map({ start pi-approx(80) });
await @approximations;

say @approximations.map({.result}).sum / @approximations;
