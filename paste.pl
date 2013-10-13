#! /usr/bin/perl

use Modern::Perl;
use Mojolicious::Lite;

get '/' => sub {shift->render('form');};

get '/#foo/#bar' => sub {
    my $self = shift;
    my $path = "./" . $self->param('foo') ."/". $self->param('bar');
    my $FILE;

    unless (open $FILE, '<', $path) {
	$self->render(text=>"Could not open file");
    }
    my $text = <$FILE>;
    close $FILE;
    $self->render('pasted', poil => $text);
};

post '/process' => sub {
    my $self = shift;
    my $text = $self->param('Text');
    my $path = "./files/" . $self->param('Title');
    my $FILE;

    unless (open $FILE, '>', $path) {
	$self->render(text=>"Could not create/open file");
    }
    print $FILE $text;
    close $FILE;

    $self->redirect_to($path);
};

app->start;

__DATA__

@@layouts/default.html.ep
<!doctype html><html>
    <head>
	<title>LolPaste</title>
	<link type="text/css" rel="stylesheet" href="style.css" />
	<link href='http://fonts.googleapis.com/css?family=Autour+One' rel='stylesheet' type='text/css'>
    </head>
    <body><%= content %></body>
</html>

@@form.html.ep

%layout 'default';
%=t h1 => 'LolPaste'
    <div id="form" />
    %=t h1 => 'Let the magic happen'
    %= form_for '/process' => (method => 'post') => begin
    %= label_for Title => 'Title:' 
    %= text_field 'Title'
    <br/>
    %= label_for Text => 'Text:'
    %= text_area 'Text', rows => 10, id =>'flex'
    <br/>
    %= submit_button 'click', id => 'button'
    %= end
   </div>

@@pasted.html.ep

%layout 'default';
%=t h1 => 'LolPaste'
  <p>Here is your paste !</p>
  <div id="pasted">
  %= $poil
  <br/>
  </div>
