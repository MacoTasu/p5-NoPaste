package NoPaste::Util;

use 5.16.3;
use strict;
use warnings;
use utf8;

use Data::UUID;
use Digest::MD5 qw(md5_hex);

# Data::UUIDだけだと長過ぎるのでmd5_hexにする
sub generate_uuid {
    my $self = shift;

    state $uuid = Data::UUID->new;
    return md5_hex($uuid->create);
}

1;
