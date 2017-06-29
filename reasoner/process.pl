#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use RADAR::Mod::WebSearch;

my $verbose = 0;
my $search = RADAR::Mod::WebSearch->new();

if (0) {
  my $item = read_file("/var/lib/myfrdcsa/codebases/internal/freekbs2/reasoner/url-list.txt");
  foreach my $item (split /\n/, $item) {
    my $res = $search->Retrieve
      (
       URL => $item,
      );
    print Dumper($res);
  }
}
if (1) {
  my $c = read_file("/var/lib/myfrdcsa/codebases/internal/freekbs2/reasoner/notes.pl");
  eval $c;
  print Dumper($items) if $verbose;
  my @all;
  my @links;
  foreach my $key (keys %$items) {
    my @things;
    # print "$key\t\t".$items->{$key}->{Desc}."\n" if $verbose;
    push @things, $key;
    push @things, $items->{$key}->{Desc};
    if (1) {
      foreach my $url (@{$items->{$key}->{Url}}) {
	if ($url =~ /^http/) {
	  my $res = $search->Retrieve
	    (
	     URL => $url,
	    );
	  print Dumper($res) if $verbose;
	  push  @things, $res;
	  push @links, @{$res->{Links}};
	}
      }
    }
    push @all, \@things;
  }
  print Dumper(\@all,\@links);
}
