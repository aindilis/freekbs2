#!/usr/bin/perl -w

my $database = shift @ARGV;
my $context = shift @ARGV;

# grab all the ISA Classes and return

# for now just grab all statements of the form, ("isa" " ")

# do a query to get all classes

print "(setq nlu-classes\n      '(";
foreach my $item (@$res) {
  my $pred = $item->[0];
  if ($pred =~ /^[\w\s-]+$/) {
    print "(\"".$pred."\" . ((\"Arity\" . nil)))\n\t";
  }
}
print "))\n";

