package Gruntmaster::Daemon::Generator::Undef;

use 5.014000;
use strict;
use warnings;

use Log::Log4perl qw/get_logger/;

our $VERSION = "5999.000_001";

##################################################

sub generate{
  get_logger->trace("Pretending to generate test $_[0]...");
}

1;
__END__

=encoding utf-8

=head1 NAME

Gruntmaster::Daemon::Generator::Undef - Pretend to generate tests

=head1 SYNOPSIS

  use Gruntmaster::Daemon::Generator::Undef;
  Gruntmaster::Daemon::Generator::Undef->generate(5, $meta);

=head1 DESCRIPTION

Gruntmaster::Daemon::Generator::Undef is a noop test generator. It is useful for L<interactive|Gruntmaster::Daemon::Runner::Interactive> problems, where there is no input.

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.


=cut
