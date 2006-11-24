#!/usr/bin/perl

use strict;
use diagnostics;

my @servers = ('localhost:11211');
if ($ENV{CGISESS_MEMCACHED_SERVERS}) {
    @servers = split ':', $ENV{CGISESS_MEMCACHED_SERVERS};
}

use Test::More;
use CGI::Session::Test::Default;
use DBI;

for (qw(Cache::Memcached)) {
    eval "require $_";
    if ($@) {
        plan(skip_all=>"$_ is NOT available");
        exit 0;
    }
}

my $memcached = Cache::Memcached->new({
    servers => \@servers,
    debug   => 1,
});
my $dsn = $ENV{DBI_DSN} || '';
my $dbh = DBI->connect(
    $ENV{DBI_DSN} || 'DBI:mysql:cgi_session;host=localhost',
    $ENV{DBI_USER} || 'root',
    $ENV{DBI_PASS} || '',
    { RaiseError => 1 },
) or die $DBI::errstr;

my $TEST_KEY = '__cgi_session_driver_memcached_mysql';
$memcached->set($TEST_KEY, 1);
unless (defined $memcached->get($TEST_KEY)) {
    plan(skip_all=>"memcached server is NOT available");
    exit 0;
}

require CGI::Session::Driver::memcached_mysql;
my $t = CGI::Session::Test::Default->new(
    dsn  => "dr:memcached_mysql",
    args => { Memcached => $memcached, Handle => $dbh }
);

plan tests => $t->number_of_tests;
$t->run();
