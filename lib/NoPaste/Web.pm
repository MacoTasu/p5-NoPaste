package NoPaste::Web;

use 5.16.3;
use strict;
use warnings;
use utf8;
use Kossy;
use NoPaste::Model;

sub model {
    state $model = NoPaste::Model->new();
    return $model;
}

get '/' => sub {
    my ($self, $c) = @_;
    $c->render('index.tx');
};

post '/' => sub {
    my ($self, $c) = @_;
    my $uuid;
    eval {
        my $title = $c->req->param('title');
        my $body  = $c->req->param('body');

        $uuid = model->entry_model->register(
            title => $title,
            body  => $body
        );
    };
    if (my $error = $@) {
        # エラーログを収集する場合はそちらに投げるようにする
        warn $error;
        $c->halt(500, "Internal Server Error");
    }
    else {
        $c->redirect("/entries/$uuid");
    }
};

get '/entries' => sub {
    my ($self, $c) = @_;

    my $entries_with_page;
    eval {
        my $page = $c->req->param('page');
        $entries_with_page = model->entry_model->retrieve_multi_by_page(
            $page ? (page => $page) : (),
            is_short_body => 1,
        );
    };
    if (my $error = $@) {
        warn $error;
        $c->halt(500, "Internal Server Error");
    }
    else {
        $c->render('entries.tx', $entries_with_page);
    }
};

# uuidは推測されにくいようにランダムでかつuniqueなものにする
get '/entries/:uuid' => sub {
    my ($self, $c) = @_;
    my $entry;
    eval {
        my $uuid = $c->args->{uuid};
        $entry = model->entry_model->retrieve_by_uuid($uuid);
    };
    if (my $error = $@) {
        warn $error;
        $c->halt(500, "Internal Server Error");
    }
    else {
        $c->render('entry.tx', { entry => $entry });
    }
};

1;
