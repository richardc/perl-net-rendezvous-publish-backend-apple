use strict;
package Net::ZeroConf::Backend::Rendezvous;
use XSLoader;
use base qw( Net::ZeroConf::Backend Class::Accessor::Lvalue::Fast );
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

sub browse {
    my $self = shift;
    my %args = @_;
    return $self->_newhandle( xs_browse( map {
        $_ || ''
    } @args{ qw( object type domain ) } ));
}

# under the apple api, stopping a browser is exactly like stopping a publish
*browse_stop = \&publish_stop;

sub step {
    my $self = shift;
    my $time = shift;
    $time *= 1000; # millisecs
    xs_step_for( $time, values %{ $self->_handles } );
}

1;
