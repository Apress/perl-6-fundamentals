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

my @dates = %dates.keys.sort;
$subplots.plot:
    $[@dates.map(&pydate)],
    $[ %dates{@dates} ],
    label     => 'Total',
    marker    => '.',
    linestyle => '';

for @top-authors -> $author {
    my @dates = %by-author{$author}.keys.sort;
    my @counts = %by-author{$author}{@dates};
    $subplots.plot:
        $[ @dates.map(&pydate) ],
        $@counts,
        label     => $author,
        marker    =>'.',
        linestyle => '';
}


$subplots.legend(loc=>'upper center', shadow=>True);

plot('title', 'Contributions per day');
plot('show');

