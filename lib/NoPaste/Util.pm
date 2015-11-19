package NoPaste::Util;

use 5.16.3;
use strict;
use warnings;
use utf8;

use Data::UUID;
use Digest::MD5 qw(md5_base64);

# Data::UUIDだけだと長過ぎて嫌なのでbase64に変換する
sub generate_uuid {
    my $self = shift;

    state $uuid = Data::UUID->new;
    return md5_base64($uuid->create);
}

1;
