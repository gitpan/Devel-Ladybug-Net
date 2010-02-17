package Devel::Ladybug::Runtime;

our $Backends;

package main;

use strict;
use diagnostics;

use Test::More qw| no_plan |;

use File::Tempdir;

use constant false => 0;
use constant true  => 1;

use vars qw| $tempdir $path $nofs %classPrototype %instancePrototype |;

BEGIN {
  $tempdir = File::Tempdir->new;

  $path = $tempdir->name;

  if ( !-d $path ) {
    $nofs = "Couldn't find usable tempdir for testing";
  }
}

#####
##### Set up environment
#####

SKIP: {
  skip( $nofs, 2 ) if $nofs;

  require_ok("Devel::Ladybug::Runtime");
  ok( Devel::Ladybug::Runtime->import($path), 'setup environment' );

  use_ok("Devel::Ladybug::Net");
}

do {
  %classPrototype = (
    testDomain    => Devel::Ladybug::Domain->assert(),
    testEmailAddr => Devel::Ladybug::EmailAddr->assert(),
    testIPv4Addr  => Devel::Ladybug::IPv4Addr->assert(),
    testSubnet    => Devel::Ladybug::Subnet->assert(),
    testUri       => Devel::Ladybug::URI->assert(),
  );

  %instancePrototype = (
    testDomain    => "example.com",
    testEmailAddr => "root\@example.com",
    testIPv4Addr  => "127.0.0.1",
    testSubnet    => "10.0.0.0/24",
    testUri       => "http://www.example.com/",
  );
};

SKIP: {
  skip( $nofs, 2 ) if $nofs;

  my $class = "Devel::Ladybug::Net::YAMLTest";
  ok(
    testCreate(
      $class => {
        __useDbi       => false,
        __useFlatfile  => true,
        __useMemcached => 5,
        %classPrototype
      }
    ),
    "Class allocate"
  );

  kickClassTires($class);
}

#####
SKIP: {
  skip( $nofs, 2 ) if $nofs;

  my $class = "Devel::Ladybug::Net::JSONTest";
  ok(
    testCreate(
      $class => {
        __useDbi       => false,
        __useFlatfile  => 2,
        __useMemcached => 5,
        %classPrototype
      }
    ),
    "Class allocate"
  );

  kickClassTires($class);
}

#####
##### SQLite Tests
#####

SKIP: {
  if ($nofs) {
    skip( $nofs, 2 );
  } elsif ( !$Devel::Ladybug::Runtime::Backends->{"SQLite"} ) {
    my $reason = "DBD::SQLite is not supported on this system";

    skip( $reason, 2 );
  }

  my $class = "Devel::Ladybug::Net::SQLiteTest";
  ok(
    testCreate(
      $class => {
        __useDbi       => 2,
        __useMemcached => 5,
        %classPrototype
      }
    ),
    "Class allocate, table create"
  );

  kickClassTires($class);
}

SKIP: {
  if ($nofs) {
    skip( $nofs, 2 );
  } elsif ( !$Devel::Ladybug::Runtime::Backends->{"PostgreSQL"} ) {
    my $reason = "PostgreSQL is not supported on this system";

    skip( $reason, 2 );
  }

  my $class = "Devel::Ladybug::Net::PgTest";
  ok(
    testCreate(
      $class => {
        __useDbi       => 3,
        __useMemcached => 5,
        %classPrototype
      }
    ),
    "Class allocate, table create"
  );

  kickClassTires($class);
}

#####
##### MySQL/InnoDB Tests
#####

SKIP: {
  if ($nofs) {
    skip( $nofs, 2 );
  } elsif ( !$Devel::Ladybug::Runtime::Backends->{"MySQL"} ) {
    my $reason = "DBD::mysql not supported on this system or db not ready";

    skip( $reason, 2 );
  }

  my $class = "Devel::Ladybug::Net::MySQLTest";
  ok(
    testCreate(
      $class => {
        __useDbi       => 1,
        __useMemcached => 5,
        %classPrototype
      }
    ),
    "Class allocate, table create"
  );

  kickClassTires($class);
}

#####
#####
#####

sub kickClassTires {
  my $class = shift;

  return if $nofs;

  return if !UNIVERSAL::isa( $class, "Devel::Ladybug::Object" );

  if ( $class->__useDbi ) {

 #
 # Just in case there was already a table, make sure the schema is fresh
 #
    ok( $class->__dropTable, "Drop existing table" );

    ok( $class->__createTable, "Re-create table" );
  }

  my $asserts = $class->asserts;

  do {
    my $obj;
    isa_ok(
      $obj = $class->new(
        name => Devel::Ladybug::Utility::randstr(),
        %instancePrototype
      ),
      $class
    );
    ok( $obj->save,   "Save to backing store" );
    ok( $obj->exists, "Exists in backing store" );

    $asserts->each(
      sub {
        my $key  = shift;
        my $type = $asserts->{$key};

        isa_ok( $obj->{$key}, $type->objectClass,
          sprintf( '%s "%s"', $class->pretty($key), $obj->{$key} ) );
      }
    );
  };

  ok($class->count > 0, "Object count > 0");

  $class->each(
    sub {
      my $id = shift;

      my $obj;
      isa_ok( $obj = $class->load($id),
        $class, "Object retrieved from backing store" );

      $asserts->each(
        sub {
          my $key  = shift;
          my $type = $asserts->{$key};

          if ( exists $instancePrototype{$key} ) {
            ok(
              ( $obj->{$key} == $instancePrototype{$key} )
               && ( $obj->{$key} ne "Bogus Crap" )
               && ( $obj->{$key} ne [ "Bogus Crap" ] ),
              "$class: $key matches orig value"
            );
          }

          isa_ok( $obj->{$key}, $type->objectClass,
            sprintf( '%s "%s"', $class->pretty($key), $obj->{$key} ) );
        }
      );

      ok( $obj->remove, "Remove from backing store" );

      ok( !$obj->exists, "Object was removed" );
    }
  );

  if ( $class->__useDbi ) {
    ok( $class->__dropTable, "Drop table" );
  }
}

#
#
#
sub testCreate {
  my $class          = shift;
  my $classPrototype = shift;

  eval { Devel::Ladybug::create( $class, $classPrototype ); };

  return $class->isa($class);
}
