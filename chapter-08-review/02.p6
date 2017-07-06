sub random-choice() {
    Bool.pick;
}

# right way:
if random-choice() {
    say 'You were lucky.';
}

# # wrong way:
# if random-choice {
#     say 'You were lucky.';
# }

