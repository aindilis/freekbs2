#!/usr/bin/perl -w

# Summarize the contents of the KB, for people to understand what
# might be being stored by a particular KB

# start with enumerating the Contexts

#!/usr/bin/perl -w

use PerlLib::MySQL;

use Data::Dumper;

my $mymysql = PerlLib::MySQL->new
  (DBName => $ARGV[0] || "freekbs2");

sub ListContexts {
  my @contexts;
  my $res = $mymysql->Do
    (
     Array => 1,
     Statement => "select DISTINCT Context from tuples",
    );
  foreach my $item (@$res) {
    my $context = $item->[0];
    push @contexts, $context;
  }
  return \@contexts;
}

sub SummarizeContents {
  my @contexts = @{ListContexts()};
  foreach my $context (@contexts) {
    print $context."\n";
    my $predicates = {};
    my $contextstring = $mymysql->Quote($context);
    my $res = $mymysql->Do
      (
       Array => 1,
       Statement => "select DISTINCT a.Value from arguments a, tuples t where a.ID = t.ID and a.KeyID=0 and t.Context=$contextstring;",
      );
    foreach my $item (@$res) {
      my $pred = $item->[0];
      $predicates->{$pred}++;
    }
    print "\t".join(" | ",sort keys %$predicates)."\n\n";
  }
}

SummarizeContents();
