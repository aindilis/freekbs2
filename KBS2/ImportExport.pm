package KBS2::ImportExport;

use Manager::Misc::Light2;
use KBS2::Util;
use KBS2::ImportExport::Guess;

use Data::Dumper;
use File::Slurp;
use MIME::Base64;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyLight Types Debug MyGuess /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyLight
    (Manager::Misc::Light2->new);
  $self->Debug(
	       # 1 ||
	       $args{Debug} || $UNIVERSAL::debug || 0);
  $self->Types
    ({
      "Interlingua" => 1,
      "Perl String" => 1,
      "Emacs String" => 1,
      "CycL String" => 1,

      #       # The following should be added at some point
      #       "OWL String" => 0,
      #       "RDF String" => 0,
      #       "N3 String" => 0,
      #       "RDF Data Structure" => 0,
      #       "N3 Data Structure" => 0,
      #       "TPTP String" => 0,
      #       "Natural Language Sentence" => 0,
      #       "Natural Language Text" => 0,
      #       "WSD Logic Form" => 0,
      #       "RelEx Logic Form" => 0,
      #       "FreeLogicForm Logic Form" => 0,
      #       "CAndC Logic Form" => 0,
      #       "Formalize Result" => 0,
      #       "KBS2::Object::Theory" => 0,
      #       "KBS2::Object::Formula" => 0,
      #       "KBS2::Object::Formula String" => 0,
      #       "KBS2::Object::Formula Condensed String" => 0,
     });

  my @mods = qw(KIF CycL LogicForm Prolog SWIPL PDDL2_2);
  foreach my $mod (@mods) {
    # load this service up, added it to keys
    # my $dir = "$UNIVERSAL::systemdir/KBS2/ImportExport/Mod";
    my $dir = "/var/lib/myfrdcsa/codebases/internal/freekbs2/KBS2/ImportExport/Mod";
    my $name = $mod;
    $name =~ s/::/\//g;
    require "$dir/$name.pm";
    my $module = "KBS2::ImportExport::Mod::$mod"->new
      (
       Self => $self,
       Debug => $self->Debug,
      );
    foreach my $type (keys %{$module->Types}) {
      # print Dumper({Type => $type});
      $self->Types->{$type} = $module;
    }
  }
}

sub Convert {
  my ($self,%args) = @_;
  if ($args{Input}) {
    if (! exists $args{InputType} and exists $args{GuessInputType}) {
      if (! $self->MyGuess) {
	$self->MyGuess
	  (KBS2::ImportExport::Guess->new
	   (ImportExport => $self));
      }
      my $res = $self->MyGuess->Guess(Formulae => $args{Input});
      print Dumper($res) unless $args{Quiet};
      if ($res->{Success}) {
	# hopefully there is only one key
	$args{InputType} = [keys %{$res->{Result}}]->[0];
	if ($args{InputType} eq 'CycL Light Domain') {
	  $args{InputType} = 'CycL String';
	}
	print "Guessed InputType: $args{InputType}\n" if $self->Debug;
      } else {
	warn "No input type known\n";
      }
    }
    if (exists $self->Types->{$args{InputType}}) {
      my $result = $self->ConvertToInterlingua
	(
	 Input => $args{Input},
	 InputType => $args{InputType},
	);
      print Dumper({
		    ResRESSY => $result,
		    OutputType => $args{OutputType},
		   }) if $self->Debug;
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
  # convert to a perl formula
  if ($args{InputType} eq "Interlingua") {
    return {
	    Success => 1,
	    Interlingua => $args{Input},
	   };
  } elsif ($args{InputType} eq "Perl Formula") {
    return {
	    Success => 1,
	    Interlingua => [$args{Input}],
	   };
  } elsif ($args{InputType} eq "Perl Formulae") {
    return {
	    Success => 1,
	    Interlingua => $args{Input},
	   };
  } elsif ($args{InputType} eq "Perl String") {
    return {
	    Success => 1,
	    Interlingua => StringToFormulae
	    (
	     FromType => "Perl",
	     String => $args{Input},
	    ),
	   };
  } elsif ($args{InputType} eq "Emacs String") {
    return {
	    Success => 1,
	    Interlingua => StringToFormulae
	    (
	     FromType => "Emacs",
	     String => $args{Input},
	    ),
	   };
  } else {
    # check for it in one of the mods
    if (exists $self->Types->{$args{InputType}}) {
      my $ref = ref $self->Types->{$args{InputType}};
      if ($ref ne "") {
	return $self->Types->{$args{InputType}}->ConvertToInterlingua
	  (
	   Input => $args{Input},
	   InputType => $args{InputType},
	  );
      } else {
	return {
		Success => 0,
		Reasons => {
			    "Not Yet Implemented" => 1,
			   },
	       };
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
}

sub ConvertToOutputType {
  my ($self,%args) = @_;
  if ($args{OutputType} eq "Interlingua") {
    return {
	    Success => 1,
	    Output => $args{Interlingua},
	   };
  } elsif ($args{OutputType} eq "Perl Formula") {
    return {
	    Success => 1,
	    Output => $args{Interlingua}->[0],
	   };
  } elsif ($args{OutputType} eq "Perl Formulae") {
    return {
	    Success => 1,
	    Output => $args{Interlingua},
	   };
  } elsif ($args{OutputType} eq "Perl String") {
    return {
	    Success => 1,
	    Output => FormulaeToString
	    (
	     Type => "Perl",
	     Formulae => $args{Interlingua},
	    ),
	   };
  } elsif ($args{OutputType} eq "Emacs String") {
    my $output;
    my $item = $args{Interlingua}->[0];
    my $ref = ref($item);
    if ($ref eq 'ARRAY') {
      $output = FormulaeToString
	(
	 Type => "Emacs",
	 Formulae => $args{Interlingua},
	);
    } elsif ($ref eq "GLOB") {
      $output = PerlGlobToStringEmacs(Glob => $item);
    } else {
      $output = EmacsQuote(Arg => $item);
    }
    return {
	    Success => 1,
	    Output => $output,
	   };
  } else {
    # check for it in one of the mods
    if (exists $self->Types->{$args{OutputType}}) {
      my $ref = ref $self->Types->{$args{OutputType}};
      if ($ref ne "") {
	return $self->Types->{$args{OutputType}}->ConvertToOutputType
	  (
	   Interlingua => $args{Interlingua},
	   OutputType => $args{OutputType},
	  );
      } else {
	return {
		Success => 0,
		Reasons => {
			    "Not Yet Implemented" => 1,
			   },
	       };
      }
    } else {
      return {
	      Success => 0,
	      Reasons => {
			  "Unknown OutputType" => Dumper($args{OutputType}),
			 }
	     };
    }
  }
}

1;
