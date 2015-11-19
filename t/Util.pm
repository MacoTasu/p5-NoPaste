package t::Util;
use strict;
use warnings;
use utf8;
use parent 'Exporter';
use NoPaste::Test;

sub import {
    my ($class, @args) = @_;
    strict->import;
    warnings->import;
    utf8->import;

    $class->export_to_level(1, $class, @args);

    require Test::More;
    Test::More->export_to_level(1);

    require Test::Deep;
    Test::Deep->export_to_level(1);

    require Test::Deep::Matcher;
    Test::Deep::Matcher->export_to_level(1);
}

sub setup_db {
    NoPaste::Test->setup_db(@_);
}

1;
