use warnings;
use strict;
use Test::More tests => 8;
use Data::Dumper;
use JSON::XS qw/encode_json/;


use Schema;

my %args = ( @ARGV );
my $size = $args{"size"}  || "small";
my $dbname =  $args{"dbname"} || "t/etc/" . $size . ".db";
my $dbtype = $args{"dbtype"} || "SQLite";
my $password = $args{"p"};
my $username = $args{"u"};
my $host = $args{"h"};

##auto correct db types

$dbtype = "SQLite" if $dbtype =~ /sqlite/i;
$dbtype = "mysql" if $dbtype =~ /mysql/i;
$dbtype = "PostgreSQL" if $dbtype =~ /pg|postgre/i;



my $schema = Schema->init_schema($dbname, $dbtype, $username, $password , $host);

my $user = 1;

$schema->user($user);

my $book_rs = $schema->resultset("Book");

is($book_rs->count,20, "found 20 books");

## find all authors of a particular book 

my $book = $book_rs->search_rs( { -and => [ { 'me.id' => {'>=', 3} } , { 'me.id' => {'<=', 4}   } ] }, 
								{ 
									prefetch => { author_books => 'author'  }  ,
									order_by => { -asc => 'me.id' }
								});

my $authors = $book->first->authors;

my $first_book = $book->next;

is($book->count, 2, 'Found 8 records correctly');

is($first_book->id,4, "Found book id to be correct");

is($first_book->categories->first->category, "Computer Science", "Correct category ");

is($first_book->subtitle, 'The Complete Language ANSI/ISO Compliant, Third Edition', "Found Frzoen column");

is($authors->count,5 , 'This book has 5 authors');

is($authors->first->first_name, 'Connor', "Found correct fist name ");

is($authors->first->country, 'China', "Found correct frozen column ");

## convert entire book hash along with authors

