#!/usr/bin/perl -w

# we need to test rename, clear, and remove

use KBS2::Client;

my $context = "This is a test";
my $client = KBS2::Client->new
  (
   Context => $context,
  );

# add something here
my $res = $client->Send
  (
   QueryAgent => 1,
   Assert => "(a b)",
   InputType => "KIF String",
   Quiet => 1,
  );
if ($res->Data->{Result}->{Success}) {
  print "Successfully asserted: $item\n";
} else {
  print "Not asserted: $item\n";
}

# now go ahead and clear it

$client->ClearContext
  (
   Context => $context,
  );

# now go ahead and create a different context, and then rename it to another context

# reassert it
my $res = $client->Send
  (
   QueryAgent => 1,
   Assert => "(a b)",
   InputType => "KIF String",
   Quiet => 1,
  );
if ($res->Data->{Result}->{Success}) {
  print "Successfully asserted: $item\n";
} else {
  print "Not asserted: $item\n";
}

system "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -l | grep \"This\"";

my $context2 = "This is another test";
$client->RenameContext
  (
   Context => $context,
   Data => {
	    NewContext => $context2,
	   },
  );

system "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -l | grep \"This\"";

# finally remove the new context
$client->RemoveContext
  (
   Context => $context2,
  );

system "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -l | grep \"This\"";
