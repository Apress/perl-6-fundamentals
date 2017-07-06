#!/usr/bin/env perl6

sub MAIN(*@cmd) {
    my $proc = Proc::Async.new(|@cmd);
    my $collector = Channel.new;
    for $proc.stdout, $proc.stderr -> $supply {
        $supply.tap: { $collector.send($_) }
    }
    my $result = $proc.start.result;
    $collector.close;
    my $output = $collector.list.join;

    my $exitcode = $result.exitcode;
    if $exitcode != 0 {
        say "Program @cmd[] exited with code $exitcode";
        print "Output:\n", $output if $output;
    }
    exit $exitcode;
}
