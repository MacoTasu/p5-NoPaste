use t::Util;
use Mouse::Util::TypeConstraints qw(find_type_constraint);

use_ok "NoPaste::Type";

subtest "UInt" => sub {
    my $type = find_type_constraint("UInt");

    ok $type->check(1), 'valid: 1';
    ok $type->check(0), 'valid: 0';
    ok !$type->check(-1), 'invalid: -1';
    ok !$type->check(undef), 'valid: undef';
};

subtest "EntryTitleWidth" => sub {
    my $type = find_type_constraint("EntryTitleWidth");

    ok $type->check(undef), 'valid: undef';
    ok $type->check(''), 'valid: ""';
    ok $type->check('a'), 'valid: a';
    ok $type->check('a'x120), 'valid: ax120';
    ok !$type->check('a'x121), 'inalid: ax121';
};

subtest "EntryBodyWidth" => sub {
    my $type = find_type_constraint("EntryBodyWidth");

    ok $type->check('a'), 'valid: a';
    ok $type->check('a'x10000), 'valid: ax10000';
    ok !$type->check('a'x10001), 'inalid: ax10001';
    ok !$type->check(undef), 'invalid: undef';
    ok !$type->check(''), 'valid: ""';
};

done_testing;
