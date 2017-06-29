#!/usr/bin/perl -w

use KBS2::Client;
use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;

my $client = KBS2::Client->new
  (
   Context => "Org::FRDCSA::PSE2",
  );

my $importexport = KBS2::ImportExport->new();
my $res;
if (1) {
  $res = $importexport->Convert
    (
     Input => "(\"isa\" var-X \"person\")",
     InputType => "Emacs String",
     OutputType => "Interlingua",
    );
} else {
  $res = $importexport->Convert
    (
     Input => "(isa ?X person)",
     InputType => "KIF String",
     OutputType => "Interlingua",
    );
}
my $formula;
if (0) {
  $formula = $res->{Output}->[0]
} else {
  $formula = [
	      "isa",
	      \*{"main::?X"},
	      # "Andrew Dougherty",
	      "person"
	     ];
}
print Dumper($formula);
print Dumper
  ($client->Send
   (
    QueryAgent => 1,
    Query => [$formula],
    InputType => "Interlingua",
    Flags => {
	      OutputType => "CycL String",
	     },
   ));
