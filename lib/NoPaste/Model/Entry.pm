package NoPaste::Model::Entry;

use 5.16.3;
use strict;
use warnings;
use utf8;

use NoPaste::Type;
use Data::Validator;
use NoPaste::Util;
use constant ROWS => 10;

use Mouse;

has db => (
    is       => 'ro',
    isa      => 'DBIx::Sunny::db',
    required => 1,
);

sub retrieve_multi_by_page {
    my $self = shift;
    state $rule = Data::Validator->new(
        page => { isa => 'Maybe[UInt]', default => 1 },
    )->with('Sequenced');
    my $args = $rule->validate(@_);
    my $page = $args->{page};

    my $offset;
    if ($page == 1 || !$page) {
        $offset = 0;
    }
    else {
        $offset = ($page - 1) * ROWS;
    }

    my $entries = $self->db->select_all(
        'SELECT * FROM entries ORDER BY id LIMIT ? OFFSET ?',
        ROWS, $offset
    );

    return {
        entries => $entries,
        page    => {
            prev => $page - 1 <= 0 ? undef : $page - 1,
            next => scalar(@$entries) < ROWS ? undef : $page + 1,
        },
    }
}

sub retrieve_by_uuid {
    my $self = shift;
    state $rule = Data::Validator->new(
        uuid => { isa => 'Str' },
    )->with('Sequenced');
    my $args = $rule->validate(@_);

    return $self->db->select_row('SELECT * FROM entries WHERE uuid=?', $args->{uuid});
}

sub register {
    my $self = shift;
    state $rule = Data::Validator->new(
        title => { isa => 'EntryTitleWidth' },
        body  => { isa => 'EntryBodyWidth' },
    );
    my $args = $rule->validate(@_);
    my $title = $args->{title};
    my $body = $args->{body};

    my $uuid = NoPaste::Util::generate_uuid;
    $self->db->query(
        'INSERT INTO entries (title, body, uuid, created_at) VALUES (?, ?, ?, NOW())',
        $args->{title}, $args->{body}, $uuid
    );

    return $uuid;
}

1;
