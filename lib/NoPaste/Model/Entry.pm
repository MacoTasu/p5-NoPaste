package NoPaste::Model::Entry;

use 5.16.3;
use strict;
use warnings;
use utf8;

use NoPaste::Type;
use Data::Validator;
use NoPaste::Util;
use constant {
    ROWS                  => 10,
    SHORT_BODY_MAX_LENGTH => 100,
};

use Mouse;

has db => (
    is       => 'ro',
    isa      => 'DBIx::Sunny::db',
    required => 1,
);

sub retrieve_multi_by_page {
    my $self = shift;
    state $rule = Data::Validator->new(
        page          => { isa => 'Maybe[UInt]', default => 1 },
        is_short_body => { isa => "Bool" },
    );
    my $args = $rule->validate(@_);
    my $page = $args->{page};
    my $is_short_body = $args->{is_short_body};

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

    my $compile_entries;
    if ($is_short_body) {
        $compile_entries = $self->_compile_entries_to_short_body($entries);
    }

    return {
        entries => $is_short_body ? $compile_entries : $entries,
        page    => {
            prev => $page - 1 <= 0 ? undef : $page - 1,
            next => scalar(@$entries) < ROWS ? undef : $page + 1,
        },
    }
}

sub _compile_entries_to_short_body {
    my ($self, $entries) = @_;
    my $compile_entries = [];
    for my $entry (@{$entries}) {
        my $compile_entry = $self->_compile_entry_to_short_body($entry);
        push @{$compile_entries}, $compile_entry;
    }

    return $compile_entries;
}

sub _compile_entry_to_short_body {
    my ($self, $entry) = @_;
    my $body = $entry->{body};
    return $entry if (length($body) < SHORT_BODY_MAX_LENGTH);
    return {
        %{$entry},
        body => sprintf("%s...", substr($body, 0, SHORT_BODY_MAX_LENGTH)),
    };
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
