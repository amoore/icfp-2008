#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

use POE qw(Component::Client::TCP);

use Rover;
use World;

my $hostname = 'localhost';
my $port = 7777;
my $result = GetOptions ( 'hostname=s' => \$hostname,
                          'port=i' => \$port,
                     );

POE::Component::Client::TCP->new
  ( RemoteAddress => $hostname,
    RemotePort    => $port,
    Filter        => [ "POE::Filter::Line", Literal => ";" ],
    ServerInput   => \&handle_server_input,
);

my $rover;
my $world;

sub handle_server_input {
    my ( $kernel, $heap, $session, $input ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
    # warn $input;

    if ( $input =~ /^I/ ) {
        warn 'initializing';
        $world = World->new->initialize_from_string( $input );
        $rover = Rover->new();
        return;
    }

    if ( $input =~ /^T/ ) {
        $rover->receive_update( $input );
    } elsif ( $input =~ /^E/ ) {
        # we're out of time
        warn ' <<<< TIME >>> ';
        # $rover = Rover->new();
    } elsif ( $input =~ /^C/ ) {
        # we crashed. Who cares?
        warn ' <<<< CRASH >>> ';
    } elsif ( $input =~ /^K/ ) {
        # Killed
        warn ' <<<< You have been eaten by a grue >>>> ';
    } elsif ( $input =~ /^S/ ) {
        # Success?
        warn ' <<<< ----- HOME ----- >>>> ';
    } else {
        warn "unknown message: $input";
    }

    $heap->{server}->put( $rover->steering_command() );
}



warn 'running';
$poe_kernel->run();
exit 0;
