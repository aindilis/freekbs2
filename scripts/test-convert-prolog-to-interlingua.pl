#!/usr/bin/perl -w

use Language::Prolog::Yaswi ':query';

use Data::Dumper;

sub ConvertPrologToInterLingua {
  my (%args) = @_;
  my $result = swi_parse($args{Prolog});
  print Dumper($result);

}

my @testinputs = (
		  "completed(task).",
		  "completed('this is a test').",
		  "'this is a test'.",
		  "completed",
		  "completed(this)",
		  "completed(this).
completed(that).",
		 );

foreach my $testinput (@testinputs) {
  ConvertPrologToInterLingua(Prolog => $testinput);
}
