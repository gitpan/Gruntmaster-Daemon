package Gruntmaster::Daemon::Judge::Points;

use 5.014000;
use strict;
use warnings;

use Gruntmaster::Daemon::Constants qw/AC REJ/;
use List::Util qw/sum/;
use Log::Log4perl qw/get_logger/;

our $VERSION = '5999.000_001';

##################################################

sub judge{
  no warnings qw/numeric/;
  get_logger->trace("Judging results: @_");
  my $points = sum 0, grep { !ref } @_;
  $points == 100 ? (result => AC, result_text => 'Accepted') : (result => REJ, result_text => "$points points", points => $points)
}

1;
__END__

=encoding utf-8

=head1 NAME

Gruntmaster::Daemon::Judge::Points - 0 to 100 points IOI-style judge

=head1 SYNOPSIS

  use Gruntmaster::Daemon::Judge::Points;
  Gruntmaster::Daemon::Judge::Points->judge($result1, $result2, $result3, ...);

=head1 DESCRIPTION

Gruntmaster::Daemon::Judge::Points is a judge which adds up the given results and returns C<Accepted> if the final score is 100 points or C<X points> otherwise.

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.


=cut
