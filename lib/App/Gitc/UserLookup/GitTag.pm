package App::Gitc::UserLookup;

use strict;
use warnings;

# ABSTRACT: App::Gitc::Util helper
# VERSION

use App::Gitc::Util qw( git );

# Lets you put your users in a git tag.
sub users {
    return map { s{^user/}{}; $_ } git 'tag -l user/*';    
}
