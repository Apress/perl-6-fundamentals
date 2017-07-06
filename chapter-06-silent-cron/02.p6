sub MAIN(*@cmd, :$timeout) {
    my $proc = Proc::Async.new(|@cmd);
    my $collector = Channel.new;
    for $proc.stdout, $proc.stderr -> $supply {
        $supply.tap: { $collector.send($_) }
    }
    my $promise = $proc.start;
    my $waitfor = $promise;
    $waitfor = Promise.anyof(Promise.in($timeout), $promise)
        if $timeout;
    await $waitfor;

    if !$timeout || $promise.status ~~ Kept {
        my $exitcode = $promise.result.exitcode;
        my $output = $collector.list.join;

        if $exitcode != 0 {
            say "Program @cmd[] exited with code $exitcode";
            print "Output:\n", $output if $output;
        }
        exit $exitcode;
    }
    else {
        $proc.kill;
        say "Program @cmd[] did not finish after $timeout seconds";
        sleep 1 if $promise.status ~~ Planned;
        $proc.kill(9);
        $ = await $promise;
        exit 2;
    }
}
