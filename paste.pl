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
    my $text = join "", <$FILE>;
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

