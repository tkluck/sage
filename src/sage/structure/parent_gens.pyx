r"""
Base class for old-style parent objects with generators

.. note::

   This class is being deprecated, see
   ``sage.structure.parent.Parent`` and
   ``sage.structure.category_object.CategoryObject`` for the new
   model.

Many parent objects in Sage are equipped with generators, which are
special elements of the object.  For example, the polynomial ring
`\ZZ[x,y,z]` is generated by `x`, `y`, and `z`.  In Sage the `i^{th}`
generator of an object ``X`` is obtained using the notation
``X.gen(i)``.  From the Sage interactive prompt, the shorthand
notation ``X.i`` is also allowed.

REQUIRED: A class that derives from ParentWithGens *must* define
the ngens() and gen(i) methods.

OPTIONAL: It is also good if they define gens() to return all gens,
but this is not necessary.

The ``gens`` function returns a tuple of all generators, the
``ngens`` function returns the number of generators.

The ``_assign_names`` functions is for internal use only, and is
called when objects are created to set the generator names.  It can
only be called once.

The following examples illustrate these functions in the context of
multivariate polynomial rings and free modules.

EXAMPLES::

    sage: R = PolynomialRing(ZZ, 3, 'x')
    sage: R.ngens()
    3
    sage: R.gen(0)
    x0
    sage: R.gens()
    (x0, x1, x2)
    sage: R.variable_names()
    ('x0', 'x1', 'x2')

This example illustrates generators for a free module over `\ZZ`.

::

    sage: M = FreeModule(ZZ, 4)
    sage: M
    Ambient free module of rank 4 over the principal ideal domain Integer Ring
    sage: M.ngens()
    4
    sage: M.gen(0)
    (1, 0, 0, 0)
    sage: M.gens()
    ((1, 0, 0, 0), (0, 1, 0, 0), (0, 0, 1, 0), (0, 0, 0, 1))
"""

###############################################################################
#   Sage: System for Algebra and Geometry Experimentation
#       Copyright (C) 2005, 2006 William Stein <wstein@gmail.com>
#  Distributed under the terms of the GNU General Public License (GPL)
#  The full text of the GPL is available at:
#                  http://www.gnu.org/licenses/
###############################################################################

import sage.misc.defaults
from sage.misc.latex import latex_variable_name
import gens_py
cimport parent
from sage.structure.coerce_dict import MonoDict

include '../ext/stdsage.pxi'

cdef inline check_old_coerce(parent.Parent p):
    if p._element_constructor is not None:
        raise RuntimeError, "%s still using old coercion framework" % p

def is_ParentWithGens(x):
    """
    Return True if x is a parent object with generators, i.e., derives from
    :class:`sage.structure.parent_gens.ParentWithGens` and False otherwise.

    EXAMPLES::

        sage: from sage.structure.parent_gens import is_ParentWithGens
        sage: is_ParentWithGens(QQ['x'])
        True
        sage: is_ParentWithGens(CC)
        True
        sage: is_ParentWithGens(Primes())
        False
    """
    return PY_TYPE_CHECK(x, ParentWithGens)

def is_ParentWithAdditiveAbelianGens(x):
    """
    Return True if x is a parent object with additive abelian generators, i.e.,
    derives from
    :mod:`sage.structure.parent_gens.ParentWithAdditiveAbelianGens` and False
    otherwise.

    EXAMPLES::

        sage: from sage.structure.parent_gens import is_ParentWithAdditiveAbelianGens
        sage: is_ParentWithAdditiveAbelianGens(QQ)
        False
        sage: is_ParentWithAdditiveAbelianGens(QQ^3)
        True
    """
    return PY_TYPE_CHECK(x, ParentWithAdditiveAbelianGens)

def is_ParentWithMultiplicativeAbelianGens(x):
    """
    Return True if x is a parent object with additive abelian generators, i.e.,
    derives from
    :class:`sage.structure.parent_gens.ParentWithMultiplicativeAbelianGens` and
    False otherwise.

    EXAMPLES::

        sage: from sage.structure.parent_gens import is_ParentWithMultiplicativeAbelianGens
        sage: is_ParentWithMultiplicativeAbelianGens(QQ)
        False
        sage: is_ParentWithMultiplicativeAbelianGens(DirichletGroup(11))
        True
    """
    return PY_TYPE_CHECK(x, ParentWithMultiplicativeAbelianGens)

def _certify_names(names):
    v = []
    try:
        names = tuple(names)
    except TypeError:
        names = [str(names)]
    for N in names:
        if not isinstance(N, str):
            N = str(N)
        N = N.strip().strip("'")
        if len(N) == 0:
            raise ValueError, "variable name must be nonempty"
        if not N.isalnum() and not N.replace("_","").isalnum():
            # We must be alphanumeric, but we make an exception for non-leading '_' characters.
            raise ValueError, "variable names must be alphanumeric, but one is '%s' which is not."%N
        if not N[0].isalpha():
            raise ValueError, "first letter of variable name must be a letter"
        v.append(N)
    return tuple(v)

def normalize_names(int ngens, names=None):
    r"""
    Return a tuple of strings of variable names of length ngens given the input names.

    INPUT:

    - ``ngens`` - integer

    - ``names``

      - tuple or list of strings, such as ('x', 'y')

      - a string prefix, such as 'alpha'

      - string of single character names, such as 'xyz'

    EXAMPLES::

        sage: from sage.structure.parent_gens import normalize_names as nn
        sage: nn(1, 'a')
        ('a',)
        sage: nn(2, 'zzz')
        ('zzz0', 'zzz1')
        sage: nn(2, 'ab')
        ('a', 'b')
        sage: nn(3, ('a', 'bb', 'ccc'))
        ('a', 'bb', 'ccc')
        sage: nn(4, ['a1', 'a2', 'b1', 'b11'])
        ('a1', 'a2', 'b1', 'b11')

    TESTS::

        sage: nn(2, 'z1')
        ('z10', 'z11')
        sage: PolynomialRing(QQ, 2, 'alpha0')
        Multivariate Polynomial Ring in alpha00, alpha01 over Rational Field
    """
    if names is None:
        return None
    if isinstance(names, str) and names.find(',') != -1:
        names = names.split(',')
    if isinstance(names, str) and ngens > 1 and len(names) == ngens:
        maybe_names = tuple(names)
        try:
            _certify_names(maybe_names)
            names = maybe_names
        except ValueError:
            # this happens when you try for 2 names starting "x0"
            # that gets split to "x", "0" and fails the certification
            pass
    if isinstance(names, str):
        name = names
        names = sage.misc.defaults.variable_names(ngens, name)
        names = _certify_names(names)
    else:
        names = _certify_names(names)
        if not isinstance(names, (list, tuple)):
            raise TypeError, "names must be a list or tuple of strings"
        for x in names:
            if not isinstance(x,str):
                raise TypeError, "names must consist of strings"
        if ngens != 0 and len(names) != ngens:
            raise IndexError, "the number of names must equal the number of generators"
    return names

# Classes that derive from ParentWithGens must define gen(i) and
# ngens() functions.  It is also good if they define gens() to return
# all gens, but this is not necessary.

## def make_parent_gens_v0(_class, _dict,
##                         base, has_coerce_map_from, names):
##     """
##     This should work for any Python class deriving from this, as long
##     as it doesn't implement some screwy __new__() method.
##     """
##     cdef ParentWithGens new_object
##     new_object = _class.__new__(_class)
##     if base is None:
##         new_object._base = new_object
##     else:
##         new_object._base = base
##     new_object._has_coerce_map_from = has_coerce_map_from
##     new_object._names = names
##     if not _dict is None:
##         new_object.__dict__ = _dict
##     return new_object

cdef class ParentWithGens(parent_base.ParentWithBase):
    # Derived class *must* call __init__ and set the base!
    def __init__(self, base, names=None, normalize=True, category = None):
        """
        EXAMPLES::

            sage: class MyParent(ParentWithGens):
            ...       def ngens(self): return 3
            sage: P = MyParent(base = QQ, names = 'a,b,c', normalize = True, category = Groups())
            sage: P.category()
            Category of groups
            sage: P._names
            ('a', 'b', 'c')
        """
        self._base = base
        self._has_coerce_map_from = MonoDict(23)
        self._assign_names(names=names, normalize=normalize)

        # Why does not this call ParentWithBase.__init__ ?
        parent_base.ParentWithBase.__init__(self, base, category=category)
        #if category is not None:
        #    self._init_category_(category)

##     def x__reduce__(self):
##         if self._base is self:
##             base = None
##         else:
##             base = self._base
##         if HAS_DICTIONARY(self):
##             _dict = self.__dict__
##         else:
##             _dict = None
##         return (make_parent_gens_v0, (self.__class__,
##                                       _dict, base,
##                                       self._has_coerce_map_from,
##                                       self._names))

    # Derived class *must* define ngens method.
    def ngens(self):
        check_old_coerce(self)
        raise NotImplementedError, "Number of generators not known."

    # Derived class *must* define gen method.
    def gen(self, i=0):
        check_old_coerce(self)
        raise NotImplementedError, "i-th generator not known."

    def gens(self):
       """
       Return a tuple whose entries are the generators for this
       object, in order.
       """
       cdef int i, n
       if self._gens != None:
           return self._gens
       else:
           v = []
           n = self.ngens()
           for i from 0 <= i < n:
               v.append(self.gen(i))
           self._gens = tuple(v)
           return self._gens

    def _assign_names(self, names=None, normalize=True):
        """
        Set the names of the generator of this object.

        This can only be done once because objects with generators
        are immutable, and is typically done during creation of the object.


        EXAMPLES:

        When we create this polynomial ring, self._assign_names is called by the constructor:

        ::

            sage: R = QQ['x,y,abc']; R
            Multivariate Polynomial Ring in x, y, abc over Rational Field
            sage: R.2
            abc

        We can't rename the variables::

            sage: R._assign_names(['a','b','c'])
            Traceback (most recent call last):
            ...
            ValueError: variable names cannot be changed after object creation.
        """
        if self._element_constructor is not None:
            return parent.Parent._assign_names(self, names=names, normalize=normalize)
        if names is None: return
        if normalize:
            names = normalize_names(self.ngens(), names)
        if self._names is not None and names != self._names:
            raise ValueError, 'variable names cannot be changed after object creation.'
        if isinstance(names, str):
            names = (names, )  # make it a tuple
        elif not PY_TYPE_CHECK(names, tuple):
            raise TypeError, "names must be a tuple of strings"
        self._names = names

    #################################################################################
    # Give all objects with generators a dictionary, so that attribute setting
    # works.   It would be nice if this functionality were standard in Pyrex,
    # i.e., just define __dict__ as an attribute and all this code gets generated.
    #################################################################################
    def __getstate__(self):
        if self._element_constructor is not None:
            return parent.Parent.__getstate__(self)
        d = []
        try:
            d = list(self.__dict__.copy().iteritems()) # so we can add elements
        except AttributeError:
            pass
        d = dict(d)
        d['_base'] = self._base
        d['_gens'] = self._gens
        d['_gens_dict'] = self._gens_dict
        d['_list'] = self._list
        d['_names'] = self._names
        d['_latex_names'] = self._latex_names
        try:
            d['_generator_orders'] = self._generator_orders
        except AttributeError:
            pass

        return d

    def __setstate__(self, d):
        if d.has_key('_element_constructor'):
            return parent.Parent.__setstate__(self, d)
        try:
            self.__dict__.update(d)
            self._generator_orders = d['_generator_orders']
        except (AttributeError,KeyError):
            pass
        self._base = d['_base']
        self._gens = d['_gens']
        self._gens_dict = d['_gens_dict']
        self._list = d['_list']
        self._names = d['_names']
        self._latex_names = d['_latex_names']


    #################################################################################
    # Morphisms of objects with generators
    #################################################################################

    def hom(self, im_gens, codomain=None, check=True):
        r"""
        Return the unique homomorphism from self to codomain that
        sends ``self.gens()`` to the entries of ``im_gens``.
        Raises a TypeError if there is no such homomorphism.

        INPUT:

        - ``im_gens`` - the images in the codomain of the generators of
          this object under the homomorphism

        - ``codomain`` - the codomain of the homomorphism

        - ``check`` - whether to verify that the images of generators extend
          to define a map (using only canonical coercions).

        OUTPUT:

        - a homomorphism self --> codomain

        .. note::

           As a shortcut, one can also give an object X instead of
           ``im_gens``, in which case return the (if it exists)
           natural map to X.

        EXAMPLE: Polynomial Ring
        We first illustrate construction of a few homomorphisms
        involving a polynomial ring.

        ::

            sage: R.<x> = PolynomialRing(ZZ)
            sage: f = R.hom([5], QQ)
            sage: f(x^2 - 19)
            6

            sage: R.<x> = PolynomialRing(QQ)
            sage: f = R.hom([5], GF(7))
            Traceback (most recent call last):
            ...
            TypeError: images do not define a valid homomorphism

            sage: R.<x> = PolynomialRing(GF(7))
            sage: f = R.hom([3], GF(49,'a'))
            sage: f
            Ring morphism:
              From: Univariate Polynomial Ring in x over Finite Field of size 7
              To:   Finite Field in a of size 7^2
              Defn: x |--> 3
            sage: f(x+6)
            2
            sage: f(x^2+1)
            3

        EXAMPLE: Natural morphism

        ::

            sage: f = ZZ.hom(GF(5))
            sage: f(7)
            2
            sage: f
            Ring Coercion morphism:
              From: Integer Ring
              To:   Finite Field of size 5

        There might not be a natural morphism, in which case a TypeError exception is raised.

        ::

            sage: QQ.hom(ZZ)
            Traceback (most recent call last):
            ...
            TypeError: Natural coercion morphism from Rational Field to Integer Ring not defined.
        """
        if self._element_constructor is not None:
            return parent.Parent.hom(self, im_gens, codomain, check)
        if isinstance(im_gens, parent.Parent):
            return self.Hom(im_gens).natural_map()
        if codomain is None:
            from sage.structure.all import Sequence
            im_gens = Sequence(im_gens)
            codomain = im_gens.universe()
        return self.Hom(codomain)(im_gens, check=check)


cdef class ParentWithMultiplicativeAbelianGens(ParentWithGens):
    def generator_orders(self):
        check_old_coerce(self)
        if self._generator_orders != None:
            return self._generator_orders
        else:
            g = []
            for x in self.gens():
                g.append(x.multiplicative_order())
            self._generator_orders = g
            return g

    def __iter__(self):
        """
        Return an iterator over the elements in this object.
        """
        return gens_py.multiplicative_iterator(self)



cdef class ParentWithAdditiveAbelianGens(ParentWithGens):
    def generator_orders(self):
        check_old_coerce(self)
        if self._generator_orders != None:
            return self._generator_orders
        else:
            g = []
            for x in self.gens():
                g.append(x.additive_order())
            self._generator_orders = g
            return g

    def __iter__(self):
        """
        Return an iterator over the elements in this object.
        """
        return gens_py.abelian_iterator(self)




cdef class localvars:
    r"""
    Context manager for safely temporarily changing the variables
    names of an object with generators.

    Objects with named generators are globally unique in Sage.
    Sometimes, though, it is very useful to be able to temporarily
    display the generators differently.   The new Python ``with``
    statement and the localvars context manager make this easy and
    safe (and fun!)

    Suppose X is any object with generators.  Write

    ::

        with localvars(X, names[, latex_names] [,normalize=False]):
             some code
             ...

    and the indented code will be run as if the names in X are changed
    to the new names.  If you give normalize=True, then the names are
    assumed to be a tuple of the correct number of strings.

    EXAMPLES::

        sage: R.<x,y> = PolynomialRing(QQ,2)
        sage: with localvars(R, 'z,w'):
        ...       print x^3 + y^3 - x*y
        ...
        z^3 + w^3 - z*w

    .. note::

       I wrote this because it was needed to print elements of the
       quotient of a ring R by an ideal I using the print function for
       elements of R.  See the code in
       ``quotient_ring_element.pyx``.

    AUTHOR:

    - William Stein (2006-10-31)
    """
    cdef object _obj
    cdef object _names
    cdef object _latex_names
    cdef object _orig

    def __init__(self, obj, names, latex_names=None, normalize=True):
        self._obj = obj
        if normalize:
            self._names = normalize_names(obj.ngens(), names)
            self._latex_names = latex_names
        else:
            self._names = names
            self._latex_names = latex_names

    def __enter__(self):
        self._orig = self._obj.__temporarily_change_names(self._names, self._latex_names)

    def __exit__(self, type, value, traceback):
        self._obj.__temporarily_change_names(self._orig[0], self._orig[1])


