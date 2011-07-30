use 5.010001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my %mk;
system("sh ./build_detect_platform");
open(MK,"build_config.mk") or die;
map { $mk{$1} = $2 if(/^(.+?)\=(.*)$/) } <MK>;
close(MK);

# fix: why MM_Unix->init_dirscan() haven't found these O_FILES?
$OBJECT = "LevelDB.o db/builder.o db/db_impl.o db/db_iter.o db/filename.o db/dbformat.o db/log_reader.o db/log_writer.o db/memtable.o db/repair.o db/table_cache.o db/version_edit.o db/version_set.o db/write_batch.o port/port_posix.o table/block.o table/block_builder.o table/format.o table/iterator.o table/merger.o table/table.o table/table_builder.o table/two_level_iterator.o util/arena.o util/cache.o util/coding.o util/comparator.o util/crc32c.o util/env.o util/env_posix.o util/hash.o util/histogram.o util/logging.o util/options.o util/status.o";


WriteMakefile(
    NAME              => 'Tie::LevelDB',
    VERSION_FROM      => 'lib/Tie/LevelDB.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Tie/LevelDB.pm', # retrieve abstract from module
       AUTHOR         => 'martin <martin@>') : ()),
    LIBS              => [''], # e.g., '-lm'
    DEFINE            => ($mk{SNAPPY} ? '-DSNAPPY':'').
							" ".$mk{PLATFORM_CFLAGS}." ".$mk{PORT_CFLAGS}
							.' -o $@',
    INC               => '-I. -Iinclude -Iport -Iutil',
    #OBJECT            => '$(O_FILES)', # link all the C files too
    OBJECT            => $OBJECT,

	'CC'			    => 'g++ '.$mk{PLATFORM_CFLAGS}." ".$mk{PORT_CFLAGS},
	'LD'			    => 'g++ '.$mk{PLATFORM_LDFLAGS},
    'XSOPT'             => '-C++',
    'TYPEMAPS'          => ['perlobject.map' ],
);

