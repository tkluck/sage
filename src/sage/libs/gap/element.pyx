"""
libGAP element wrapper

This document describes the individual wrappers for various GAP
elements. For general information about libGAP, you should read the
:mod:`~sage.libs.gap.libgap` module documentation.
"""

###############################################################################
#       Copyright (C) 2012, Volker Braun <vbraun.name@gmail.com>
#
#   Distributed under the terms of the GNU General Public License (GPL)
#   as published by the Free Software Foundation; either version 2 of
#   the License, or (at your option) any later version.
#                   http://www.gnu.org/licenses/
###############################################################################

from sage.structure.sage_object cimport SageObject
from sage.structure.parent import Parent
from sage.rings.all import ZZ




############################################################################
### helper functions to construct lists and records ########################
############################################################################

cdef libGAP_Obj make_gap_list(sage_list):
    """
    Convert Sage lists into Gap lists

    INPUT:

    - ``a`` -- list of :class:`GapElement`.

    OUTPUT:

    The list of the elements in ``a`` as a Gap ``Obj``.
    """
    # FIXME slow -- to make fast directly use ADD_LIST in Gap's C code.
    from sage.libs.gap.libgap import libgap
    cdef GapElement l = libgap.eval('[]')
    for x in sage_list:
        l.Add(x)
    return l.value


cdef libGAP_Obj make_gap_record(sage_dict):
    """
    Convert Sage lists into Gap lists

    INPUT:

    - ``a`` -- list of :class:`GapElement`.

    OUTPUT:

    The list of the elements in ``a`` as a Gap ``Obj``.

    TESTS::

        sage: libgap({'a': 1, 'b':123})   # indirect doctest
        rec( a := 1, b := 123 )
    """
    from sage.libs.gap.libgap import libgap
    data = [ (str(key), libgap(value)) for key, value in sage_dict.iteritems() ]

    libgap_enter()
    cdef libGAP_Obj rec = libGAP_NEW_PREC(len(data))
    cdef GapElement val
    cdef libGAP_UInt rnam
    for d in data:
        key, val = d
        rnam = libGAP_RNamName(key)
        libGAP_AssPRec(rec, rnam, val.value)
    libgap_exit()
    return rec


cdef libGAP_Obj make_gap_integer(sage_int):
    """
    Convert Sage lists into Gap lists

    INPUT:

    - ``sage_int`` -- a Sage integer.

    OUTPUT

    The integer as a GAP ``Obj``.

    TESTS::

        sage: libgap(1)   # indirect doctest
        1
    """
    libgap_enter()
    cdef libGAP_Obj result = libGAP_INTOBJ_INT(<int>sage_int)
    libgap_exit()
    return result


cdef libGAP_Obj make_gap_string(sage_string):
    """
    Convert a Sage string to a Gap string

    INPUT:

    - ``sage_string`` -- a Sage integer.

    OUTPUT

    The string as a GAP ``Obj``.

    TESTS::

        sage: libgap('string')   # indirect doctest
        "string"
    """
    libgap_enter()
    cdef libGAP_Obj result
    libGAP_C_NEW_STRING(result, len(sage_string), <char*>sage_string)
    libgap_exit()
    return result


############################################################################
### generic construction of GapElements ####################################
############################################################################

cdef GapElement make_any_gap_element(parent, libGAP_Obj obj):
    """
    Return the libGAP element wrapper of ``obj``

    The most suitable subclass of GapElement is determined
    automatically. Use this function to wrap GAP objects unless you
    know exactly which type it is (then you can use the specialized
    ``make_GapElement_...``)
    """
    if obj is NULL:
        return make_GapElement(parent, obj)
    # print 'num', libGAP_TNUM_OBJ(obj), libGAP_TNUM_BAG(obj), libGAP_T_STRING
    cdef int num = libGAP_TNUM_OBJ(obj)
    if num == libGAP_T_INT or num == libGAP_T_INTPOS or num == libGAP_T_INTNEG:
        return make_GapElement_Integer(parent, obj)
    elif num == libGAP_T_RAT:
        return make_GapElement_Rational(parent, obj)
    elif num == libGAP_T_BOOL:
        return make_GapElement_Boolean(parent, obj)
    elif num == libGAP_T_FUNCTION:
        return make_GapElement_Function(parent, obj)
    elif num == libGAP_T_PERM2 or num == libGAP_T_PERM4:
        return make_GapElement_Permutation(parent, obj)
    elif num == libGAP_T_PREC:
        return make_GapElement_Record(parent, obj)
    elif num >= libGAP_T_STRING and num <= libGAP_T_STRING_SSORT + libGAP_IMMUTABLE:
        # GAP strings are lists, too. Make sure this comes before make_GapElement_List
        return make_GapElement_String(parent, obj)
    elif num >= libGAP_FIRST_LIST_TNUM and num <= libGAP_LAST_LIST_TNUM:
        return make_GapElement_List(parent, obj)
    else:
        return make_GapElement(parent, obj)


############################################################################
### GapElement #############################################################
############################################################################

cdef GapElement make_GapElement(parent, libGAP_Obj obj):
    r"""
    Turn a Gap C object (of type ``Obj``) into a Cython ``GapElement``.

    INPUT:

    - ``parent`` -- the parent of the new :class:`GapElement`

    - ``obj`` -- a GAP object.

    OUTPUT:

    A :class:`GapElement_Function` instance, or one of its derived
    classes if it is a better fit for the GAP object.

    EXAMPLES::

        sage: libgap(0)
        0
        sage: type(_)
        <type 'sage.libs.gap.element.GapElement_Integer'>

        sage: libgap.eval('')
        NULL

        sage: libgap(None)
        Traceback (most recent call last):
        ...
        AttributeError: 'NoneType' object has no attribute '_gap_init_'
    """
    cdef GapElement r = GapElement.__new__(GapElement)
    r._initialize(parent, obj)
    return r


cdef class GapElement(RingElement):
    r"""
    Wrapper for all Gap objects.

    .. NOTE::

        In order to create ``GapElements`` you should use the
        ``libgap`` instance (the parent of all Gap elements) to
        convert things into ``GapElement``. You must not create
        ``GapElement`` instances manually.

    EXAMPLES::

        sage: libgap(0)
        0

    If Gap finds an error while evaluating, a corresponding assertion is raised::

        sage: libgap.eval('1/0')
        Traceback (most recent call last):
        ...
        ValueError: libGAP: Error, Rational operations: <divisor> must not be zero

    Also, a ``ValueError`` is raised if the input is not a simple expression::

        sage: libgap.eval('1; 2; 3')
        Traceback (most recent call last):
        ...
        ValueError: can only evaluate a single statement
    """

    def __cinit__(self):
        """
        The Cython constructor.

        EXAMPLES::

            sage: libgap.eval('1')
            1
        """
        self.value = NULL
        self._compare_by_id = False


    def __init__(self):
        """
        The ``GapElement`` constructor

        Users must use the ``libgap`` instance to construct instances
        of :class:`GapElement`. Cython programmers must use
        :funct:`make_GapElement` factory function.

        TESTS::

            sage: from sage.libs.gap.element import GapElement
            sage: GapElement()
            Traceback (most recent call last):
            ...
            TypeError: this class cannot be instantiated from Python
        """
        raise TypeError('this class cannot be instantiated from Python')


    cdef _initialize(self, parent, libGAP_Obj obj):
        r"""
        Initialize the GapElement.

        This Cython method is called from :func:`make_GapElement` to
        initialize the newly-constructed object. You must never call
        it manually.

        TESTS::

            sage: n_before = libgap.count_GAP_objects()
            sage: a = libgap.eval('123')
            sage: b = libgap.eval('456')
            sage: c = libgap.eval('CyclicGroup(3)')
            sage: d = libgap.eval('"a string"')
            sage: libgap.collect()
            sage: del c
            sage: libgap.collect()
            sage: n_after = libgap.count_GAP_objects()
            sage: n_after - n_before
            3
        """
        assert self.value is NULL
        self._parent = parent
        self.value = obj
        if obj is NULL:
            return
        reference_obj(obj)


    def __dealloc__(self):
        r"""
        The Cython destructor

        TESTS::

            sage: pre_refcount = libgap.count_GAP_objects()
            sage: def f():
            ...       local_variable = libgap.eval('"This is a new string"')
            sage: f()
            sage: f()
            sage: f()
            sage: post_refcount = libgap.count_GAP_objects()
            sage: post_refcount - pre_refcount
            0
        """
        if self.value is NULL:
            return
        dereference_obj(self.value)


    def trait_names(self):
        """
        Return all Gap function names.

        OUTPUT:

        A list of strings.

        EXAMPLES::

            sage: x = libgap(1)
            sage: len(x.trait_names()) > 1000
            True
        """
        import gap_functions
        return gap_functions.common_gap_functions


    def __getattr__(self, name):
        r"""
        Return functionoid implementing the function ``name``.

        EXAMPLES::

            sage: lst = libgap([])
            sage: lst.Add(1)    # this is the syntactic sugar
            sage: lst
            [ 1 ]

        The above is equivalent to the following calls::

            sage: lst = libgap.eval('[]')
            sage: libgap.eval('Add') (lst, 1)
            sage: lst
            [ 1 ]

        TESTS::

            sage: lst.Adddddd(1)
            Traceback (most recent call last):
            ...
            AttributeError: name "Adddddd" is not defined in GAP.

            sage: libgap.eval('some_name := 1')
            1
            sage: lst.some_name
            Traceback (most recent call last):
            ...
            AttributeError: name "some_name" does not define a GAP function.
        """
        # print '__getattr__', name
        if name in ('__dict__', '_getAttributeNames', '__custom_name', 'keys'):
            raise AttributeError('Python special name, not a GAP function.')
        try:
            proxy = make_GapElement_MethodProxy\
                (self.parent(), gap_eval(name), self)
        except ValueError:
            raise AttributeError('name "'+str(name)+'" is not defined in GAP.')
        if not proxy.is_function():
            raise AttributeError('name "'+str(name)+'" does not define a GAP function.')
        return proxy


    def _repr_(self):
        r"""
        Return a string representation of ``self``.

        EXAMPLES::

            sage: libgap(0)
            0
            sage: libgap.eval('')
            NULL
            sage: libgap(0)
            0
            sage: libgap(0)._repr_()
            '0'
        """
        if  self.value == NULL:
            return 'NULL'
        try:
            libgap_enter()
            libgap_start_interaction('')
            libGAP_ViewObjHandler(self.value)
            s = libgap_get_output()
            return s.strip()
        finally:
            libgap_finish_interaction()
            libgap_exit()


    cpdef _set_compare_by_id(self):
        """
        Set comparison to compare by ``id``

        By default, GAP is used to compare libGAP objects. However,
        this is not defined for all GAP objects. To have libGAP play
        nice with ``UniqueRepresentation``, comparison must always
        work. This method allows one to override the comparison to
        sort by the (unique) Python ``id``.

        Obviously it is a bad idea to change the comparison of objects
        after you have inserted them into a set/dict. You also must
        not mix libGAP objects with different sort methods in the same
        container.

        EXAMPLES::

            sage: F1 = libgap.FreeGroup(['a'])
            sage: F2 = libgap.FreeGroup(['a'])
            sage: F1 == F2
            Traceback (most recent call last):
            ...
            ValueError: libGAP: cannot compare: Error, no method found!
            Error, no 1st choice method found for `<' on 2 arguments

            sage: F1._set_compare_by_id()
            sage: F1 == F2
            Traceback (most recent call last):
            ...
            ValueError: comparison style must be the same for both operands

            sage: F1._set_compare_by_id()
            sage: F2._set_compare_by_id()
            sage: F1 == F2
            False
        """
        self._compare_by_id = True


    cpdef _assert_compare_by_id(self):
        """
        Ensure that comparison is by ``id``

        See :meth:`_set_compare_by_id`.

        OUTPUT:

        This method returns nothing. A ``ValueError`` is raised if
        :meth:`_set_compare_by_id` has not been called on this libgap
        object.

        EXAMPLES::

            sage: x = libgap.FreeGroup(1)
            sage: x._assert_compare_by_id()
            Traceback (most recent call last):
            ...
            ValueError: requires a libGAP objects whose comparison is by "id"

            sage: x._set_compare_by_id()
            sage: x._assert_compare_by_id()
        """
        if not self._compare_by_id:
            raise ValueError('requires a libGAP objects whose comparison is by "id"')


    cdef int _cmp_c_impl(self, Element other) except -2:
        """
        Compare ``self`` with ``other``.

        Uses the GAP comparison by default, or the Python ``id`` if
        :meth:`_set_compare_by_id` was called.

        OUTPUT:

        `-1`, `0`, or `+1` depending on the comparison value of
        ``self`` and ``other``.  Raises a ``ValueError`` if GAP does
        not support comparison of ``self`` and ``other``, unless
        :meth:`_set_compare_by_id` was called on both ``self`` and
        ``other``.

        EXAMPLES::

            sage: a = libgap(123)
            sage: b = libgap('string')
            sage: abs(a._cmp_(b))
            1
            sage: (a < b) or (a > b)
            True
            sage: a._cmp_(libgap(123))
            0

        GAP does not have a comparison function for two ``FreeGroup``
        objects. LibGAP signals this by raising a ``ValueError`` ::

            sage: F1 = libgap.FreeGroup(['a'])
            sage: F2 = libgap.FreeGroup(['a'])
            sage: F1 == F2
            Traceback (most recent call last):
            ...
            ValueError: libGAP: cannot compare: Error, no method found!
            Error, no 1st choice method found for `<' on 2 arguments

            sage: F1._set_compare_by_id()
            sage: F1 == F2
            Traceback (most recent call last):
            ...
            ValueError: comparison style must be the same for both operands

            sage: F1._set_compare_by_id()
            sage: F2._set_compare_by_id()
            sage: F1 == F2
            False
        """
        if self._compare_by_id != (<GapElement>other)._compare_by_id:
            raise ValueError('comparison style must be the same for both operands')
        if self._compare_by_id:
            return cmp(id(self), id(other))
        cdef GapElement c_other = <GapElement>other
        libgap_enter()
        try:
            sig_on()
            equal = libGAP_EQ(self.value, c_other.value)
            if equal:
                sig_off()
                return 0
            less = libGAP_LT(self.value, c_other.value)
            sig_off()
        except RuntimeError, msg:
            raise ValueError('libGAP: cannot compare: '+str(msg))
        finally:
            libgap_exit()
        return -1 if less else +1


    cpdef ModuleElement _add_(self, ModuleElement right):
        r"""
        Add two GapElement objects.

        EXAMPLES::

            sage: g1 = libgap(1)
            sage: g2 = libgap(2)
            sage: g1._add_(g2)
            3
            sage: g1 + g2    # indirect doctest
            3

            sage: libgap(1) + libgap.CyclicGroup(2)
            Traceback (most recent call last):
            ...
            ValueError: libGAP: Error, no method found!
            Error, no 1st choice method found for `+' on 2 arguments
        """
        cdef libGAP_Obj result
        try:
            libgap_enter()
            sig_on()
            result = libGAP_SUM(self.value, (<GapElement>right).value)
            sig_off()
        except RuntimeError, msg:
            libGAP_ClearError()
            raise ValueError('libGAP: '+str(msg))
        finally:
            libgap_exit()
        return make_any_gap_element(self.parent(), result)


    cpdef ModuleElement _sub_(self, ModuleElement right):
        r"""
        Subtract two GapElement objects.

        EXAMPLES::

            sage: g1 = libgap(1)
            sage: g2 = libgap(2)
            sage: g1._sub_(g2)
            -1
            sage: g1 - g2    # indirect doctest
            -1

            sage: libgap(1) - libgap.CyclicGroup(2)
            Traceback (most recent call last):
            ...
            ValueError: libGAP: Error, no method found!
            Error, no 1st choice method found for `-' on 2 arguments
        """
        cdef libGAP_Obj result
        try:
            libgap_enter()
            sig_on()
            result = libGAP_DIFF(self.value, (<GapElement>right).value)
            sig_off()
        except RuntimeError, msg:
            libGAP_ClearError()
            raise ValueError, 'libGAP: '+str(msg)
        finally:
            libgap_exit()
        return make_any_gap_element(self.parent(), result)


    cpdef RingElement _mul_(self, RingElement right):
        r"""
        Multiply two GapElement objects.

        EXAMPLES::

            sage: g1 = libgap(3)
            sage: g2 = libgap(5)
            sage: g1._mul_(g2)
            15
            sage: g1 * g2    # indirect doctest
            15

            sage: libgap(1) * libgap.CyclicGroup(2)
            Traceback (most recent call last):
            ...
            ValueError: libGAP: Error, no method found!
            Error, no 1st choice method found for `*' on 2 arguments
        """
        cdef libGAP_Obj result
        try:
            libgap_enter()
            sig_on()
            result = libGAP_PROD(self.value, (<GapElement>right).value)
            sig_off()
        except RuntimeError, msg:
            libGAP_ClearError()
            raise ValueError, 'libGAP: '+str(msg)
        finally:
            libgap_exit()
        return make_any_gap_element(self.parent(), result)


    cpdef RingElement _div_(self, RingElement right):
        r"""
        Divide two GapElement objects.

        EXAMPLES::

            sage: g1 = libgap(3)
            sage: g2 = libgap(5)
            sage: g1._div_(g2)
            3/5
            sage: g1 / g2    # indirect doctest
            3/5

            sage: libgap(1) / libgap.CyclicGroup(2)
            Traceback (most recent call last):
            ...
            ValueError: libGAP: Error, no method found!
            Error, no 1st choice method found for `/' on 2 arguments

            sage: libgap(1) / libgap(0)
            Traceback (most recent call last):
            ...
            ValueError: libGAP: Error, Rational operations: <divisor> must not be zero
        """
        cdef libGAP_Obj result
        try:
            libgap_enter()
            sig_on()
            result = libGAP_QUO(self.value, (<GapElement>right).value)
            sig_off()
        except RuntimeError, msg:
            libGAP_ClearError()
            raise ValueError, 'libGAP: '+str(msg)
        finally:
            libgap_exit()
        return make_any_gap_element(self.parent(), result)


    def __mod__(GapElement self, GapElement right):
        r"""
        Modulus of two GapElement objects.

        EXAMPLES::

            sage: g1 = libgap(5)
            sage: g2 = libgap(2)
            sage: g1 % g2
            1

            sage: libgap(1) % libgap.CyclicGroup(2)
            Traceback (most recent call last):
            ...
            ValueError: libGAP: Error, no method found!
            Error, no 1st choice method found for `mod' on 2 arguments
        """
        cdef libGAP_Obj result
        try:
            libgap_enter()
            sig_on()
            result = libGAP_MOD(self.value, right.value)
            sig_off()
        except RuntimeError, msg:
            libGAP_ClearError()
            raise ValueError, 'libGAP: '+str(msg)
        finally:
            libgap_exit()
        return make_any_gap_element(self.parent(), result)


    def __pow__(GapElement self, right, dummy):
        r"""
        Exponentiation of two GapElement objects.

        EXAMPLES::

            sage: g1 = libgap(5)
            sage: g2 = libgap(2)
            sage: g1 ^ g2
            25

            sage: libgap.CyclicGroup(2) ^ 2
            Traceback (most recent call last):
            ...
            ValueError: libGAP: Error, no method found!
            Error, no 1st choice method found for `^' on 2 arguments

            sage: libgap(3) ^ Infinity
            Traceback (most recent call last):
            ...
            ValueError: libGAP: Error, Variable: 'Infinity' must have a value
        """
        if not PY_TYPE_CHECK(right, GapElement):
            libgap = self.parent()
            right = libgap(right)
        cdef libGAP_Obj result
        try:
            libgap_enter()
            sig_on()
            result = libGAP_POW(self.value, (<GapElement>right).value)
            sig_off()
        except RuntimeError, msg:
            libGAP_ClearError()
            raise ValueError, 'libGAP: '+str(msg)
        finally:
            libgap_exit()
        return make_any_gap_element(self.parent(), result)


    def is_function(self):
        """
        Return whether the wrapped GAP object is a function.

        OUTPUT:

        Boolean.

        EXAMPLES::

            sage: a = libgap.eval("NormalSubgroups")
            sage: a.is_function()
            True
            sage: a = libgap(2/3)
            sage: a.is_function()
            False
        """
        return libGAP_IS_FUNC(self.value)


    def is_list(self):
        r"""
        Return whether the wrapped GAP object is a GAP List.

        OUTPUT:

        Boolean.

        EXAMPLES::

            sage: libgap.eval('[1, 2,,,, 5]').is_list()
            True
            sage: libgap.eval('3/2').is_list()
            False
        """
        return libGAP_IS_PLIST(self.value)


    def is_record(self):
        r"""
        Return whether the wrapped GAP object is a GAP record.

        OUTPUT:

        Boolean.

        EXAMPLES::

            sage: libgap.eval('[1, 2,,,, 5]').is_record()
            False
            sage: libgap.eval('rec(a:=1, b:=3)').is_record()
            True
        """
        return libGAP_IS_REC(self.value)


    cpdef is_bool(self):
        r"""
        Return whether the wrapped GAP object is a GAP boolean.

        OUTPUT:

        Boolean.

        EXAMPLES::

            sage: libgap(True).is_bool()
            True
        """
        libgap = self.parent()
        cdef GapElement r_sage = libgap.IsBool(self)
        cdef libGAP_Obj r_gap = r_sage.value
        return r_gap == libGAP_True


    def is_int(self):
        r"""
        Return whether the wrapped GAP object is a GAP integer.

        OUTPUT:

        Boolean.

        EXAMPLES::

            sage: libgap(1).is_int()
            True
        """
        return libGAP_IS_INTOBJ(self.value)


    def is_string(self):
        r"""
        Return whether the wrapped GAP object is a GAP string.

        OUTPUT:

        Boolean.

        EXAMPLES::

            sage: libgap('this is a string').is_string()
            True
        """
        return libGAP_IS_STRING(self.value)


    def is_permutation(self):
        r"""
        Return whether the wrapped GAP object is a GAP permutation.

        OUTPUT:

        Boolean.

        EXAMPLES::

            sage: perm = libgap.PermList( libgap([1,5,2,3,4]) );  perm
            (2,5,4,3)
            sage: perm.is_permutation()
            True
            sage: libgap('this is a string').is_permutation()
            False
        """
        return (libGAP_TNUM_OBJ(self.value) == libGAP_T_PERM2 or
                libGAP_TNUM_OBJ(self.value) == libGAP_T_PERM4)


    def sage(self):
        r"""
        Return the Sage equivalent of the :class:`GapElement`

        EXAMPLES::

            sage: libgap(1).sage()
            1
            sage: type(_)
            <type 'sage.rings.integer.Integer'>

            sage: libgap(3/7).sage()
            3/7
            sage: type(_)
            <type 'sage.rings.rational.Rational'>

            sage: libgap.eval('5 + 7*E(3)').sage()
            7*zeta3 + 5

            sage: libgap(True).sage()
            True
            sage: libgap(False).sage()
            False
            sage: type(_)
            <type 'bool'>

            sage: libgap('this is a string').sage()
            'this is a string'
            sage: type(_)
            <type 'str'>
        """
        if self.value is NULL:
            return None
        libgap = self.parent()
        if libgap.IsCyc(self).sage():
            conductor = self.Conductor()
            coeff = self.CoeffsCyc(conductor)
            conductor = conductor.sage()
            coeff = coeff.sage()
            from sage.rings.number_field.number_field import CyclotomicField
            F = CyclotomicField(conductor)
            return F(coeff)
        raise NotImplementedError('cannot construct equivalent Sage object')




############################################################################
### GapElement_Integer #####################################################
############################################################################

cdef GapElement_Integer make_GapElement_Integer(parent, libGAP_Obj obj):
    r"""
    Turn a Gap integer object into a GapElement_Integer Sage object

    EXAMPLES::

        sage: libgap(123)
        123
        sage: type(_)
        <type 'sage.libs.gap.element.GapElement_Integer'>
    """
    cdef GapElement_Integer r = GapElement_Integer.__new__(GapElement_Integer)
    r._initialize(parent, obj)
    return r


cdef class GapElement_Integer(GapElement):
    r"""
    Derived class of GapElement for GAP rational numbers.

    EXAMPLES::

        sage: i = libgap(123)
        sage: type(i)
        <type 'sage.libs.gap.element.GapElement_Integer'>
    """

    def sage(self):
        r"""
        Return the Sage equivalent of the :class:`GapElement_Integer`

        OUTPUT:

        An integer

        EXAMPLES::

            sage: libgap([ 1, 3, 4 ]).sage()
            [1, 3, 4]
            sage: all( x in ZZ for x in _ )
            True
        """
        return ZZ(libGAP_INT_INTOBJ(self.value))


############################################################################
### GapElement_Rational ####################################################
############################################################################

cdef GapElement_Rational make_GapElement_Rational(parent, libGAP_Obj obj):
    r"""
    Turn a Gap Rational number (of type ``Obj``) into a Cython ``GapElement_Rational``.

    EXAMPLES::

        sage: libgap(123/456)
        41/152
        sage: type(_)
        <type 'sage.libs.gap.element.GapElement_Rational'>
    """
    cdef GapElement_Rational r = GapElement_Rational.__new__(GapElement_Rational)
    r._initialize(parent, obj)
    return r


cdef class GapElement_Rational(GapElement):
    r"""
    Derived class of GapElement for GAP rational numbers.

    EXAMPLES::

        sage: r = libgap(123/456)
        sage: type(r)
        <type 'sage.libs.gap.element.GapElement_Rational'>
    """

    def sage(self):
        r"""
        Return the Sage equivalent of the :class:`GapElement`

        OUTPUT:

        A Python list.

        EXAMPLES::

            sage: r = libgap(123/456);  r
            41/152
            sage: type(_)
            <type 'sage.libs.gap.element.GapElement_Rational'>
            sage: r.sage()
            41/152
            sage: type(_)
            <type 'sage.rings.rational.Rational'>
        """
        libgap = self.parent()
        return libgap.NumeratorRat(self).sage() / libgap.DenominatorRat(self).sage()


############################################################################
### GapElement_Boolean #####################################################
############################################################################

cdef GapElement_Boolean make_GapElement_Boolean(parent, libGAP_Obj obj):
    r"""
    Turn a Gap Boolean number (of type ``Obj``) into a Cython ``GapElement_Boolean``.

    EXAMPLES::

        sage: libgap(True)
        true
        sage: type(_)
        <type 'sage.libs.gap.element.GapElement_Boolean'>
    """
    cdef GapElement_Boolean r = GapElement_Boolean.__new__(GapElement_Boolean)
    r._initialize(parent, obj)
    return r


cdef class GapElement_Boolean(GapElement):
    r"""
    Derived class of GapElement for GAP boolean values.

    EXAMPLES::

        sage: b = libgap(True)
        sage: type(b)
        <type 'sage.libs.gap.element.GapElement_Boolean'>
    """

    def sage(self):
        r"""
        Return the Sage equivalent of the :class:`GapElement`

        OUTPUT:

        A Python boolean if the values is either true or false. GAP
        booleans can have the third value ``Fail``, in which case a
        ``ValueError`` is raised.

        EXAMPLES::

            sage: b = libgap.eval('true');  b
            true
            sage: type(_)
            <type 'sage.libs.gap.element.GapElement_Boolean'>
            sage: b.sage()
            True
            sage: type(_)
            <type 'bool'>

            sage: libgap.eval('fail')
            fail
            sage: _.sage()
            Traceback (most recent call last):
            ...
            ValueError: the GAP boolean value "fail" cannot be represented in Sage
        """
        if self.value == libGAP_True:   return True
        if self.value == libGAP_False:  return False
        raise ValueError('the GAP boolean value "fail" cannot be represented in Sage')


    def __nonzero__(self):
        """
        Check that the boolean is "true".

        This is syntactic sugar for using libgap. See the examples below.

        OUTPUT:

        Boolean.

        EXAMPLES::

            sage: gap_bool = [libgap.eval('true'), libgap.eval('false'), libgap.eval('fail')]
            sage: for x in gap_bool:
            ...       if x:     # this calls __nonzero__
            ...           print x, type(x)
            true <type 'sage.libs.gap.element.GapElement_Boolean'>

            sage: for x in gap_bool:
            ...       if not x:     # this calls __nonzero__
            ...           print x, type(x)
            false <type 'sage.libs.gap.element.GapElement_Boolean'>
            fail <type 'sage.libs.gap.element.GapElement_Boolean'>
       """
        return self.value == libGAP_True


############################################################################
### GapElement_String ####################################################
############################################################################

cdef GapElement_String make_GapElement_String(parent, libGAP_Obj obj):
    r"""
    Turn a Gap String (of type ``Obj``) into a Cython ``GapElement_String``.

    EXAMPLES::

        sage: libgap('this is a string')
        "this is a string"
        sage: type(_)
        <type 'sage.libs.gap.element.GapElement_String'>
    """
    cdef GapElement_String r = GapElement_String.__new__(GapElement_String)
    r._initialize(parent, obj)
    return r


cdef class GapElement_String(GapElement):
    r"""
    Derived class of GapElement for GAP strings.

    EXAMPLES::

        sage: s = libgap('string')
        sage: type(s)
        <type 'sage.libs.gap.element.GapElement_String'>
    """

    def sage(self):
        r"""
        Return the Sage equivalent of the :class:`GapElement`

        OUTPUT:

        A Python list.

        EXAMPLES::

            sage: s = libgap.eval(' "string" '); s
            "string"
            sage: type(_)
            <type 'sage.libs.gap.element.GapElement_String'>
            sage: s.sage()
            'string'
            sage: type(_)
            <type 'str'>
        """
        libgap_enter()
        s = libGAP_CSTR_STRING(self.value)
        libgap_exit()
        return s



############################################################################
### GapElement_Function ####################################################
############################################################################

cdef GapElement_Function make_GapElement_Function(parent, libGAP_Obj obj):
    r"""
    Turn a Gap C function object (of type ``Obj``) into a Cython ``GapElement_Function``.

    INPUT:

    - ``parent`` -- the parent of the new :class:`GapElement`

    - ``obj`` -- a GAP function object.

    OUTPUT:

    A :class:`GapElement_Function` instance.

    EXAMPLES::

        sage: libgap.CycleLength
        <Gap function "CycleLength">
        sage: type(_)
        <type 'sage.libs.gap.element.GapElement_Function'>
    """
    cdef GapElement_Function r = GapElement_Function.__new__(GapElement_Function)
    r._initialize(parent, obj)
    return r


cdef class GapElement_Function(GapElement):
    r"""
    Derived class of GapElement for GAP functions.

    EXAMPLES::

        sage: f = libgap.Cycles
        sage: type(f)
        <type 'sage.libs.gap.element.GapElement_Function'>
    """


    def __repr__(self):
        r"""
        Return a string representation

        OUTPUT:

        String.

        EXAMPLES::

            sage: libgap.Orbits
            <Gap function "Orbits">
        """
        libgap = self.parent()
        name = libgap.NameFunction(self)
        s = '<Gap function "'+name.sage()+'">'
        return s


    def __call__(self, *args):
        """
        Call syntax for functions.

        INPUT:

        - ``*args`` -- arguments. Will be converted to `GapElement` if
          they are not already of this type.

        OUTPUT:

        A :class:`GapElement` encapsulating the functions return
        value, or ``None`` if it does not return anything.

        EXAMPLES::

            sage: a = libgap.NormalSubgroups
            sage: b = libgap.SymmetricGroup(4)
            sage: libgap.collect()
            sage: a
            <Gap function "NormalSubgroups">
            sage: b
            Sym( [ 1 .. 4 ] )
            sage: a(b)
            [ Group(()),
              Group([ (1,4)(2,3), (1,3)(2,4) ]),
              Group([ (2,4,3), (1,4)(2,3), (1,3)(2,4) ]),
              Sym( [ 1 .. 4 ] ) ]

            sage: libgap.eval("a := NormalSubgroups")
            <Gap function "NormalSubgroups">
            sage: libgap.eval("b := SymmetricGroup(4)")
            Sym( [ 1 .. 4 ] )
            sage: libgap.collect()
            sage: libgap.eval('a') (libgap.eval('b'))
            [ Group(()),
              Group([ (1,4)(2,3), (1,3)(2,4) ]),
              Group([ (2,4,3), (1,4)(2,3), (1,3)(2,4) ]),
              Sym( [ 1 .. 4 ] ) ]
            sage: a = libgap.eval('a')
            sage: b = libgap.eval('b')
            sage: libgap.collect()
            sage: a(b)
            [ Group(()),
              Group([ (1,4)(2,3), (1,3)(2,4) ]),
              Group([ (2,4,3), (1,4)(2,3), (1,3)(2,4) ]),
              Sym( [ 1 .. 4 ] ) ]

        Not every ``GapElement`` is callable::

            sage: f = libgap(3)
            sage: f()
            Traceback (most recent call last):
            ...
            TypeError: 'sage.libs.gap.element.GapElement_Integer' object is not callable

        We illustrate appending to a list which returns None::

            sage: a = libgap([]); a
            [  ]
            sage: a.Add(5); a
            [ 5 ]
            sage: a.Add(10); a
            [ 5, 10 ]

        TESTS::

            sage: s = libgap.Sum
            sage: s(libgap([1,2]))
            3
            sage: s(libgap(1), libgap(2))
            Traceback (most recent call last):
            ...
            ValueError: libGAP: Error, no method found!
            Error, no 1st choice method found for `SumOp' on 2 arguments

            sage: for i in range(0,100):
            ...       rnd = [ randint(-10,10) for i in range(0,randint(0,7)) ]
            ...       # compute the sum in GAP
            ...       _ = libgap.Sum(rnd)
            ...       try:
            ...           libgap.Sum(*rnd)
            ...           print 'This should have triggered a ValueError'
            ...           print 'because Sum needs a list as argument'
            ...       except ValueError:
            ...           pass

            sage: libgap_exec = libgap.eval("Exec")
            sage: libgap_exec('echo hello from the shell > /dev/null')
        """
        cdef libGAP_Obj result = NULL
        cdef libGAP_Obj arg_list
        cdef int i, n = len(args)

        if n > 0:
            libgap = self.parent()
            a = [x if isinstance(x,GapElement) else libgap(x) for x in args]

        try:
            libgap_enter()
            sig_on()
            if n == 0:
                result = libGAP_CALL_0ARGS(self.value)
            elif n == 1:
                result = libGAP_CALL_1ARGS(self.value,
                                           (<GapElement>a[0]).value)
            elif n == 2:
                result = libGAP_CALL_2ARGS(self.value,
                                           (<GapElement>a[0]).value,
                                           (<GapElement>a[1]).value)
            elif n == 3:
                result = libGAP_CALL_3ARGS(self.value,
                                           (<GapElement>a[0]).value,
                                           (<GapElement>a[1]).value,
                                           (<GapElement>a[2]).value)
            elif n == 4:
                result = libGAP_CALL_4ARGS(self.value,
                                           (<GapElement>a[0]).value,
                                           (<GapElement>a[1]).value,
                                           (<GapElement>a[2]).value,
                                           (<GapElement>a[3]).value)
            elif n == 5:
                result = libGAP_CALL_5ARGS(self.value,
                                           (<GapElement>a[0]).value,
                                           (<GapElement>a[1]).value,
                                           (<GapElement>a[2]).value,
                                           (<GapElement>a[3]).value,
                                           (<GapElement>a[4]).value)
            elif n == 6:
                result = libGAP_CALL_6ARGS(self.value,
                                           (<GapElement>a[0]).value,
                                           (<GapElement>a[1]).value,
                                           (<GapElement>a[2]).value,
                                           (<GapElement>a[3]).value,
                                           (<GapElement>a[4]).value,
                                           (<GapElement>a[5]).value)
            elif n >= 7:
                libgap_exit()
                arg_list = make_gap_list(args)
                libgap_enter()
                result = libGAP_CALL_XARGS(self.value, arg_list)
            sig_off()
        except RuntimeError, msg:
            raise ValueError('libGAP: '+str(msg))
        finally:
            libgap_exit()

        if result == NULL:
            # We called a procedure that does not return anything
            return None

        return make_any_gap_element(self.parent(), result)


    def _sage_doc_(self):
        r"""
        Return the help string

        EXAMPLES::

            sage: f = libgap.CyclicGroup
            sage: 'constructs  the  cyclic  group' in f._sage_doc_()
            True

        You would get the full help by typing ``f?`` in the command line.
        """
        libgap = self.parent()
        from sage.interfaces.gap import gap
        return gap.help(libgap.NameFunction(self).sage(), pager=False)




############################################################################
### GapElement_MethodProxy #################################################
############################################################################

cdef GapElement_MethodProxy make_GapElement_MethodProxy(parent, libGAP_Obj function, GapElement base_object):
    r"""
    Turn a Gap C rec object (of type ``Obj``) into a Cython ``GapElement_Record``.

    This class implement syntactic sugar so that you can write
    ``gapelement.f()`` instead of ``libgap.f(gapelement)`` for any GAP
    function ``f``.

    INPUT:

    - ``parent`` -- the parent of the new :class:`GapElement`

    - ``obj`` -- a GAP function object.

    - ``base_object`` -- The first argument to be inserted into the function.

    OUTPUT:

    A :class:`GapElement_MethodProxy` instance.

    EXAMPLES::

        sage: lst = libgap([])
        sage: type( lst.Add )
        <type 'sage.libs.gap.element.GapElement_MethodProxy'>
    """
    cdef GapElement_MethodProxy r = GapElement_MethodProxy.__new__(GapElement_MethodProxy)
    r._initialize(parent, function)
    r.first_argument = base_object
    return r


cdef class GapElement_MethodProxy(GapElement_Function):
    r"""
    Helper class returned by ``GapElement.__getattr__``.

    Derived class of GapElement for GAP functions. Like its parent,
    you can call instances to implement function call syntax. The only
    difference is that a fixed first argument is prepended to the
    argument list.

    EXAMPLES::

        sage: lst = libgap([])
        sage: lst.Add
        <Gap function "Add">
        sage: type(_)
        <type 'sage.libs.gap.element.GapElement_MethodProxy'>
        sage: lst.Add(1)
        sage: lst
        [ 1 ]
    """

    def __call__(self, *args):
        """
        Call syntax for methods.

        This method is analogous to
        :meth:`GapElement_Function.__call__`, except that it inserts a
        fixed :class:`GapElement` in the first slot of the function.

        INPUT:

        - ``*args`` -- arguments. Will be converted to `GapElement` if
          they are not already of this type.

        OUTPUT:

        A :class:`GapElement` encapsulating the functions return
        value, or ``None`` if it does not return anything.

        EXAMPLES::

            sage: lst = libgap.eval('[1,,3]')
            sage: lst.Add.__call__(4)
            sage: lst.Add(5)
            sage: lst
            [ 1,, 3, 4, 5 ]
        """
        if len(args) > 0:
            return GapElement_Function.__call__(self, * ([self.first_argument] + list(args)))
        else:
            return GapElement_Function.__call__(self, self.first_argument)



############################################################################
### GapElement_List ########################################################
############################################################################

cdef GapElement_List make_GapElement_List(parent, libGAP_Obj obj):
    r"""
    Turn a Gap C List object (of type ``Obj``) into a Cython ``GapElement_List``.

    EXAMPLES::

        sage: libgap([0, 2, 3])
        [ 0, 2, 3 ]
        sage: type(_)
        <type 'sage.libs.gap.element.GapElement_List'>
    """
    cdef GapElement_List r = GapElement_List.__new__(GapElement_List)
    r._initialize(parent, obj)
    return r


cdef class GapElement_List(GapElement):
    r"""
    Derived class of GapElement for GAP Lists.

    .. NOTE::

        Lists are indexed by `0..len(l)-1`, as expected from
        Python. This differs from the GAP convention where lists start
        at `1`.

    EXAMPLES::

        sage: lst = libgap.SymmetricGroup(3).List(); lst
        [ (), (1,3), (1,2,3), (2,3), (1,3,2), (1,2) ]
        sage: type(lst)
        <type 'sage.libs.gap.element.GapElement_List'>
        sage: len(lst)
        6
        sage: lst[3]
        (2,3)

    We can easily convert a Gap ``List`` object into a Python ``list``::

        sage: list(lst)
        [(), (1,3), (1,2,3), (2,3), (1,3,2), (1,2)]
        sage: type(_)
        <type 'list'>

    Range checking is performed::

        sage: lst[10]
        Traceback (most recent call last):
        ...
        IndexError: index out of range.
    """

    def __len__(self):
        r"""
        Return the length of the list.

        OUTPUT:

        Integer.

        EXAMPLES::

            sage: lst = libgap.eval('[1,,,4]')   # a sparse list
            sage: len(lst)
            4
        """
        return libGAP_LEN_PLIST(self.value)


    def __getitem__(self, i):
        r"""
        Return the ``i``-th element of the list.

        As usual in Python, indexing starts at `0` and not at `1` (as
        in GAP).

        INPUT:

        - ``i`` -- integer.

        OUTPUT:

        The ``i``-th element as a :class:`GapElement`.

        EXAMPLES::

            sage: lst = libgap.eval('["first",,,"last"]')   # a sparse list
            sage: lst[0]
            "first"
        """
        if i<0 or i>=len(self):
            raise IndexError('index out of range.')
        return make_any_gap_element(self.parent(),
                                    libGAP_ELM_PLIST(self.value, i+1))


    def sage(self):
        r"""
        Return the Sage equivalent of the :class:`GapElement`

        OUTPUT:

        A Python list.

        EXAMPLES::

            sage: libgap([ 1, 3, 4 ]).sage()
            [1, 3, 4]
            sage: all( x in ZZ for x in _ )
            True
        """
        return [ x.sage() for x in self ]




############################################################################
### GapElement_Permutation #################################################
############################################################################


cdef GapElement_Permutation make_GapElement_Permutation(parent, libGAP_Obj obj):
    r"""
    Turn a Gap C permutation object (of type ``Obj``) into a Cython ``GapElement_Permutation``.

    EXAMPLES::

        sage: libgap.eval('(1,3,2)(4,5,8)')
        (1,3,2)(4,5,8)
        sage: type(_)
        <type 'sage.libs.gap.element.GapElement_Permutation'>
    """
    cdef GapElement_Permutation r = GapElement_Permutation.__new__(GapElement_Permutation)
    r._initialize(parent, obj)
    return r


cdef class GapElement_Permutation(GapElement):
    r"""
    Derived class of GapElement for GAP permutations.

    .. NOTE::

        Permutations in GAP act on the numbers starting with 1.

    EXAMPLES::

        sage: perm = libgap.eval('(1,5,2)(4,3,8)')
        sage: type(perm)
        <type 'sage.libs.gap.element.GapElement_Permutation'>
    """

    def sage(self):
        r"""
        Return the Sage equivalent of the :class:`GapElement`

        EXAMPLES::

            sage: perm_gap = libgap.eval('(1,5,2)(4,3,8)');  perm_gap
            (1,5,2)(3,8,4)
            sage: perm_gap.sage()
            (1,5,2)(3,8,4)
            sage: type(_)
            <type 'sage.groups.perm_gps.permgroup_element.PermutationGroupElement'>
        """
        from sage.groups.perm_gps.permgroup_element import PermutationGroupElement
        libgap = self.parent()
        return PermutationGroupElement(libgap.ListPerm(self).sage())



############################################################################
### GapElement_Record ######################################################
############################################################################

cdef GapElement_Record make_GapElement_Record(parent, libGAP_Obj obj):
    r"""
    Turn a Gap C rec object (of type ``Obj``) into a Cython ``GapElement_Record``.

    EXAMPLES::

        sage: libgap.eval('rec(a:=0, b:=2, c:=3)')
        rec( a := 0, b := 2, c := 3 )
        sage: type(_)
        <type 'sage.libs.gap.element.GapElement_Record'>
    """
    cdef GapElement_Record r = GapElement_Record.__new__(GapElement_Record)
    r._initialize(parent, obj)
    return r


cdef class GapElement_Record(GapElement):
    r"""
    Derived class of GapElement for GAP records.

    EXAMPLES::

        sage: rec = libgap.eval('rec(a:=123, b:=456)')
        sage: type(rec)
        <type 'sage.libs.gap.element.GapElement_Record'>
        sage: len(rec)
        2
        sage: rec['a']
        123

    We can easily convert a Gap ``rec`` object into a Python ``dict``::

        sage: dict(rec)
        {'a': 123, 'b': 456}
        sage: type(_)
        <type 'dict'>

    Range checking is performed::

        sage: rec['no_such_element']
        Traceback (most recent call last):
        ...
        IndexError: libGAP: Error, Record: '<rec>.no_such_element' must have an assigned value
    """

    def __len__(self):
        r"""
        Return the length of the record.

        OUTPUT:

        Integer. The number of entries in the record.

        EXAMPLES::

            sage: rec = libgap.eval('rec(a:=123, b:=456, S3:=SymmetricGroup(3))')
            sage: len(rec)
            3
        """
        return libGAP_LEN_PREC(self.value)


    def __iter__(self):
        r"""
        Iterate over the elements of the record.

        OUTPUT:

        A :class:`GapElement_RecordIterator`.

        EXAMPLES::

            sage: rec = libgap.eval('rec(a:=123, b:=456)')
            sage: iter = rec.__iter__()
            sage: type(iter)
            <type 'sage.libs.gap.element.GapElement_RecordIterator'>
            sage: list(rec)
            [('a', 123), ('b', 456)]
        """
        return GapElement_RecordIterator(self)


    cpdef libGAP_UInt record_name_to_index(self, bytes py_name):
        r"""
        Convert string to GAP record index.

        INPUT:

        - ``py_name`` -- a python string.

        OUTPUT:

        A ``UInt``, which is a GAP hash of the string. If this is the
        first time the string is encountered, a new integer is
        returned(!)

        EXAMPLE::

            sage: rec = libgap.eval('rec(first:=123, second:=456)')
            sage: rec.record_name_to_index('first')   # random output
            1812L
            sage: rec.record_name_to_index('no_such_name') # random output
            3776L
        """
        cdef char* c_name = py_name
        try:
            libgap_enter()
            return libGAP_RNamName(c_name)
        finally:
            libgap_exit()

    def __getitem__(self, name):
        r"""
        Return the ``name``-th element of the GAP record.

        INPUT:

        - ``name`` -- string.

        OUTPUT:

        The record element labelled by ``name`` as a :class:`GapElement`.

        EXAMPLES::

            sage: rec = libgap.eval('rec(first:=123, second:=456)')
            sage: rec['first']
            123
        """
        i = self.record_name_to_index(name)
        cdef libGAP_Obj result
        try:
            sig_on()
            result = libGAP_ELM_REC(self.value, i)
            sig_off()
        except RuntimeError, msg:
            raise IndexError('libGAP: '+str(msg))
        return make_any_gap_element(self.parent(), result)


    def sage(self):
        r"""
        Return the Sage equivalent of the :class:`GapElement`

        EXAMPLES::

            sage: libgap.eval('rec(a:=1, b:=2)').sage()
            {'a': 1, 'b': 2}
            sage: all( isinstance(key,str) and val in ZZ for key,val in _.items() )
            True

            sage: rec = libgap.eval('rec(a:=123, b:=456, Sym3:=SymmetricGroup(3))')
            sage: rec.sage()
            {'a': 123,
             'Sym3': NotImplementedError('cannot construct equivalent Sage object',),
             'b': 456}
        """
        result = dict()
        for key, val in self:
            try:
                val = val.sage()
            except Exception as ex:
                val = ex
            result[key] = val
        return result


cdef class GapElement_RecordIterator(object):
    r"""
    Iterator for :class:`GapElement_Record`

    Since Cython does not support generators yet, we implement the
    older iterator specification with this auxiliary class.

    INPUT:

    - ``rec`` -- the :class:`GapElement_Record` to iterate over.

    EXAMPLES::

        sage: rec = libgap.eval('rec(a:=123, b:=456)')
        sage: list(rec)
        [('a', 123), ('b', 456)]
        sage: dict(rec)
        {'a': 123, 'b': 456}
    """

    def __cinit__(self, rec):
        r"""
        The Cython constructor.

        INPUT:

        - ``rec`` -- the :class:`GapElement_Record` to iterate over.

        EXAMPLES::

            sage: libgap.eval('rec(a:=123, b:=456)')
            rec( a := 123, b := 456 )
        """
        self.rec = rec
        self.i = 1


    def __next__(self):
        r"""
        The next elemnt in the record.

        OUTPUT:

        A tuple ``(key, value)`` where ``key`` is a string and
        ``value`` is the corresponding :class:`GapElement`.

        EXAMPLES::

            sage: rec = libgap.eval('rec(a:=123, b:=456)')
            sage: iter = rec.__iter__()
            sage: iter.__next__()
            ('a', 123)
            sage: iter.next()
            ('b', 456)
        """
        cdef libGAP_UInt i = self.i
        if i>len(self.rec):
            raise StopIteration
        # note the abs: negative values mean the rec keys are not sorted
        libgap_enter()
        key_index = abs(libGAP_GET_RNAM_PREC(self.rec.value, i))
        key = libGAP_NAME_RNAM(key_index)
        cdef libGAP_Obj result = libGAP_GET_ELM_PREC(self.rec.value,i)
        libgap_exit()
        val = make_any_gap_element(self.rec.parent(), result)
        self.i += 1
        return (key, val)

