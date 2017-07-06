use Inline::Python;

my $proc = run :out, <git log --date=short --pretty=format:%ad!%an>;
my (%total, %by-author, %dates);
for $proc.out.lines -> $line {
    my ( $date, $author ) = $line.split: '!', 2;
    %total{$author}++;
    %by-author{$author}{$date}++;
    %dates{$date}++;
}

my @top-authors = %total.sort(-*.value).head(5).map(*.key);

my @dates = %dates.keys.sort;
my @stack = $[] xx @top-authors;

for @dates -> $d {
    for @top-authors.kv -> $idx, $author {
        @stack[$idx].push: %by-author{$author}{$d} // 0;
    }
}


my $py = Inline::Python.new;
$py.run('import datetime');
$py.run('import matplotlib.pyplot');
sub plot(Str $name, |c) {
    $py.call('matplotlib.pyplot', $name, |c);
}

sub pydate(Str $d) {
    $py.call('datetime', 'date', $d.split('-').map(*.Int));
}

my ($figure, $subplots) = plot('subplots');
$figure.autofmt_xdate();

$subplots.stackplot($[@dates.map(&pydate)], @stack);
plot('title', 'Contributions per day');
plot('show');


