#! /usr/bin/perl
use strict;
use warnings;
use Mojolicious::Lite;
use Digest::MD5 qw( md5_hex );
use Redis;

#####################################################################
# App setup                                                         #
#####################################################################
# this is for signed cookies, but there is none so this is just
# to prevent stupid debug messages
app->secrets( [ 'super secret sauce', 'sauce super secret' ] );

# Automatically name log files development and set log lvl (debug | info)
app->mode('development');

# a nicer access to redis than just a global variable
helper redis =>
  sub { state $redis = Redis->new( server => '127.0.0.1:6379' ); };

#####################################################################
# App routes                                                        #
#####################################################################
get '/' => sub { shift->render('form'); };
get '/#digest_id' => \&display_paste;
post '/process'   => \&process_post;

#####################################################################
# Controllers                                                       #
#####################################################################

sub display_paste {
    my $self = shift;

    my $file = $self->redis->hgetall( $self->param('digest_id') );
    $self->render( 'pasted', file_info => $file );
}

sub process_post {
    my $self           = shift;
    my $title          = $self->param('Title');
    my $type           = $self->param('Type');
    my $text           = $self->param('Text');
    my $digest_post_id = md5_hex( $title . $type . $text . time );

    $self->redis->hset( $digest_post_id, 'title', $title );
    $self->redis->hset( $digest_post_id, 'type',  $type );
    $self->redis->hset( $digest_post_id, 'text',  $text );
    return $self->redirect_to("/$digest_post_id");
}

app->start;

