#!/usr/bin/perl -w

use Test::More no_plan;
use Test::Deep;

my $noisy = 1;
my $standalonemode = 1;

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

my $tests =
  [
   {
    Type => "KIF String",
    Statements => ['(implies (and (not (equals ?Type knight)) (lies_5Fbetween (square ?X1 ?Y1) (square ?X3 ?Y3) (square ?X2 ?Y2)) (in (on ?Piece (square ?X3 ?Y3)) ?Pos)) (line_5Fblocked (piece ?Color ?Type) (square ?X1 ?Y1) (square ?X2 ?Y2) ?Pos))'],
    Results => ["error"],
   },
   #    {
   #     Type => "KIF String",
   #     Statements => ['(implies (and (not (equals ?Type knight)) (lies_5Fbetween (square ?X1 ?Y1) (square ?X3 ?Y3) (square ?X2 ?Y2)) (in (on ?Piece (square ?X3 ?Y3)) ?Pos)) (line_5Fblocked (piece ?Color ?Type) (square ?X1 ?Y1) (square ?X2 ?Y2) ?Pos))'],
   #     Results => ["error"],
   #    },
  ];

sub DoTests {
  my (%args) = @_;
  my $i = 1;
  foreach my $test (@$tests) {
    # assert it and see what type of result comes from it
    if ($noisy) {
      print "Clearing the context...\n";
    }
    $client->ClearContext
      (
       Context => $context,
      );
    if ($noisy) {
      print "Finished clearing the context.\n";
      print "problemset ".$i++."\n";
    }
    # clear the context
    foreach my $assertion (@{$test->{Statements}}) {
      print Dumper($assertion);
      my $res = $client->Send
	(
	 QueryAgent => 1,
	 Assert => $assertion,
	 InputType => $test->{Type},
	);
      my $expectedresult = shift @{$test->{Results}};
      print Dumper([$res,$expectedresult]);
    }
  }
}

DoTests();

$testharness->StopTemporaryUniLangInstance unless $standalonemode;
