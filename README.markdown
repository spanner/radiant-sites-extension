# Sites #

Developed from the original `multi_site` extension, itself inspired by the old virtual_domain behaviour (anyone else remember that?)

This is extension is in development and doesn't work yet. It takes our fork of multi_site and adds site templates, import-export, subdomain-creation and other requirements for creating new sites on the fly. Some of these features may later spin off into their own extensions, but we'll start them off together here and see what happens.

## Status

If it works, it's by accident.

### To do ###

* Change interface to `has_site` and `has_many_sites` to allow, for example, a user access to some but not all sites.
* Site-scoped (and global) Radiant::Config (without breaking the cache) 
* YAML site templates and chooser 
* Non-horrible site admin interface
* Userland site-creation interface
* Site import and export
* Dashboard integration

## Requirements ##

There are no absolute requirements but you will want to install our submenu extension since that has taken over the job of showing the site-chooser above any site-scoped index page.

## Installation ##

	$ git submodule add git://github.com/spanner/radiant-sites-extension.git vendor/extensions/sites
	
If you're coming from multi_site, don't run `rake db:migrate:extensions`: the radiant migrator ignores the migration task defined here, which does some useful checking of `multi_site` migrations. Instead, this:

	$ rake radiant:extensions:sites:migrate
	$ rake radiant:extensions:sites:update

## Scoped resources ##

If you want to site-scope a model class (let's say you want your assets to be site-specific as well as your pages), all you have to do is add a line to the top of the class:

	has_site

If you want selective availability of some resources to many sites (or many sites to some users), this:

	has_many_sites

The scoping takes effect at the ActiveRecord level - it wraps `with_scope` round every call to find (actually, to find_every), count and similar methods. If an object is out of site scope it is as though it didn't exist. This usually means your controller and view code hardly need to change at all: they just see fewer objects.

You can explicitly state that something 

	has_no_site

Which is the same as not saying that it does have a site, except that it will negate any previous `has_site` declaration and might be useful in a subclass.

### Compatibility ###

Please note that the old `is_site_scoped` interface is about to break. Our [fork of `multi_site`](http://github.com/spanner/radiant-multi-site-extension "spanner's radiant-multi-site-extension at master - GitHub") is still available and works fine if you prefer that and don't need the other functionality. If you're just hosting a few sites of your own, it's all you need.

### Validations ###

If a site-scoped class includes any calls to `validates_uniqueness_of`, those too will be scoped to the site. This presents problems with model classes that have already got uniqueness validations, like most of radiant's core classes: it's very difficult to go back and change the validation rules. Instead, we reach back and change the whole validation mechanism. That happens very early on in the initialization of the app, so we can't look at associations. Instead, when defining the validations we check for the presence of a `site_id` column and scope to that if it's there. It's not a very nice solution but it does work, and if the column isn't used the scoping has no effect.

Have a look at `lib/sites/scoped_validation.rb` to see what I mean. I hope that a bit of headscratching with the core team will let us get rid of this hack, but for now it is needed to support `scoped_admin`.

There is, or will soon be, more about this [in the wiki](http://wiki.github.com/spanner/radiant-sites-extension) and one day I'll get round to posting some [proper documentation](http://spanner.org/radiant/sites).

### Questions and comments ###

Would be very welcome. Contact Will on will at spanner.org or drop [something into lighthouse](http://spanner.lighthouseapp.com/projects/26912-radiant-extensions). Github messages also fine.
