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

sub MAIN($dir = '.') {
    print-tree(tree($dir.IO));
}


