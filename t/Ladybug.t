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

  my $class = "Devel::LadybugNet_YAMLTest::YAMLTest01";
  ok(
    testCreate(
      $class => {
        __useDbi       => false,
        __useYaml      => true,
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
    my $reason = "DBD::SQLite is not installed";

    skip( $reason, 2 );
  }

  my $class = "LadybugNet_SQLiteTest::SQLiteTest01";
  ok(
    testCreate(
      $class => {
        __dbiType      => 1,
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
    my $reason = "DBD::mysql not installed or 'op' db not ready";

    skip( $reason, 2 );
  }

  my $class = "Devel::Ladybug::Net::MySQLTest01";
  ok(
    testCreate(
      $class => {
        __dbiType      => 0,
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

  $class->allIds->each(
    sub {
      my $id = shift;

      my $obj;
      isa_ok( $obj = $class->load($id),
        $class, "Object retrieved from backing store" );

      $asserts->each(
        sub {
          my $key  = shift;
          my $type = $asserts->{$key};

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
