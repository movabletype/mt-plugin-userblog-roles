# UserblogRoles, a plugin for Movable Type

Authors: Six Apart Ltd.  
Copyright: 2009 Six Apart Ltd.  
License: [Artistic License 2.0](http://www.opensource.org/licenses/artistic-license-2.0.php)


## Overview

Define the role(s) provisioned to new users on their user blogs.

The UserblogRoles plugin overrides the default role ("Blog Administrator") provided to the owner of new user blogs. One of more roles are defined as the value of the `UserblogStartingRoles` [configuration directive](http://www.movabletype.org/documentation/appendices/config-directives/).

When the Movable Type installation is configured to create new blogs for each user the user is given the role of "Blog Administrator" on their blog. With the "Blog Administrator" role the user has full permissions to everything on this blog. In some systems it may be desireable to remove some functionality\* and permissions (such as the ability to edit templates if every user is given the same template set).

\* [The Demenuator](http://github.com/sixapart/mt-plugin-Demenuator) (de-MENU-ator) plugin removes specified menus and menu items from the MT UI.


## Requirements

* MT 4.x


## Features

* Defines one or more roles to be assigned to users created


## Documentation

Once the plugin is installed, add the `UserblogStartingRoles` config directive to the [`mt-config.cgi`](http://www.movabletype.org/documentation/installation/mt-config.html) file.

The value can be one or more comma-separated roles listed on the System Overview > Manage > Users > Roles screen.

To specify the "Author" role:

    UserblogStartingRoles Author

To specify a custom role such as "Userblogger", create the role in Movable Type then specify the role as such:

    UserblogStartingRoles Userblogger

To specify more than one role:

    UserblogStartingRoles Editor, Designer


## Installation

1. Move the UserblogRoles plugin directory to the MT `plugins` directory.

Should look like this when installed:

    $MT_HOME/
        plugins/
            UserblogRoles/

[More in-depth plugin installation instructions](http://tinyurl.com/easy-plugin-install).


## Desired Feature Wish List

* add wish-list item here


## Support

This plugin is not an official Six Apart Ltd. release, and as such support from Six Apart Ltd. for this plugin is not available.
