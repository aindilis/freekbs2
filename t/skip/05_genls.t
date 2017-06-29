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

# Also, implement a ("genls" "contextA" "contextB") system.

# (implies (transitive-binary-relation ?X) (implies (and (?X ?A ?B) (?X ?B ?C)) (?X ?A ?C)))
# (transitive-binary-relation genls)

# ;; Create a permissions system for asserting knowledge.  also, use
# ;;   cryptographic signing to validate asserted data as either being
# ;;   asserted by that person or a party that has gained access to their
# ;;   key or broken encryption technology or hacked the database etc.

my $problemsets = [
		   {
		    Theory => [
			       # # this does not work (duh, because Vampire is first order)
			       # '(=> (transitive-binary-relation ?X) (=> (and (?X ?A ?B) (?X ?B ?C)) (?X ?A ?C)))',
			       # '(transitive-binary-relation genls)',

			       # have to use this
			       '(=> (and (genls ?A ?B) (genls ?B ?C)) (genls ?A ?C))',
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
      print Dumper($res);
    }
    Approve("Continue: ");
  }
}

DoTests();
