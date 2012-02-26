use 5.008008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Lexer::Lex',
    VERSION_FROM      => 'lib/Lexer/Lex.pm', # finds $VERSION
    PREREQ_PM         => {IO::Scalar => 2.0}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Lexer/Lex.pm', # retrieve abstract from module
       AUTHOR         => 'Dmitriy Ryajov <dryajov@>') : ()),
);
