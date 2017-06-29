#!/usr/bin/perl -w

use KBS2::Util;
use PerlLib::SwissArmyKnife;

my $output = FormulaeToString
  (
   Type => 'Perl',
   Formulae => '#$isa',
  );
print $output."\n";
