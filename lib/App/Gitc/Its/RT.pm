package App::Gitc::Its::RT;
use strict;
use warnings;

# ABSTRACT: Support for RT ITS (Issue Tracking System)
# VERSION

use App::Gitc::Util qw( project_config );

=head1 DESCRIPTION

=head1 METHODS

=head2 label_*

Just the name of this ITS.

=cut

sub label_service { 'RT' }
sub label_issue { 'RT' }

sub issue_number { shift->{ changeset } }

=head2 its_for_changeset

Basically a convoluted 'new'.

=cut

sub its_for_changeset {
    my ( $class, $changeset ) = @_;

    my $project_config = project_config();

    # Removes non-digits.
    $changeset =~ tr/0-9//cd;

    my $self = {
        rt_url      => $project_config->{ rt_url },
        rt_user     => $project_config->{ rt_user },
        rt_password => $project_config->{ rt_password },
        changeset   => $changeset,
    };

    bless $self, $class;

    return $self;
}

=head2 run_rt

Runs RT with the necessary commands, dies if something went wrong.

=cut

sub run_rt {
    my ( $self, @params ) = @_;

    open my $fh, '-|', '/usr/bin/rt', @params;

    chomp( my @output = <$fh> );

    close $fh;

    if ( $? >> 8 ) {
        die "/usr/bin/rt " . join( q{ }, @params ) . " failed.\n";
    }

    return join qq{\n}, @output;
}

=head2 transition_state

Method that is called in ::Util to transition a ticket from one status to
another.

=cut

sub transition_state {
    my ( $self, $params ) = @_;

    my $command = $params->{ command };

    my $config = project_config();

    my $command_config = $config->{ rt_statuses }->{ $command };

    if ( $params->{ command } eq 'promote' ) {
        $command_config = $command_config->{ $params->{ target } };
    }

    die "Invalid command for RT: $command.\n" if !$command_config;

    my $qr = qr/$command_config->{ from }/;

    my $current_status = $self->issue_state();

    if ( $current_status !~ $qr ) {
        warn "Ticket is currently in status $current_status. Not changing.\n";
    }

    $self->run_rt(
        'comment', $self->{ changeset },
        '-m', $params->{ message }
    );

    $self->run_rt(
        qw( edit -t ticket ), $self->{ changeset },
        'set', "status=$command_config->{ to }",
    );
}

=head2 issue_state

Returns the current state of the issue.

=cut

sub issue_state {
    my ( $self ) = @_;

    my $info = $self->run_rt(
        qw( show -t ticket -s ), $self->{ changeset }
    );

    my ( $current_status ) = $info =~ m{^Status:\s+(.+)\s*$}im;

    return $current_status;    
}

=head2 get_issue

Returns an issue from the system.  Because this system initialises ealier, we
just return ourself.

=cut

sub get_issue {
    my ( $self ) = @_;

    return $self;
}

=head2 issue_changeset_uri

Returns an issue's URI.

=cut

sub issue_changeset_uri {
    my ( $self ) = @_;

    my $config = project_config();
    my $uri    = $config->{ rt_url };

    return "$uri/Ticket/Display.html?id=$self->{ changeset }\n";
}

1;
