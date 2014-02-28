package Gruntmaster::Daemon::Format;

use 5.014000;
use strict;
use warnings;
use parent qw/Exporter/;
no if $] > 5.017011, warnings => 'experimental::smartmatch';

use POSIX qw//;
use File::Basename qw/fileparse/;
use File::Slurp qw/write_file/;
use Gruntmaster::Daemon::Constants qw/TLE OLE DIED NZX/;
use Time::HiRes qw/alarm/;
use List::MoreUtils qw/natatime/;
use Log::Log4perl qw/get_logger/;
use IPC::Signal qw/sig_name sig_num/;

our $VERSION = "5999.000_002";
our @EXPORT_OK = qw/prepare_files/;

##################################################

sub command_and_args{
	my ($format, $basename) = @_;

	given($format) {
		"./$basename" when [qw/C CPP PASCAL/];
		"./$basename.exe" when 'MONO';
		java => $basename when 'JAVA';
		perl => $basename when 'PERL';
		python => $basename when 'PYTHON';
		default { die "Don't know how to execute format $format" }
	}
}

sub mkrun{
	my $format = shift;
	sub{
		my ($name, %args) = @_;
		my $basename = fileparse $name, qr/\.[^.]*/;
		my $ret = fork // die 'Cannot fork';
		if ($ret) {
			my $tle;
			local $SIG{ALRM} = sub { kill KILL => $ret; $tle = 1};
			alarm $args{timeout} if exists $args{timeout};
			wait;
			alarm 0;
			my $sig = $? & 127;
			my $signame = sig_name $sig;
			die [TLE, "Time Limit Exceeded"] if $tle;
			die [OLE, 'Output Limit Exceeded'] if $sig && $signame eq 'XFSZ';
			die [DIED, "Crash (SIG$signame)"] if $sig;
			die [NZX, "Non-zero exit status: " . ($? >> 8)] if $?;
		} else {
			my @fds = exists $args{fds} ? @{$args{fds}} : ();
			$^F = 50;
			POSIX::close $_ for 0 .. $^F;
			my $it = natatime 2, @fds;
			while (my ($fd, $file) = $it->()) {
				open my $fh, $file or die $!;
				my $oldfd = fileno $fh;
				if ($oldfd != $fd) {
					POSIX::dup2 $oldfd, $fd or die $!;
					POSIX::close $oldfd or die $!;
				}
			}
			exec 'gruntmaster-exec', $args{mlimit} // 0, $args{olimit} // 0, command_and_args($format, $basename), exists $args{args} ? @{$args{args}} : ();
			exit 42
		}
	}
}

sub prepare{
	my ($name, $format) = @_;
	get_logger->trace("Preparing file $name...");

	$Gruntmaster::Daemon::errors .= `gruntmaster-compile $format $name 2>&1`;
	$Gruntmaster::Daemon::errors .= "\n";
	die 'Compile error' if $?
}

sub prepare_files{
	my $meta = shift;

	for my $file (values $meta->{files}) {
		my ($format, $name, $content) = @{$file}{qw/format name content/};

		$file->{run} = mkrun($format);
		write_file $name, $content;
		prepare $name, $format;
	}
}

1;
__END__

=encoding utf-8

=head1 NAME

Gruntmaster::Daemon::Format - Utility functions for handling source files

=head1 SYNOPSIS

  use Gruntmaster::Daemon::Format qw/prepare_files/;
  prepare_files { files => {
    prog => {
      name => 'prog.pl',
      format => 'PERL',
      content => 'print "Hello, world!"'
    },
    ver => {
      name => 'ver.cpp',
      format => 'CPP',
      content => ...
    },
  }};

=head1 DESCRIPTION

Gruntmaster::Daemon::Format exports utility functions for handling source files.

=over

=item B<prepare_files> I<$meta>

Compiles all the source files in C<< $meta->{files} >>.

=back

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.


=cut
