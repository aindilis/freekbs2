#!/usr/bin/perl -w

use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;

my $importexport = KBS2::ImportExport->new();

sub Test {
  my $terms = [
	       'a(b(c,d),e,f(g,h,i(j,k,l(m,n))))',
	       'a(b,c(d))',
	       'before((shopAt(Agent,Store),partOfStoreFranchise(Store,aldiGroceryStores)),hasOnPerson(Agent,and(empty(groceryBags),quarterDollarCoin))).',
	       'knows_not(A, B) :- not(holds(A, B)).',

	      ];

  my @convertback;
  foreach my $term (@$terms) {
    my $res1 = $importexport->Convert
      (
       Input => $term,
       InputType => 'Prolog',
       OutputType => 'PDDL2_2',
      );
    print ClearDumper({Res1 => $res1});
    if ($res1->{Success}) {
      print $res1->{Output}."\n";
      my $res2 = $importexport->Convert
	(
	 Input => $res1->{Output},
	 InputType => 'PDDL2_2',
	 OutputType => 'Prolog',
	);
      if ($res2->{Success}) {
	print $res2->{Output}."\n";
	if ($term eq $res2->{Output}) {
	  print "A match!\n";
	} else {
	  print "Not a match.\n";
	}
      }
    }
    print "\n\n";
  }
}

Test();
