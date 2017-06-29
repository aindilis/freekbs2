#!/usr/bin/perl -w

use File::Slurp;

use Data::Dumper;

my $c = read_file("statuses");

$c =~ s/^# //mg;
# print $c."\n";

my $data = {};
my @item;
my @allitems;
foreach my $line (split /\n/, $c) {
  if ($line =~ /^-{9,}$/) {
    my $tmp = pop @item;
    if (scalar @item) {
      my @copy = @item;
      push @allitems, \@copy;
    }
    @item = ($tmp);
  } else {
    push @item, $line;
  }
}
push @allitems, \@item;

foreach my $item (@allitems) {
  my $first = shift @$item;
  my $state = 0;
  my @description;
  foreach my $line (@$item) {
    if ($line =~ /^\+ (.+)\s+\((.+)\)$/) {
      $state = 1;
    } elsif ($line =~ /^  \+ (.+)\s+\((.+)\)$/) {
      $state = 2;
    } else {
      if ($state == 1) {
	push @description, $line;
      }
    }
  }
  $data->{$first} = {
		     
		    }
}
