
Initial Installation Instructions:

    When initially installing gitc you need to do the following:

    Create a database for gitc to use
    Create the tables as defined in sql/*

    Modify:
        lib/GSG/Gitc/Util.pm
            Search for "# CONFIGURE"
            inside of the dbh subroutine, add your database connection credentials

        lib/GSG/Gitc/Config.pm
            Search for "# CONFIGURE"
            Add your project configuration here

        gitc-submit 
            Search for "# CONFIGURE"
            configure to get valid developer usernames

Additional documentation:

https://github.com/GrantStreetGroup/gitc/wiki

