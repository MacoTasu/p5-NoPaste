package NoPaste::Test;

use 5.16.1;
use strict;
use warnings;
use utf8;

use NoPaste::Config;
use Test::mysqld;
use Test::TCP;
use Test::More;

sub setup_db {
    my $class = shift;

    my $port = Test::TCP::empty_port();
    my $mysqld = Test::mysqld->new(
        my_cnf => {
            port                   => $port,
            user                   => 'root',
        },
    ) or plan skip_all => $Test::mysqld::errstr;

    system("mysql -uroot -h 127.0.0.1 -P $port test < sql/schema.sql")==0 or die "Cannot update schema: \n-- $!\n";

    return $mysqld;
}

1;
