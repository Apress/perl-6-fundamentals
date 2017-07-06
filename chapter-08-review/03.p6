my class OutputCapture {
    has @.lines;
    method print(\s) {
        # the private name with ! still works
        @!lines.push(s);
    }
    method captured() {
        @!lines.join;
    }
}
my $c = OutputCapture.new;
$c.print('42');
# use the `lines` accessor method:
say $c.lines;       # Output: [42]

