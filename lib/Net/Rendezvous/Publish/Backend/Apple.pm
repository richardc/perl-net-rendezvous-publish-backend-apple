use strict;
package Net::Rendezvous::Publish::Backend::Apple;
use XSLoader;
use base qw( Net::Rendezvous::Publish::Backend Class::Accessor::Lvalue::Fast );
__PACKAGE__->mk_accessors(qw( _handles ));
our $VERSION = 0.01;

XSLoader::load __PACKAGE__;

sub new {
    my $self = shift;
    $self = $self->SUPER::new;
    $self->_handles = {};
    return $self;
}

sub _newhandle {
    my $self = shift;
    my $handle = shift;
    $self->_handles->{ $handle } = $handle;
    return $handle;
}

sub publish {
    my $self = shift;
    my %args = @_;
    return $self->_newhandle( xs_publish( map {
        $_ || ''
    } @args{ qw( object name type domain host port txt ) } ) );
}

sub publish_stop {
    my $self = shift;
    my $id = shift;
    xs_stop( $id );
    delete $self->_handles->{ $id };
}

sub step {
    my $self = shift;
    my $time = shift;
    $time *= 1000; # millisecs
    xs_step_for( $time, values %{ $self->_handles } );
}

1;
