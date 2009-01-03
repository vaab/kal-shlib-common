What is kal-shlib-common ?
--------------------------

This is part of 'kal-shlib' package, you should see documentation of
kal-shlib-core for more general information.

How can install it ?
--------------------

From source:

Consider this release as Very Alpha. Use at your own risk. It may or may not
upgrade to a more user friendly version in future, depending on my spare time.

Nethertheless, this package support GNU install quite well so a simple :

# ./configure && make && make install

Should work (and has been tested and is currently used).

Note : you can specify a '--prefix=/your/location'

From debian package:

A debian package repository is available at:

deb http://deb.kalysto.org no-dist kal-alpha

you should include this repository to your apt system and then:

What are dependencies for this pacakge ?
----------------------------------------

You will need to install:

kal-shlib-core

before using this package.

What does contain this package ?
---------------------------------

Libraries which are files called 'lib*.sh' installed in
  $prefix/lib/shlib/

The debian package version will install directly to this location
(knowing that prefix is "/")

