package NoPaste::Type;
use 5.16.3;
use strict;
use warnings;
use utf8;
use Mouse::Util::TypeConstraints;

subtype 'UInt'
    => as "Int"
    => where {
        my $value = shift;
        return if not defined $value;
        return if $value < 0;
        return 1;
    }
    => message {
        my $value = shift;
        "This number ($value) is not less than zero!"
    };
