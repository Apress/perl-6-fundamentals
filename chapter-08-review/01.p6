sub chunks(Str $s, Int $chars) {
#         ^^^^^^^^^^^^^^^^^^^^ signature
#   ^^^^^^ name
    gather for 0 .. $s.chars / $chars - 1 -> $idx {
        take substr($s, $idx * $chars, $chars);
    }
}

say &chunks.name;       # Ouptput: chunks
say chunks 'abcd', 2;   # Ouptput: (ab cd)
say chunks('abcd', 2);  # Ouptput: (ab cd)

say chunks(join('x', 'ab', 'c'), 2);

# Errors:
# say chunks(join 'x', 'ab', 'c', 2);

say chunks join('x', 'ab', 'c'), 2;

