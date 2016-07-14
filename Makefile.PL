use 5.010001;
use ExtUtils::MakeMaker;
use ExtUtils::MakeMaker::Config;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

# fix: why MM_Unix->init_dirscan() haven't found these O_FILES?
my $OBJECT = "LevelDB.o";

WriteMakefile(
	NAME              => 'Tie::LevelDB',
	VERSION_FROM      => 'lib/Tie/LevelDB.pm', # finds $VERSION
	PREREQ_PM         => {}, # e.g., Module::Name => 1.1
	($] >= 5.005 ?     ## Add these new keywords supported since 5.005
	  (ABSTRACT_FROM  => 'lib/Tie/LevelDB.pm', # retrieve abstract from module
	   AUTHOR         => 'martin <martin@>') : ()),
	LIBS              => ' -lleveldb',
	DEFINE            => $mk{PLATFORM_CFLAGS}." ".$mk{PORT_CFLAGS} .' -o $@',
	INC               => '-I.',
	#OBJECT            => '$(O_FILES)', # link all the C files too
	OBJECT            => $OBJECT,
	CC                => 'g++ '.$mk{PLATFORM_CFLAGS}." ".$mk{PORT_CFLAGS},
	LD                => 'g++ '.$mk{PLATFORM_LDFLAGS},
	XSOPT             => '-C++',
	TYPEMAPS          => ['perlobject.map' ],
);
