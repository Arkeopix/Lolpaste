#! /usr/bin/perl

use Modern::Perl;
use Mojolicious::Lite;
use URI::file;

get '/' => sub {
    shift->render('form');
};

get '/#foo/#bar' => sub {
    my $self = shift;
    my $path = "./" . $self->param('foo') ."/". $self->param('bar');

    unless (open FILE, '<', $path) {
	$self->render(text=>"Could not open file");
    }
    my $text = <FILE>;
    close FILE;
    $self->render(text=>$text);
};

post '/process' => sub {
    my $self = shift;
    my $text = $self->param('Text');
    my $title = $self->param('Title');
    
    unless (open FILE, '>', "./files/$title") {
	$self->render(text=>"Could not create/open file");
    }
    print FILE $text;
    close FILE;

    my $url = URI->new("./files/$title");
    $self->redirect_to($url);
};

app->start;

__DATA__

@@ form.html.ep
%=t h1 => 'Paste'
%= form_for '/process' => (method => 'post') => begin
  Title: <%= text_field 'Title' %>
  Text: <%= text_area 'Text', cols => 50, rows => 10 %>
  %= submit_button 'click'
%= end
