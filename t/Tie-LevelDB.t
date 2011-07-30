# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Tie-LevelDB.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 6;
BEGIN { use_ok('Tie::LevelDB') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $DBDIR = "/tmp/leveldb-test";
system("rm -rf $DBDIR");
my $db = Tie::LevelDB->new($DBDIR);
is(ref $db,"Tie::LevelDB");
ok(-d $DBDIR);

is($db->Get("k1"),'');
$db->Put("k1","v1");
is($db->Get("k1"),"v1");
$db->Delete("k1");
is($db->Get("k1"),'');

system("rm -rf $DBDIR");
