use v6;

constant separator = '+---+---+---+';

sub MAIN($sudoku) {
    my $substituted = $sudoku.trans: '0' => ' ';

    for $substituted.comb(9) -> $line {
        say separator if $++ %% 3;
        say '|', $line.comb(3).join('|'), '|';
    }
    say separator;
}
