---
layout: post
title: "Feedburner and Apache Redirects"
date: 2007-06-05 16:15
comments: true
categories: web
author: David Glassborow
---
Looking at the load this blog is causing, virtually all of it's requests are for the syndication feeds so I decided to off-load the network bandwidth to [Feed Burner](http://www.feedburner.com) ( recently acquired by Google).

Feedburner basically checks your site every 30 minutes (you can also manually request an update) and caches the response. Rather than ask my subscribers to change the feeds source, I decided to use Apache to redirect all requests to my feeds to feedburner, unless it was actually feedburner requesting the information.

To get this to work took a bit of Apache shenanigans, so I thought I would document it here both for myself and for anyone else who needs to do the same. It is also a useful example of how powerful Apache is, particularly as a forward facing server than manages the virtual URL space and links it up to various webs server technologies and platforms behind the scenes (loose URL => implementation coupling). The blog is running on Ruby on Rails, Typo engine, running on port 4000 internally. Our firewall blocks outside access to this port, so we use Apache to proxy it for us (it rewrites any URL's on the way out to be the correct external address). We also use it as an SSL gateway, so we setup all the certificates in just one place.
<!--more-->
All configuration in Apache is done in the http.conf file. Here is the setup I am using for the blogs subdomain with notes of what is going on. There is also a similar `VirtualHost` setting for 443 (SSL Access), but doesn't really add much by posting it here. I will give a quick summary of what is going on here, but full details can be found on the excellent [Apache documentation](http://httpd.apache.org/docs/)

    # Concept First blog
    <VirtualHost *:80>
      ServerName blogs.conceptfirst.com
      DocumentRoot "e:/Blogs/www"
      ErrorLog "e:/blogs/logs/error.log"
      CustomLog e:/blogs/logs/access.log common
      DirectoryIndex index.html
      <Directory "e:/Blogs/www">
        Options none
        AllowOverride None
        Order allow,deny
        Allow from all
      </Directory>

Tell apache which virtual host name this is for, where static files are, where to put log files, etc.

      RewriteEngine on

RewriteEngine on tells apache to apply the following rules. Apache can handle redirects and proxying using `Redirect` and `ProxyPass` directives, but I had issues with the order things were being done in, so used rewrite rules for it all. Rewrite rules are more flexible and powerful than the individual Redirect or ProxyPass directives, so its worth understanding their capabilities in full.

      RewriteLogLevel 0
      # RewriteLog "e:/rewrite.log"

If having problems debugging rewrite rules, I'd recommend just setting up a log file and turning RewriteLogLevel to 9. Turn it off by putting back to 0 when everything is working.

      # Redirect feeds to feedburner unless actually feed burner. Only do main ones
      RewriteCond %{HTTP_USER_AGENT} !FeedBurner  
      RewriteRule /xml/rss20/feed.xml$ http://feeds.feedburner.com/ConceptFirst [R,L]
      RewriteCond %{HTTP_USER_AGENT} !FeedBurner  
      RewriteRule /xml/atom10/feed.xml$ http://feeds.feedburner.com/ConceptFirst [R,L]

This is the configuration that tells Apache to redirect all my traffic to feedburner unless its from Feedburner itself.

- RewriteCond: A condition rule, applies to the next line. It is negated by !
- RewriteRule: A rewriting rule, with a match part (regular expression) and a target
 - [R]: Send a HTTP 302 redirect
 - [P]: Do a internal proxy
 - [L]: Stop applying rewrite rules after this one

So the first two lines tells Apache (in random syntax pseudo-code): `IF (HTTP_USER_AGENT <> 'FeedBurner') AND (URL = '/xml/rss20/feed.xml') THEN SEND_REDIRECT_TO('http://feeds.feedburner.com/ConceptFirst') AND STOP_PROCESSING_RULES`

Feedburner uses the HTTP header USER_AGENT set to FeedBurner so that is how we detect it and don't redirect it to itself ! I am only redirecting my main feeds here, the categorised feeds and individual comment feeds are still handled by the blog engine.

      # Make admin secure
      RewriteRule /accounts(.*) https://blogs.conceptfirst.com/accounts$1 [R,L] 
      RewriteRule /admin(.*) https://blogs.conceptfirst.com/admin$1 [R,L] 

These two lines use a similar rules to make sure the admin parts of the blog are handled through HTTPS so we don't get any cleartext passwords floating around on the net. The $1 at the end of the redirect is the matched data from (.*) in the regular expression. So if the URL is /admin/login, $1 will be /login.

      # Proxy to mongrel for everything but the media directory
      RewriteCond $1 !^Media/(.*)
      RewriteRule /(.*) http://localhost:4000/$1 [P,L]

This is the rule that actually gets the blog pages from the internal ruby on rails app. The condition rule is checking the URL match to make sure it is not part of the Media subdirectory (this is a static directory that apache serves up, it contains images for blog entries, etc). Everything else gets passed to the server running on 4000.

      ExpiresActive On
      ExpiresByType text/html "now plus 1 day"
      ExpiresByType image/gif "now plus 1 week"
      ExpiresByType image/jpeg "now plus 1 week"
      ExpiresByType text/css "now plus 1 week"
      ExpiresByType image/png "now plus 1 week"
      ExpiresByType image/jpg "now plus 1 week"
    </VirtualHost>

The Expires stuff is the Apache way of setting the HTTP expires headers when sending responses. I've set images to be cached on the client for a week to help reduce bandwidth and load on the server.

I greatly recommend Apache, its very easy to setup, and very powerful (although it does test your knowledge of regular expressions :-), we've used it to proxy Ruby On Rails, Cold Fusion, IIS and home grown web servers, and its great for rewriting URLs to make them technology agnostic and nice and RESTful.