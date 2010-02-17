#
# File: lib/Devel/Ladybug/EmailAddr.pm
#
# Copyright (c) 2009 TiVo Inc.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Common Public License v1.0
# which accompanies this distribution, and is available at
# http://opensource.org/licenses/cpl1.0.txt
#
package Devel::Ladybug::EmailAddr;

use strict;
use warnings;

use Devel::Ladybug::Class qw| true false |;

use Data::Validate::Email;
use Email::Address;

use base qw| Email::Address Devel::Ladybug::Array |;

use overload
  fallback => true,
  "eq" => sub {
    my $A = shift;
    my $B = shift;

    if ( !UNIVERSAL::isa($A, "Devel::Ladybug::EmailAddr") ) {
      $A = Devel::Ladybug::EmailAddr->new($A);
    }
    if ( !UNIVERSAL::isa($B, "Devel::Ladybug::EmailAddr") ) {
      $B = Devel::Ladybug::EmailAddr->new($B);
    }

    return ( "$A" eq "$B" );
  },
  "==" => sub { shift eq shift };

use constant AssertFailureMessage =>
  "Received value is not an email address";

sub assert {
  my $class = shift;
  my @rules = @_;

  my %parsed = Devel::Ladybug::Type::__parseTypeArgs(
    sub {
      my $self = shift;

      if ( !UNIVERSAL::isa( $self, "Devel::Ladybug::EmailAddr" ) ) {
        $self = $class->new($self);
      }

      Data::Validate::Email::is_email( "$self" )
        || throw Devel::Ladybug::AssertFailed(AssertFailureMessage);
    },
    @rules
  );

  $parsed{columnType} ||= 'VARCHAR(256)';

  return $class->__assertClass()->new(%parsed);
}

sub new {
  my $class      = shift;
  my @components = @_;

  if ( $components[0] && UNIVERSAL::isa($components[0],"ARRAY") ) {
    @components = @{ $components[0] };
  }

  my $self =
    ( @components > 1 )
    ? Email::Address->new(@components)
    : ( Email::Address->parse( $components[0] ) )[0];

  throw Devel::Ladybug::AssertFailed(AssertFailureMessage) if !$self;

  Data::Validate::Email::is_email( $self->address() )
    || throw Devel::Ladybug::AssertFailed(AssertFailureMessage);

  return bless $self, $class;
}

sub isa {
  my $class = shift;
  my $what  = shift;

  return false if $what eq 'Devel::Ladybug::Array';

  return UNIVERSAL::isa( $class, $what );
}

true;

__END__

=pod

=head1 NAME

Devel::Ladybug::EmailAddr - Overloaded RFC 2822 email address object

=head1 SYNOPSIS

  use Devel::Ladybug::EmailAddr;

  #
  # From address:
  #
  do {
    my $addr = Devel::Ladybug::EmailAddr->new('root@example.com');
  }

  #
  # From name and address:
  #
  do {
    my $addr = Devel::Ladybug::EmailAddr->new("Rewt", 'root@example.com');
  }

  #
  # From a formatted string:
  #
  do {
    my $addr = Devel::Ladybug::EmailAddr->new("Rewt <root@example.com>');
  }

=head1 DESCRIPTION

Extends L<Email::Address>, L<Devel::Ladybug::Array>. Uses
L<Data::Validate::Email> to verify input.

=head1 PUBLIC CLASS METHODS

=over 4

=item * C<assert(Devel::Ladybug::Class $class: *@rules)>

Returns a new Devel::Ladybug::Type::EmailAddr instance which
encapsulates the received L<Devel::Ladybug::Subtype> rules.

  create "YourApp::Example::" => {
    someAddr  => Devel::Ladybug::EmailAddr->assert(
      subtype(
        optional => true
      )
    ),

    # ...
  };

=item * C<new(Devel::Ladybug::Class $class: Str $addr)>

Returns a new Devel::Ladybug::EmailAddr instance which encapsulates the
received value.

  my $object = Devel::Ladybug::EmailAddr->new('root@example.com');

=back

=head1 SEE ALSO

See L<Email::Address> for RFC-related methods inherited by this class.

L<Devel::Ladybug::Array>, L<Data::Validate::Email>

This file is part of L<Devel::Ladybug::Net>.

=cut
