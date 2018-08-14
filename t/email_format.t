use strict;
use warnings;

use App::Gitc::Util qw( sendmail );

{
    no warnings 'redefine';

    *App::Gitc::Util::find_sendmail = sub { "t/sendmail-test-email_format.pl" };
    *App::Gitc::Util::project_config = sub { +{} };
}

print "1..1\n";

sendmail({
    to      => 'info@bizowie.com',
    subject => 'Uncompromising ERP',
    content => q{Imagine an ERP that doesn't compromise. One that offers a robust financial suite, combined with operational applications that can automate tedious processes and improve productivity.

Bizowie's full-featured system combines the most powerful ERP backend on the market with a beautiful, user-friendly interface, implementation by business process experts, and nearly infinite flexibility. With us, the sky's the limit.},
    subject_format => '%{changeset} of %{project}: %{subject}',
    project => 'bizowie',
    changeset => 'quickfix1',
});

