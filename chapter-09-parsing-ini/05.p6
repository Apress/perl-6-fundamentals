use v6;

grammar IniFile {
    token ws      { \h* }
    token key     { \w+ }
    token value   { <!before \s> <-[\n;]>+ <!after \s> }
    rule  pair    { <key> '='  <value> \n+ }
    token header  { '[' ( <-[ \[ \] \n ]>+ ) ']' \n+ }
    token comment { ';' \N*\n+  }
    token block   { [<pair> | <comment>]* }
    token section { <header> <block> }
    token TOP     { <block> <section>* }
}

sub parse-ini(Str $input) {
    my $m = IniFile.parse($input);
    unless $m {
        die "The input is not a valid INI file.";
    }

    sub block(Match $m) {
        my %result;
        for $m<block><pair> -> $pair {
            %result{ $pair<key>.Str } = $pair<value>.Str;
        }
        return %result;
    }

    my %result;
    %result<_> = block($m);
    for $m<section> -> $section {
        %result{ $section<header>[0].Str } = block($section);
    }
    return %result;
}

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

say parse-ini($ini).perl;
