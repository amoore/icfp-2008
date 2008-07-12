package World;
use Moose;

has 'dx'            => (is => 'rw', isa => 'Num');
has 'dy'            => (is => 'rw', isa => 'Num');
has 'time_limit'    => (is => 'rw', isa => 'Int');
has 'min_sensor'    => (is => 'rw', isa => 'Num');
has 'max_sensor'    => (is => 'rw', isa => 'Num');
has 'max_speed'     => (is => 'rw', isa => 'Num');
has 'max_turn'      => (is => 'rw', isa => 'Num');
has 'max_hard_turn' => (is => 'rw', isa => 'Num');

sub initialize_from_string {
    my $self = shift;
    my $line = shift;

    # I dx dy time-limit min-sensor max-sensor max-speed max-turn max-hard-turn ;
    my ( $I, $dx, $dy, $time_limit, $min_sensor, $max_sensor, $max_speed, $max_turn, $max_hard_turn ) = split( /\s+/, $line );
    $self->dx( $dx );
    $self->dy( $dy );
    $self->time_limit( $time_limit );
    $self->min_sensor( $min_sensor );
    $self->max_sensor( $max_sensor );
    $self->max_speed( $max_speed );
    $self->max_turn( $max_turn );
    $self->max_hard_turn( $max_hard_turn );
    warn "The map is $dx x $dy. You have $time_limit ms";

    return $self;
    
}

1;
