use inc::Module::Install;

name 'App-Gitc';
all_from 'lib/App/Gitc.pm';

# modules present in the core Perl installation
requires 'Carp';
requires 'File::Temp';
requires 'FindBin';
requires 'Getopt::Long';
requires 'List::Util';
requires 'POSIX';
requires 'Term::ReadLine';
requires 'Class::MOP';

# non-core modules
requires 'Algorithm::Dependency';
requires 'DBI';
requires 'Email::Simple';
requires 'List::MoreUtils';
requires 'Text::Levenshtein';
requires 'YAML::Syck';

# JIRA modules
requires 'JIRA::Client';
requires 'JIRA::Client::REST';

# testing modules
test_requires 'Test::More';

# gitc scripts
install_script 'git-merge-theirs';
install_script 'gitc';
install_script 'gitc-archive-tags';
install_script 'gitc-branch';
install_script 'gitc-branch-point';
install_script 'gitc-cancel';
install_script 'gitc-changesets-in';
install_script 'gitc-current-branch';
install_script 'gitc-diff';
install_script 'gitc-diffsites';
install_script 'gitc-diff-versions';
install_script 'gitc-edit';
install_script 'gitc-fail';
install_script 'gitc-group';
install_script 'gitc-history';
install_script 'gitc-import-tags';
install_script 'gitc-list';
install_script 'gitc-log';
install_script 'gitc-open';
install_script 'gitc-pass';
install_script 'gitc-project-name';
install_script 'gitc-promote';
install_script 'gitc-promoted';
install_script 'gitc-quickfix';
install_script 'gitc-rebase';
install_script 'gitc-review';
install_script 'gitc-setup';
install_script 'gitc-show';
install_script 'gitc-status';
install_script 'gitc-submit';
install_script 'gitc-sync';
install_script 'gitc-touch';
install_script 'gitc-unpromoted';

WriteAll;
