package NoPaste::Config;
use 5.16.3;
use strict;
use warnings;
use utf8;
use File::Basename;

use Config::ENV 'PLACK_ENV';

my $path = sprintf "%s/../../", dirname(__FILE__);

common load("$path/config/development.pl");

=put

If add new PLACK_ENV config, Please write:

config production => +{
    load("$path/config/production.pl");
}

=cut

1;
