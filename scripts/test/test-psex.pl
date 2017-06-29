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
	    Method => "MySQL",
	    Database => "freekbs2",
	    Context => "default",
	    FormulaString => "(\"completed\" (\"UniLang-Entry\" var-x0))",
	    Flags => {
		      Quiet => 1,
		      OutputType => "CycL String",
		     },
	   },
  );


print Dumper($message);
