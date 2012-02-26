package Lexer::Lex;

use 5.008008;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our $VERSION = '0.01';

use Lexer::Token;
use Carp;

use Data::Dumper;

#contructor
#
#params IN: 1 - ref to tokens array
#           2 - unmatched text function ref
#           3 - expresion terminator
#
#       OUT:1 - blessed ref
sub new {

	my $that     = shift;
	my $class    = ref($that) || $that;
	my $tokens   = shift;                 #ref to tokens list of arrays
	my $unmatch  = shift;
	my $fld_term = shift || "\n";

	my $self = {
		_source     => undef,
		_content    => undef,
		_last       => undef,
		_terminator => "$fld_term",
		_tokens     => undef,
		_unmatch    => new Lexer::Token( 'ERROR', '', $unmatch )
		,                                 #set default ERROR token
		_buf   => '',    #buffer with read chars
		_conds => {},    #active conditions
		_line  => 1,     #current line, line terminator is \n or \r\n
		DATA   => {},    #public memeber, can be used to pass data around
	};

	bless( $self, $class );

	#create token objects
	foreach my $token (@$tokens) {

		my $label = shift @$token;    #get label and check for conditions
		my ( $patt, $action, $skip ) = @$token;
		my $new_token = Lexer::Token->new( $label, $patt, $action, $skip );
		push( @{ $self->{_tokens} }, $new_token );

	}

	return $self;
}

#private funtion
#fills buf with chars up to
#next statment terminator
sub _read {
	my $self = shift;

	my $file     = $self->{_source};
	my $new_line = $self->{new_line};

	my $cur  = 0;
	my $char = undef;
	my $ret  = 1;

	# read in 1024 byte chunks
	if ( read( $file, $char, 1024 ) ) {
		$self->{_buf} .= $char;
	} elsif ( !length( $self->{_buf} ) ) {

		#delay EOF untill _buf is empty
		return Lexer::Token->new( 'EOF', '' );
	}

	#$self->{_buf} = shift @{ $self->{_content} };

	return 0;
}

#private function
#recognizes one lexime and returns
sub _lex {
	my $self = shift;

	my $buf    = \$self->{_buf};
	my $tokens = $self->{_tokens};

  TOKENS:
	foreach my $token ( @{$tokens} ) {
		unless ( length($$buf) ) {    #read if empty
			my $eof = $self->_read;
			if ($eof) {               #return eof token on end of file
				$self->{_last} = $eof;
				return $eof;
			}
		}

		if ( $token->{conditions} ) {
			next
			  unless ( $self->_check_cnds($token) );    #check conditions-
		}

		my $pattern = $token->pattern;    #get the pattern for the token-
		if ( $$buf =~ s/^$pattern//g ) {
			$token->{content} = $&;       #make token hold the match-
			$self->{_last}    = $token;
			my $action = $token->action;
			$action->($self) if $action;    #callback-

			$self->{_line} += $token->{content} =~ tr/\n/\n/;    # count lines

			goto TOKENS
			  if $token->skip;  # skip unvanted chars, restart the loop to match
			                    # next token from the beginning
			return $token;      # return matched token
		}
	}

	if ( length($$buf) ) {
		my $err = $self->{_unmatch};
		$err->content($$buf);
		my $action = $err->action;
		$action->($self) if $action;    #call error action if defined
		return $err;
	}
}

# turn token on
sub on {
	my $self  = shift;
	my $label = shift;

	$self->{_conds}->{$label} = 1;
}

# turn token off
sub off {
	my $self  = shift;
	my $label = shift;

	$self->{_conds}->{$label} = 0;
}

#public function
#initializes source file
#parameters  IN: 1 - file path or handle ref
#           OUT: --
sub from {
	my $self = shift;
	my $file = shift;

	croak "Usage: " . ref($self) . "->from(\$file) or file name\n"
	  unless defined $file;
	if ( !ref($file) && ref( \$file ) ne "GLOB" ) {
		require IO::File;
		$file = IO::File->new( $file, "r" )
		  || die "Unable to open file $file !\nError: $!\n";
	}

	$self->{_source} = $file;
}

sub loop {
	my $self = shift;

	while ( $self->token->label ne 'EOF' && $self->token->label ne 'ERROR' ) { }
}

#public function
#returns current token
sub token {
	my $self = shift;
	return $self->_lex;
}

#public function
#returns last matched token
sub last {
	my $self = shift;

	return $self->{_last} unless (@_);
	my $cur = $self->{_last};
	$self->{_last} = shift;
	return $cur;
}

sub unmatched {
	my $self = shift;

	return $self->{_unmatch}->content;
}

#public function
#returns last read line number
sub get_line {
	my $self = shift;
	return $self->{_line};
}

DESTROY {
	my $self = shift;
	close $self->{_source}
	  if defined $self->{_source};
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Lexer::Lex - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Lexer::Lex;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Lexer::Lex, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Dmitriy Ryajov, E<lt>dryajov@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Dmitriy Ryajov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
