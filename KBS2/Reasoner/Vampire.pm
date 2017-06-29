package KBS2::Reasoner::Vampire;

use base qw(KBS2::Reasoner);

use Capability::TheoremProving::Vampire::VampireKIF;
use KBS2::ImportExport;
use KBS2::Util;

use Data::Dumper;
use File::Slurp;
use XML::Smart;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Debug Prover MyImportExport /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug} || $UNIVERSAL::debug);
  $self->Prover
    (Capability::TheoremProving::Vampire::VampireKIF->new
     (
      Debug => $self->Debug,
     ));
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
    $self->Prover->StartServer
      (
       # Restart => exists $conf->{'-r'},
      );
  }
}

sub RestartServer {
  my ($self,%args) = @_;
  $self->Prover->StartServer
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
     Theory => $args{Theory},
    );

  my @load = @{$res->{Load}};
  $args{Attributes}->{LoadSize} = scalar @load;

  # ADD THE FORMULA

  my $res2 = $self->MyImportExport->Convert
    (
     Input => [$args{Formula}],
     InputType => "Interlingua",
     OutputType => "KIF String",
    );

  if (! $res2->{Success}) {
    return $res2;
  }
  my $kifstring = $res2->{Output};

  # need to xmlify this kif statement I believe
  # now you may do whatever

  my $bindingslimit = 100;
  my $xmltext = "<$type>$kifstring</$type>";
  if ($type eq "query") {
    # FIXME: figure out if this is a yes-no or a binding
    if (UnboundVariablesInFormulaP(Formula => $args{Formula})) {
      $xmltext = "<$type bindingsLimit='$bindingslimit'>$kifstring</$type>";
    }
  }

  push @load, $xmltext;

  my $querytext = join("\n",@load);
  print Dumper({Query => $querytext}) if $self->Debug;

  my $res3 = $self->MyImportExport->Convert
    (
     Input => [$args{Formula}],
     InputType => "Interlingua",
     OutputType => "KIF Light Domain",
    );
  print Dumper({KIFExport => $res3}) if $self->Debug;
  if ($res3->{Success}) {
    my $res2 = $self->Prover->QueryVampire
      (
       Attributes => $args{Attributes},
       Query => $querytext,
       Formula => $res3->{Output}->[0],
      );

    # FIX ME: if there are results exactly the same as the binding
    # limit, increase the binding limit by orders of magnitude and
    # repeat

    print Dumper({QueryResult => $res2}) if $self->Debug();
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
  foreach my $formula (@{$args{Theory}}) {
    # translate it into KIF

    my $res = $self->MyImportExport->Convert
      (
       Input => [$formula],
       InputType => "Interlingua",
       OutputType => "KIF String",
      );
    if (! $res->{Success}) {
      return $res;
    }
    my $kifstring = $res->{Output};

    # assert it in XML
    my $xmltext = "<assertion>$kifstring</assertion>";
    push @load, $xmltext;

    # now have to translate this result into KBS2 lingua
    # well, just make sure it's okay

    # don't know how to deal with this yet
  }
  return {
	  Load => \@load,
	 };
}

1;

