#!/usr/bin/perl -w

# use KBS::Util;
# use PerlLib::Util;

use UniLang::Util::TempAgent;

use Data::Dumper;


my $tempagent = UniLang::Util::TempAgent->new
  ();

if (0) {
  foreach my $person (qw(Andy Eva Kate Joe Mom Dad Gene Ann)) {
    my $message = $tempagent->MyAgent->QueryAgent
      (
       Receiver => "KBS2",
       Data => {
		Command => "assert",
		Context => "temp1",
		FormulaString => '("isa" "'.$person.'" "Human Being")',
		_DoNotLog => 1,
	       },
      );
    print Dumper($message);
  }

  my $message2 = $tempagent->MyAgent->QueryAgent
    (
     Receiver => "KBS2",
     Data => {
	      Command => "query",
	      Context => "temp1",
	      FormulaString => '("isa" ?X "Human Being")',
	      _DoNotLog => 1,
	     },
    );
  print Dumper($message2);
} else {
  foreach my $item (qw(a b)) {
    my $message = $tempagent->MyAgent->QueryAgent
      (
       Receiver => "KBS2",
       Data => {
		Command => "assert",
		Context => "temp1",
		FormulaString => '("p" "'.$item.'")',
		_DoNotLog => 1,
	       },
      );
    print Dumper($message);
  }

  my $message2 = $tempagent->MyAgent->QueryAgent
    (
     Receiver => "KBS2",
     Data => {
	      Command => "query",
	      Context => "temp1",
	      FormulaString => '("p" ?X)',
	      _DoNotLog => 1,
	     },
    );
  print Dumper($message2);
}
