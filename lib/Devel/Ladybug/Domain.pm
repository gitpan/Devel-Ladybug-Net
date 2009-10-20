#
# File: lib/Devel/Ladybug/Domain.pm
#
# Copyright (c) 2009 TiVo Inc.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Common Public License v1.0
# which accompanies this distribution, and is available at
# http://opensource.org/licenses/cpl1.0.txt
#

package Devel::Ladybug::Domain;

use strict;
use warnings;

use Devel::Ladybug::Class qw| true false |;

use Data::Validate::Domain;

use base qw| Devel::Ladybug::Str |;

use constant AssertFailureMessage =>
  "Received value is not a domain name";

sub assert {
  my $class = shift;
  my @rules = @_;

  my %parsed = Devel::Ladybug::Type::__parseTypeArgs(
    sub {
      Data::Validate::Domain::is_domain("$_[0]")
        || throw Devel::Ladybug::AssertFailed(AssertFailureMessage);
    },
    @rules
  );

  $parsed{columnType} ||= 'VARCHAR(512)';

  return $class->__assertClass()->new(%parsed);
}

sub new {
  my $class  = shift;
  my $string = shift;

  Data::Validate::Domain::is_domain("$string")
    || throw Devel::Ladybug::AssertFailed(AssertFailureMessage);

  my $self = $class->SUPER::new($string);

  return bless $self, $class;
}

true;

__END__

=pod

=head1 NAME

Devel::Ladybug::Domain - Fully qualified domain name object

=head1 SYNOPSIS

  use Devel::Ladybug::Domain;

  #
  # A fully qualified domain name
  #
  my $domain = Devel::Ladybug::Domain->new("example.com");

=head1 DESCRIPTION

Domain name object.

Extends L<Devel::Ladybug::Str>. Uses L<Data::Validate::Domain> to
verify input.

=head1 PUBLIC CLASS METHODS

=over 4

=item * C<assert(Devel::Ladybug::Class $class: *@rules)>

Returns a new Devel::Ladybug::Type::Domain instance which encapsulates
the received L<Devel::Ladybug::Subtype> rules.

  create "YourApp::Example::" => {
    someAddr  => Devel::Ladybug::Domain->assert(
      subtype(
        optional => true
      )
    ),

    # ...
  };

=item * C<new(Devel::Ladybug::Class $class: Str $addr)>

Returns a new Devel::Ladybug::Domain instance which encapsulates the
received value.

  my $object = Devel::Ladybug::Domain->new($addr);

=back

=head1 SEE ALSO

L<Devel::Ladybug::Str>, L<Data::Validate::Domain>

This file is part of L<Devel::Ladybug::Net>.

=cut
