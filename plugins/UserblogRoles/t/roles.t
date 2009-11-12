use strict;
use warnings;

use lib 't/lib', 'lib', 'extlib';
use Test::More tests => 15;
use MT::Test qw( :cms :db );
use MT;
use MT::Association;
use MT::Author;
use MT::Blog;
use MT::TemplateMap;

my $app = MT::App->instance;

my $blog = MT::Blog->new();
$blog->set_values(
    {   name         => 'none',
        site_url     => 'http://narnia.na/nana/',
        archive_url  => 'http://narnia.na/nana/archives/',
        site_path    => 't/site/',
        archive_path => 't/site/archives/',
        archive_type => 'Individual,Monthly,Weekly,Daily,Category,Page',
        archive_type_preferred   => 'Individual',
        description              => "Narnia None Test Blog",
        custom_dynamic_templates => 'custom',
        convert_paras            => 1,
        allow_reg_comments       => 1,
        allow_unreg_comments     => 0,
        allow_pings              => 1,
        sort_order_posts         => 'descend',
        sort_order_comments      => 'ascend',
        remote_auth_token        => 'token',
        convert_paras_comments   => 1,
        google_api_key           => 'r9Vj5K8PsjEu+OMsNZ/EEKjWmbCeQAv1',
        server_offset            => '-3.5',
        children_modified_on     => '20000101000000',
        language                 => 'en_us',
        file_extension           => 'html',
    }
);
$blog->id(1);
$blog->commenter_authenticators('enabled_TypeKey');
$blog->save() or die "Couldn't save blog 1: " . $blog->errstr;
use MT::TemplateMap;
my @tms = MT::TemplateMap->load();
for my $tm ( @tms ) {
    $tm->remove();
}

MT->config( 'NewUserTemplateBlogId', 1 );

my ( @associations, $association );
my $a = _new_author( 'Abigail', 2 );
$app->run_callbacks( 'new_user_provisioning', $a );
$association = MT::Association->load( { author_id => $a->id } );
my $blog_admin = MT::Role->load_by_permission('administer_blog');
is( $association->blog_id, 2,
    'New user provisioning creates blog in base case' );
is( $association->role_id, $blog_admin->id,
    'New user provisioning sets user to blog admin in base case' );

MT->config( 'UserblogStartingRoles', 'Editor' );
my $b = _new_author( 'Barry', 3 );
$app->run_callbacks( 'new_user_provisioning', $b );
@associations = MT::Association->load( {blog_id => 3 } );
is( scalar @associations, 1,
    'UserblogStartingRoles set to "Editor" results in single association' );
$association = $associations[0];
my $editor = MT::Role->load( $association->role_id );
is( $editor->name, 'Editor',
    '...which is the Editor role' );

MT->config( 'UserblogStartingRoles', 'Editor, Designer' );
my $c = _new_author( 'Carlos', 4 );
$app->run_callbacks( 'new_user_provisioning', $c );
@associations = MT::Association->load( {blog_id => 4 } );
is( scalar @associations, 2,
    'UserblogStartingRoles set to "Editor, Designer" results in two associations' );
my $designer = MT::Role->load({ name => 'Designer'});
is( $associations[0]->role_id, $editor->id,
    '...the first of which is the Editor role' );
is( $associations[1]->role_id, $designer->id,
    '...and the second of which is the Designer role' );

MT->config( 'UserblogStartingRoles', 'Xyzzy' );
my $d = _new_author( 'Donna', 5 );
$app->run_callbacks( 'new_user_provisioning', $d );
@associations = MT::Association->load( {blog_id => 5 } );
is( scalar @associations, 1,
    'UserblogStartingRoles set to "Xyzzy" results in one association' );
is( $associations[0]->role_id, $blog_admin->id,
    '...which is Blog Administrator (default), since Xyzzy role was not found' );

MT->config( 'UserblogStartingRoles', 'Blog Administrator, Designer' );
my $e = _new_author( 'Emil', 6 );
$app->run_callbacks( 'new_user_provisioning', $e );
@associations = MT::Association->load( {blog_id => 6 } );
is( scalar @associations, 2,
    'UserblogStartingRoles set to "Blog Administrator, Designer" results in two associations' );
is( $associations[0]->role_id, $blog_admin->id,
    '...the first of which is the Blog Administrator role' );
is( $associations[1]->role_id, $designer->id,
    '...and the second of which is the Designer role' );

MT->config( 'UserblogStartingRoles', 'Editor' );
my $f = _new_author( 'Frances', 7 );
my $blog2 = MT::Blog->load(2);
my $blog3 = MT::Blog->load(3);
MT::Association->link( $f => $designer => $blog2 );
MT::Association->link( $f => $designer => $blog3 );
$app->run_callbacks( 'new_user_provisioning', $f );
@associations = MT::Association->load( {blog_id => 7 } );
is( $associations[0]->role_id, $editor->id,
    'UserblogStartingRoles is applied even if new author has non-Blog Administrator roles elsewhere' );

my $g = _new_author( 'Gary', 8 );
MT::Association->link( $g => $designer => $blog2 );
MT::Association->link( $g => $blog_admin => $blog3 );
$app->run_callbacks( 'new_user_provisioning', $g );
@associations = MT::Association->load( {blog_id => 8 } );
is( $associations[0]->role_id, $blog_admin->id,
    '...but if new author has Blog Administrator roles elsewhere, UserblogStartingRoles is ignored' );

MT->config( 'UserblogStartingRoles', $designer->id );
my $h = _new_author( 'Harry', 9 );
$app->run_callbacks( 'new_user_provisioning', $h );
@associations = MT::Association->load( {blog_id => 9 } );
is( $associations[0]->role_id, $designer->id,
    'UserblogStartingRoles can take id instead of role name');

sub _new_author {
    my ( $name, $id ) = @_;
    my $a = MT::Author->new();
    $a->set_values(
        {   name         => lc($name),
            nickname     => $name,
            email        => lc($name) . '@example.com',
            url          => "http://$name.com/",
            api_password => 'seecret',
            auth_type    => 'MT',
            created_on   => '19780131074500',
        }
    );
    $a->set_password("password");
    $a->type( MT::Author::AUTHOR() );
    $a->id($id);
    $a->save() or die "Failed to save author $name";
    return $a;
}
