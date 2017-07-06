#!/usr/bin/env perl6

use SVG;

role Path {
    has $.name;
    has $.size;
    method total-size() { ... }
}


class File does Path {
}

class Directory does Path {
    has @.children;
    has $!total-size;
    method total-size() {
        $!total-size //= $.size + @.children.map(*.total-size).sum;
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

sub svg-tree-gen(:&color=&random-color, :&terminate!, :&base-height!, :&subdivide-x!, :&other!) {
    sub inner($tree, :$x1!, :$x2!, :$y1!, :$y2!) {
        return if terminate(:$x1, :$x2, :$y1, :$y2);
        take 'rect' => [
            x      => $x1,
            y      => $y1,
            width  => $x2 - $x1,
            height => base-height(:$y1, :$y2),
            style  => "fill:" ~ color(),
            title  => [$tree.name ~ ', ' ~ format-size($tree.total-size)],
        ];
        return if $tree ~~ File;
        if subdivide-x(:$x1, :$y1, :$x2, :$y2) {
            # split along the x-axis
            subdivide $tree, $x1, $x2, -> $child, $x1, $x2 {
                inner($child, :$x1, :$x2, :y1(other($y1)), :$y2);
            }
        }
        else {
            # split along the y-axis
            subdivide $tree, $y1, $y2, -> $child, $y1, $y2 {
                inner($child, :x1(other($x1)), :$x2, :$y1, :$y2);
            }
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

sub color-range(|) {
    state ($r, $g, $b) = (0, 240, 120);
    $r = ($r + 5) % 256;
    $g = ($g + 10) % 256;
    $b = ($b + 15) % 256;
    return "rgb($r,$g,$b)";
}


my &flame-graph = svg-tree-gen
    terminate   => -> :$y1, :$y2, | { $y1 > $y2 },
    base-height => -> | { 15 },
    subdivide-x => -> | { True },
    other       => -> $y1 { $y1 + 16 },
    color       => &color-range,
    ;

my &tree-map = svg-tree-gen
    terminate   => -> :$x1, :$y1, :$x2, :$y2 { ($x2 - $x1) * ($y2 - $y1) < 20 },
    base-height => -> :$y1, :$y2 {  $y2 - $y1 },
    subdivide-x => -> :$x1, :$x2, :$y1, :$y2 { $x2 - $x1 > $y2 - $y1 },
    other       => -> $a { $a },
    color       => &color-range,
    ;



sub random-color {
    return 'rgb(' ~ (1..3).map({ (^256).pick }).join(',') ~ ')';
}

enum GraphType <flame tree>;

sub MAIN($dir = '.', GraphType :$type=flame) {
    my $tree = tree($dir.IO);
    my $width = 1024;
    my $height = 768;
    my &grapher = $type == flame ?? &flame-graph !! &tree-map;
    say SVG.serialize(
        :svg[
            :$width,
            :$height,
            | do gather grapher $tree, x1 => 0, x2 => $width, y1 => 0, y2 => $height
        ]
    );

}

