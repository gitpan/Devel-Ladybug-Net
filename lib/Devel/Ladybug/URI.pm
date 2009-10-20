#
# File: lib/Devel/Ladybug/URI.pm
#
# Copyright (c) 2009 TiVo Inc.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Common Public License v1.0
# which accompanies this distribution, and is available at
# http://opensource.org/licenses/cpl1.0.txt
#
package Devel::Ladybug::URI;

use strict;
use warnings;

use Devel::Ladybug::Class qw| true false |;

use Data::Validate::URI;

use base qw| Devel::Ladybug::Str |;

use constant AssertFailureMessage => "Received value is not a URI";

sub assert {
  my $class = shift;
  my @rules = @_;

  my %parsed = Devel::Ladybug::Type::__parseTypeArgs(
    sub {
      Data::Validate::URI::is_uri("$_[0]")
        || throw Devel::Ladybug::AssertFailed(AssertFailureMessage);
    },
    @rules
  );

  $parsed{columnType} ||= 'VARCHAR(256)';

  return $class->__assertClass()->new(%parsed);
}

sub new {
  my $class  = shift;
  my $string = shift;

  Data::Validate::URI::is_uri($string)
    || throw Devel::Ladybug::AssertFailed(AssertFailureMessage);

  my $self = $class->SUPER::new($string);

  return bless $self, $class;
}

true;

__END__

=pod

=head1 NAME

Devel::Ladybug::URI - Overloaded URI object class

=head1 SYNOPSIS

  use Devel::Ladybug::URI;

  my $addr = Devel::Ladybug::URI->new("http://www.example.com/");

=head1 DESCRIPTION

Extends L<Devel::Ladybug::Str>. Uses L<Data::Validate::URI> to verify
input.

=head1 PUBLIC CLASS METHODS

=over 4

=item * C<assert(Devel::Ladybug::Class $class: *@rules)>

Returns a new Devel::Ladybug::Type::URI instance which encapsulates the
received L<Devel::Ladybug::Subtype> rules.

  create "YourApp::Example::" => {
    someAddr  => Devel::Ladybug::URI->assert(...),

    # ...
  };

=item * C<new(Devel::Ladybug::Class $class: Str $addr)>

Returns a new Devel::Ladybug::URI instance which encapsulates the
received value.

  my $object = Devel::Ladybug::URI->new($addr);

=back

=head1 SEE ALSO

L<URI>, L<Devel::Ladybug::Str>, L<Data::Validate::URI>

This file is part of L<Devel::Ladybug::Net>.

=cut
