#!/usr/bin/perl -w

use KBS2::Client;
use Manager::Dialog qw(Approve);

use Data::Dumper;

$UNIVERSAL::systemdir =  "/var/lib/myfrdcsa/codebases/internal/freekbs2";
my $context = "test-kbs2-vampire";
my $client = KBS2::Client->new
  (
   Debug => 0,
   Method => "MySQL",
   Database => "freekbs2",
   Context => $context,
  );

my $problemsets = [
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
	);
      if ($res->Data->{Result}->{TruthValue} eq $problemset->{Queries}->{$item}) {
	print "correct: $item\n";
      } else {
	print "inccorrect: $item\n";
      }
    }
    Approve("Continue: ");
  }
}

DoTests();
