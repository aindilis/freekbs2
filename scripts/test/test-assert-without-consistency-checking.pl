#!/usr/bin/perl -w

use KBS2::Client;
use PerlLib::SwissArmyKnife;
use UniLang::Util::TestHarness;

my $context = "test-kbs2-vampire";
my $client = KBS2::Client->new
  (
   Host => 'localhost',
   Port => 9000,
   Debug => 0,
   Method => "MySQL",
   Database => "freekbs2",
   Context => $context,
  );

$client->ClearContext
  (
   Context => $context,
  );

foreach my $item (1..30) {
  my $res = $client->Send
    (
     QueryAgent => 1,
     Assert => [["p", $item]],
     InputType => "Interlingua",
     Flags => {
	       AssertWithoutCheckingConsistency => $ARGV[0],
	      },
    );
}
