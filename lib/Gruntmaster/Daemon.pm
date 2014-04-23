package Gruntmaster::Daemon;

use 5.014000;
use strict;
use warnings;

our $VERSION = '5999.000_003';

use Gruntmaster::Daemon::Constants qw/ERR/;
use Gruntmaster::Daemon::Format qw/prepare_files/;
use Gruntmaster::Data;

use File::Basename qw/fileparse/;
use File::Temp qw/tempdir/;
use JSON qw/decode_json encode_json/;
use Sys::Hostname qw/hostname/;
use Time::HiRes qw/time/;
use Try::Tiny;
use Log::Log4perl qw/get_logger/;
use LWP::UserAgent;

use constant PAGE_SIZE => 10;
use constant FORMAT_EXTENSION => {
	C => 'c',
	CPP => 'cpp',
	MONO => 'cs',
	JAVA => 'java',
	PASCAL => 'pas',
	PERL => 'pl',
	PYTHON => 'py',
};

##################################################

my $db;
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
	get_logger->trace("Purging $_[0]");
	for my $host (@purge_hosts) {
		my $req = HTTP::Request->new(PURGE => "http://$host$_[0]");
		$ua->request($req)
	}
}

sub process{
	my ($job, $jobr) = @_;

	my @results;
	my @full_results = ();
	my $meta;
	our $errors = '';
	try {
		if (ref $job) {
			$meta = $job;
		} else {
			$meta = {
				problem => $jobr->problem->id,
				files => {
					prog => {
						name => 'prog.' . $jobr->extension,
						format => $jobr->format,
						content => $jobr->source,
					},
				},
				map { $_ => $jobr->problem->get_column($_) } qw/generator runner judge testcnt timeout olimit/
			};
			$meta->{tests} = decode_json $jobr->problem->tests if $meta->{runner} eq 'File';

			$meta->{files}{ver} = {
				name => 'ver.' . FORMAT_EXTENSION->{$jobr->problem->verformat},
				format => $jobr->problem->verformat,
				content => $jobr->problem->versource,
			} if $jobr->problem->verformat;
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
		$meta->{results} = \@full_results
	} catch {
		s,(.*) at .*,$1,;
		chomp;
		$meta->{result} = -1;
		$meta->{result_text} = $_;
	};

	get_logger->info("Job result: " . $meta->{result_text});
	return unless $jobr;
	$jobr->update({
		result => $meta->{result},
		result_text => $meta->{result_text},
		results => encode_json $meta->{results},
		$errors ? (errors => $errors) : ()
	});

	my $log = $jobr->contest ? 'ct/' . $jobr->contest->id . '/log' : 'log';
	my $page = int (($job + PAGE_SIZE - 1) / PAGE_SIZE);

	purge "/$log/$job";
	purge "/$log/";
	purge "/$log/st";
	purge "/$log/page/$_" for $page - 1, $page, $page + 1;
}

sub got_job{
	my $job = $_[0];
	my $id = $job->id;
	get_logger->debug("Taking job $id...");
	my $daemon = hostname . ":$$";
	$job->update({daemon => $daemon});
	#if (set_job_daemon $job, hostname . ":$$") {
	if (1) {
		get_logger->debug("Succesfully taken job $id");
		process $id, $job;
		get_logger->debug("Job $id done");
	} else {
		get_logger->debug("Job $id already taken");
	}
}

sub run{
	$db = Gruntmaster::Data->connect('dbi:Pg:');
	Log::Log4perl->init('/etc/gruntmasterd/gruntmasterd-log.conf');
	get_logger->info("gruntmasterd $VERSION started");
	chdir tempdir 'gruntmasterd.XXXX', CLEANUP => 1, TMPDIR => 1;
	while (1) {
		my $job = $db->jobs->search({daemon => undef}, {rows => 1})->first;
		got_job $job if defined $job;
		sleep 2 unless defined $job;
	}
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
