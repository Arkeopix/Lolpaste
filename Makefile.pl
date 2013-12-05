#! /usr/bin/perl

use ExtUtils::MakeMaker;

WriteMakefile(
    PREREQ_PM => {'Mojolicious' => '4.59',
		  'Modern'      => '1.20121103',
    }
);
