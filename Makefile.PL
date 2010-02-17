use ExtUtils::MakeMaker;

my $prereqs = {
           Devel::Ladybug => 0.410,
   Data::Validate::Domain => 0.09,
    Data::Validate::Email => 0.04,
       Data::Validate::IP => 0.08,
      Data::Validate::URI => 0.05,
           Email::Address => 1.889,
            File::Tempdir => 0.02,

};

WriteMakefile(
  VERSION_FROM  => 'lib/Devel/Ladybug/Net.pm',
  NAME          => 'Devel::Ladybug::Net',
  PREREQ_PM     => $prereqs,
  LICENSE       => 'open_source',
  AUTHOR        => 'Alex Ayars <pause@nodekit.org>',
);
