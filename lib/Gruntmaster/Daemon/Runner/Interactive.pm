package Gruntmaster::Daemon::Runner::Interactive;

use 5.014000;
use strict;
use warnings;

use File::Slurp qw/slurp/;
use Gruntmaster::Daemon::Constants qw/WA/;
use Log::Log4perl qw/get_logger/;
use POSIX qw/mkfifo/;
use Try::Tiny;

our $VERSION = '5999.000_004';

##################################################

sub run{
	my ($test, $meta) = @_;
	get_logger->trace("Running on test $test...");

	mkfifo 'fifo1', 0600 or die $! unless -e 'fifo1';
	mkfifo 'fifo2', 0600 or die $! unless -e 'fifo2';

	my $ret = fork // get_logger->logdie("Fork failed: $!");
	if ($ret) {
		try {
			$meta->{files}{prog}{run}->($meta->{files}{prog}{name}, fds => [qw/0 fifo1 1 >fifo2/], map {defined $meta->{$_} ? ($_ => $meta->{$_}) : () } qw/timeout mlimit/);
		} catch {
			die $_
		} finally {
			waitpid $ret, 0;
		};
		die [WA, "Wrong Answer"] if $?;
	} else {
		try {
			$meta->{files}{ver}{run}->($meta->{files}{ver}{name}, fds => [qw/1 >fifo1 0 fifo2 4 >result/], args => [$test], map {defined $meta->{$_} ? ($_ => $meta->{$_}) : () } qw/timeout mlimit/);
		} catch {
			exit 1;
		};
		exit
	}

	unlink 'fifo1';
	unlink 'fifo2';

	scalar slurp 'result'
}

1;
__END__

=encoding utf-8

=head1 NAME

Gruntmaster::Daemon::Runner::Interactive - Make an interactive verifier talk to the program

=head1 SYNOPSIS

  use Gruntmaster::Daemon::Runner::Interactive;
  Gruntmaster::Daemon::Runner::Interactive::run(5, $meta);

=head1 DESCRIPTION

B<WARNING: This runner is experimental!>

Gruntmaster::Daemon::Runner::Interactive is a runner which runs the program and an interactive verifier in parallel, connecting each program's STDIN to the other's STDOUT. The verifier, C<< $meta->{files}{ver} >>, should return nonzero if the program gives an incorrect answer, or print the test score to fd 4 then return 0 if the answer is correct.

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.


=cut
