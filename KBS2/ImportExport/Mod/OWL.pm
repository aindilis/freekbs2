package KBS2::ImportExport::OWL;

use OBO::Parser::OWLParser;

use Data::Dumper;
use File::Slurp;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyParser
    (OBO::Parser::OWLParser->new);
}

sub Import {
  my %args = @_;
  my $c;
  if ($args{Text}) {
    # $c = $args{Text};
  } elsif ($args{File}) {
    my $ontology = $my_parser->work($args{File});
    print Dumper($ontology);
  }

}

sub Export {
  my ($self,%args) = @_;
  print "Not yet implemented\n";
}

1;
