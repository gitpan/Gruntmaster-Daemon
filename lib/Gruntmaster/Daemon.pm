package Gruntmaster::Daemon;

use 5.014000;
use strict;
use warnings;

our $VERSION = '5999.000_002';

use Gruntmaster::Daemon::Constants qw/ERR/;
use Gruntmaster::Daemon::Format qw/prepare_files/;
use Gruntmaster::Data;

use File::Basename qw/fileparse/;
use File::Temp qw/tempdir/;
use Sys::Hostname qw/hostname/;
use Time::HiRes qw/time/;
use Try::Tiny;
use Log::Log4perl qw/get_logger/;
use LWP::UserAgent;

use constant PAGE_SIZE => 10;

##################################################

my $ua = LWP::UserAgent->new;
my @purge_hosts = exists $ENV{PURGE_HOSTS} ? split ' ', $ENV{PURGE_HOSTS} : ();

sub safe_can_nodie {
  my ($type, $sub, $name) = @_;

  return unless $name =~ /^\w+$/;
  no strict 'refs';
  my $pkg = __PACKAGE__ . "::${type}::${name}";
  eval "require $pkg" or get_logger->warn("Error while requiring $pkg: $@");
  $pkg->can($sub);
}

sub safe_can {
  my ($type, $sub, $name) = @_;

  safe_can_nodie @_ or get_logger->logdie("No such \l$type: '$name'");
}

sub purge {
	for my $host (@purge_hosts) {
		my $req = HTTP::Request->new(PURGE => "http://$host$_[0]");
		$ua->request($req)
	}
}

sub process{
  my $job = shift;

  my @results;
  my @full_results = ();
  my $meta = {};
  our $errors = '';
  try {
	$meta = job_inmeta $job;
	if (job_problem $job) {
	  local $_ = job_problem $job;
	  my $pbmeta = problem_meta;
	  my %files = exists $meta->{files} ? %{$meta->{files}} : ();
	  $meta = {
		  %$meta,
		  problem => $_,
		  (defined problem_generator() ? (generator => problem_generator) : ()),
		  (defined problem_runner()    ? (runner    => problem_runner)    : ()),
		  (defined problem_judge()     ? (judge     => problem_judge)     : ()),
		  (defined problem_testcnt()   ? (testcnt   => problem_testcnt)   : ()),
		  (defined problem_timeout()   ? (timeout   => problem_timeout)   : ()),
		  (defined problem_olimit()    ? (olimit    => problem_olimit)    : ()),
		  %$pbmeta
	  };
	  $meta->{files} = {%files, %{$pbmeta->{files}}} if exists $pbmeta->{files};
	}

	prepare_files $meta;
	chomp $errors;

	my ($files, $generator, $runner, $judge, $testcnt) = map { $meta->{$_} or die "Required parameter missing: $_"} qw/files generator runner judge testcnt/;

	$generator = safe_can Generator => generate => $generator;
	$runner = safe_can Runner => run => $runner;
	$judge = safe_can Judge => judge => $judge;

	for my $test (1 .. $testcnt) {
	  my $start_time = time;
	  my $result;
	  try {
		$generator->($test, $meta);
		$result = $runner->($test, $meta);
	  } catch {
		$result = $_;
		unless (ref $result) {
		  chomp $result;
		  $result = [ERR, $result];
		}
	  };

	  if (ref $result) {
		get_logger->trace("Test $test result is " . $result->[1]);
		push @full_results, {id => $test, result => $result->[0], result_text => $result->[1], time => time - $start_time}
	  } else {
		get_logger->trace("Test $test result is $result");
		push @full_results, {id => $test, result => 0, result_text => $result, time => time - $start_time}
	  }
	  push @results, $result;
	  last if $meta->{judge} eq 'Absolute' && ref $result
	}

	my %results = $judge->(@results);
	$meta->{$_} = $results{$_} for keys %results;
  } catch {
	s,(.*) at .*,$1,;
	chomp;
	$meta->{result} = -1;
	$meta->{result_text} = $_;
  };

  get_logger->info("Job result: " . $meta->{result_text});
  set_job_result $job, $meta->{result};
  set_job_result_text $job, $meta->{result_text};
  set_job_results $job, \@full_results if scalar @full_results;
  set_job_errors $job, $errors;

  my $log = $Gruntmaster::Data::contest ? "ct/$Gruntmaster::Data::contest/log" : 'log';

  PUBLISH gensrc => ($Gruntmaster::Data::contest // '') . ".$job";
  PUBLISH genpage => "$log/job/$job.html";
  PUBLISH genpage => "$log/index.html";
  PUBLISH genpage => "$log/st.html";
  my $page = ($job + PAGE_SIZE - 1) / PAGE_SIZE;
  PUBLISH genpage => "$log/@{[$page - 1]}.html";
  PUBLISH genpage => "$log/$page.html";
  PUBLISH genpage => "$log/@{[$page + 1]}.html";

  purge "/$log/job/$job";
  purge "/$log/";
  purge "/$log/st";
  purge "/$log/$_" for $page - 1, $page, $page + 1;
}

sub got_job{
	$_[0] =~ /^(\w*)\.(\d+)$/;
	my $job = $2;
	local $Gruntmaster::Data::contest = $1 if $1;
	get_logger->debug("Taking job $job@{[defined $1 ? \" of contest $1\" : '']}...");
	if (set_job_daemon $job, hostname . ":$$") {
		get_logger->debug("Succesfully taken job $job");
		process $job;
		get_logger->debug("Job $job done");
	} else {
		get_logger->debug("Job $job already taken");
	}
}

sub run{
  Log::Log4perl->init('/etc/gruntmasterd/gruntmasterd-log.conf');
  get_logger->info("gruntmasterd $VERSION started");
  chdir tempdir 'gruntmasterd.XXXX', CLEANUP => 1, TMPDIR => 1;
  SUBSCRIBE jobs => \&got_job;
  WAIT_FOR_MESSAGES 86400 while 1
}

1;
__END__

=head1 NAME

Gruntmaster::Daemon - Gruntmaster 6000 Online Judge -- daemon

=head1 SYNOPSIS

  use Gruntmaster::Daemon;
  Gruntmaster::Daemon->run;

=head1 DESCRIPTION

Gruntmaster::Daemon is the daemon component of the Gruntmaster 6000 online judge.

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.


=cut
