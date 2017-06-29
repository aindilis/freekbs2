#!/usr/bin/perl -w

use KBS2::Util;
use PerlLib::Util;
use UniLang::Util::TempAgent;

use Data::Dumper;

my $tempagent = UniLang::Util::TempAgent->new
  ();

my $context = $ARGV[0];

my $message = $tempagent->MyAgent->QueryAgent
  (
   Receiver => "KBS2",
   Contents => "$context all-asserted-knowledge",
   Data => {
	    _DoNotLog => 1,
	   },
  );

my $assertions = DeDumper($message->Contents);
foreach my $assertion (@$assertions) {
  # generate this and assert
  print RelationToString
    (
     Type => "Emacs",
     Relation => $assertion,
    )."\n";
}
