use v6;

my $sudoku = '000000075000080094000500600010000200000900057006003040001000023080000006063240000';
$sudoku = $sudoku.trans('0' => ' ');

sub chunks(Str $s, Int $chars) {
    gather loop (my $idx = 0; $idx < $s.chars; $idx += $chars) {
        take substr($s, $idx, $chars);
    }
}

my $separator = '+---+---+---+';
my $index = 0;
for chunks($sudoku, 9) -> $line {
    if $index++ %% 3 {
        say $separator;
    }
    say '|', chunks($line, 3).join('|'), '|';
}
say $separator;

