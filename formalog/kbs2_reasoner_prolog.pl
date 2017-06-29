:- dynamic markedDynamic/1.

:- consult('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl').

kbs2ReasonerPrologInit :-
	kbs2Query('KBS2_Reasoner_Prolog','KBS2_Reasoner_Prolog_Yaswi',['all-asserted-knowledge','all-contexts'],[perl_object('UniLang::Util::Message',List)]),
	member(=>('Data',List2),List),
	member(=>('Result',List3),List2),
	member([Context,AssertionList],List3),
	convertListToTerm(AssertionList,Assertion),
	Assertion =.. [Predicate|Args],
	length(Args,Arity),
	record(Context,Predicate,Arity,Assertion),
	fail.
kbs2ReasonerPrologInit.

record(Context,Predicate,Arity,Assertion) :-
	not(markedDynamic(Context:Head/Arity)) -> (assert(markedDynamic(Context:Head/Arity)),false) ; false.
record(Context,Predicate,Arity,Assertion) :-
	see([Context:Predicate/Arity,Assertion]),
	assert(Context:Assertion).

convertListToTerm([Head|Tail],Assertion) :-
	convertTailToListOfSubterms(Tail,Subterms),
	Assertion =.. [Head|Subterms].
convertListToTerm(Head,Head) :-
	atomic(Head).

convertTailToListOfSubterms(Tail,Subterms) :-
	findall(SubAssertion,getSubassertions(Tail,SubAssertion),Subterms).

getSubassertions(Tail,SubAssertion) :-
	member(Item,Tail),
	convertListToTerm(Item,SubAssertion).


%% [perl_object('UniLang::Util::Message',[=>('Contents',''),=>('Date','Fri Apr 22 18:58:58 CDT 2016'),=>('DataFormat','Perl'),=>('Data',[=>('Result',[['Org::FRDCSA::PaperlessOffice::Cabinet::paperport',['has-datetimestamp',['document-fn',paperport,'JRHE9y339i'],'1265209837']],['Org::FRDCSA::PaperlessOffice::Cabinet::paperport',['has-folder',['document-fn',paperport,qOsErYXlfM],'Samples']]



:- kbs2ReasonerPrologInit.