#!/usr/bin/perl

use strict;
use warnings;
use threads;
use XML::Simple;
use Data::Dumper;

sub logmsg{
	my $msg=shift;

	my $now=localtime;
	print "[$now] $msg\n";
}


sub readConfig{
	if(!-e "config.xml"){
		logmsg("config.xml not found");
		exit 0;
	}

	my $config=XMLin('config.xml', ForceArray=>1);
	return $config;
}

sub doStuff{
	my $dev=shift;
	my $adbp=shift;
	my $conf=shift;

	my $adbCommand=$adbp." -s $dev";
	my $powerCommand=$adbCommand." ".$conf->{standard_actions}[0]->{action}->{power}->{adb_command}[0];
	my $backCommand=$adbCommand." ".$conf->{standard_actions}[0]->{action}->{back}->{adb_command}[0];
	my $homeCommand=$adbCommand." ".$conf->{standard_actions}[0]->{action}->{home}->{adb_command}[0];

	while(1){
		#sleep random
		my $sleeptime=(int(rand(240))+120);#entre 2 y 6 minutos
		logmsg("$dev sleeping $sleeptime");
		sleep($sleeptime); 
		(undef, undef, my $hour)=localtime(time);
		logmsg("Hour: $hour");

		#activity between 8 and 19
		if($hour<8 or $hour>19){
			next;
		}
		print"\n\n---------------------\n";
		logmsg("Device $dev");


		#perform action?
		if(rand()<0.2){
			next;
		}
		
		#do action
		#select random action
		my $actionIndex=int(rand(scalar(@{$conf->{action_list}[0]->{action}})));
		my $action=$conf->{action_list}[0]->{action}[$actionIndex];
		logmsg("Selected ".$action->{app});
		my $command=$adbCommand." ".$action->{adb_command}[0];

		#select random parameters
		if(exists $action->{parameters}){
			my $paramIndex=int(rand(scalar(@{$action->{parameters}[0]->{parameter}})));
			my $parameter=$action->{parameters}[0]->{parameter}[$paramIndex];
			logmsg("Selected parameter ".$parameter);
			$command.=" ".$parameter
		}

		#unlock screen
		logmsg("Unlock: ".$powerCommand);
		`$powerCommand`; sleep(1);

		#act
		logmsg("Command: ".$command);
		`$command`; sleep(int(rand(180))+30); #entre 30 segundos y 3 minutos

		#back button
		logmsg("Back: ".$backCommand);
		`$backCommand`; sleep(2);

		#lock screen
		logmsg("Lock: ".$powerCommand);
		`$powerCommand`; 
	}
}

my $config=readConfig();
#print Dumper $config;

my $adbPath=$config->{adb_path}[0];
logmsg("adb path: ".$adbPath);
#logmsg("Num actions: ".scalar(@{$config->{action_list}[0]->{action}}));

my $res=`$adbPath devices`;

#sleep(5);

my @devices;
while($res=~/^([a-z0-9:.]+)\s+device$/igm){
    push @devices, $1;
}

my @threads;
foreach my $dev(@devices){
	push @threads, threads->create(\&doStuff, $dev, $adbPath, $config);
}

foreach my $thread(@threads){
	$thread->join();
}

