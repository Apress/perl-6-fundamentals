sub count-primes(Int $upto) {
    (1..$upto).grep(&is-prime).elems;
}

my $p = start count-primes 10_000;
say $p.status;
await $p;
say $p.result;

