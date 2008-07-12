package VectorField;
use Moose;

has 'weight' => ( is      => 'rw',
                  isa     => 'ArrayRef[Int]',
                  default => [ map { 0 } ( 0..72 ) ] );
has 'rover_x'     => (is => 'rw', isa => 'Num');
has 'rover_y'     => (is => 'rw', isa => 'Num');

sub clear {
    my $self = shift;

    $self->weight( [ map { 0 } ( 0..72 ) ] );
}

sub add_boulder {
    my $self = shift;
    my ( $x, $y, $r ) = @_;

    
    
}
