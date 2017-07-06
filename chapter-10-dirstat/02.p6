use SVG;

class File {
    has $.name;
    has $.size;
    method total-size() { $.size }
}

class Directory {
    has $.name;
    has $.size;
    has @.children;
    has $!total-size;
    method total-size() {
        $!total-size //= $.size + @.children.map({.total-size}).sum;
    }
}

sub tree(IO::Path $path) {
    if $path.d {
        return Directory.new(
            name     => $path.basename,
            size     => $path.s,
            children => dir($path).map(&tree),
        );
    }
    else {
        return File.new(
            name => $path.Str,
            size => $path.s,
        );
    }
}

sub print-tree($tree, Int $indent = 0) {
    say ' ' x $indent, format-size($tree.total-size), '  ', $tree.name;
    if $tree ~~ Directory {
        print-tree($_, $indent + 2) for $tree.children
    }
}

sub format-size(Int $bytes) {
    my @units = flat '', <k M G T P>;
    my @steps = (1, { $_ * 1024 } ... *).head(6);
    for @steps.kv -> $idx, $step {
        my $in-unit = $bytes / $step;
        if $in-unit < 1024 {
            return sprintf '%.1f%s', $in-unit, @units[$idx];
        }
    }
}

sub tree-map($tree, :$x1!, :$x2!, :$y1!, :$y2) {
    # do not produce rectangles for small files/dirs
    return if ($x2 - $x1) * ($y2 - $y1) < 20;

    # produce a rectangle for the current file or dir
    take 'rect' => [
        x      => $x1,
        y      => $y1,
        width  => $x2 - $x1,
        height => $y2 - $y1,
        style  => "fill:" ~ random-color(),
        title  => [$tree.name],
    ];
    return if $tree ~~ File;

    if $x2 - $x1 > $y2 - $y1 {
        # split along the x-axis
        my $base = ($x2 - $x1) / $tree.total-size;
        my $new-x = $x1;
        for $tree.children -> $child {
            my $increment = $base * $child.total-size;
            tree-map(
                $child,
                x1 => $new-x,
                x2 => $new-x + $increment,
                :$y1,
                :$y2,
            );
            $new-x += $increment;
        }
    }
    else {
        # split along the y-axis
        my $base = ($y2 - $y1) / $tree.total-size;
        my $new-y = $y1;
        for $tree.children -> $child {
            my $increment = $base * $child.total-size;
            tree-map(
                $child,
                :$x1,
                :$x2,
                y1 => $new-y,
                y2 => $new-y + $increment,
            );
            $new-y += $increment;
        }
    }
}

sub random-color {
    return 'rgb(' ~ (1..3).map({ (^256).pick }).join(',') ~ ')';
}

sub MAIN($dir = '.') {
    my $tree = tree($dir.IO);
    use SVG;
    my $width = 1024;
    my $height = 768;
    say SVG.serialize(
        :svg[
            :$width,
            :$height,
            | gather tree-map $tree, x1 => 0, x2 => $width, y1 => 0, y2 => $height
        ]
    );
}

