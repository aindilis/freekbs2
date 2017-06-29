#!/usr/bin/perl -w

use KBS2::Client;
use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;

my $formula;
my $client = KBS2::Client->new
  (
   Context => "Org::FRDCSA::Academician::Test",
  );

sub Do {
  my (%args) = @_;
  print Dumper
    ($client->Send
     (
      QueryAgent => 1,
      Query => [$args{Formula}],
      InputType => "Interlingua",
      Flags => {
		OutputType => "CycL String",
	       },
     )) unless $args{Skip};
}

Do(
   Skip => 1,
   Formula =>
   [
    "done",
    [
     "read-range",
     "andrewdo",
     \*{"main::?PAGENO1"},
     \*{"main::?PAGENO2"},
     \*{"main::?DOC"},
    ],
   ],
  );

Do(
   Skip => 1,
   Formula =>
   [
    "and",
    [
     "done",
     [
      "read-range",
      "andrewdo",
      \*{"main::?PAGENOA1"},
      \*{"main::?PAGENOA2"},
      \*{"main::?DOCA"},
     ],
    ],
    [
     "done",
     [
      "read-range",
      "andrewdo",
      \*{"main::?PAGENOB1"},
      \*{"main::?PAGENOB2"},
      \*{"main::?DOCB"},
     ],
    ],
    [
     "larger-range-than",
     [
      "read-range",
      "andrewdo",
      \*{"main::?PAGENOA1"},
      \*{"main::?PAGENOA2"},
      \*{"main::?DOCA"},
     ],
     [
      "read-range",
      "andrewdo",
      \*{"main::?PAGENOB1"},
      \*{"main::?PAGENOB2"},
      \*{"main::?DOCB"},
     ],
    ],
   ],
  );



Do(
   Skip => 1,
   Formula =>
   [
    "and",
    [
     "done",
     \*{"main::?READRANGE1"},
    ],
    [
     "done",
     \*{"main::?READRANGE2"},
    ],
    [
     "larger-range-than",
     \*{"main::?READRANGE1"},
     \*{"main::?READRANGE2"},
    ],
   ],
  );

Do(
   Skip => 1,
   Formula =>
   [
    "and",
    [
     "done",
     \*{"main::?READRANGE1"},
    ],
    [
     "forall",
     [
      \*{"main::?READRANGE2"},
     ],
     [
      "implies",
      [
       "done",
       \*{"main::?READRANGE2"},
      ],
      [
       "larger-range-than",
       \*{"main::?READRANGE1"},
       \*{"main::?READRANGE2"},
      ],
     ],
    ],
   ],
  );

Do(
   Skip => 1,
   Formula =>
   [
    "and",
    [
     "done",
     [
      "read-range",
      "andrewdo",
      \*{"main::?PAGENOA1"},
      \*{"main::?PAGENOA2"},
      \*{"main::?DOCA"},
     ],
    ],
    [
     "forall",
     [
      \*{"main::?PAGENOB1"},
      \*{"main::?PAGENOB2"},
      \*{"main::?DOCB"},
     ],
     [
      "implies",
      [
       "done",
       [
	"read-range",
	"andrewdo",
	\*{"main::?PAGENOB1"},
	\*{"main::?PAGENOB2"},
	\*{"main::?DOCB"},
       ],
      ],
      [
       "larger-range-than",
       [
	"read-range",
	"andrewdo",
	\*{"main::?PAGENOA1"},
	\*{"main::?PAGENOA2"},
	\*{"main::?DOCA"},
       ],
       [
	"read-range",
	"andrewdo",
	\*{"main::?PAGENOB1"},
	\*{"main::?PAGENOB2"},
	\*{"main::?DOCB"},
       ],
      ],
     ],
    ],
   ],
  );

Do(
   Formula =>
   [
    "forall",
    [
     \*{"main::?X"},
    ],
    [
     "implies",
     [
      ">=",
      \*{"main::?X"},
      "1"
     ],
     [
      ">=",
      \*{"main::?X"},
      "0"
     ],
    ],
   ],
  );
