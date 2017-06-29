package KBS2::Client::Response;

use KBS2::Util;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Message /

  ];
sub init {
  my ($self,%args) = @_;
  $self->Message($args{Message});
}

sub Bindings {
  my ($self,%args) = @_;
  # do more checking of this initially (check that the response type
  # is correct, etc)
  return $self->Message->Data->{Result}->{Bindings}->[0]
}

sub MatchBindings {
  my ($self,%args) = @_;
  my $variablename = $args{VariableName};
  my @res;
  foreach my $bindingset (@{$self->Bindings}) {
    foreach my $binding (@$bindingset) {
      if (TermIsVariable($binding->[0]) eq $variablename) {
	push @res, $binding->[1];
      }
    }
  }
  return \@res;
}

1;
