#!/usr/bin/perl -w

use Test::More no_plan;
use Test::Deep;

use Data::Dumper;

my $noisy = 0;

use_ok('KBS2::Client');
use_ok('KBS2::ImportExport');
use_ok('PerlLib::SwissArmyKnife');
use_ok('UniLang::Util::TempAgent');
use_ok('UniLang::Util::TestHarness');

my $testharness = UniLang::Util::TestHarness->new();
isa_ok( $testharness, 'UniLang::Util::TestHarness' );

$testharness->StartTemporaryUniLangInstance;
if ($noisy) {
  print "UniLang Started.\n";
}

my $context = "test-kbs2-vampire";
my $client = KBS2::Client->new
  (
   Host => $testharness->Host,
   Port => $testharness->Port,
   Debug => 0,
   Method => "MySQL",
   Database => "freekbs2",
   Context => $context,
  );
isa_ok($client, 'KBS2::Client');
if ($noisy) {
  print "KBS2::Client Started.";
}

my $importexport = KBS2::ImportExport->new();
isa_ok( $importexport, 'KBS2::ImportExport' );
if ($noisy) {
  print"KBS2::ImportExport Created.";
}

my $problemsets = [
		   {
		    Theory => [
			       # # this does not work (duh, because Vampire is first order)
			       # '(=> (transitive-binary-relation ?X) (=> (and (?X ?A ?B) (?X ?B ?C)) (?X ?A ?C)))',
			       # '(transitive-binary-relation genls)',

			       # have to use this
			       # '(=> (and (genls ?A ?B) (genls ?B ?C)) (genls ?A ?C))',
			       '(genls A B)',
			       '(genls B C)',
			       '(genls C D)',
			      ],
		    Queries => {
				'(genls A ?X)' => "unknown",
			       },
		   },
		  ];

sub DoTests {
  my (%args) = @_;
  my $i = 1;
  foreach my $problemset (@$problemsets) {
    # clear the context
    $client->ClearContext
      (
       Context => $context,
      );

    print "problemset ".$i++."\n";
    foreach my $item (@{$problemset->{Theory}}) {
      my $res = $client->Send
	(
	 QueryAgent => 1,
	 Assert => $item,
	 InputType => "KIF String",
	 Quiet => 1,
	);
      if ($res->Data->{Result}->{Success}) {
	print "Successfully asserted: $item\n";
      } else {
	print "Not asserted: $item\n";
      }
    }

    foreach my $item (keys %{$problemset->{Queries}}) {
      my $res = $client->Send
	(
	 QueryAgent => 1,
	 Query => $item,
	 InputType => "KIF String",
	 OutputType => "CycL String",
	 Quiet => 1,
	);
      note(Dumper({Res => $res}));
    }
  }
}

DoTests();

$testharness->StopTemporaryUniLangInstance;
