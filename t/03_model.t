use t::Util;

use_ok 'NoPaste::Model';

subtest 'new' => sub {
    my $model = NoPaste::Model->new;

    ok $model->db->ping;
    isa_ok $model->entry_model, "NoPaste::Model::Entry";
};

done_testing;
