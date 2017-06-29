#!/usr/bin/perl -w

use UniLang::Util::TempAgent;

use Data::Dumper;

my $client = UniLang::Util::TempAgent->new;

my $message = $client->MyAgent->QueryAgent
  (
   Receiver => "KBS2",
   Data => {
	    _DoNotLog => 1,
	    Command => "query",
	    Context => "Org::FRDCSA::Audience::MPS",
	    FormulaString => "(\"audience-message-class\" ?X)",
	    Flags => {
		      Quiet => 1,
		      OutputType => "CycL String",
		     },
	   },
  );

print Dumper($message);

#      (freekbs-util-data-dumper
#       (list
#        (cons "_DoNotLog" 1)
#        (cons "Context" audience-freekbs-context)
#        (cons "Command" "query")
#        (cons "Flags" (list (cons "Type" "cyc-like")))
#        (cons "FormulaString" "(\"audience-message-class\" ?X)")
#        )
#       )
