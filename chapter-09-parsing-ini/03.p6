use v6;

grammar IniFile {
    token key     { \w+ }
    token value   { <!before \s> <-[\n;]>+ <!after \s> }
    token pair    { <key> \h* '=' \h* <value> \n+ }
    token header  { '[' <-[ \[ \] \n ]>+ ']' \n+ }
    token comment { ';' \N*\n+  }
    token block   { [<pair> | <comment>]* }
    token section { <header> <block> }
    token TOP     { <block> <section>* }
}



multi sub MAIN('test') {
    use Test;
    ok IniFile.parse('abc', :rule<key>), '<key> matches a simple identifier';
    nok IniFile.parse('[abc]', :rule<key>), '<key> does not match a section header';
    nok IniFile.parse("a\nb", :rule<value>), '<value> does not match \n';

    ok IniFile.parse("key=value\n", :rule<pair>), 'simple pair';
    ok IniFile.parse("key = value\n\n", :rule<pair>), 'pair with blanks';
    nok IniFile.parse("key\n= value\n", :rule<pair>), 'pair with newline before assignment';
    ok IniFile.parse("[abc]\n", :rule<header>), 'simple header';
    ok IniFile.parse("[a c]\n", :rule<header>), 'header with spaces';
    nok IniFile.parse("[a [b]]\n", :rule<header>), 'cannot nest headers';
    nok IniFile.parse("[a\nb]\n", :rule<header>), 'No newlines inside headers';

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

    ok IniFile.parse($ini), 'Can parse a full INI file';

    done-testing;
}
