#!/usr/bin/perl -w

use KBS2::ImportExport;

use Data::Dumper;

my $items =
  [
   '("desires" "andrewdo" ("read" "Cohen, P. and Levesque, H. (1990). Intention is choice with commitment. Artificial Intelligence, 42, 213–261."))',
  ];

my $ie = KBS2::ImportExport->new;
print Dumper
  ($ie->Convert
   (
    InputType => "Emacs String",
    Input => $items->[0],
    OutputType => "Interlingua",
   ));
