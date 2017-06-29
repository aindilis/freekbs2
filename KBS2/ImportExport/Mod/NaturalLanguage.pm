package KBS2::ImportExport::Mod::NaturalLanguage;

use Formalize::UniLang::Client;

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
  $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/internal/freekbs2";
  $self->MyFormalize
    (Formalize::UniLang::Client->new());
  $self->Types
    ({
      "Interlingua" => 1,
      "Natural Language" => 1,
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
  } elsif ($args{InputType} eq "Natural Language") {
    my $res = $self->ConvertNaturalLanguageToInterLingua
      (
       NaturalLanguage => $args{Input},
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
  } elsif ($args{OutputType} eq "Natural Language") {
    my $res = $self->ConvertInterlinguaToNaturalLanguage
      (
       Interlingua => $args{Interlingua},
       PrettyPrint => 0,
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Output => $res->{LogicForm},
	     };
    } else {
      return $res;
    }
  } else {
    return
      {
       Success => 0,
       Reasons => {
		   "Unknown OutputType" => $args{OutputType},
		  },
      };
  }
}

sub ConvertNaturalLanguageToInterLingua {
  my ($self,%args) = @_;
  my $res = $self->MyFormalize->ConvertNaturalLanguageToInterLingua
    (
     NaturalLanguage => $args{NaturalLanguage},
    );
  if ($res->{Success}) {
    return {
	    Success => 1,
	    Interlingua => $res->{Interlingua},
	   };
  } else {
    return $res;
  }
}

sub ConvertInterlinguaToNaturalLanguage {
  my ($self,%args) = @_;
  return {
	  Success => 0,
	  Reasons => {
		      "Not yet implemented" => 1,
		     },
	 };
}

1;
