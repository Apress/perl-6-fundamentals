# Grapheme Clusters
my $s = "ø\c[COMBINING TILDE]";
say $s;         # Output: ø̃
say $s.chars;   # Output: 1

# Bytes
my $bytes = 'Perl 6'.encode('UTF-8');   # utf8:0x<50 65 72 6c 20 36>
$*OUT.write($bytes);

# Numbers
say ٤٢;             # 42
say "٤٢".Int;       # 42
say "\c[TIBETAN DIGIT HALF ZERO]".unival;

# Unicode Properties
say "ø".uniprop;                            # Ll
say "\c[TIBETAN DIGIT HALF ZERO]".uniprop;  # No

say "a".uniprop-bool('ASCII_Hex_Digit');    # True
say "ü".uniprop-bool('Numeric_Type');       # False
say ".".uniprop("Word_Break");              # MidNumLet

# Collation
my @list = <a ö ä Ä o ø>;
say @list.sort;                     # (a o Ä ä ö ø)

use experimental :collation;
say @list.collate;                  # (a ä Ä o ö ø)
$*COLLATION.set(:tertiary(False));
say @list.collate;                  # (a Ä ä o ö ø)

