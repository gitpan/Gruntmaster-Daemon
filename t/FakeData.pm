package Gruntmaster::Data;
use v5.14;
use warnings;
use parent qw/Exporter/;

BEGIN { $INC{'Gruntmaster/Data.pm'} = 1; }

my (@jobs, %problems);

sub job_inmeta				{ $jobs[$_[0]]{inmeta} };
sub set_job_inmeta			{ $jobs[$_[0]]{inmeta} = $_[1] };
sub job_problem			{ $jobs[$_[0]]{problem} };
sub set_job_problem		{ $jobs[$_[0]]{problem} = $_[1] };

sub set_job_result			{ $jobs[$_[0]]{result} = $_[1] };
sub set_job_result_text	{ $jobs[$_[0]]{result_text} = $_[1] };
sub set_job_results		{ $jobs[$_[0]]{results} = $_[1] };
sub set_job_errors			{ $jobs[$_[0]]{errors} = $_[1] };
sub set_job_daemon			{ $jobs[$_[0]]{daemon} = $_[1] };

sub problem_meta			{ $problems{$_[0]}{meta} }
sub set_problem_meta		{ $problems{$_[0]}{meta} = $_[1] }

sub get_job { $jobs[$_[0]] }

sub PUBLISH {}
sub SUBSCRIBE {}
sub WAIT_FOR_MESSAGES {}

our @EXPORT = do {
	no strict 'refs';
	grep { $_ =~ /^[a-zA-Z]/ and exists &$_ } keys %{__PACKAGE__ . '::'};
};

1
