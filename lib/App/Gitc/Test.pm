package App::Gitc::Test;
use strict;
use warnings;

# ABSTRACT: Test class for gitc
# VERSION

use Test::More '';
use App::Gitc::Util qw( branch_point unpromoted );
use Exporter 'import';

BEGIN {
    our @EXPORT = qw( branch_point_is unpromoted_is );
};

sub branch_point_is {
    my ( $ref, $expected, $message ) = @_;
    my $sha1 = branch_point($ref);
    Test::More::is( $sha1, $expected, $message );
}

sub unpromoted_is {
    my ( $source, $target, $expected, $message ) = @_;
    my @changesets = unpromoted( $source, $target );
    Test::More::is_deeply(\@changesets, $expected, $message);
}

1;
