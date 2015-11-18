package NoPaste::Type;
use 5.16.3;
use strict;
use warnings;
use utf8;
use Mouse::Util::TypeConstraints;

subtype 'UInt'
    => as 'Int'
    => where {
        my $value = shift;
        return if $value < 0;
        return 1;
    }
    => message {
        my $value = shift;
        return "This number ($value) is not less than zero!";
    };

subtype 'EntryTitleWidth'
    => as 'Maybe[Str]'
    => where {
        my $value = shift;
        return 1 if not defined $value;

        my $size = length($value);
        return 0 if 120 < $size;
        return 1;
    }
    => message {
        my $value = shift;
        return "Number of characters in the title ($value) is not more than 120!";
    };

subtype 'EntryBodyWidth'
    => as 'Str'
    => where {
        my $value = shift;
        my $size = length($value);
        return 0 if $size <= 0;
        return 0 if 10000 < $size;
        return 1;
    }
    => message {
        my $value = shift;
        return "Number of characters in the body ($value), caracters is 1 to 10,000!";
    };
