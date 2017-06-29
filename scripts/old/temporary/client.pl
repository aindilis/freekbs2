#!/usr/bin/perl -w

use KBS2::Client;

use Data::Dumper;

my $c = KBS2::Client->new();

$c->Send
  (Assert => ["test", "123"]);
$c->Send
  (Assert => ["test", "456"]);
$c->Send
  (Assert => ["test", "789"]);
print Dumper
  ($c->Send
   (Query => ["test",undef]));
$c->Send
  (Unassert => ["test",undef]);

print Dumper
  ($c->Send
   (Query => ["moved-to-codebase-incoming",undef,undef]));

$c->MyAgent->Deregister;
