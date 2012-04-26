What is kal-shlib-common ?
--------------------------

This is part of ``kal-shlib-*`` package, you should see `documentation`_ of
``kal-shlib-core`` for more general information.

.. _documentation: https://github.com/vaab/kal-shlib-core/blob/master/README.rst

How can install it ?
--------------------

From source
'''''''''''

Consider this release as Very Alpha. Use at your own risk. It may or may not
upgrade to a more user friendly version in future, depending on my spare time.

Nethertheless, this package support GNU install quite well so a simple::

  # autogen.sh && ./configure && make && make install

Should work (and has been tested and is currently used).

.. note:: you can specify a prefix thanks to ``--prefix=/your/location`` as
  ``configure`` argument.

From debian package
'''''''''''''''''''

A debian package repository is available at::

  deb http://deb.kalysto.org no-dist kal-alpha

you should include this repository to your apt system and then::
  
  apt-get update && apt-get install kal-shlib-common

What are dependencies for this pacakge ?
----------------------------------------

You will need to install::

  kal-shlib-core

before using this package. Note that if you choose the debian package
installation, dependencies will be installed automatically.

What does contain this package ?
---------------------------------

Libraries which are files called ``lib*.sh`` installed in
``$prefix/lib/shlib/``

The debian package version will install directly to this location (knowing that
prefix is ``/usr``)

What these libraries provide ?
------------------------------

I'm sorry, but this README should answer such question but I didn't have time
to answer it. The source code is quite readable. Enjoy ;)
