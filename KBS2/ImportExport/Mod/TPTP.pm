package KBS2::ImportExport::Mod::TPTP;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Types Debug /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug} || $UNIVERSAL::debug);
  $self->Types
    ({
      "Interlingua" => 1,
      "TPTP" => 1,
     });
}

sub Convert {
  my ($self,%args) = @_;
  if ($args{Input}) {
    if (exists $self->Types->{$args{InputType}}) {
      my $result = $self->ConvertToInterlingua
	(
	 Input => $args{Input},
	 InputType => $args{InputType},
	);
      if ($result->{Success}) {
	return $self->ConvertToOutputType
	  (
	   Interlingua => $result->{Interlingua},
	   OutputType => $args{OutputType},
	  );
      } else {
	return $result;
      }
    }
  }
}

sub ConvertToInterlingua {
  my ($self,%args) = @_;
  # takes as args InputType and Input
  if ($args{InputType} eq "Interlingua") {
    # it is already in interlingua format
    return {
	    Success => 1,
	    Interlingua => $args{Input},
	   };
  } elsif ($args{InputType} eq "TPTP") {
    my $res = $self->ConvertTPTPToInterLingua
      (
       TPTP => $args{Input},
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Interlingua => $res->{Interlingua},
	     };
    } else {
      return $res;
    }
  } else {
    return {
	    Success => 0,
	    Reasons => {
			"Unknown InputType" => Dumper($args{InputType}),
		       }
	   };
  }
}

sub ConvertToOutputType {
  my ($self,%args) = @_;
  # takes as args OutputType and Interlingua
  if ($args{OutputType} eq "Interlingua") {
    return {
	    Success => 1,
	    Output => $args{Interlingua},
	   };
  } elsif ($args{OutputType} eq "TPTP") {
    my $res = $self->ConvertInterlinguaToTPTP
      (
       Interlingua => $args{Interlingua},
       PrettyPrint => 0,
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Output => $res->{TPTP},
	     };
    } else {
      return $res;
    }
  } else {
    return {
	    Success => 0,
	    Reasons => {
			"Unknown OutputType" => $args{OutputType},
		       }
	   };
  }
}

sub ConvertTPTPToInterLingua {
  my ($self,%args) = @_;
  my @interlingua;
  foreach my $lf (@{$args{TPTP}}) {
    my $res = $self->ProcessLF
      (
       TPTP => $lf,
      );
    if (! $res->{Success}) {
      return $res;
    }
    push @interlingua, $res->{Interlingua};
  }
  return {
	  Success => 1,
	  Interlingua => \@interlingua,
	 };
}

sub ConvertInterlinguaToTPTP {
  my ($self,%args) = @_;
  return {
	  Success => 0,
	  Reasons => {
		      "Not yet implemented" => 1,
		     },
	 };
}

sub CleanTerm {
  my ($self,%args) = @_;
  my @term;
  my $term = $args{Term};
  if ($term =~ /^(.+?)\s*\((.+)\)$/) {
    my $predicate = $1;
    my $args = $2;
    push @term, $predicate;
    foreach my $shouldbevar (split /,/, $args) {
      if ($shouldbevar =~ /\+/) {
	push @term, ["xwn_joined", map {MakeVariable(String => $_)} split /\+/, $shouldbevar];
      } else {
	push @term, MakeVariable(String => $shouldbevar);
      }
    }
  } else {
    return {
	    Success => 0,
	    Reasons => {
			"Term ERROR: $term" => 1,
		       },
	   };
  }
  return {
	  CleanedTerm => \@term,
	 };
}

sub MakeVariable {
  my %args = @_;
  my $string = $args{String};
  $string =~ s/\s+//g;
  return \*{"::?$string"};
}

1;
