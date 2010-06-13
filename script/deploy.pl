use aliased 'DBIx::Class::DeploymentHandler' => 'DH';
use lib "lib";
use Schema;

`rm -f music.db`;

my $s = Schema->connect("dbi:SQLite:music.db");

$s->deploy;
$s->user(1);

my $artist_rs = $s->resultset("Artist");
my $cd_rs = $s->resultset("Cd");

my $artist = $artist_rs->fetch_new();

$artist->save( { first_name => "Harshal",
                 last_name  => "Shah",
                 dbo        => "1979-04-07",
                 address_1  => "A/13 Anand Nagar ",
                 address_2  => "Forjett Street",
                 city       => "Mumbai",
                 state      => "Maharashtra",
                 country    => "India",
                 zip        => 400034,
                 summary    => "Just a test" });

my $cd = $cd_rs->fetch_new();

$cd->save( {    name        => "5th Symphony",
                release_date=> "2010-06-01",
                artist_id   => $artist->id,
                record_company => "Pentagram Records",
                summary     => "My very 1st record" });

