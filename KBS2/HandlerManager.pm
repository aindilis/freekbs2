package KBS2::HandlerManager;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Handlers /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Handlers({});
  foreach my $file (split /\n/, `ls $UNIVERSAL::systemdir/KBS2/Handler`) {
    if ($file =~ /^(.+)\.pm$/) {
      my $name = $1;
      my $module = "KBS2/Handler/$name.pm";
      require $module;
      my $class = $module;
      $class =~ s/\.pm$//;
      $class =~ s/\//::/g;
      $self->Handlers->{$name} = "$class"->new();
      print Dumper({
		    Class => $class,
		    Name => $name,
		    Module => $module,
		   }) if 0;
    }
  }
}

sub ProcessMessage {
  my ($self,%args) = @_;
  foreach my $value (values %{$self->Handlers}) {
    $value->ProcessMessage(%args);
  }
}

1;
