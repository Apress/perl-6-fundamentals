use v6;

my token key { \w+ }
my regex value { <!before \s> <-[ \n ; ]>+ <!after \s> }
my token pair { <key> \h* '=' \h* <value> \n+ }
my token header { '[' <-[ \[ \] \n ]>+ ']' \n+ }
my token comment { ';' \N*\n+ }

my token block   { [ <pair> | <comment> ]* }
my token section { <header> <block> }
my token inifile { <block> <section>* }


multi sub MAIN('test') {
    use Test;
    ok 'abc'    ~~ /^ <key> $/, '<key> matches a simple identifier';
    ok '[abc]' !~~ /^ <key> $/, '<key> does not match a section header';

    is ' abc ' ~~ /<value>/, 'abc', '<value> does not match leading or trailing whitespace';
    is ' a' ~~ /<value>/, 'a', '<value> matches single non-whitespace too';
    ok "a\nb" !~~ /^ <value> $/, '<value> does not match \n';

    ok "key=value\n" ~~ /<pair>/, 'simple pair';
    ok "key = value\n\n" ~~ /<pair>/, 'pair with blanks';
    ok "key\n= value\n" !~~ /<pair>/, 'pair with newline before assignment';

    ok "[abc]\n"    ~~ /^ <header> $/, 'simple header';
    ok "[a c]\n"    ~~ /^ <header> $/, 'header with spaces';
    ok "[a [b]]\n" !~~ /^ <header> $/, 'cannot nest headers';
    ok "[a\nb]\n"  !~~ /^ <header> $/, 'No newlines inside headers';

    my $ini = q:to/EOI/;
    key1=value2

    [section1]
    key2=value2
    key3 = with spaces
    ; comment lines start with a semicolon, and are
    ; ignored by the parser

    [section2]
    more=stuff
    EOI

    ok $ini ~~ /^<inifile>$/, 'Can parse a full INI file';


    done-testing;
}
