#!/usr/bin/env perl6

sub from-timestamp(Int \timestamp) {
    sub formatter($_) {
        sprintf '%04d-%02d-%02d %02d:%02d:%02d',
                .year, .month,  .day,
                .hour, .minute, .second,
    }
    given DateTime.new(+timestamp, :&formatter) {
        when .Date.DateTime == $_ { return .Date }
        default { return $_ }
    }
}

sub from-date-string(Str $date, Str $time?) {
    my $d = Date.new($date);
    if $time {
        my ( $hour, $minute, $second ) = $time.split(':');
        return DateTime.new(date => $d, :$hour, :$minute, :$second);
    }
    else {
        return $d.DateTime;
    }
}

#| Convert timestamp to ISO date
multi sub MAIN(Int \timestamp) {
    say from-timestamp(+timestamp);
}

#| Convert ISO date to timestamp
multi sub MAIN(Str $date where { try Date.new($_) }, Str $time?) {
    say from-date-string($date, $time).posix;
}

#| Run internal tests
multi sub MAIN('test') {
    use Test;
    plan 2;
    subtest 'timestamp', {
        plan 2;
        is-deeply from-timestamp(1450915200), Date.new('2015-12-24'),
            'Date';;

        my $dt = from-timestamp(1450915201);
        is $dt, "2015-12-24 00:00:01",
            'DateTime with string formatting';
    };

    subtest 'from-date-string', {
        plan 2;
        is from-date-string('2015-12-24').posix, 1450915200,
            'one argument';
        is from-date-string('2015-12-24', '00:00:01').posix, 1450915201,
            'two arguments';
    };
}
