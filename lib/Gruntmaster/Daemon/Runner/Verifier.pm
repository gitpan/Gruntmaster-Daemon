package Gruntmaster::Daemon::Runner::Verifier;

use 5.014000;
use strict;
use warnings;

use Gruntmaster::Daemon::Constants qw/WA/;
use File::Slurp qw/slurp/;
use Log::Log4perl qw/get_logger/;
use Try::Tiny;

our $VERSION = '5999.000_002';

##################################################

sub run{
  my ($test, $meta) = @_;
  get_logger->trace("Running on test $test...");
  $meta->{files}{prog}{run}->($meta->{files}{prog}{name}, fds => [qw/0 input 1 >output/], map {defined $meta->{$_} ? ($_ => $meta->{$_}) : () } qw/timeout olimit mlimit/);

  try {
	$meta->{files}{ver}{run}->($meta->{files}{ver}{name}, fds => [qw/0 input 3 output 1 >result/], args => [$test]);
  } catch {
	die [WA, "Wrong answer"]
  };
  scalar slurp 'result';
}

1;
__END__

=encoding utf-8

=head1 NAME

Gruntmaster::Daemon::Runner::Verifier - Check the program output with a verifier

=head1 SYNOPSIS

  use Gruntmaster::Daemon::Runner::Verifier;
  Gruntmaster::Daemon::Runner::Verifier->run(5, $meta);

=head1 DESCRIPTION

Gruntmaster::Daemon::Runner::Verifier is a runner which uses a verifier program to check the correctness of the output.

The verifier program, C<< $meta->{files}{ver} >>, reads the test input from stdin and the output from fd 3. If the output is incorrect, it should return a nonzero value. Otherwise, it should print the score on this test and then return 0.

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.


=cut
