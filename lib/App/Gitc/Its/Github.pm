package App::Gitc::Its::Github;

use strict;
use warnings;

=head1 NAME

App::Gitc::Its::Github;

=head1 Synopsis

Support for Github Issue Tracking

=head1 Description

=head1 Methods

=cut

use Pithub::Issues;

use App::Gitc::Util qw(
    project_config
    command_name
    current_branch
);

sub label_service { return 'Github'; }
sub label_issue { return 'Issue'; }

sub get_issue {
    my ($self, $changeset, %params) = @_;

    my $number = $self->issue_number($changeset) or return undef;

    our %github_issue;
    return $github_issue{$number} 
        if exists $github_issue{$number} and not $params{reload};

    my $issue = eval {
        my $github = $self->get_github_object or return;
        my $issue = $self->_get_issue($number); # TODO get github issue
        die "Issue $number didn't return an object" unless $issue;
        return $github_issue{$number} = $issue;
    };

    warn "Error accessing Github: $@" if $@;
    return $issue;
}

sub get_github_object {
    my ($self) = @_;

    our $github;
    if (!$github) {
        my %opts = $self->get_github_opts;
        $github = Pithub::Issues->new(%opts);
    }

    return $github;
}

sub get_github_opts {
# TODO figure out config
}

sub _get_issue {
    my ($self, $number) = @_;

    our $github;
    $github ||= $self->get_github_object;

    my $r = $github->get(issue_id => $number);
    die "Issue $number didn't return an object" unless $r->response->code == 200;

    return $r->content;
}

sub issue_number {
    my ($self, $changeset_or_number) = @_;

    $changeset_or_number =~ s/.*?(\d+)[a-z]?$/$1/;
    
    return $changeset_or_number;
}

sub issue_summary {
    my ($self, $issue) = @_;
    return unless $issue;

    return $issue->{title};
}

sub transition_state {
    my ($self, $args) = @_;
    $args ||= {};
    $args->{with_time} = 1 unless exists $args->{with_time};
    return "Skipping Github changes, as requested by GITC_NO_GITHUB\n"
        if $ENV{GITC_NO_GITHUB};

    my $label = $self->label_issue;

    # validate the arguments
    my ($command, $message, $reviewer, $issue) = @{$args}{qw/command message reviewer issue/};
    die "No message" unless $message;
    $issue = $self->get_issue(current_branch(), reload => 1) unless defined $issue;
    return "NOT CHANGING Github $label: changeset not in Github?\n"
        if not $issue;
    my $state = $self->_states( $command, $args->{target} );
    my ($from, $to, $flag) = @{$state}{qw/from to flag/};

    my ($github_user) = $self->lookup_github_user;
    $message = (getpwuid $>)[6]   # user's name
        . ": $message\n";

    $message = $flag." ".$message if $flag;

    my ( $rc );
    eval {
        my $github = $self->get_github_object or return;
        my $r = $github->comments->create(issue_id => $issue->{number}, data => {body => $message});
        die "Could not comment on issue $issue->{number}" unless $r->response->code == 201;
        $r = $github->labels->remove(issue_id => $issue->{number}, label => $from);
        die "Could not update issue $issue->{number}" unless $r->response->code == 200;
        $r = $github->labels->add(issue_id => $issue->{number}, data => [$to]);
        die "Could not update issue $issue->{number}" unless $r->response->code == 200;
        $rc = ($r->{_content}[0]{name} eq $to); 
        # TODO update github
    };
    die $@ if $@;

    if ($rc) {
        return "Changed Github $label to '$to'\n";
    }
    else {
        return "NOT CHANGING GITHUB $label: currently '%s'\n",
            $self->issue_state($issue);
    }
}

sub issue_state {
    my ($self, $issue) = @_;
    return unless $issue;

    return $issue->{labels}[0]{name};
}

sub state_blocked {
    my $self = shift;
    my ($command, $state) = @_;
    my $statuses = project_config()->{'github_statuses'}{$command}
    or die "No Github statuses for $command";

    #promotions need another level of dereference
    my $block = $statuses->{block};
    return unless $block;

    return 1 if any { $_ eq $state } @{$block};

    return;
}

sub issue_changeset_uri {
    my ($self, $issue) = @_;

    return $issue->{html_url};
}

sub issue_project {
    my ($self, $issue) = @_;
    return unless $issue;

    my ($project) = $issue->{url} =~ m|([^/]+)/issues/\d+$|;
}

sub issue_promotion_notes {
return;
}

sub issue_scheduled_release {
return;
}

sub _states {
    my $self = shift;
    my ( $command, $target ) = @_;
    my $statuses = project_config()->{'github_statuses'}{$command}
        or die "No Github statuses for $command";

    #handle the common case
    if ( not $target ) {
        die "No initial status" unless $statuses->{from};
        die "No final status" unless $statuses->{to};
    return ( $statuses );
    }

    # promotions need another level of dereference
    die "No initial status for target $target" unless $statuses->{$target}{from};
    die "No final status for target $target" unless $statuses->{$target}{to};

    return $statuses->{$target};
}

1;
