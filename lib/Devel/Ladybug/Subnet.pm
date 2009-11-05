#
# File: lib/Devel/Ladybug/Subnet.pm
#
# Copyright (c) 2009 TiVo Inc.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Common Public License v1.0
# which accompanies this distribution, and is available at
# http://opensource.org/licenses/cpl1.0.txt
#
package Devel::Ladybug::Subnet;

use strict;
use warnings;

use Devel::Ladybug::Class qw| true false |;

use base qw| Devel::Ladybug::Str |;

use constant AssertFailureMessage =>
  "Received arg isn't in CIDR notation";

sub isSubnet {
  my $arg = shift;

  if ( $arg =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)\/(\d+)$/ ) {
    my @subnet = ( $1, $2, $3, $4, $5 );

    for my $i ( 0 .. 3 ) {
      return false if $subnet[$i] < 0;
      return false if $subnet[$i] > 255;
    }

    return false if $subnet[4] < 0;
    return false if $subnet[4] > 32;

    return true;
  } else {
    return false;
  }
}

sub assert {
  my $class = shift;
  my @rules = @_;

  my %parsed = Devel::Ladybug::Type::__parseTypeArgs(
    sub {
      isSubnet( $_[0] )
        || throw Devel::Ladybug::AssertFailed(AssertFailureMessage);
    },
    @rules
  );

  $parsed{columnType} ||= 'VARCHAR(18)';

  return $class->__assertClass()->new(%parsed);
}

sub new {
  my $class  = shift;
  my $string = shift;

  isSubnet($string)
    || throw Devel::Ladybug::AssertFailed(AssertFailureMessage);

  my $self = $class->SUPER::new($string);

  return bless $self, $class;
}

true;
__END__

=pod

=head1 NAME

Devel::Ladybug::Subnet - Overloaded Subnet object

=head1 SYNOPSIS

  use Devel::Ladybug::Subnet;

  my $addr = Devel::Ladybug::Subnet->new("10.0.0.0/24");

=head1 DESCRIPTION

Simple class to represent subnets as strings.

Extends L<Devel::Ladybug::Str>.

=head1 PUBLIC CLASS METHODS

=over 4

=item * $class->assert(@rules)

Returns a new Devel::Ladybug::Type::Subnet instance which encapsulates
the received L<Devel::Ladybug::Subtype> rules.

  create "YourApp::Example::" => {
    someAddr  => Devel::Ladybug::Subnet->assert( subtype(...) ),

    # ...
  };

=item * $class->new($addr);

Returns a new Devel::Ladybug::Subnet instance which encapsulates the
received value.

  my $subnet = Devel::Ladybug::Subnet->new("10.0.0.0/24");

=back

=head1 SEE ALSO

L<Devel::Ladybug::Str>, L<Devel::Ladybug::Array>.

This file is part of L<Devel::Ladybug::Net>.

=cut
