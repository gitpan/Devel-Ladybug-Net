#
# File: lib/Devel/Ladybug/Net.pm
#
# Copyright (c) 2009 TiVo Inc.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Common Public License v1.0
# which accompanies this distribution, and is available at
# http://opensource.org/licenses/cpl1.0.txt
#

package Devel::Ladybug::Net;

our $VERSION = '0.399_003';

use strict;
use warnings;

use Devel::Ladybug::Domain;
use Devel::Ladybug::EmailAddr;
use Devel::Ladybug::IPv4Addr;
use Devel::Ladybug::Subnet;
use Devel::Ladybug::URI;

1;
__END__

=pod

=head1 NAME

Devel::Ladybug::Net - Network datatypes for L<Devel::Ladybug>

=head1 VERSION

This documentation is for version B<0.399_003> of Devel::Ladybug::Net.

=head1 SYNOPSIS

Load all network datatype packages:

  use Devel::Ladybug::Net;

...or load them as needed:

  # use Devel::Ladybug::Domain;
  # use Devel::Ladybug::EmailAddr;
  # use Devel::Ladybug::IPv4Addr;
  # use Devel::Ladybug::Subnet;
  # use Devel::Ladybug::URI;

=head1 DESCRIPTION

This package provides several assertable network-related datatypes for
L<Devel::Ladybug>.

All classes are overloaded.

=head1 TYPES

=over 4

=item * L<Devel::Ladybug::Domain> - Domain name

=item * L<Devel::Ladybug::EmailAddr> - Email address

=item * L<Devel::Ladybug::IPv4Addr> - IPv4 address

=item * L<Devel::Ladybug::Subnet> - CIDR-notation subnet string

=item * L<Devel::Ladybug::URI> - URI

=back

=head1 AUTHOR

  Alex Ayars <pause@nodekit.org>

=head1 COPYRIGHT

  File: lib/Devel/Ladybug/Net.pm
 
  Copyright (c) 2009 TiVo Inc.
 
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Common Public License v1.0
  which accompanies this distribution, and is available at
  http://opensource.org/licenses/cpl1.0.txt

=cut
