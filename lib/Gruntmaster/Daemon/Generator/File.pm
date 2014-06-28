package Gruntmaster::Daemon::Generator::File;

use 5.014000;
use strict;
use warnings;

use File::Copy qw/copy/;
use File::Slurp qw/write_file/;
use Log::Log4perl qw/get_logger/;

our $VERSION = "5999.000_004";

##################################################

sub generate{
	my ($test, $meta) = @_;
	get_logger->trace("Generating test $test ...");
	if (exists $meta->{infile}) {
		write_file 'input', $meta->{infile}[$test - 1]
	} else {
		copy "/var/lib/gruntmasterd/pb/$meta->{problem}/$test.in", 'input'
	}
}

1;
__END__

=encoding utf-8

=head1 NAME

Gruntmaster::Daemon::Generator::File - Generate tests from files

=head1 SYNOPSIS

  use Gruntmaster::Daemon::Generator::File;
  Gruntmaster::Daemon::Generator::File::generate(5, $meta);

=head1 DESCRIPTION

Gruntmaster::Daemon::Generator::File is a static test generator.
If C<< $meta->{infile} >> exists, the input for test C<$i> is C<< $meta->{infile}[$i - 1] >>.
Otherwise, the input for test C<$i> is F<< /var/lib/gruntmasterd/pb/$meta->{problem}/$test.in >>.

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.


=cut
