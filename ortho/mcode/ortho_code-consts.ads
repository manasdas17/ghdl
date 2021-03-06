--  Mcode back-end for ortho - Constants handling.
--  Copyright (C) 2006 Tristan Gingold
--
--  GHDL is free software; you can redistribute it and/or modify it under
--  the terms of the GNU General Public License as published by the Free
--  Software Foundation; either version 2, or (at your option) any later
--  version.
--
--  GHDL is distributed in the hope that it will be useful, but WITHOUT ANY
--  WARRANTY; without even the implied warranty of MERCHANTABILITY or
--  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
--  for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with GCC; see the file COPYING.  If not, write to the Free
--  Software Foundation, 59 Temple Place - Suite 330, Boston, MA
--  02111-1307, USA.
with Interfaces; use Interfaces;

package Ortho_Code.Consts is
   type OC_Kind is (OC_Signed, OC_Unsigned, OC_Float, OC_Lit, OC_Null,
                    OC_Array, OC_Record, OC_Union,
                    OC_Subprg_Address, OC_Address,
                    OC_Sizeof);

   function Get_Const_Kind (Cst : O_Cnode) return OC_Kind;

   function Get_Const_Type (Cst : O_Cnode) return O_Tnode;

   --  Get bytes for signed, unsigned, float, lit, null.
   procedure Get_Const_Bytes (Cst : O_Cnode; H, L : out Uns32);

   --  Used to set the length of a constrained type.
   --  FIXME: check for no overflow.
   function Get_Const_U32 (Cst : O_Cnode) return Uns32;

   function Get_Const_U64 (Cst : O_Cnode) return Unsigned_64;
   function Get_Const_I64 (Cst : O_Cnode) return Integer_64;

   function Get_Const_F64 (Cst : O_Cnode) return IEEE_Float_64;

   --  Get the low and high part of a constant.
   function Get_Const_Low (Cst : O_Cnode) return Uns32;
   function Get_Const_High (Cst : O_Cnode) return Uns32;

   function Get_Const_Low (Cst : O_Cnode) return Int32;
   function Get_Const_High (Cst : O_Cnode) return Int32;

   function Get_Const_Aggr_Length (Cst : O_Cnode) return Int32;
   function Get_Const_Aggr_Element (Cst : O_Cnode; N : Int32) return O_Cnode;

   --  Only available in HLI.
   function Get_Const_Union_Field (Cst : O_Cnode) return O_Fnode;
   function Get_Const_Union_Value (Cst : O_Cnode) return O_Cnode;

   --  Declaration for an address.
   function Get_Const_Decl (Cst : O_Cnode) return O_Dnode;

   --  Get the type whose size is expected.
   function Get_Sizeof_Type (Cst : O_Cnode) return O_Tnode;

   --  Get the value of a named literal.
   --function Get_Const_Literal (Cst : O_Cnode) return Uns32;

   --  Create a literal from an integer.
   function New_Signed_Literal (Ltype : O_Tnode; Value : Integer_64)
                               return O_Cnode;
   function New_Unsigned_Literal (Ltype : O_Tnode; Value : Unsigned_64)
                                 return O_Cnode;

   function New_Float_Literal (Ltype : O_Tnode; Value : IEEE_Float_64)
                              return O_Cnode;

   --  Create a null access literal.
   function New_Null_Access (Ltype : O_Tnode) return O_Cnode;
   function New_Global_Unchecked_Address (Decl : O_Dnode; Atype : O_Tnode)
                                         return O_Cnode;
   function New_Global_Address (Decl : O_Dnode; Atype : O_Tnode)
                               return O_Cnode;
   function New_Subprogram_Address (Subprg : O_Dnode; Atype : O_Tnode)
                                   return O_Cnode;

   function New_Named_Literal
     (Atype : O_Tnode; Id : O_Ident; Val : Uns32; Prev : O_Cnode)
     return O_Cnode;

   --  For boolean/enum literals.
   function Get_Lit_Ident (L : O_Cnode) return O_Ident;
   function Get_Lit_Chain (L : O_Cnode) return O_Cnode;
   function Get_Lit_Value (L : O_Cnode) return Uns32;

   type O_Record_Aggr_List is limited private;
   type O_Array_Aggr_List is limited private;

   --  Build a record/array aggregate.
   --  The aggregate is constant, and therefore can be only used to initialize
   --  constant declaration.
   --  ATYPE must be either a record type or an array subtype.
   --  Elements must be added in the order, and must be literals or aggregates.
   procedure Start_Record_Aggr (List : out O_Record_Aggr_List;
                                Atype : O_Tnode);
   procedure New_Record_Aggr_El (List : in out O_Record_Aggr_List;
                                 Value : O_Cnode);
   procedure Finish_Record_Aggr (List : in out O_Record_Aggr_List;
                                 Res : out O_Cnode);

   procedure Start_Array_Aggr (List : out O_Array_Aggr_List; Atype : O_Tnode);
   procedure New_Array_Aggr_El (List : in out O_Array_Aggr_List;
                                Value : O_Cnode);
   procedure Finish_Array_Aggr (List : in out O_Array_Aggr_List;
                                Res : out O_Cnode);

   --  Build an union aggregate.
   function New_Union_Aggr (Atype : O_Tnode; Field : O_Fnode; Value : O_Cnode)
                           return O_Cnode;

   --  Returns the size in bytes of ATYPE.  The result is a literal of
   --  unsigned type RTYPE
   --  ATYPE cannot be an unconstrained array type.
   function New_Sizeof (Atype : O_Tnode; Rtype : O_Tnode) return O_Cnode;

   --  Returns the offset of FIELD in its record.  The result is a literal
   --  of unsigned type RTYPE.
   function New_Offsetof (Field : O_Fnode; Rtype : O_Tnode) return O_Cnode;

   procedure Disp_Stats;

   type Mark_Type is limited private;
   procedure Mark (M : out Mark_Type);
   procedure Release (M : Mark_Type);

   procedure Finish;
private
   type O_Array_Aggr_List is record
      Res : O_Cnode;
      El : Int32;
   end record;

   type O_Record_Aggr_List is record
      Res : O_Cnode;
      Rec_Field : O_Fnode;
      El : Int32;
   end record;

   type Mark_Type is record
      Cnode : O_Cnode;
      Els : Int32;
   end record;

end Ortho_Code.Consts;
