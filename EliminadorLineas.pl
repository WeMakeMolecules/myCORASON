#!/usr/local/bin/perl -w
#latest version modified by Pablo Cruz-Morales June 2020
use experimental 'smartmatch';
use lib './';
use globals2;
my $directory =  "$dir2/$NAME2/CONCATENADOS";
`perl -I . -pi -e "s/^\n//" $directory/*`;            ####delete double lines                    

