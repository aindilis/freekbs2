package KBS2::Rules;

use KBS2::Util;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;
}

sub Apply {
  my ($self,%args) = @_;
  # just put the rules here for now

  # Add a rule here to retrieve and analyze

  # perform some action based on looking up a set of actions to be
  # performed for various
  if ($args{Action} eq "assert") {
    if ($args{Formula}->[0] =~ /^due-date-for-entry|completed|skipped|obsolete$/i) {
      # this means a new due date has been asserted, update the agenda
      # print "Would call the rule \"agenda -u\" here if it were active\n";

      # # system "/var/lib/myfrdcsa/codebases/internal/myfrdcsa/bin/agenda -u &";
    }

    my $infostring = "By:".
      $args{Asserter}." ".
	$args{Context}." ".
	  $args{Action}." ".
	    FormulaToString
	      (
	       Formula => $args{Formula},
	       Type => "Emacs",
	      );
    print $infostring."\n";

    # we also want to send completed tasks to irc
    if (0) {
      print Dumper($UNIVERSAL::agent);
      print Dumper($infostring);
      $UNIVERSAL::agent->SendContents
	(
	 Receiver => "UniLang-IRC-Bot",
	 Contents => $infostring,
	 Data => {
		  _DoNotLog => 1,
		 },
	);
    }
  }
}

1;
