use t::Util;
use Mouse::Util::TypeConstraints qw(find_type_constraint);

use_ok "NoPaste::Type";

subtest "UInt" => sub {
    my $type = find_type_constraint("UInt");

    ok $type->check(1), 'is valid: 1';
    ok $type->check(0), 'is valid: 0';
    ok !$type->check(-1), 'invalid: -1';
    ok !$type->check(undef), 'is valid: undef';
};

done_testing;
