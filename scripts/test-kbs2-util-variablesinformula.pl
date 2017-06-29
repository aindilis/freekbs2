#!/usr/bin/perl -w

use KBS2::Util;
use PerlLib::SwissArmyKnife;

my $res = ListVariablesInFormula(Formula =>  [ 'allTermAssertions', 'andrewDougherty', \*{'::?X'} ]);
print Dumper($res);
