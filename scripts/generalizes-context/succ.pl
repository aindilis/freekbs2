#!/usr/bin/perl -w

use KBS2::Client;
use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;

my $client = KBS2::Client->new
  (
   Context => "Org::FRDCSA::FreeKBS2::Library::Successor",
  );

my $importexport = KBS2::ImportExport->new();
my $formula;
foreach my $i (0..1000) {
  $formula = [
	      "succ",
	      $i,
	      $i + 1,
	     ];
  print Dumper($formula);
  $client->Send
    (
     Assert => [$formula],
     InputType => "Interlingua",
     Flags => {
	       AssertWithoutCheckingConsistency => 1,
	      },
    );
}
