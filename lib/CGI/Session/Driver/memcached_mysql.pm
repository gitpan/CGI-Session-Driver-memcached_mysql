package CGI::Session::Driver::memcached_mysql;

# $Id$

use strict;

use Carp qw(croak);
use CGI::Session::Driver::mysql;

@CGI::Session::Driver::memcached_mysql::ISA = ( "CGI::Session::Driver::mysql" );
$CGI::Session::Driver::memcached::VERSION = "0.01";

sub init {
    my $self = shift;
    unless (defined $self->{Memcached}) {
        return $self->set_error("init(): 'Memcached' attribute is required.");
    }

    return $self->SUPER::init();
}

sub retrieve {
    my $self = shift;
    my ($sid) = @_;
    croak "retrieve(): usage error" unless $sid;

    my $memcached = $self->{Memcached};
    my $rv = $memcached->get("$sid");
#warn "retrieve(): CACHE HIT sid=$sid, $rv\n" if (defined $rv);
    
    unless (defined $rv) {
#        warn "retrieve(): CACHE MISS sid=$sid\n";
        return $self->SUPER::retrieve(@_);
    }

    return $rv;
}


sub store {
    my $self = shift;
    my ($sid, $datastr) = @_;
    croak "store(): usage error" unless $sid && $datastr;

#warn "store(): sid=$sid, $datastr\n";
    my $memcached = $self->{Memcached};
    $memcached->set($sid, $datastr);

    return $self->SUPER::store(@_);
}

sub remove {
    my $self = shift;
    my ($sid) = @_;
    croak "remove(): usage error" unless $sid;

    $self->{Memcached}->delete($sid);

    return $self->SUPER::remove(@_);
}


1;


=pod

=head1 NAME

CGI::Session::Driver::memcached_mysql - CGI::Session driver for memcached and mysql

=head1 SYNOPSIS

    use CGI::Session;
    use DBI;
    use Cache::Memcached;
    
    $dbh = DBI->connect(
        'DBI:mysql:cgi_session;host=localhost', 'root', ''
    ) or die $DBI::errstr;
    $memcached = Cache::Memcached->new({
        servers => [ 'localhost:11211' ],
        debug   => 0,
        compress_threshold => 10_000,
    });
    $s = CGI::Session->new('driver:memcached_mysql', $sid,
                           { Memcached => $memcached, Handle => $dbh } );

=head1 DESCRIPTION

B<memcached_mysql> stores session data into memcached and MySQL. It retrieves session data from memcached first. If that fails, then it retrives session data from MySQL. So CGI::Session::driver::memcached_mysql ensures your session data is stored into MySQL at least.

=head1 DRIVER ARGUMENTS

B<memcached_mysql> supports all the arguments documented in L<CGI::Session::Driver::mysql|CGI::Session::Driver::mysql> and L<CGI::Session::Driver::memcached>.

=head1 REQUIREMENTS

=over 4

=item L<CGI::Session>

=item L<Cache::Memcached>

=back

=head1 SEE ALSO

=item L<CGI::Session::Driver::mysql>

=item L<CGI::Session::Driver::memcached>

=cut

=head1 AUTHOR

Kazuhiro Oinuma <oinume@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 - 2006 Kazuhiro Oinuma <oinume@cpan.org>. All rights reserved. This library is free software. You can modify and or distribute it under the same terms as Perl itself.

=cut

