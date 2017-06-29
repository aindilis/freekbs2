#!/usr/bin/perl -w

use Test::More no_plan;
use Test::Deep;

use Data::Dumper;

use_ok('KBS2::Util');

diag PerlDataStructureToStringEmacs
  (DataStructure => ["p", \*{'::?X'}, \*{'::?X'}]);

diag DumperQuote2
  (EmacsStringToFormulae
   (
    String => PerlDataStructureToStringEmacs
    (DataStructure => ["p", \*{'::?X'}, \*{'::?X'}]),
   ));
