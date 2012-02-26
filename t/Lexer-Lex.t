use strict;
use warnings;

use IO::Scalar;

use Test::More;
BEGIN { use_ok('Lexer::Lex') }

#########################

my $lex = new Lexer::Lex(
	[
		['TOKEN', qr/\w+/,
		sub {
	        return 1;
		},],
	    ['SPACES', qr/\s+?/]
    ]
);

isa_ok $lex, 'Lexer::Lex';

# buff for testing 
my $buf = << 'EOF';
Word Word1
EOF

$lex->from(IO::Scalar->new(\$buf));

my $token;

############################

# test first token
$token = $lex->token;

# test type
isa_ok $token, 'Lexer::Token';

# test for content
is $token->label,   'TOKEN';
is $token->content, 'Word';

############################

############################

# test spaces
$token = $lex->token;

# test type
isa_ok $token, 'Lexer::Token';

# test for content
is $token->label,   'SPACES';
like $token->content, qr/\s+/;

############################

############################

# test third token
$token = $lex->token;

# test type
isa_ok $token, 'Lexer::Token';

# test for content
is $token->label,   'TOKEN';
is $token->content, 'Word1';

############################

done_testing();
