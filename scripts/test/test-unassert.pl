#!/usr/bin/perl -w

use KBS2::Client;
use PerlLib::SwissArmyKnife;
use UniLang::Util::TestHarness;

my $context = "test-kbs2-vampire";
my $client = KBS2::Client->new
  (
   Host => 'localhost',
   Port => 9000,
   Debug => 0,
   Method => "MySQL",
   Database => "freekbs2-test",
   Context => $context,
  );

$client->ClearContext
  (
   Context => $context,
  );

my $res1 = $client->Send
  (
   QueryAgent => 1,
   Assert => "(p b)",
   InputType => "KIF String",
  );
print Dumper($res1);

my $res2 = $client->Send
  (
   QueryAgent => 1,
   Query => "(p ?X)",
   InputType => "KIF String",
   ResultType => 'object',
  );
print Dumper
  ($res2->MatchBindings
   (
    VariableName => "?X",
   ));

my $res3 = $client->Send
  (
   QueryAgent => 1,
   Unassert => "(p b)",
   InputType => "KIF String",
  );
print Dumper($res3);

my $res4 = $client->Send
  (
   QueryAgent => 1,
   Query => "(p ?X)",
   InputType => "KIF String",
   ResultType => 'object',
  );
print Dumper
  ($res4->MatchBindings
   (
    VariableName => "?X",
   ));
