use v6;

my $sudoku = '000000075000080094000500600010000200000900057006003040001000023080000006063240000';
$sudoku = $sudoku.trans('0' => ' ');

for 0..8 -> $line-number {
    say substr $sudoku, $line-number * 9, 9;
}

