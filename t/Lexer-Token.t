use strict;
use warnings;

use Test::More;
BEGIN { use_ok('Lexer::Token') }

#########################

# test for object creation
my $token = new_ok( 'Lexer::Token' =>  ['LABEL', qr##, sub {}, 1] );

# test for object type
isa_ok $token, 'Lexer::Token';

# test for object concistency
can_ok 'Lexer::Token', qw/label content pattern action skip/;

is $token->label,'LABEL';
is $token->skip, 1;

isa_ok  $token->pattern,'Regexp';   
isa_ok  $token->action, 'CODE';

done_testing();
