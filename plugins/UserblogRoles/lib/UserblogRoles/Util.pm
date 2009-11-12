package UserblogRoles::Util;

use MT::Association;
use MT::ConfigMgr;
use MT::Blog;
use MT::Role;

sub newblog_callback {
    my ( $cb, $user ) = @_;
    my $default_roles = MT->config->UserblogStartingRoles;
    my $blog;
    if ($default_roles) {
        my $orig_role = MT::Role->load_by_permission('administer_blog');
        if ( !$orig_role ) {    # Can't find Blog Administrator
            return 1;
        }
        my @association = MT::Association->load(
            { author_id => $user->id, role_id => $orig_role->id } );
        if ( !@association or @association > 1 ) {
            # Something strange has happened!
            return 1;
        }
        my $old_association = shift @association;
        $blog            = MT::Blog->load( $old_association->blog_id );
        if ( !$blog ) {

            # Something else strange has happened!
            return 1;
        }
        my @roles = split( /\s*,\s*/, $default_roles );
        my ( $original_duplicated, $dirty );
        foreach my $role_name (@roles) {
            my $role = MT::Role->load( { name => $role_name } );
            if ( !$role ) {
                $role = MT::Role->load($role_name);
            }
            if ( $role and $role->id != $orig_role->id ) {
                MT::Association->link( $user => $role => $blog );
                $dirty = 1;
            }
            elsif ($role) {
                $original_duplicated = 1;
            }
        }
        if ( $dirty and !$original_duplicated ) {
            $old_association->remove;
        }
    }
}

1;
