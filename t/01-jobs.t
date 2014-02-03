#!/usr/bin/perl -w
use v5.14;
use strict;
use warnings;

use t::FakeData;
BEGIN { Gruntmaster::Data->import }
use Gruntmaster::Daemon;

use Cwd qw/cwd/;
use File::Basename qw/fileparse/;
use File::Slurp qw/read_file/;
use File::Temp qw/tempdir/;
use List::Util qw/sum/;
use Log::Log4perl;
use Test::More;
use YAML::Any qw/LoadFile/;

##################################################

my $loglevel = $ENV{TEST_LOG_LEVEL} // 'OFF';
my $log_conf = <<CONF;
log4perl.category.Gruntmaster.Daemon = $loglevel, stderr

log4perl.appender.stderr                          = Log::Log4perl::Appender::Screen
log4perl.appender.stderr.layout                   = Log::Log4perl::Layout::PatternLayout
log4perl.appender.stderr.layout.ConversionPattern = [\%d] [\%F{1}:\%M{1}:\%L] [\%p] \%m\%n
CONF
Log::Log4perl->init(\$log_conf);

$ENV{PATH}.=':' . cwd;

sub check_job{
  my $job = shift;
  my $jobh = get_job $job;
  my $meta = job_inmeta $job;
  $meta->{result} = $jobh->{result};
  $meta->{result_text} = $jobh->{result_text};
  $meta->{results} = $jobh->{results};
  if (defined $meta->{results}) {
	delete $meta->{results}[$_]{time} for keys $meta->{results};
  }
  is $meta->{result}, $meta->{expected_result}, "Result is correct";
  is $meta->{result_text}, $meta->{expected_result_text}, "Result text is correct";
  is_deeply $meta->{results}, $meta->{expected_results}, "Results are correct";
}

my @problems = exists $ENV{TEST_PROBLEMS} ? map {"t/problems/$_"} split ' ', $ENV{TEST_PROBLEMS} : <t/problems/*>;
plan tests => 3 * sum map { my @temp = <$_/tests/*>; scalar @temp } @problems;
note "Problems to be tested: " . join ', ', @problems;

my $tempdir = tempdir CLEANUP => 1;

my $job = 0;

for my $problem (@problems) {
  my $meta = LoadFile "$problem/meta.yml";
  for (1 .. $meta->{testcnt}) {
	$meta->{infile}[$_ - 1] = read_file "$problem/$_.in" if $meta->{generator} eq 'File';
	$meta->{okfile}[$_ - 1] = read_file "$problem/$_.ok" if $meta->{runner} eq 'File';
  }
  if (exists $meta->{files}) {
	  $_->{content} = read_file "$problem/$_->{name}" for values $meta->{files}
  }
  set_problem_meta scalar fileparse($problem), $meta;

 TODO: {
	local $TODO = $meta->{todo} if exists $meta->{todo};
	note "Now testing problem $meta->{name} ($meta->{description})";

	for my $source (<$problem/tests/*>) {
	  my $meta = LoadFile "$source/meta.yml";
	  $meta->{files}{prog}{content} = read_file "$source/$meta->{files}{prog}{name}";
	  $job++;
	  set_job_inmeta $job, $meta;
	  set_job_problem $job, scalar fileparse $problem;
	  note "Running $meta->{test_name} ($meta->{test_description})...";
	  my $savedcwd = cwd;
	  chdir $tempdir;
	  Gruntmaster::Daemon::process $job;
	  check_job $job;
	  chdir $savedcwd;
	}
  }
}
