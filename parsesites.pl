#!/usr/bin/perl

while(<>){
	s/^(.*)$/<parameter><![CDATA[http:\/\/$1]]><\/parameter>/;
	print;
}
