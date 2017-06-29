#!/usr/bin/perl -w

use KBS2::ImportExport;

use Data::Dumper;

$UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/internal/freekbs2";

my $ie = KBS2::ImportExport->new;

# load a bunch of CycL (note this is labelled KIF by mistake)

my $result = $ie->Convert
  (
   Input => "(var-X \"stuff\")",
   InputType => "Emacs String",
   OutputType => "Interlingua",
  );
print Dumper($result);
