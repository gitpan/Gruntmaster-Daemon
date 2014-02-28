package Gruntmaster::Daemon::Generator::Run;

use 5.014000;
use strict;
use warnings;

use Log::Log4perl qw/get_logger/;

our $VERSION = '5999.000_002';

##################################################

sub generate{
  my ($test, $meta) = @_;
  my $gen = $meta->{files}{gen};
  get_logger->trace("Generating test $test...");
  $gen->{run}->($gen->{name}, args => [ $test ], fds => [qw/1 >input/]);
}

1;
__END__

=encoding utf-8

=head1 NAME

Gruntmaster::Daemon::Generator::Run - Generate tests from program output

=head1 SYNOPSIS

  use Gruntmaster::Daemon::Generator::Run;
  Gruntmaster::Daemon::Generator::Run->generate(5, $meta);

=head1 DESCRIPTION

Gruntmaster::Daemon::Generator::Run is a dynamic test generator. Test C<$i> is the output of running C<< $meta->{files}{gen} >> with argument C<$i>.

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.


=cut
