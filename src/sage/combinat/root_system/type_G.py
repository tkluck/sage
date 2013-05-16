"""
Root system data for type G
"""
#*****************************************************************************
#       Copyright (C) 2008-2009 Daniel Bump
#       Copyright (C) 2008-2009 Justin Walker
#       Copyright (C) 2008-2013 Nicolas M. Thiery <nthiery at users.sf.net>
#
#  Distributed under the terms of the GNU General Public License (GPL)
#                  http://www.gnu.org/licenses/
#*****************************************************************************
import ambient_space
from sage.sets.family import Family

class AmbientSpace(ambient_space.AmbientSpace):
    """
    EXAMPLES::

        sage: e = RootSystem(['G',2]).ambient_space(); e
        Ambient space of the Root system of type ['G', 2]

    One can not construct the ambient lattice because the simple
    coroots have rational coefficients::

        sage: e.simple_coroots()
        Finite family {1: (0, 1, -1), 2: (1/3, -2/3, 1/3)}
        sage: e.smallest_base_ring()
        Rational Field

    TESTS::

        sage: TestSuite(e).run()
        sage: [WeylDim(['G',2],[a,b]) for a,b in [[0,0], [1,0], [0,1], [1,1]]] # indirect doctest
        [1, 7, 14, 64]
    """

    def dimension(self):
        """
        EXAMPLES::

            sage: e = RootSystem(['G',2]).ambient_space()
            sage: e.dimension()
            3
        """
        return 3

    def simple_root(self, i):
        """
        EXAMPLES::

            sage: CartanType(['G',2]).root_system().ambient_space().simple_roots()
            Finite family {1: (0, 1, -1), 2: (1, -2, 1)}
         """
        return self.monomial(1)-self.monomial(2) if i == 1 else self.monomial(0)-2*self.monomial(1)+self.monomial(2)
    def positive_roots(self):
        """
        EXAMPLES::

            sage: CartanType(['G',2]).root_system().ambient_space().positive_roots()
            [(0, 1, -1), (1, -2, 1), (1, -1, 0), (1, 0, -1), (1, 1, -2), (2, -1, -1)]
        """
        return [ self(v) for v in
                 [[0,1,-1],[1,-2,1],[1,-1,0],[1,0,-1],[1,1,-2],[2,-1,-1]]]

    def negative_roots(self):
        """
        EXAMPLES::

            sage: CartanType(['G',2]).root_system().ambient_space().negative_roots()
            [(0, -1, 1), (-1, 2, -1), (-1, 1, 0), (-1, 0, 1), (-1, -1, 2), (-2, 1, 1)]
        """
        return [ self(v) for v in
                 [[0,-1,1],[-1,2,-1],[-1,1,0],[-1,0,1],[-1,-1,2],[-2,1,1]]]

    def fundamental_weights(self):
        """
        EXAMPLES::

            sage: CartanType(['G',2]).root_system().ambient_space().fundamental_weights()
            Finite family {1: (1, 0, -1), 2: (2, -1, -1)}
        """
        return Family({ 1: self([1,0,-1]),
                        2: self([2,-1,-1])})

from cartan_type import CartanType_standard_finite, CartanType_simple, CartanType_crystalographic
class CartanType(CartanType_standard_finite, CartanType_simple, CartanType_crystalographic):
    def __init__(self):
        """
        EXAMPLES::

            sage: ct = CartanType(['G',2])
            sage: ct
            ['G', 2]
            sage: ct._repr_(compact = True)
            'G2'

            sage: ct.is_irreducible()
            True
            sage: ct.is_finite()
            True
            sage: ct.is_crystalographic()
            True
            sage: ct.is_simply_laced()
            False
            sage: ct.dual()
            ['G', 2]^*
            sage: ct.affine()
            ['G', 2, 1]

        TESTS::

            sage: TestSuite(ct).run()
        """
        CartanType_standard_finite.__init__(self, "G", 2)

    def _latex_(self):
        r"""
        Return a latex representation of ``self``.

        EXAMPLES::

            sage: latex(CartanType(['G',2]))
            G_2
            sage: latex(CartanType(['G',2]).dual())
            G_2^\vee
        """
        return "G_2"

    AmbientSpace = AmbientSpace

    def dynkin_diagram(self):
        """
        Returns a Dynkin diagram for type G.

        EXAMPLES::

            sage: g = CartanType(['G',2]).dynkin_diagram()
            sage: g
              3
            O=<=O
            1   2
            G2
            sage: sorted(g.edges())
            [(1, 2, 1), (2, 1, 3)]
        """
        from dynkin_diagram import DynkinDiagram_class
        g = DynkinDiagram_class(self)
        g.add_edge(1,2)
        g.set_edge_label(2,1,3)
        return g

    def _latex_dynkin_diagram(self, label=lambda x: x, node_dist=2, dual=False):
        r"""
        Return a latex representation of the Dynkin diagram.

        EXAMPLES::

            sage: print CartanType(['G',2])._latex_dynkin_diagram()
            \draw (0,0) -- (2 cm,0);
            \draw (0, 0.15 cm) -- +(2 cm,0);
            \draw (0, -0.15 cm) -- +(2 cm,0);
            \draw[shift={(0.8, 0)}, rotate=180] (135 : 0.45cm) -- (0,0) -- (-135 : 0.45cm);
            \draw[fill=white] (0, 0) circle (.25cm) node[below=4pt]{$1$};
            \draw[fill=white] (2 cm, 0) circle (.25cm) node[below=4pt]{$2$};
        """
        ret = "\\draw (0,0) -- (%s cm,0);\n"%node_dist
        ret += "\\draw (0, 0.15 cm) -- +(%s cm,0);\n"%node_dist
        ret += "\\draw (0, -0.15 cm) -- +(%s cm,0);\n"%node_dist
        if dual:
            ret += self._latex_draw_arrow_tip(0.5*node_dist+0.2, 0, 0)
        else:
            ret += self._latex_draw_arrow_tip(0.5*node_dist-0.2, 0, 180)
        ret += "\\draw[fill=white] (0, 0) circle (.25cm) node[below=4pt]{$%s$};\n"%label(1)
        ret += "\\draw[fill=white] (%s cm, 0) circle (.25cm) node[below=4pt]{$%s$};"%(node_dist, label(2))
        return ret

    def ascii_art(self, label = lambda x: x):
        """
        Returns an ascii art representation of the Dynkin diagram

        EXAMPLES::

            sage: print CartanType(['G',2]).ascii_art(label = lambda x: x+2)
              3
            O=<=O
            3   4
        """
        return "  3\nO=<=O\n%s   %s"%tuple(label(i) for i in (1,2))

# For unpickling backward compatibility (Sage <= 4.1)
from sage.structure.sage_object import register_unpickle_override
register_unpickle_override('sage.combinat.root_system.type_G', 'ambient_space',  AmbientSpace)
