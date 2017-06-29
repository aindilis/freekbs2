package KBS2::ImportExport::Mod::Verber;

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
      "Verber" => 1,
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
  } elsif ($args{InputType} eq "Verber") {
    my $res = $self->ConvertVerberToInterLingua
      (
       Verber => $args{Input},
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Interlingua => $res->{Interlingua},
	     };
    } else {
      return $res;
    }
  } elsif ($args{InputType} eq "Verber String") {
    my $res = $self->ConvertVerberStringToInterLingua
      (
       Verber => $args{Input},
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
  } elsif ($args{OutputType} eq "Verber") {
    my $res = $self->ConvertInterlinguaToVerber
      (
       Interlingua => $args{Interlingua},
       PrettyPrint => 0,
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Output => $res->{Verber},
	     };
    } else {
      return $res;
    }
  } elsif ($args{OutputType} eq "Verber String") {
    my $res = $self->ConvertInterlinguaToVerberString
      (
       Interlingua => $args{Interlingua},
       PrettyPrint => 0,
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Output => $res->{VerberString},
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

sub ConvertVerberToInterLingua {
  my ($self,%args) = @_;
  my @interlingua;
  # print Dumper({Args => \%args});
  foreach my $lf (@{$args{Verber}}) {
    my $res = $self->ProcessLF
      (
       LogicForm => $lf,
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

sub ConvertVerberStringToInterLingua {
  my ($self,%args) = @_;
  my @interlingua;
  # print Dumper({Args => \%args});
  foreach my $lf (@{$args{Verber}}) {
    my $res = $self->ProcessLF
      (
       LogicForm => $lf,
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

sub ConvertInterlinguaToVerber {
  my ($self,%args) = @_;
  return {
	  Success => 0,
	  Reasons => {
		      "Not yet implemented" => 1,
		     },
	 };
}

sub ConvertInterlinguaToVerberString {
  my ($self,%args) = @_;
  return {
	  Success => 0,
	  Reasons => {
		      "Not yet implemented" => 1,
		     },
	 };
}

1;
