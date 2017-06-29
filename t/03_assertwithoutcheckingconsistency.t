#!/usr/bin/perl -w

use Test::More no_plan;
use Test::Deep;

my $noisy = 1;
my $standalonemode = 0;

use_ok('KBS2::Client');
use_ok('PerlLib::SwissArmyKnife');
use_ok('UniLang::Util::TestHarness');

my $testharness = UniLang::Util::TestHarness->new();
isa_ok( $testharness, 'UniLang::Util::TestHarness' );

$testharness->StartTemporaryUniLangInstance unless $standalonemode;
if ($noisy) {
  print "UniLang Started.\n";
}

my $context = "test-kbs2-vampire";
my $client;

if ($standalonemode) {
  $client = KBS2::Client->new
    (
     Host => 'localhost',
     Port => 9000,
     Debug => 0,
     Method => "MySQL",
     Database => "freekbs2",
     Context => $context,
    );
} else {
  $client = KBS2::Client->new
    (
     Host => $testharness->Host,
     Port => $testharness->Port,
     Debug => 0,
     Method => "MySQL",
     Database => "freekbs2",
     Context => $context,
    );
}
isa_ok($client, 'KBS2::Client');
if ($noisy) {
  print "KBS2::Client Started.";
}

$client->ClearContext
  (
   Context => $context,
  );

foreach my $item (1..10) {
  my $res = $client->Send
    (
     QueryAgent => 1,
     Assert => [["p", $item]],
     InputType => "Interlingua",
     Flags => {
	       AssertWithoutCheckingConsistency => 1,
	      },
    );
}

$testharness->StopTemporaryUniLangInstance unless $standalonemode;
