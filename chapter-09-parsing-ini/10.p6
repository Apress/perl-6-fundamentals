use v6;
class IniFile::Actions {
    method key($/)     { make $/.Str }
    method value($/)   { make $/.Str }
    method pair($/)    { make $<key>.made => $<value>.made }
    method header($/)  { make $/[0].Str }
    method block($/)   { make $<pair>.map({ .made }).hash }
    method section($/) { make $<header>.made => $<block>.made }
    method TOP($/)     {
        make {
            _ => $<block>.made,
            $<section>.map: { .made },
        }
    }
}

grammar IniFile {
    token ws      { \h* }
    token key     { \w+ }
    token value   { <!before \s> <-[\n;]>+ <!after \s> }
    rule  pair    {
        <key>
        [ '=' || <expect('=')> ]
        [ <value> || <expect('value')> ]
        \n+
    }
    token header { '[' ~ ']' ( <-[ \[ \] \n ]>+ ) \n+ }
    token comment { ';' \N*\n+  }
    token block   { [<pair> | <comment>]* }
    token section { <header> <block> }
    token TOP     { <block> <section>* }

    method parse-ini(Str $input, :$rule = 'TOP') {
        my $m = self.parse($input,
            :actions(IniFile::Actions),
            :$rule,
        );
        say $m.perl;
        unless $m {
            die "The input is not a valid INI file.";
        }

        return $m.made
    }

    method FAILGOAL($goal) {
        my $cleaned-goal = $goal.trim;
        $cleaned-goal = $0 if $goal ~~ / \' (.+) \' /;
        self.error("Cannot find closing $cleaned-goal");
    }

    method expect($what) {
        self.error("expected $what");
    }

    method error($msg) {
        my $parsed-so-far = self.target.substr(0, self.pos);
        my @lines = $parsed-so-far.lines;
        die "Cannot parse input as INI file: $msg at line @lines.elems(), after '@lines[*-1]'";
    }
}

my $malformed-ini = q:to/EOI/;
key1=value2

[section1
EOI

say IniFile.parse-ini($malformed-ini).perl;
