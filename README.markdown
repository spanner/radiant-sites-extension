# Multi Site #

Created by Sean Cribbs, November 2007. Inspired by the original virtual_domain behavior.

Multi Site allows you to host multiple websites on a single Radiant installation.

## (Forked) ##

This is an extended version by spanner that also gives you a flexible but very robust way to scope other model classes to the current site. It's just a framework - nothing is scoped by default - but very easy to apply. See under scoped resources below.

### Status ###

Hm. Late beta? This is pretty solid now and quite thoroughly tested but a week or two in the wild wouldn't hurt.

### Installation ###

	$ git submodule add git://github.com/spanner/radiant-multi-site-extension.git vendor/extensions/multi_site
	$ rake radiant:extensions:multi_site:migrate
	$ rake radiant:extensions:multi_site:update

or maybe soon just:

	$ rake ray:extension:install name="multi-site" hub="spanner"

### Compatibility ###
This ought to be a drop-in replacement for the original multi_site. It differs from the original in that it will throw an error if no site can be found, but one of the migrations will make sure that a default site is available. In the normal run of events that site will catch all requests, and all manner of thing will be well.

This version of multi_site does cause failures in radiant's main tests, usually when a site is required but the tests don't supply it. I will probably add a 'lax mode' at some point that doesn't mind if no site is defined.

### Scoped resources ###

If you want to site-scope a model class (let's say you want your photo galleries to be site-specific as well as your pages), all you have to do is add a line to the top of the class:

	is_site_scoped

If you want the option to share some instances between sites (say you want some of your users to be confined to one site but some to see all of them):

	is_site_scoped :shareable => true

The scoping takes effect at the ActiveRecord level - it wraps `with_scope` round every call to find (actually, to find_every) and a few other methods. If an object is out of site scope it is as though it didn't exist. This usually means your controller and view code hardly need to change at all: they just see fewer objects. You can fine-tune the scoping by specifying the `site_scope_condition` method in each scoped class.

If a site-scoped class includes any calls to `validates_uniqueness_of`, those too will be scoped to the site. There's a hack there, though: the validations are defined with the model and saved as [procs in an inheritable class attribute][1] which causes all sorts of misery when you want to change them. Instead we've alias_chained the `validates_uniqueness_of` method to apply scope from the start. This has to happen very early in the initialisation procedure, when we don't really have much configuration information, so the uniqueness validation scope is applied to every model with a `site_id` column. I hope to find a better solution but it does work.

There is, or will soon be, more about this [in the wiki][2] and one day I'll get round to posting some [proper documentation][3].

### Examples ###

The [scoped_admin extension][4] uses this method to confine layouts, snippets and (some) 
users to sites. It only takes four lines of code and two partials.

We've also shrunk the [paperclipped_multi_site extension][5] to a one-liner.

Our [reader extension][6] - which handles the mechanics of site membership - is site scoped if this extension is present. It includes a useful `fake_site_scope` class that drops a warning in the log if site-scoping is not possible but otherwise lets the extension work in a single-site installation.

### Security ###

Is one of the main goals. A couple of our clients are very security-conscious and we needed something in which there was no risk at all of the wrong person seeing a page. This will make more sense when I publish the [groups][7]) extension, which is next. If you see a loophole we'd be __very__ glad to know of it.

### Questions and comments ###

Would be very welcome. Contact Will on will at spanner.org.

[1]: <http://casperfabricius.com/site/2008/12/06/removing-rails-validations-with-metaprogramming/>
[2]: <http://wiki.github.com/spanner/radiant-multi-site-extension>
[3]: <http://spanner.org/radiant/multi_site> "Not there yet!"
[4]: <http://github.com/spanner/radiant-scoped-admin-extension>
[5]: <http://github.com/spanner/radiant-paperclipped_multisite-extension>
[6]: <http://github.com/spanner/radiant-reader-extension>
[7]: <http://github.com/spanner/radiant-groups-extension>

- - -

## Original multi_site ##

Each site has its own independent 
sitemap/page-tree and these attributes:

* name: Whatever you want to call the site
* domain: A Ruby regular expression (without the //) to match the request against
* base_domain: A canonical domain name for doing quicker matches and for
               generating absolute URLs against
* homepage_id: The numerical database ID of the root page (usually
               you can just leave this alone).

Included images are slightly modified from FamFamFam Silk Icons by Mark James:
http://www.famfamfam.com/lab/icons/silk/

### Installation ###

1) Unpack/checkout/export the extension into vendor/extensions of your 
   project.

2) Run the extension migrations.

	$ rake production db:migrate:extensions

3) Run the extension update task.

	$ rake production radiant:extensions:multi_site:update

4) Restart your server

### Other Extensions ###

Multi Site allows you to customize routes within your other extensions. To
restrict a route to a particular site, pass the site's name into the
conditions hash:

	map.resources :things, :conditions => { :site => 'My Site' }

You can also scope a route to multiple sites with an array:

	map.resources :things, :conditions => { :site => ['My Site', 'Your Site'] }

### Acknowledgments ###

Thanks to Digital Pulp, Inc. for funding the initial development of this
extension as part of the Redken.com project.