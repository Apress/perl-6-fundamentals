class ExecutionResult {
    has Int $.exitcode = -1;
    has Str $.output is required;
    has Bool $.timed-out = False;
    method is-success {
        !$.timed-out && $.exitcode == 0;
    }
}

sub run-with-timeout(@cmd, :$timeout, :$executer = Proc::Async) {
    my $proc = $executer.defined ?? $executer !! $executer.new(|@cmd);
    my $collector = Channel.new;
    for $proc.stdout, $proc.stderr -> $supply {
        $supply.tap: { $collector.send($_) }
    }
    my $promise = $proc.start;
    my $waitfor = $promise;
    $waitfor = Promise.anyof(Promise.in($timeout), $promise)
        if $timeout;
    $ = await $waitfor;

    $collector.close;
    my $output = $collector.list.join;

    if !$timeout || $promise.status ~~ Kept {
        say "No timeout";
        return ExecutionResult.new(
            :$output,
            :exitcode($promise.result.exitcode),
        );
    }
    else {
        $proc.kill;
        sleep 1 if $promise.status ~~ Planned;
        $proc.kill(9);
        $ = await $promise;
        return ExecutionResult.new(
            :$output,
            :timed-out,
        );
    }
}

multi sub MAIN(*@cmd, :$timeout) {
    my $result = run-with-timeout(@cmd, :$timeout);
    unless $result.is-success {
        say "Program @cmd[] ",
            $result.timed-out ?? "ran into a timeout"
                              !! "exited with code $result.exitcode()";

        print "Output:\n", $result.output if $result.output;
    }
    exit $result.exitcode // 2;
}

my class Mock::Proc::Async {
    has $.out = '';
    has $.err = '';
    method stdout {
        Supply.from-list($.out);
    }
    method stderr {
        Supply.from-list($.err);
    }
    method kill($?) {}
    has $.exitcode = 0;
    has $.execution-time = 1;
    method start {
        Promise.in($.execution-time).then({ 
            (class {
                has $.exitcode;
                method sink() {
                    die "mock Proc used in sink context";
                }
            
            }).new(:$.exitcode);
        });
    }
}

multi sub MAIN('test') {
    use Test;

    my class Mock::Proc::Async {
        has $.exitcode = 0;
        has $.execution-time = 0;
        has $.out = '';
        has $.err = '';
        method kill($?) {}
        method stdout {
            Supply.from-list($.out);
        }
        method stderr {
            Supply.from-list($.err);
        }
        method start {
            Promise.in($.execution-time).then({ 
                (class {
                    has $.exitcode;
                    method sink() {
                        die "mock Proc used in sink context";
                    }
                }).new(:$.exitcode);
            });
        }
    }

    # no timeout, success
    my $result = run-with-timeout([],
        timeout => 2,
        executer => Mock::Proc::Async.new(
            out => 'mocked output',
        ),
    );
    isa-ok $result, ExecutionResult;
    is $result.exitcode, 0, 'exit code';
    is $result.output, 'mocked output', 'output';
    ok $result.is-success, 'success';

    # timeout
    $result = run-with-timeout([],
        timeout => 0.1,
        executer => Mock::Proc::Async.new(
            execution-time => 1,
            out => 'mocked output',
        ),
    );
    isa-ok $result, ExecutionResult;
    is $result.output, 'mocked output', 'output';
    ok $result.timed-out, 'timeout reported';
    nok $result.is-success, 'success';
}

