package App::Gitc::Config;
use strict;
use warnings;

require Exporter;
our @ISA = qw( Exporter );
our @EXPORT = qw( $git_config );

=head1 Synopsis

Configuration file for gitc

=head1 Description

Contains a set of hashref configurations for each project.


The '%config' hash contains the configuration as follows...

repo_base: This is the git username@server that contains the repo
projects: each top level key is the repo/project name (matches repo name 'gitc setup cbs-taxsys' looks up the 'cbs-taxsys' entry)
          '_default' is a special case containing the base/default configuration
          the name is case sensitive and contains a hashref with the following options:
    default_its: Default ITS (issue tracking system) to use (can be 'eventum' or 'jira')
    eventum_uri: URI used to access the Eventum API (Setting this to 'undef' prevents default/automatic API access for eventum style changesets)
    jira_uri: URI used to access the JIRA API (Setting this to 'undef' prevents default/automatic API access for JIRA style changesets)
    open onto: This is the base branch used when creating new changesets (i.e. 'master' means branches start from the master HEAD)

    eventum_statuses: For Eventum transitions; Contains a set of hashrefs, top level key is the 'command' (i.e. for gitc open XXX, the top level is 'open')
                  The 'promote' command is special and has another level for the target (i.e. gitc promote stage, looks at 'promote' => { .. 'stage' => {...} })
                  Each command may have the following options:
        from: A regex of the acceptable starting ITS status/state (use '.*' for any, use '|' to split different states as in 'in test|ready for staging')
        to: The target state/status
        block: An ARRAYREF of states/status that prevent the command from running (i.e. 'gitc open' fails if the initial state is 'closed', 'completed' or 'in production')

    jira_statuses: For JIRA transitions; Contains a set of hashrefs, top level key is the 'command' (i.e. for gitc open XXX, the top level is 'open')
                  The 'promote' command is special and has another level for the target (i.e. gitc promote stage, looks at 'promote' => { .. 'stage' => {...} })
                  Each command may have the following options:
        from: A regex of the acceptable starting ITS status/state (use '.*' for any, use '|' to split different states as in 'in test|ready for staging')
        to: The target state/status
        block: An ARRAYREF of states/status that prevent the command from running (i.e. 'gitc open' fails if the initial state is 'closed', 'completed' or 'in production')
        flag: This is used by the JIRA ITS to prefix the message with an icon (i.e. '(*)' adds a star icon) [see JIRA docs for available icons]

=cut

my %default_config = (
    'eventum_uri'      => 'https://eventum.example.com',
    'jira_uri'         => 'https://example.atlassian.net/',
    'eventum_statuses' => {
        open => {
            from => '.*',
            to   => 'in progress',
            block => [ 'closed', 'completed', 'in production' ],
        },
        edit => {
            from => '.*',
            to   => 'in progress',
        },
        submit => {
            from => 'in progress|failed',
            to   => 'pending review',
        },
        fail => {
            from => 'pending review',
            to   => 'failed',
        },
        pass => {
            from => 'pending review',
            to   => 'merged',
        },
        promote => {
            test => {
                from => 'merged',
                to   => 'in test',
            },
            stage => {
                from => 'in test|ready for staging',
                to   => 'in stage',
            },
            prod => {
                from => 'in stage|ready for release',
                to   => 'CLOSE',
            },
        },
    },
    'jira_statuses' => {
        open => {
            from => '.*',
            to   => 'In Progress',
            flag => '(*)', 
            block => [ 'Closed', 'Completed', 'Released' ],
        },
        edit => {
            from => '.*',
            to   => 'In Progress',
            flag => '(*)',
        },
        submit => {
            from => 'In Progress|Failed|Info Needed',
            to   => 'Work Pending Review',
            flag => '(?)',
        },
        fail => {
            from => 'Work Pending Review',
            to   => 'Failed',
            flag => '(n)',
        },
        pass => {
            from => 'Work Pending Review',
            to   => 'Work Reviewed',
            flag => '(y)',
        },
        promote => {
            test => {
                from => 'Work Reviewed',
                to   => 'In Test',
                flag => '(+)',
            },
            stage => {
                from => 'In Test|Passed in Test',
                to   => 'In Stage',
                flag => '(+)',
            },
            prod => {
                from => 'In Stage|Passed in Stage',
                to   => 'Ready for Release',
                flag => '(+)',
            },
        },
    },
    'open onto' => 'master',
);

our %config = (
    repo_base => 'git@example',
    projects  => {

        _default => \%default_config,

        'gitc' => {
            %default_config,
            'open onto' => 'master',
        },
        # CONFIGURE
        # You must define your project configuration here
        # TODO this should be pulled from a configuration file
    },
);

# The exported version of the configuration
our $git_config = \%config;

=head1 AUTHOR

Grant Street Group <F<developers@grantstreet.com>>

=head1 COPYRIGHT AND LICENSE

    Copyright 2012 Grant Street Group, All Rights Reserved.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut

1;
