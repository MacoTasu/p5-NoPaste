package NoPaste::Model;

use 5.16.3;
use strict;
use warnings;
use utf8;

use NoPaste::Config;
use DBIx::Sunny;
use String::CamelCase qw(decamelize);
use Plack::Util;

use Mouse;

has db => (
    is      => 'ro',
    isa     => 'DBIx::Sunny::db',
    lazy    => 1,
    default => sub {
        state $db ||= DBIx::Sunny->connect(
            @{NoPaste::Config->param('database')}
        );
        return $db;
    },
);

for my $model (qw(Entry)) {
    my $klass = Plack::Util::load_class($model, __PACKAGE__);
    has decamelize($model).'_model' => (
        is      => 'ro',
        isa     => $klass,
        lazy    => 1,
        default => sub {
            my $self = shift;
            return $klass->new(db => $self->db);
        },
    );
}

no Mouse;

1;
