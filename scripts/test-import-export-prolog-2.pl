#!/usr/bin/perl -w

use KBS2::ImportExport;
use KBS2::Util;
use PerlLib::SwissArmyKnife;

my $importexport = KBS2::ImportExport->new();

my $prolog = read_file('/var/lib/myfrdcsa/codebases/minor/suppositional-reasoner/Suppose/Resources/chess/chesskb/board-standard.pro');

my @testinputs = (
		  "test",
		  "completed(task).",
		  "completed('this is a test').",
		  # "'this is a test'.",
		  "completed",
		  "completed(this).",
		  "completed(this).
completed(that).",
		 );

foreach my $testinput (@testinputs) {
  my $res1 = $importexport->Convert
    (
     Input => $testinput,
     InputType => "Prolog",
     OutputType => "Interlingua",
    );
  print Dumper($res1);
}
