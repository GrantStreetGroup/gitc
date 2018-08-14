#!/usr/bin/perl
use strict;
use warnings;

# SLURP!
my $email = do { local $/; <STDIN> };

print "ok\n"
    if $email =~ m{^Subject: quickfix1 of bizowie: Uncompromising ERP$}ms
