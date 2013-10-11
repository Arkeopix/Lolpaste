#! /usr/bin/perl

use Modern::Perl;
use WWW::Mechanize;
use Getopt::Long;

my %pastebin_conf = (
    paste_format	=> '1',
    paste_code		=> '',
    paste_expire_date	=> 'N',
    paste_private	=> '0',
    paste_name		=> ''
    );

GetOptions(\%pastebin_conf, 
	   "paste_format=i", 
	   "paste_code=s",
	   "paste_expire_date=s", 
	   "paste_private=i", 
	   "paste_name=s") 
    or die "Bad Options";

my $mech = WWW::Mechanize->new;

$mech->get("http://pastebin.com/");
die $mech->res->status_line unless $mech->success;

unless ($pastebin_conf{text}) {
    $pastebin_conf{paste_name} ||= $ARGV[0];
    $pastebin_conf{paste_code} = join "", <>;
}

$mech->set_fields(%pastebin_conf);
$mech->submit;
die $mech->res->status_line unless $mech->success;

print $mech->response->request->uri->as_string, "\n";
