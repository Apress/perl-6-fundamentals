grammar Foo {
    token x { x }
    token TOP { <x>* }
}

my $match = Foo.parse('');
say so $match;
say $match<x>.map(*.made);
