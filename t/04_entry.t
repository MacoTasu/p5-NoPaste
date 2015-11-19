use t::Util;
use NoPaste::Model;
use Test::Mock::Guard qw(mock_guard);
use String::Random;

use_ok 'NoPaste::Model::Entry';

my $mysqld = t::Util::setup_db();
my $guard = mock_guard(
    'NoPaste::Config', {
        param => sub {
            my ($self, $key) = @_;
            my $dsn = $mysqld->dsn;
            my $info = +{
                database => [$mysqld->dsn, 'root', '', {}]
            };
            return $info->{$key};
        },
    },
);

my $entry_model = NoPaste::Model->new()->entry_model;

subtest 'register -> retrieve_by_uuid' => sub {
    my $uuid = $entry_model->register(
        title => 'hoge',
        body  => 'fuga'
    );

    my $entry = $entry_model->retrieve_by_uuid($uuid);

    cmp_deeply $entry, {
        id         => 1,
        uuid       => $uuid,
        title      => 'hoge',
        body       => 'fuga',
        created_at => is_string,
    };
};

# testデータ作成
my $random = String::Random->new;
for (1..15) {
    $entry_model->register(
        title => $random->randregex('[A-Z0-9a-z]{0,120}'),
        body  => $random->randregex('[A-Z0-9a-z]{1,10000}'),
    );
}

subtest 'retrieve_multi_by_page, page=1,2,3' => sub {
    my $compile_guard = mock_guard(
        'NoPaste::Model::Entry', {
            _compile_entries_to_short_body => sub {}
        },
    );
    my $entries_with_page = $entry_model->retrieve_multi_by_page(
        page          => 1,
        is_short_body => 0,
    );
    is @{$entries_with_page->{entries}}, NoPaste::Model::Entry::ROWS;
    cmp_deeply $entries_with_page->{page}, {
        prev => undef,
        next => 2,
    };
    is $compile_guard->call_count("NoPaste::Model::Entry", '_compile_entries_to_short_body'), 0;


    $entries_with_page = $entry_model->retrieve_multi_by_page(
        page          => 2,
        is_short_body => 0,
    );
    is @{$entries_with_page->{entries}}, 6;
    cmp_deeply $entries_with_page->{page}, {
        prev => 1,
        next => undef,
    };
    is $compile_guard->call_count("NoPaste::Model::Entry", '_compile_entries_to_short_body'), 0;


    $entries_with_page = $entry_model->retrieve_multi_by_page(
        page          => 3,
        is_short_body => 0,
    );
    is @{$entries_with_page->{entries}}, 0;
    cmp_deeply $entries_with_page->{page}, {
        prev => 2,
        next => undef,
    };


    $entry_model->retrieve_multi_by_page(
        page          => 1,
        is_short_body => 1,
    );
    is $compile_guard->call_count("NoPaste::Model::Entry", '_compile_entries_to_short_body'), 1;
};

subtest '_compile_entries_to_short_body' => sub {
    my $compile_guard = mock_guard(
        'NoPaste::Model::Entry', {
            _compile_entry_to_short_body => sub {}
        },
    );

    my $entries = [map { { body => $_ } } qw(a b c)];
    $entry_model->_compile_entries_to_short_body($entries);

    is $compile_guard->call_count("NoPaste::Model::Entry", '_compile_entry_to_short_body'), 3;
};

subtest '_compile_entry_to_short_body' => sub {
    my $short_entry = {
        body => 'a'x (NoPaste::Model::Entry::SHORT_BODY_MAX_LENGTH - 1),
    };
    my $short_result = $entry_model->_compile_entry_to_short_body($short_entry);
    cmp_deeply $short_result, $short_entry;

    my $fit_entry = {
        body => 'a'x NoPaste::Model::Entry::SHORT_BODY_MAX_LENGTH,
    };
    my $fit_result = $entry_model->_compile_entry_to_short_body($fit_entry);
    cmp_deeply $fit_result, $fit_entry;

    my $long_entry = {
        body => 'a'x (NoPaste::Model::Entry::SHORT_BODY_MAX_LENGTH + 1),
    };
    my $long_result = $entry_model->_compile_entry_to_short_body($long_entry);
    cmp_deeply $long_result, { body => 'a'x NoPaste::Model::Entry::SHORT_BODY_MAX_LENGTH."..." };
};


done_testing;
