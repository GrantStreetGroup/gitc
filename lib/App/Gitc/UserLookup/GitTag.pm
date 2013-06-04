package App::Gitc::UserLookup;

use strict;
use warnings;

use App::Gitc::Util qw( git );

# Lets you put your users in a git tag.
sub users {
    return map { s{^user/}{}; $_ } git 'tag -l user/*';    
}
