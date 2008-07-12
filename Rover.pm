package Rover;
use Moose; # automatically turns on strict and warnings
 
has 'time_stamp'   => (is => 'rw', isa => 'Num');
has 'ctl'   => (is => 'rw', isa => 'Str');
has 'x'     => (is => 'rw', isa => 'Num');
has 'y'     => (is => 'rw', isa => 'Num');
has 'dir'   => (is => 'rw', isa => 'Num');
has 'speed' => (is => 'rw', isa => 'Num');

has 'home_x'     => (is => 'rw', isa => 'Num', default => 0);
has 'home_y'     => (is => 'rw', isa => 'Num', default => 0);
has 'home_r'     => (is => 'rw', isa => 'Num');


=head1 PUBLIC METHODS

these are the things I'm calling from my POE loop

=head2 receive_update

pass in the telemetry line

=cut

sub receive_update {
    my $self = shift;
    my $telemetry_line = shift;

    # T time-stamp vehicle-ctl vehicle-x vehicle-y vehicle-dir vehicle-speed objects ;
    my ( $T, $time_stamp, $vehicle_ctl, $vehicle_x, $vehicle_y, $vehicle_dir, $vehicle_speed, $objects ) = split( /\s+/, $telemetry_line, 8 );
    if ( ! defined $vehicle_x ) {
        warn "unable to parse: $telemetry_line";
        return;
    }
    $self->time_stamp( $time_stamp );
    $self->ctl( $vehicle_ctl ); # is this where I split this up?
    $self->x( $vehicle_x );
    $self->y( $vehicle_y );
    $self->dir( $vehicle_dir );
    $self->speed( $vehicle_speed );
    # warn "You are at $vehicle_x x $vehicle_y, facing $vehicle_dir, moving $vehicle_speed m/s";

    if ( $objects ) {
        $self->update_objects( $objects )
    }

    warn $self->status_line, "\n";
}

=head2 steering_command

returns the command we should send to the Rover.

=cut

sub steering_command {
    my $self = shift;

    my $acceleration = $self->fast_if_far();
    my $steering = $self->direction_towards_home();

    my $command = $acceleration . $steering . ';';
    warn $command;
    return $command;
}

sub update_objects {
    my $self = shift;
    my $objects_line = shift;

    my $remaining_objects = $objects_line;
    while ( $remaining_objects ) {
        if ( $remaining_objects =~ /^[h]/ ) {
            $remaining_objects = $self->find_home( $remaining_objects );
        } elsif ( $remaining_objects =~ /^[b]/ ) {
            $remaining_objects = $self->find_boulder( $remaining_objects );
        } elsif ( $remaining_objects =~ /^[c]/ ) {
            $remaining_objects = $self->find_crater( $remaining_objects );
        } elsif ( $remaining_objects =~ /^[m]/ ) {
            $remaining_objects = $self->find_martian( $remaining_objects );
        } else {
            warn "unable to parse $remaining_objects";
            return;
        }
    }


}

sub find_home {
    my $self = shift;
    my $objects_line = shift;

    my ( $type, $home_x, $home_y, $home_r, $remainder ) = split( /\s+/, $objects_line, 5 );

    return $remainder;
      
}

sub find_boulder {
    my $self = shift;
    my $objects_line = shift;

    my ( $type, $boulder_x, $boulder_y, $boulder_r, $remainder ) = split( /\s+/, $objects_line, 5 );
    return $remainder;
}

sub find_crater {
    my $self = shift;
    my $objects_line = shift;

    my ( $type, $crater_x, $crater_y, $crater_r, $remainder ) = split( /\s+/, $objects_line, 5 );
    return $remainder;
}

sub find_martian {
    my $self = shift;
    my $objects_line = shift;

    my ( $type, $martian_x, $martian_y, $martian_dir, $martian_speed, $remainder ) = split( /\s+/, $objects_line, 6 );
    return $remainder;
}



=head1 ACCELERATION METHODS

These are different ways to determine how fast to go

=head2 always_accelerate

speed is of the essence

=cut

sub always_accelerate {
    my $self = shift;

    return 'a';
}

=head2 random_acceleration

random, but weighted towards acceleration. I like to get there eventually

=cut

sub random_acceleration {
    my $self = shift;
    
    my @pedal_options = qw( a b a a a a );
    return $pedal_options[ rand scalar @pedal_options ];
}

=head2 fast_if_far

=cut

sub fast_if_far {
    my $self = shift;

    my $distance_towards_home = $self->distance_towards_home;
    if ( $self->speed < $distance_towards_home ) {
        return 'a';
    } else {
        return '';
    }
    
}

=head1 STEERING METHODS

These are the options for choosing how to steer.

=head random_steering

has proven to be entertaining, but not very useful.

=cut

sub random_steering {
    my $self = shift;
    
    my @turn_options = qw( l r );
    return $turn_options[ rand scalar @turn_options ];

}

=head2 direction_towards_home

returns r or l

=cut

sub direction_towards_home {
    my $self = shift;

    my $small = 1; # allowed angle error

    my $angle_towards_home = $self->angle_towards_home();
    my $dir = $self->dir();

    if ( abs( $angle_towards_home - $dir ) < $small ) {
        return '';
    }

    if ( ( $dir - $angle_towards_home > 0 ) && ( $dir - $angle_towards_home < 180 ) ) {
        return 'r';
    } else {
        return 'l';
    }
    
}

=head2 angle_towards_home

returns -180 - 180

=cut

sub angle_towards_home {
    my $self = shift;

    my $angle = -180 * atan2( ( $self->home_y() - $self->y() ), ( $self->home_x() - $self->x() ) ) / ( 2 * atan2( -1, 0 ) );
    # warn "home is at $angle degrees";
}


sub distance_towards_home {
    my $self = shift;

    return sqrt( ( $self->x() - $self->home_x() )**2 + ( $self->y() - $self->home_y() )**2 );
}

sub status_line {
    my $self = shift;

    my $line = sprintf( '%2d: You are at %2d x %2d, facing %2d, moving %2d m/s. ',
                        $self->time_stamp, $self->x, $self->y, $self->dir, $self->speed );
    $line .= sprintf( 'Home: %2d x %2d, %2d m away at %2d degrees.',
                      $self->home_x, $self->home_y, $self->distance_towards_home, $self->angle_towards_home );
    return $line;
}

1;
