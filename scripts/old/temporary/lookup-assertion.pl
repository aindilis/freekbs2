#!/usr/bin/perl -w

# lookup in the database for the goal that matches this

# use Lingua::EN::Sentence qw(get_sentences);
use Data::Dumper;
use KBS2::Util;
use PerlLib::MySQL;
use UniLang::Util::TempAgent;

my $command = shift;
my $search = shift;

# first we need to transform the assertion into a relation, then query
# freekbs2 with that relation to get the assertion ID, then we are done

if ($command eq "GetID") {
  $search =~ s/^(un)?assert: //;

  my $tempagent = UniLang::Util::TempAgent->new;
  my $result = $tempagent->MyAgent->QueryAgent
    (
     Receiver => "KBS2",
     Contents => "MySQL:freekbs2:default get-id $search",
    );

  $VAR1 = undef;
  eval $result->Contents;
  print $VAR1;

  $tempagent->MyAgent->Deregister;
} elsif ($command eq "GetRelation") {
  
}
