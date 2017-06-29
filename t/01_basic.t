#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 2;

use_ok('KBS2');

my $kbs = eval{ KBS2->new() };
isa_ok( $kbs, 'KBS2' );
