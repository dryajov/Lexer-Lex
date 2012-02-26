package Lexer::Token;

######################################################
#
#    Package defines a Token class to be used by the
#    Lexer class to store matched tokens.
#
#    Author: DRyajov.
#
######################################################

use strict;
use Carp;

sub new {
	my $that = shift;
	my $class = ref($that) || $that;

	my ( $label, $pattern, $action, $skip ) = @_;
	croak "Label and Pattern are not optional\n" unless (@_);

	my $self = {
		label   => $label,
		pattern => $pattern,
		action  => $action
		  || undef,
		skip => $skip
		  || undef,    #special flag, controls if we want to skip this token
		content    => undef,
	};

	return bless( $self, $class );
}

sub label {
	my $self = shift;

	return $self->{label} unless (@_);
	my $old = $self->{label};
	$self->{label} = shift;

	return $old;
}

sub content {
	my $self = shift;

	return $self->{content} unless (@_);
	my $old = $self->{content};
	$self->{content} = shift;

	return $old;
}

sub pattern {
	my $self = shift;

	return $self->{pattern} unless (@_);
	my $old = $self->{pattern};
	$self->{pattern} = shift;

	return $old;
}

sub action {
	my $self = shift;

	return $self->{action} unless (@_);
	my $old = $self->{action};
	$self->{action} = shift;

	return $old;
}

sub skip {
	my $self = shift;

	return $self->{skip} unless (@_);
	my $old = $self->{skip};
	$self->{skip} = shift;

	return $old;
}

1;
