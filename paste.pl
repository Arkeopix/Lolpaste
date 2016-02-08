#! /usr/bin/perl
use strict;
use warnings;
use Digest::MD5 qw( md5_hex );
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use MIME::Base64;
use Mojolicious::Lite;
use Mojo::Log;
use Redis;

my $log = Mojo::Log->new();

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

helper gunzip => sub {
    my ($self, $base64_data) = @_;
	my $data = decode_base64($base64_data);
    my $uncompressed;
    gunzip \$data, \$uncompressed || die $GunzipError;
	return $uncompressed;
};

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

    my %file_info = $self->redis->hgetall( $self->param('digest_id') );
	
	$log->info( $file_info{title} );
	$log->info( $file_info{type} );
	$log->info( $file_info{text} );
	return $self->render('pasted', file_info => \%file_info );
}

sub process_post {
    my $self  = shift;
    my $title = $self->param('Title');
	my $type  =  $self->param('Type');
    my $text  = $self->param('Text');

	# $log->info( $title );
	# $log->info( $type  );
	# $log->info( $text  );
	
    $text = $self->gunzip($text) if $self->param('CLI');

    my $digest_post_id = md5_hex( $title . $type . time );

    $self->redis->hset( $digest_post_id, 'title', $title );
	$self->redis->hset( $digest_post_id, 'type', $type );
    $self->redis->hset( $digest_post_id, 'text',  $text );
	$self->redis->expire( $digest_post_id, 86400);
    return $self->redirect_to("/$digest_post_id");
}

app->start;

