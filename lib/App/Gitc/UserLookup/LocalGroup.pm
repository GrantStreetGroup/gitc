package App::Gitc::UserLookup::LocalGroup;

use strict;
use warnings;

use App::Gitc::Util qw( project_config );

# Users are local users in a specific group.
sub users {
    my $group = project_config()->{ user_lookup_group };

    return split m{,}, ( getgrnam( $group ) )[3]
}

1;
