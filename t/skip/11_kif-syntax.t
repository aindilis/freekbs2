#!/usr/bin/perl -w

use Data::Dumper;
use URI::Escape qw(uri_escape_utf8 uri_unescape);


my $upper = '[A-Z]';
my $lower = '[a-z]';
my $digit = '\d';
my $alpha = '(\!|\$|\%|\&|\*|\+|\-|\.|\/|\<|\=|\>|\?|\@|\_|\~)';
my $special = '(\"|\#|\\\'|\(|\)|\,|\\|\^|\`)';
my $white = '\s';

print join("\n",($upper, $lower, $digit, $alpha, $special, $white))."\n";

my $string = '(and
  (start\' ?e2 ?x1)
  (Dad#n#1\' ?x1)
  (stories-SLASH-recollections-SLASH-etc#n#2\' ?x1)
  (project#n#2\' ?x1))';

my $string2 = 'Dad%n%12\'';
# my $string2 = '[^a-zA-Z\d\!\$\%\&\*\+\-\.\/\<\=\>\?\@\_\~]'

sub EncodeToKIF {
  my %args = @_;
  my $item = $args{Item};
  return uri_escape_utf8($item,'^a-zA-Z0-9!&*\$+-./<=>?@~_');
}

sub DecodeFromKIF {
  my %args = @_;
  return [uri_unescape($args{Item},'^a-zA-Z0-9!&*\$+-./<=>?@~_')]->[0];
}

print Dumper
  (DecodeFromKIF
   (Item => EncodeToKIF
    (Item => $string2)));
