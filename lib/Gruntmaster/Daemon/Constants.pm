package Gruntmaster::Daemon::Constants;

use 5.014000;
use strict;
use warnings;
use parent qw/Exporter/;

our $VERSION = "5999.000_001";

use constant +{
  # Accepted
  AC => 0,

  # Internal server error
  ERR => -1,

  # All other errors
  WA => 1,
  NZX => 2,
  TLE => 3,
  OLE => 4,
  DIED => 5,
  REJ => 10,
};

our @EXPORT_OK = qw/AC ERR WA NZX TLE OLE DIED REJ/;

1;
__END__

=encoding utf-8

=head1 NAME

Gruntmaster::Daemon::Constants - Constants for the Gruntmaster daemon

=head1 SYNOPSIS

  use Gruntmaster::Daemon::Constants qw/WA NZX/;
  ...
  return [NZX, 'Non-zero exit status'] if $status;
  return [WA, 'Wrong answer'] unless is_correct($answer);

=head1 DESCRIPTION

Gruntmaster::Daemon::Constants provides constants which are used in more than one module.

The constants are:

=over

=item B<AC> The 'Accepted' job result.

=item B<ERR> The 'Internal server error' job result.

=item B<WA> The 'Wrong answer' job result.

=item B<NZX> The 'Non-zero exit status' job result.

=item B<TLE> The 'Time limit exceeded' job result.

=item B<OLE> The 'Output limit exceeded' job result.

=item B<DIED> The 'Crash' job result. Used when a program is killed by a signal.

=item B<REJ> The 'Rejected' job result. Used when none of the above is appropriate.

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
