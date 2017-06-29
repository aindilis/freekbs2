#!/usr/bin/perl -w

use KBS2::ImportExport;

use Data::Dumper;

my $ie = KBS2::ImportExport->new;

my $item = [
	    'and',
	    [
	     'when\'',
	     \*{'::?e6'},
	     \*{'::?e5'},
	    ],
	    [
	     'mom\'',
	     \*{'::?x1'},
	    ],
	    [
	     'read#v#9\'',
	     \*{'::?e5'},
	     \*{'::?x1'},
	     \*{'::?x2'},
	    ],
	    [
	     '#$NewspaperCopy',
	     \*{'::?x2'}
	    ],
	    [
	     'show\'',
	     \*{'::?e6'},
	     \*{'::?x3'},
	     \*{'::?x4'},
	    ],
	    [
	     'her\'',
	     \*{'::?x3'},
	    ],
	    [
	     'coupon\'',
	     \*{'::?x4'},
	    ]
	   ];


my $res = $ie->Convert
  (
   Input => [$item],
   InputType => "Interlingua",
   OutputType => "KIF String",
  );
print Dumper($res);
