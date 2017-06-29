use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'KBS2',
    VERSION_FROM    => 'KBS2.pm',
    ABSTRACT_FROM   => 'KBS2.pm',
    AUTHOR          => 'Andrew Dougherty <andrewdo@frdcsa.org>',
    PREREQ_PM       => {
			# 'Net::Bluetooth' => 0,
    },
);
