#!/usr/bin/perl -w

use KBS2::Client;
use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;

my $client = KBS2::Client->new
  (
   Context => "Org::FRDCSA::",
  );

print Dumper
  ($client->MyAgent->QueryAgent
   (
    Receiver => "KBS2",
    Data => {
	     "_DoNotLog" => 1,
	     "Command" => "query",
	     "Method" => "MySQL",
	     "Database" => "freekbs2",
	     "Context" => "Org::FRDCSA::FreeKBS2::Emacs::Test",
	     "FormulaString" => "(\"p\" \"1\")",
	     "InputType" => "Emacs String",
	     "OutputType" => "CycL String",
	     "Flags" => {
			 "OutputType" => "CycL String",
			},
	    },
   ));

print Dumper
  ($client->MyAgent->QueryAgent
   (
    Receiver => "KBS2",
    Data => {
	     "_DoNotLog" => 1,
	     "Command" => "query",
	     "Method" => "MySQL",
	     "Database" => "freekbs2",
	     "Context" => "Org::FRDCSA::FreeKBS2::Emacs::Test",
	     "FormulaString" => "(\"not\" (\"p\" \"1\"))",
	     "InputType" => "Emacs String",
	     "OutputType" => "CycL String",
	     "Flags" => {
			 "OutputType" => "CycL String",
			},
	    },
   ));
