package KBS2::Util::Conformance2;

# 12 Conformance

# 12.1 Introduction

# KIF is a highly expressive language. For many, this is a desirable feature; but
# there are disadvantages. One disadvantage is that it complicates the job of
# building fully conforming systems. Another disdvantage is that the resulting
# systems tend to be "heavyweight" (i.e. they are larger and in some cases less
# efficient than systems that employ more restricted languages).

# In order to deal with these problems, the KIF committee in the Fall of 1997
# voted to augment the basic language specification with a set of "conformance
# dimensions". These dimensions are not the same as the "conformance levels" of
# other languages. Rather, each conformance dimension has a variety of levels
# within that dimension.

# A "conformance profile" is a selection of alternatives from each conformance
# dimension. System builders are expected to make choices for each dimension and
# and then ensure that their systems adhere to the resulting comformance profile.
# Systems are expected to use the terminology defined here to share information
# about their conformance profile with other systems (in a protocol-specific
# manner).

# Although this conformance profile scheme is more complex than one based on
# conformance levels, it accommodates varying capabilities and/or computational
# constraints while providing a migration path from more restrictive to more
# expressive.

# 12.2 Conformance Dimensions

# 12.2.1 Introduction

# A conformance dimension is a classification of KIF sentences into conformance
# categories on the basis of a single syntactic criterion. (For example, the
# quantification dimension provides two categories, quantified KIF and
# unquantified KIF, based on whether or not a conforming knowledge base contans
# quantifiers.)

# 12.2.2 Logical Form



my $dimensions = {
		  "Logical Form" => {
				     Description => "The first conformance dimension concerns logical form. There are five basic categories: atomic, conjunctive, positive, logical, and rule-like. Rule-like knowledge bases are further categorized as Horn or non-Horn and recursive or non-recursive.",
				     Entries => [
						 {
						  Description => "A knowledge base is atomic if and only if it contains no logical operators.",
						  Formula => ["atomic", "knowledge base"],
						 },
						 {
						  Description => "A knowledge base is conjunctive if and only if it contains no logical operators except for conjunction."
						  Formula => ["conjunctive", "knowledge base"],
						 },
						 {
						  Description => "A knowledge base is positive if and only if it contains no logical operators except for conjunction and disjunction.",
						  Formula => ["positive", "knowledge base"],
						 },
						 {
						  Description => "A knowledge base is logical if and only if it contains no logical operators except for conjunction, disjunction, and negation.",
						  Formula => ["logical", "knowledge base"],
						 },
						 {
						  Description => "A knowledge base is rule-like if and only if every sentence is either atomic or an implication or reverse implication in which all subexpressions are atomic sentences or negations of atomic sentences. A rule system is a rule-like knowledge base.",
						  Formula => ["rule-like", "knowledge base"],
						 },
						 {
						  Description => "A rule system is Horn if and only if every constituent of every rule is atomic (i.e. no negations allowed). Otherwise, the rule system is said to be non-Horn.",
						  Formula => ["Horn", "rule system"],
						 },
						 # The dependency graph for a rule system is a graph whose nodes are the constants in relational position. There is an edge from the node for a given relation constant p to the node of relation constant q if and only if p appears in the body of a rule whose head predicate is p.
						 {
						  Description => "A rule system is recursive if there is a cycle in its dependency graph. Otherwise, the rule system is said to be non-recursive.",
						  Formula => ["recursive", "rule system"],
						 },
						],
				    },
		  "Term Complexity" => {
					Description => "The nature of terms defines a second conformance dimension. There are two categories: simple and complex.",
					Entries => [
						    {
						     Description => "A knowledge base is simple if and only if the only terms occurring the knowledge base are constants and variables.",
						     Formula => ["simple", "knowledge base"],
						    }
						    ,
						    {
						     Description => "A knowledge base is complex if and only if it contains terms other than constants or variables, e.g. functional terms or logical terms.",
						     Formula => ["complex", "knowledge base"],
						    },
						   ],
				       },
		  "Order" => {
			      Description => "The third conformance dimension concerns the presence or absence of variables.",
			      Entries => [
					  {
					   Description => "A knowledge base is ground, or zeroth-order, if and only if it contains no variables. Otherwise, a knowledge base in nonground.",
					   Formula => ["and",
						       ["ground", "knowledge base"],
						       ["zeroth-order", "knowledge base"],
						      ],
					  }
					  ,
					  {
					   Description => "A knowledge base is first-order if and only if there are no variables in the first argument of any explicit functional term or explicit relational sentence.",
					   Formula => ["and",
						       ["first-order", "knowledge base"],
						       ["nonground", "knowledge base"],
						      ],
					  },
					  {
					   Description => "A knowledge base is higher-order otherwise.",
					   Formula => ["and",
						       ["high-order", "knowledge base"],
						       ["nonground", "knowledge base"],
						      ],
					  },
					 ],

			     },
		  "Quantification" => {
				       Description => "For nonground knowledge bases, there are two alternatives -- quantified and unquantified.",
				       Entries => [
						   {
						    Description => "A nonground knowledge base is quantified if and only if it contains at least one explicit quantifier.",
						    Formula => ["quantified", "knowledge base"],
						   }
						   ,
						   {
						    Description => "A nonground knowledge base is unquantified if and only if it contains no explicit quantifiers.",
						    Formula => ["unquantified", "knowledge base"],
						   },
						  ],
				      },
		  "Metaknowledge" => {
				      Description => "The final conformance dimension concerns the ability to express metaknowledge, e.g. to write sentences about sentences.",
				      Entries => [
						  {
						   Description => "A knowledge base is baselevel if and only if it contains no occurrences of the quote operator or the wtr relation.",
						   Formula => ["baselevel", "knowledge base"],
						  }
						  ,
						  {
						   Description => "Otherwise, the knowledge base is metalevel.",
						   Formula => ["metalevel", "knowledge base"],
						  },
						 ],
				     },
		  "Common Conformance Profiles" => {
						    Description => "A conformance profile is a selection of alternatives for each conformance dimension. Given the dimensions and categories defined in the preceding section, it is possible to define a large number of profiles. A single system may use different profiles in different types of communication. In particular, it is common to use one profile for assertions and another for queries. The following paragraphs define a few common types of systems with their corresponding profiles.",
						    Entries => [
								{
								 Description => "A database system is one in which (1) all assertions are atomic, simple, ground, and baselevel and (2) all queries are positive, simple, unquantified, and baselevel.",
								 Formula => ["database", "system"],
								},
								{
								 Description => "A Horn system (e.g. pure Datalog) is one in which (1) all assertions are rules that are Horn, unquantified, and baselevel and (2) all queries are positive, non-recursive, unquantified, and baselevel.",
								 Formula => ["Horn", "system"],
								},
								{
								 Description => "A relational system is one in which (1) all assertions are rules that are simple, unquantified (but may be non-Horn and non-recursive), and baselevel and (2) all queries are logical, non-recursive, unquantified, and baselevel.",
								 Formula => ["relational", "system"],
								},
								{
								 Description => "A first-order system is one that allows the broadest categories within each conformance dimension except that only first-order expressions are accommodated.",
								 Formula => ["first-order", "system"],
								},
								{
								 Description => "A full KIF system is one that accepts the broadest categories within each conformance dimension, i.e. any KIF knowledge base is acceptable in any context.",
								 Formula => ["full KIF", "system"],
								},
							       ],
						   },
		 };

# 12.4 Dealing with Differences in Conformance Profiles

# The existence of multiple conformance profiles raises the question of what
# happens when systems with different profles must communicate.

# Whenever the conformance profile of a receiver is known, a sender should avoid
# sending expressions that fall outside the receiver's conformance profile.

# Unfortunately, this rule cannot be enforced in all situations. In some cases,
# conformance information about receivers is unavailable; and, even when
# conformance information is available, it may be desirable to send a message
# that falls outside a receiver's profile, e.g. it may be most efficient for a
# sender to broadcast a single knowledge base to a large number of receivers with
# differing conformance profiles rather than sending different knowledge bases to
# each receiver.

# Whenever a receiver receives a non-conforming expression, it is free to ignore
# the expression, even though it may be able to make sense of portions of that
# expression. If the receiver ignores a non-conforming expression and the sender
# requests a reply, the receiver should report a failure.

1;
