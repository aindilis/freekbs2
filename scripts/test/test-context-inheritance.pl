#!/usr/bin/perl -w

# make a list of the most important aspects of the system, like how to
# assert - have a manual

# test adding and deleting contexts

use Graph::Directed;

my $contexts = {};
my $contextmetadata = "0";
my $contexthierarchy = {
			"1" => "2"
			"1" => "3"
			"1" => "4"
			"2" => "5"
			"2" => "6"
			"6" => "7"
		       };

# alternatively, randomly generate the graph, checking for noncycles



foreach my $supercontext (keys %$contexthierarchy) {
  my $subcontext = $contexthierarchy->{$supercontext};
  AddContext
    (Context => $supercontext);
  AddContext
    (Context => $subcontext);
  $client->Send
    (
     Context => $contextmetadata,
     InputType => "Interlingua",
     Assert => [["genl-context",$supercontext,$subcontext]],
    );
}

sub AddContext {
  my (%args) = @_;
  if (! exists $contexts->{$args{Context}}) {
    $contexts->{$args{Context}} = 1;
    $client->Send
      (
       Context => $contextmetadata,
       InputType => "Interlingua",
       Assert => [["isa-context",$args{Context}]],
      );
  }
}

# manually compute the context subsumption graph (find a cycle if one exists)

my @predicates = qw(now); # go ahead and add assertions at random to various contexts);
# my @predicates = qw(now go ahead and add assertions at random to various contexts);
my @arguments = qw(manually compute the context subsumption graph find a cycle if one exists);
# now go ahead and add assertions at random to various contexts
foreach my $i (1..10) {
  my $pred = RandomElementOf(@predicates);
  my $arg1 = RandomElementOf(@arguments);
  my $arg2 = RandomElementOf(@arguments);
  $client->Send
    (
     Context => $contextmetadata,
     InputType => "Interlingua",
     Assert => [[$pred,$arg1,$arg2]],
    );
}

sub RandomElementOf {
  return $_[int(rand(scalar @_))];
}

# now go ahead and query everything that should belong to the context

foreach my $context (keys %$contexts) {
  my $obj = $client->Send
    (
     Context => $context,
     InputType => "Interlingua",
     Query => [["now",\*{'::?ARG1'},\*{'::?ARG1'}]],
     ResponseType => "object",
    );
  # go ahead and process
  # see if the results are as they should be
}
