package KBS2::Reasoner::Cyc;

use base qw(KBS2::Reasoner);

use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;
use System::Cyc::Java::CycAccess;

use Inline::Java qw(caught);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Debug MyCycAccess MyImportExport /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug} || $UNIVERSAL::debug);
  $self->MyCycAccess
    (System::Cyc::Java::CycAccess->new
     (
      Debug => $self->Debug,
      Variety => $args{Variety},
     ))
  $self->MyImportExport
    (
     KBS2::ImportExport->new
     (),
    );
}

sub StartServer {
  my ($self,%args) = @_;
  if (0) { #$self->Debug) {
    print "Debug, not starting servering\n";
  } else {
    $self->MyCycAccess->StartServer
      (
       # Restart => exists $conf->{'-r'},
      );
  }
}

sub RestartServer {
  my ($self,%args) = @_;
  $self->MyCycAccess->StartServer
    (
     Restart => 1,
    );
}

sub Assert {
  my ($self,%args) = @_;
  return $self->SendQuery
    (
     Type => "assert",
     Formula => $args{Formula},
     Context => $args{Context},
     Theory => $args{Theory},
    );
}

sub Unassert {
  my ($self,%args) = @_;
  # I don't think we need to do anything
  if (0) {
    return $self->SendQuery
      (
       Type => "unassert",
       Formula => $args{Formula},
       Context => $args{Context},
       Theory => $args{Theory},
      );
  } else {
    return {
	    Result => "unasserted",
	   };
  }
}

sub Query {
  my ($self,%args) = @_;
  return $self->SendQuery
    (
     Type => "query",
     Formula => $args{Formula},
     Context => $args{Context},
     Theory => $args{Theory},
     Attributes => $args{Attributes},
    );
}

sub SendQuery {
  my ($self,%args) = @_;
  my $type = $args{Type};

  print Dumper({SendQueryArgs => \%args}) if $self->Debug;

  # NOW, YOU HAVE TO LOAD EVERYTHING IN
  my $res = $self->LoadCurrentTheory
    (
     Context => $args{Context},
     Theory => $args{Theory},
    );

  my @load = @{$res->{Load}};
  $args{Attributes}->{LoadSize} = scalar @load;

  # ADD THE FORMULA
  my $res = $self->MyImportExport->Convert
    (
     Input => [$args{Formula}],
     InputType => "Interlingua",
     OutputType => "CycL String",
    );

  if (! $res->{Success}) {
    return $res;
  }
  my $cyclstring = $res->{Output};

  if ($type eq "query") {
    # set it up as a query, otherwise, assert it
    # $cyclstring;

  } else {
    # $cyclstring;
  }
  my $querytext = $cyclstring;

  print Dumper({Query => $querytext}) if $self->Debug;

  my $res3 = $self->MyImportExport->Convert
    (
     Input => [$args{Formula}],
     InputType => "Interlingua",
     OutputType => "CycL Light Domain",
    );
  print Dumper({CycLExport => $res3}) if $self->Debug;
  if ($res3->{Success}) {
    my $cycaccess = $self->MyCycAccess;
    eval {
      my $cyclist = $cycaccess->makeCycList($res3->{Output}->[0]);
      my $mt = $cycaccess->getKnownConstantByName($args{Context});
      my $properties = $cycaccess->createInferenceParams();
    };
    if ($@) {
      print $@->getMessage()."\n";
    }

    my $result;
    eval {
      $result = $cycaccess->askNewCycQuery($cyclist, $mt, $properties)
    };
    if ($@) {
      print $@->getMessage()."\n";
    }

    my @result;
    my $e1 = $result->listIterator(0);
    while ($e1->hasNext()) {
      my $o1 = $e1->next();
      if (ref($o1) eq 'System::Cyc::Java::CycAccess::org::opencyc::cycobject::CycList') {
	push @result, [\*{'::'.$o1->first()->first()->toString},$o1->first()->rest()->cyclify()];
      }
    }

    print Dumper([\@result]);
    return $res2;
  } else {
    return {
	    Success => 0,
	    Reasons => $res3->{Reasons},
	   };
  }
}

sub LoadCurrentTheory {
  my ($self,%args) = @_;
  my @load;
  # ensure that it has been loaded
  foreach my $formula (@{$args{Theory}}) {
    # translate it into CycL
    my $res = $self->MyImportExport->Convert
      (
       Input => [$formula],
       InputType => "Interlingua",
       OutputType => "CycL String",
      );
    if (! $res->{Success}) {
      return $res;
    }
    my $cyclstring = $res->{Output};
    push @load, $cyclstring;
  }
  return {
	  Load => \@load,
	 };
}

1;
