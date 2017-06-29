package testCodeFirst;
use strict; use warnings;
our $VERSION = 0.1;
use lib '../lib';
use base q{CodeFirst};

sub test :WebMethod(
		name => "sayHello",
		action => "uri:helloWorld/sayHello",
		request_body => "CodeFirst::HelloRequest",
		response_body => "CodeFirst::HelloResponse"
	) {

	# return either [ \%body, \%header ]
	# or \%body
	# or [ Body->new(), Header->new ]
	# or even [ Body->new(), [ Header1->new(), Header2->new() ]]
	# or any combination of that
	return [{

	},
	{

	}];
}

=pod

... would translate to

<element name="test">
	<complexType>
		<sequence>
			<element name="testRequest" type="bam"/>
		</sequence>
	</complexType>
</element>

=cut


=pod

sub test2 :WebMethod(
		action => "test2",
		request_header => "bar",
		reqest_body => "bam",
		response_header => "bam",
		response_body => "baz"
	) {
}

=cut

package main;
use Data::Dumper;
my $test = testCodeFirst->new();

# print Dumper $test->_action_map;
# print Dumper $test->get_transport()->get_action_map_ref();

#print $test->get_wsdl("http://localhost/foo")->toString();
use CodeFirst::Serializer;
use CodeFirst::Deserializer;
use CodeFirst::HelloResponse;
use CodeFirst::HelloRequest;
my $serializer = CodeFirst::Serializer->new();

#print $serializer->serialize("sayHelloResponse", "uri:MooseX.SOAP.CodeFirst", CodeFirst::HelloResponse->new(
#	Result => "Test"
#))->toString;
#
my $xml = $serializer->serialize("sayHello", "uri:MooseX.SOAP.testCodeFirst", CodeFirst::HelloRequest->new(
	Name => 'Flint',
	GivenName => 'Erol',
))->toString;
#print "\n\n";
print $xml, "\n";

print $test->get_wsdl()->toString(), "\n";

my $deserializer = CodeFirst::Deserializer->new();
$deserializer->schema( $test->schema );

print Dumper $deserializer->deserialize($xml, 'CodeFirst::HelloRequest');



1;