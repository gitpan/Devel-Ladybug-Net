#
# File: lib/Devel/Ladybug/IPv4Addr.pm
#
# Copyright (c) 2009 TiVo Inc.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Common Public License v1.0
# which accompanies this distribution, and is available at
# http://opensource.org/licenses/cpl1.0.txt
#
package Devel::Ladybug::IPv4Addr;

use strict;
use warnings;

use Devel::Ladybug::Class qw| true false |;

use Data::Validate::IP;

use base qw| Devel::Ladybug::Str |;

use constant AssertFailureMessage =>
  "Received value is not an IPv4 address";

sub assert {
  my $class = shift;
  my @rules = @_;

  my %parsed = Devel::Ladybug::Type::__parseTypeArgs(
    sub {
      Data::Validate::IP::is_ipv4("$_[0]")
        || throw Devel::Ladybug::AssertFailed(AssertFailureMessage);
    },
    @rules
  );

  $parsed{columnType} ||= 'VARCHAR(15)';

  return $class->__assertClass()->new(%parsed);
}

sub new {
  my $class  = shift;
  my $string = shift;

  Data::Validate::IP::is_ipv4("$string")
    || throw Devel::Ladybug::AssertFailed(AssertFailureMessage);

  my $self = $class->SUPER::new($string);

  return bless $self, $class;
}

true;

__END__

=pod

=head1 NAME

Devel::Ladybug::IPv4Addr - Overloaded IPv4 address object class

=head1 SYNOPSIS

  use Devel::Ladybug::IPv4Addr;

  my $addr = Devel::Ladybug::IPv4Addr->new("127.0.0.1");

=head1 DESCRIPTION

Extends L<Devel::Ladybug::Str>. Uses L<Data::Validate::IP> to verify
input.

=head1 PUBLIC CLASS METHODS

=over 4

=item * C<assert(Devel::Ladybug::Class $class: *@rules)>

Returns a new Devel::Ladybug::Type::IPv4Addr instance which
encapsulates the received L<Devel::Ladybug::Subtype> rules.

  create "YourApp::Example::" => {
    someAddr  => Devel::Ladybug::IPv4Addr->assert( subtype(...) ),

    # ...
  };

=item * C<new(Devel::Ladybug::Class $class: Str $addr)>

Returns a new Devel::Ladybug::IPv4Addr instance which encapsulates the
received value.

  my $object = Devel::Ladybug::IPv4Addr->new($addr);

=back

=head1 SEE ALSO

L<Devel::Ladybug::Str>, L<Data::Validate::IP>

This file is part of L<Devel::Ladybug::Net>.

=cut
