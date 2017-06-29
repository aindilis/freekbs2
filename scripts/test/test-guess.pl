#!/usr/bin/perl -w

use KBS2::ImportExport;
use KBS2::ImportExport::Guess;

use Data::Dumper;

my $items =
  [
   '(#$subEvents #$OPECMeetingInGeneva #$UAEAcceptsProductionQuota)',
   '("diagonal" "positive" "16")',
   '("rule" "0" ("entails" ("and" ("not" ("equals" var-Type "knight")) ("lies_between" ("square" var-X1 var-Y1) ("square" var-X3 var-Y3) ("square" var-X2 var-Y2)) ("in" ("on" var-Piece ("square" var-X3 var-Y3)) var-Pos)) ("line_blocked" ("piece" var-Color var-Type) ("square" var-X1 var-Y1) ("square" var-X2 var-Y2) var-Pos)))',
   '(rule (entails (and (not (equals ?Type knight)) (lies_5Fbetween (square ?X1 ?Y1) (square ?X3 ?Y3) (square ?X2 ?Y2)) (in (on ?Piece (square ?X3 ?Y3)) ?Pos)) (line_5Fblocked (piece ?Color ?Type) (square ?X1 ?Y1) (square ?X2 ?Y2) ?Pos)))',
  ];

my $ie = KBS2::ImportExport->new;
my $guess = KBS2::ImportExport::Guess->new
  (
   ImportExport => $ie,
  );

foreach my $formulae (@$items) {
  $guess->Guess(Formulae => $formulae);
}

