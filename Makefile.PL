use 5.014000;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME              => 'Gruntmaster::Daemon',
  VERSION_FROM      => 'lib/Gruntmaster/Daemon.pm',
  EXE_FILES         => [ 'gruntmasterd', 'gruntmaster-compile', 'gruntmaster-exec' ],
  ABSTRACT_FROM     => 'lib/Gruntmaster/Daemon.pm',
  AUTHOR            => 'Marius Gavrilescu <marius@ieval.ro>',
  MIN_PERL_VERSION  => '5.14.0',
  LICENSE           => 'AGPL_3',
  BUILD_REQUIRES    => {
	qw/Cwd 0
	   File::Copy 0
	   File::Copy::Recursive 0
	   File::Path 0
	   File::Temp 0
	   List::Util 0
	   Log::Log4perl 0
	   Test::More 0
	   YAML::Any 0/,
  },
  SIGN              => 1,
  PREREQ_PM         => {
	qw/Exporter 0
	   File::Basename 0
	   File::Copy 0
	   File::Temp 0
	   List::Util 0
	   Sys::Hostname 0
	   POSIX 0
	   Time::HiRes 0
	   sigtrap 0

	   BSD::Resource 0
	   File::Slurp 0
	   Gruntmaster::Data 0
	   IPC::Signal 0
	   List::MoreUtils 0
	   Log::Log4perl 0
	   Try::Tiny 0/
  },
  META_MERGE        => {
	dynamic_config => 0,
	resources      => {
		repository => 'https://git.ieval.ro/?p=gruntmaster-daemon.git',
	}
  }
);
