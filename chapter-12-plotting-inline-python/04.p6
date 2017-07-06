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
my @bottom = $[] xx @top-authors;

my $py = Inline::Python.new;
sub gen(Str $namespace, *@names) {
    $py.run("import $namespace");

    return @names.map: -> $name {
        sub (|args) {
            $py.call($namespace, $name, |args);
        }
    }
}

my (&subplots, &bar, &legend, &title, &show)
    = gen('matplotlib.pyplot', <subplots bar legend title show>);

sub pydate(Str $d) {
    $py.call('datetime', 'date', $d.split('-').map(*.Int));
}

my ($figure, $subplots) = subplots();

for @dates -> $d {
    my $bottom = 0;
    for @top-authors.kv -> $idx, $author {
        @bottom[$idx].push: $bottom;
        my $value = %by-author{$author}{$d} // 0;
        @stack[$idx].push: $value;
        $bottom += $value;
    }
}

my $width = 1.0;
my @colors = <red green blue yellow black>;
my @plots;

for @top-authors.kv -> $idx, $author {
    @plots.push: bar(
        $[@dates.map(&pydate)],
        @stack[$idx],
        $width,
        bottom => @bottom[$idx],
        color => @colors[$idx],
        edgecolor => @colors[$idx],
    );
}
legend($@plots, $@top-authors);

title('Contributions per day');
show()

