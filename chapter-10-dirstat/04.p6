#!/usr/bin/env perl6

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
        subdivide $tree, $x1, $x2, -> $child, $x1, $x2 {
            tree-map $child, :$x1, :$x2, :$y1, :$y2;
        }
    }
    else {
        # split along the y-axis
        subdivide $tree, $y1, $y2, -> $child, $y1, $y2 {
            tree-map $child, :$x1, :$x2, :$y1, :$y2;
        }
    }
}

sub subdivide($tree, $lower, $upper, &todo) {
    my $base = ($upper - $lower ) / $tree.total-size;
    my $var  = $lower;
    for $tree.children -> $child {
        my $incremented = $var + $base * $child.total-size;
        todo($child, $var, $incremented);
        $var = $incremented,
    }
}


sub flame-graph($tree, :$x1!, :$x2!, :$y!, :$height!) {
    return if $y >= $height;
    take 'rect' => [
        x      => $x1,
        y      => $y,
        width  => $x2 - $x1,
        height => 15,
        style  => "fill:" ~ random-color(),
        title  => [$tree.name ~ ', ' ~ format-size($tree.total-size)],
    ];
    return if $tree ~~ File;

    subdivide( $tree, $x1, $x2, -> $child, $x1, $x2 {
        flame-graph( $child, :$x1, :$x2, :y($y + 15), :$height );
    });
}


sub random-color {
    return 'rgb(' ~ (1..3).map({ (^256).pick }).join(',') ~ ')';
}

sub MAIN($dir = '.', :$type="flame") {
    my $tree = tree($dir.IO);
    use SVG;
    my $width = 1024;
    my $height = 768;
    my &grapher = $type eq 'flame'
            ?? { flame-graph $tree, x1 => 0, x2 => $width, y => 0, :$height }
            !! { tree-map    $tree, x1 => 0, x2 => $width, y1 => 0, y2 => $height }
    say SVG.serialize(
        :svg[
            :$width,
            :$height,
            | gather grapher()
        ]
    );
}

