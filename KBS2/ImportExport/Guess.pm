package KBS2::ImportExport::Guess;

use Data::Dumper;
use Try::Tiny;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyImportExport /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyImportExport($args{ImportExport});
}

sub Guess {
  my ($self,%args) = @_;

  # this will have to work for now

  # try to figure out which Type this is in
  my $matches = {};
  foreach my $format (keys %{$self->MyImportExport->Types}) {
    print Dumper({Format => $format});
    my $res1;
    my $success;
    try {
      no warnings 'all';
      $res1 = $self->MyImportExport->Convert
	(
	 Input => $args{Formulae},
	 InputType => $format,
	 OutputType => "Interlingua",
	);
      $success = 1;
    } catch {
      my $exception = $_;
      print Dumper({Exception => $exception}) if $UNIVERSAL::debug;
      if (defined $exception) {
	if (ref($exception) eq "String" and
	    $exception =~ /org.opencyc.parser.InvalidConstantNameException/) {
	  $success = 1;
	} else {
	  $success = 0;
	}
      }
    };
    print Dumper({Res1 => $res1});
    if ($success and $res1->{Success}) {
      my $ref = ref $res1->{Output};
      next unless $ref eq "ARRAY";
      my $res2;
      try {
	no warnings 'all';
	$res2 = $self->MyImportExport->Convert
	  (
	   Input => $res1->{Output},
	   InputType => "Interlingua",
	   OutputType => $format,
	  );
      } catch {
	if (defined $_) {
	  $success = 0;
	}
      };
      if ($success and $res2->{Success}) {
	print Dumper
	  ({
	    Output => $res2->{Output},
	    Formulae => $args{Formulae},
	   });
	if ($res2->{Output} eq $args{Formulae}) {
	  print "WTF!\n";
	  $matches->{$format} = 1; #$res1->{Output};
	}
      }
    }
  }
  print Dumper({
		Matches => $matches,
		Item => $args{Formulae},
	       }) if 0;
  return {
	  Success => 1,
	  Result => $matches,
	 };
}

sub GuessOrig {
  my ($self,%args) = @_;

  # this will have to work for now

  # try to figure out which Type this is in
  my $matches = {};
  foreach my $format (keys %{$self->MyImportExport->Types}) {
    my $res1;
    eval {
      no warnings 'all';
      $res1 = $self->MyImportExport->Convert
	(
	 Input => $args{Formulae},
	 InputType => $format,
	 OutputType => "Interlingua",
	);
    };
    if ($res1->{Success}) {
      my $ref = ref $res1->{Output};
      next unless $ref eq "ARRAY";
      my $res2;
      eval {
	no warnings 'all';
	$res2 = $self->MyImportExport->Convert
	  (
	   Input => $res1->{Output},
	   InputType => "Interlingua",
	   OutputType => $format,
	  );
      };
      if ($res2->{Success}) {
	# print Dumper($res2->{Output},$args{Formulae});
	if ($res2->{Output} eq $args{Formulae}) {
	  $matches->{$format} = 1; #$res1->{Output};
	}
      }
    }
  }
  print Dumper({
		Matches => $matches,
		Item => $args{Formulae},
	       }) if 0;
  return {
	  Success => 1,
	  Result => $matches,
	 };
}

1;
