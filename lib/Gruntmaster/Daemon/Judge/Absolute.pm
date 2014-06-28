package Gruntmaster::Daemon::Judge::Absolute;

use 5.014000;
use strict;
use warnings;

use Gruntmaster::Daemon::Constants qw/AC/;

our $VERSION = '5999.000_004';

##################################################

sub judge{
	my $result = pop;
	ref $result ? (result => $result->[0], result_text => $result->[1]) : (result => AC, result_text => 'Accepted')
}

1;
__END__

=encoding utf-8

=head1 NAME

Gruntmaster::Daemon::Judge::Absolute - All-or-nothing ACM-style judge

=head1 SYNOPSIS

  use Gruntmaster::Daemon::Judge::Absolute;
  Gruntmaster::Daemon::Judge::Absolute::judge($result1, $result2, $result3, ...);

=head1 DESCRIPTION

Gruntmaster::Daemon::Judge::Absolute is a judge which returns the result of the last test executed. Gruntmaster::Daemon stops running tests if the judge is Gruntmaster::Daemon::Judge::Absolute and a test fails, so the last test result is Accepted if and only if all tests succeeded.

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.


=cut
