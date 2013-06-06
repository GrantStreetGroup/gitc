package App::Gitc::Reversible;
use strict;
use warnings;
use base 'Exporter';

BEGIN {
    our @EXPORT = qw(
        failure_warning
        to_undo
        reversibly
    );
};

# ABSTRACT: Simple reversible computation for gitc
# VERSION

=head1 SYNOPSIS

    use App::Gitc::Reversible;
    reversibly {
        # do something with a side effect
        open my $fh, '>', '/tmp/file' or die;

        # specify how that side effect can be undone
        # (assuming '/tmp/file' did not exist before)
        to_undo { close $fh; unlink '/tmp/file' };

        operation_that_might_die($fh);
        operation_that_might_get_SIGINTed($fh);
    });

=head1 DESCRIPTION

Perform computations and automatically reverse their side effects if the
computations fail.  One often wants to perform a series of operations, some of
which have side effects, and properly "undo" all side effects if something
goes wrong with one of the operations.  By invoking your code L</reversibly>,
the undos are handled for you.

=head1 SUBROUTINES

=head2 failure_warning($message)

Call this sub from inside the coderef argument of L</reversibly> to produce a
warning if the coderef fails.  Only one message is active at a time.  In other
words, subsequent calls to L</failure_warning> change the warning that would
be produced.

=cut

sub failure_warning {
    my ($message) = @_;
    our $failure_warning = $message;
}


=head2 to_undo

Call this sub from inside the coderef argument of L</reversibly> to provide a
coderef which should be executed on failure.  It can accept a bare code block
like:

    to_undo { print "undo something\n" };

See L</reversibly> for further information.

=cut

sub to_undo (&) {
    my ($code) = @_;
    push our(@undo_stack), $code;
    return;
}

=head2 reversibly

Executes a code reference (C<$code>) allowing operations with side effects to
be automatically reversed if C<$code> fails or is interrupted.  For example:

    reversibly {
        print "hello\n";
        to_undo { print "goodbye\n" };
        die "uh oh\n" if $something_bad;
    };

just prints "hello" if C<$something_bad> is false.  If it's true, then both
"hello" and "goodbye" are printed and the exception "uh oh" is rethrown.

Upon failure, any code refs provided by calling L</to_undo> are executed in
reverse order.  Conceptually, we're unwinding the stack of side effects that
C<$code> performed up to the point of failure.

If C<$code> is interrupted with SIGINT, the side effects are undone and an
exception "SIGINT\n" is thrown.

Nested calls to C<reversibly> are handled correctly.

=cut

sub reversibly(&) {
    my ($code) = @_;

    local $SIG{INT} = sub { die "SIGINT\n" };
    local $SIG{TERM} = sub { die "SIGTERM\n" };
    local our(@undo_stack);  # to allow nested, reversible computations

    my $rc = eval { $code->() };
    if ( my $exception = $@ ) {
        our $failure_warning;
        warn $failure_warning if defined $failure_warning;
        for my $undo ( reverse @undo_stack ) {
            eval { $undo->() };
            warn "Exception during undo: $@" if $@;
        }

        # rethrow the exception, with commentary
        die "\nThe exception that caused rollback was: $exception";
    }
}


=head1 SEE ALSO

L<Data::Transaactional>, L<Object::Transaction>.

=cut

1;
