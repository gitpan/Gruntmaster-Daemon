#!/usr/bin/perl -w
use v5.14;
use strict;
use warnings;

use Test::More tests => 1;
use t::FakeData;
BEGIN { use_ok('Gruntmaster::Daemon') };
