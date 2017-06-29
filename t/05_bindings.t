#!/usr/bin/perl -w

use Test::More no_plan;
use Test::Deep;

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
			       '(temp a b c)',
			       '(temp d e f)',
			       '(temp g h i)',
			      ],
		    Queries => {
				'(temp ?X ?Y ?Z)' => [
						      '(temp a b c)',
						      '(temp d e f)',
						      '(temp g h i)',
						     ],
			       },
		   },
		   {
		    Theory => [
			       '(p x)',
			       '(=> (p ?X) (q ?Y))',
			      ],
		    Queries => {
				'(q x)' => "true",
			       },
		   },
		  ];

sub DoTests {
  my (%args) = @_;
  my $i = 1;
  foreach my $problemset (@$problemsets) {
    # clear the context
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
    foreach my $assertion (@{$problemset->{Theory}}) {
      print Dumper($assertion);
      my $res = $client->Send
	(
	 QueryAgent => 1,
	 Assert => $assertion,
	 InputType => "KIF String",
	);
      if ($res->Data->{Result}->{Success}) {
	if ($noisy) {
	  print "Successfully asserted: $assertion\n";
	}
      } else {
	if ($noisy) {
	  print "Not asserted: $assertion\n";
	}
      }
    }
    foreach my $query (keys %{$problemset->{Queries}}) {
      # convert the expected query result to the interlingua
      my @expectedresult;
      foreach my $formula (@{$problemset->{Queries}->{$query}}) {
	my $res2 = $importexport->Convert
	  (
	   Input => $formula,
	   InputType => "KIF String",
	   OutputType => "Interlingua",
	  );
	if ($res2->{Success}) {
	  push @expectedresult, $res2->{Output}->[0];
	} else {
	  # must fail here somehow
	  die "This should be noted as a failure somehow in the tests.\n";
	}
      }

      if ($noisy) {
	print "Querying: $query\n";
      }
      my $res = $client->Send
	(
	 QueryAgent => 1,
	 Query => $query,
	 InputType => "KIF String",
	);

      print Dumper($res);

      isa_ok($res,'UniLang::Util::Message');
      my @actualresult;
      foreach my $entry (@{$res->{Data}->{Result}->{Results}->[-1]->{Models}}) {
	push @actualresult, $entry->{Formulae}->[0];
      }
      cmp_deeply
	(
	 \@actualresult,
	 bag(@expectedresult),
	 "Query: $query",
	);
    }
  }
}

DoTests();

$testharness->StopTemporaryUniLangInstance;
