#! /usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Mojo::DOM;
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use MIME::Base64;
use WWW::Mechanize;

sub send_paste {
    my $params        = shift;
    my %lolpaste_conf = %$params;
    my $mech          = WWW::Mechanize->new;
    my $page          = $mech->get('http://127.0.0.1:3000');

    if ( $lolpaste_conf{input_file} ne '' ) {
        open my $fh, '<', $lolpaste_conf{input_file} or die $!;
        while (<$fh>) {
            $lolpaste_conf{text} .= $_;
        }
        close($fh);
    }

    if (   $lolpaste_conf{title} eq ''
        || $lolpaste_conf{text} eq '' )
    {
        print "title and text must be present\n";
        exit -1;
    }

    #	print $lolpaste_conf{text} . "\n";

    my $text        = $lolpaste_conf{text};
    my $gzip_output = $text;
    gzip \$text, \$gzip_output
      || die $GzipError;

    $mech->submit_form(
        form_id => 'form',
        fields  => {
            Title => $lolpaste_conf{title},
            Type  => $lolpaste_conf{type},
            Text  => encode_base64($gzip_output),
            CLI   => 1,
        },
    );
    if ( !$mech->success ) {
        die $mech->res->status_line;
    }
    print "You can now share your paste with the following uri:\n"
      . $mech->response->request->uri->as_string, "\n";
}

sub get_paste {
    my $params        = shift;
    my %lolpaste_conf = %$params;

    my $mech = WWW::Mechanize->new;
    $mech->get( 'http://127.0.0.1:3000/' . $lolpaste_conf{download} );
    my $DOM  = Mojo::DOM->new( $mech->content );
    my $text = $DOM->find('pre')->[0]->text;
    if ( $lolpaste_conf{output_file} ) {
        open my $fh, '>', $lolpaste_conf{output_file} || die $!;
        print $fh $text;
        close $fh;
    }
    else {
        print $text;
    }
}

my %lolpaste_conf = (
    title       => '',
    type        => 'plain_text',
    text        => '',
    input_file  => '',
    output_file => '',
    download    => '',
    upload      => '',
);

if ( $#ARGV == -1 ) {
    print
"Usage: web_paster [ --upload [commands_upload] | --download digest_id [commands_download] ]\n"
      . "commands_upload:\n"
      . "\t--title [title]\n"
      . "\t--type [type]\n"
      . "\t--text [text]\n"
      . "\t--input_file [file]\n"
      . "commands_download:\n"
      . "\t--output_file [file]\n";
    exit 0;
}

GetOptions( \%lolpaste_conf, 'title=s', 'type=s', 'text=s', 'input_file=s',
    'output_file=s', 'download=s', 'upload' )
  or die 'Bad option';

send_paste( \%lolpaste_conf ) if $lolpaste_conf{upload};
get_paste( \%lolpaste_conf )  if $lolpaste_conf{download};
