package KBS2::Formula;

use KBS2::Util;

use Moose;

# # have this object be able to be coerced from a regular formula, check
# # it for the absense of hashes and subroutine references, and then
# # coerce it

# # do duck typing of the formula

has Formula =>
  (
   is => 'rw',
   isa => 'HashRef',
  );

has Logic =>
  (
   is => 'rw',
   isa => 'Str',
  );

sub MarkBoundVariables {
  my ($self, %args) = @_;
  $self->MarkBoundVariablesRecursive
    (
     Subexpression => $self->Formula,
    );
}

sub MarkBoundVariablesRecursive {
  my ($self, %args) = @_;
  my $ref = ref($args{Subexpression});
  if ($ref eq 'ARRAY') {
    foreach my $entry (@{$args{Subexpression}}) {
      MarkBoundVariablesRecursive
	(
	 Subexpression => $entry,
	);
    }
  } else {
    my $res = TermIsVariable($args{Subexpression});
    if (defined $res) {
      # check if it is bound
      print Dumper($res);
    }
  }
}

# sub SubstituteInBindingsForAllCorrespondingAndUnboundVariables {
#   # variables
  

# }

1;
