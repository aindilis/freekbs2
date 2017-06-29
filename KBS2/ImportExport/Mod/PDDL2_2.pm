package KBS2::ImportExport::Mod::PDDL2_2;

print STDERR "warning: PDDL2_2 import export not fully functional\n";

use KBS2::ImportExport;
use KBS2::Util;
use PerlLib::SwissArmyKnife;
use PerlLib::Util;

use Try::Tiny;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Types Debug ParentSelf /

  ];

sub init {
  my ($self,%args) = @_;
  $self->ParentSelf($args{Self});
  $self->Debug($args{Debug} || $UNIVERSAL::debug);
  $self->Types
    ({
      "Interlingua" => 1,
      "PDDL2_2" => 1,
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
  } elsif ($args{InputType} eq "PDDL2_2") {
    # my $res = $self->ConvertPDDL2_2ToInterLinguaHelper
    #   (
    #    PDDL2_2 => $args{Input},
    #   );
    $res = {};
    print Dumper({Res => $res}) if $self->Debug;
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
  } elsif ($args{OutputType} eq "PDDL2_2") {
    my $res = $self->ConvertInterlinguaToPDDL2_2
      (
       Interlingua => $args{Interlingua},
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Output => $res->{PDDL2_2},
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

sub ConvertInterlinguaToPDDL2_2 {
  my ($self,%args) = @_;
  my @results;
  foreach my $term (@{$args{Interlingua}}) {
    my $res1 = $self->ConvertInterlinguaToPDDL2_2Helper(Interlingua => $term);
    print Dumper({Res11 => $res1});
    if ($res1->{Success}) {
      push @results, $res1->{Output};
    } else {
      # throw an error
    }
  }
  return
    {
     Success => 1,
     PDDL2_2 => \@results,
    };
}

sub ConvertInterlinguaToPDDL2_2Helper {
  my ($self,%args) = @_;
  my $res1;
  my $res2 = $self->ConvertFromNestedTermToFunctionFreeFirstOrderPredicateCalculus(Term => $args{Interlingua});
  my @new = sort {SortVarName($a,$b)} @functionfree;
  unshift @new, 'and';
  return
    {
     Success => 1,
     Output => \@new,
    };
}

sub ConvertPDDL2_2ToInterlinguaHelper {
  my ($self,%args) = @_;
  # fixme: implement this
  return {
	  Success => 1,
	  Output => $args{PDDL2_2},
	 };
}

sub ConvertFromNestedTermToFunctionFreeFirstOrderPredicateCalculus {
  my ($self,%args) = @_;
  ++$assertionid;
  $termid = 1;
  return $self->ConvertFromNestedTermToFunctionFreeFirstOrderPredicateCalculusHelper(Term => $args{Term});
}

sub ConvertFromNestedTermToFunctionFreeFirstOrderPredicateCalculusHelper {
  my ($self,%args) = @_;
  my $varname = 'v'.$assertionid.'_'.$termid;
  # my $varname = ['v',$assertionid,$termid];
  my $term = $args{Term};
  my $ref = ref($term);
  if ($ref eq 'ARRAY') {
    my $length = scalar @$term;
    my $predicate = shift @$term;
    if ($length == 1) {
      my $newterm = [$predicate,$varname],;
      push @functionfree, $newterm;
      return {
	      Success => 1,
	      Result => $newterm,
	     };
    } else {
      my @results = ($predicate,$varname);
      my @results2 = ($predicate,$varname);
      foreach my $subterm (@$term) {
	++$termid;
	my $res1 = $self->ConvertFromNestedTermToFunctionFreeFirstOrderPredicateCalculusHelper(Term => $subterm);
	if ($res1->{Success}) {
	  push @results, $res1->{Result};
	  push @results2, $res1->{Result}[1]
	}
      }
      push @functionfree, \@results2;
      return {
	      Success => 1,
	      Result => \@results,
	     };
    }
  } else {
    my $newterm = [$term,$varname];
    push @functionfree, $newterm;
    return {
	    Success => 1,
	    Result => $newterm,
	   };
  }
}

sub SortVarName {
  my ($a,$b) = @_;
  if ($a->[1] =~ /v(\d+)_(\d+)/) {
    my $an = $2;
    if ($b->[1] =~ /v(\d+)_(\d+)/) {
      my $bn = $2;
      # print "<$an><$bn>\n";
      $an <=> $bn;
    }
  }
}

1;
