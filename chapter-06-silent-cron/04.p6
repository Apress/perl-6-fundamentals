sub count-primes(Int $upto) {
    (1..$upto).grep(&is-prime).elems;
}

my $p1 = start count-primes 10_000;
my $p2 = $p1.then({ say .result });
await $p2;
