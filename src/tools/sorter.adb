-- WORDS, a Latin dictionary, by Colonel William Whitaker (USAF, Retired)
--
-- Copyright William A. Whitaker (1936–2010)
--
-- This is a free program, which means it is proper to copy it and pass
-- it on to your friends. Consider it a developmental item for which
-- there is no charge. However, just for form, it is Copyrighted
-- (c). Permission is hereby freely given for any and all use of program
-- and data. You can sell it as your own, but at least tell me.
-- 
-- This version is distributed without obligation, but the developer
-- would appreciate comments and suggestions.
-- 
-- All parts of the WORDS system, source code and data files, are made freely
-- available to anyone who wishes to use them, for whatever purpose.

with Text_IO;
with direct_io;
with Strings_package; use Strings_package;
with dictionary_package; use dictionary_package;
procedure sorter is
   --  This program sorts a file of lines (Strings) on 4 subStrings Mx .. Nx
   --  Sort by Stringwise (different cases), numeric, or POS enumeration

   package boolean_io is new Text_IO.enumeration_io (boolean);
   use boolean_io;
   package Integer_IO is new Text_IO.Integer_IO (Integer);
   use Integer_IO;
   package float_io is new Text_IO.float_io (float);
   use float_io;
   use Text_IO;

   name_length : constant := 80;
   st, enter_line : String (1 .. name_length) := (others => ' ');
   ls, last : Integer := 0;
   input_name : String (1 .. 80) := (others => ' ');

   line_length : constant := 300;        --  ##################################
                                         --  Max line length on input file
                                         --  Shorter => less disk space to sort
   current_length : Integer := 0;
   subtype text_type is String (1 .. line_length);
   --type LINE_TYPE is
   -- record
   --   CURRENT_LENGTH : CURRENT_LINE_LENGTH_TYPE := 0;
   --   TEXT : TEXT_TYPE;
   -- end record;
   package line_io is new direct_io (text_type);
   use line_io;
   blank_text : text_type := (others => ' ');

   line_text : text_type := blank_text;
   old_line : text_type := blank_text;
   p_line : text_type := blank_text;

   type sort_type is (a, c, g, u, n, f, p, s);
   package sort_type_io is new Text_IO.enumeration_io (sort_type);
   use sort_type_io;

   type way_type is (i, d);
   package way_type_io is new Text_IO.enumeration_io (way_type);
   use way_type_io;

   input  : Text_IO.File_Type;
   output : Text_IO.File_Type;
   work   : line_io.File_Type;

   m1, m2, m3, m4 : natural := 1;
   n1, n2, n3, n4 : natural := line_length;
   z1, z2, z3, z4 : natural := 0;

   s1, s2, s3, s4 : sort_type := a;
   w1, w2, w3, w4 : way_type := i;

   entry_finished : exception;

   --  For section numbering of large documents and standards
   type section_type is
      record
         first_level   : Integer := 0;
         second_level  : Integer := 0;
         third_level   : Integer := 0;
         fourth_level  : Integer := 0;
         fifth_level   : Integer := 0;
      end record;

   no_section : constant section_type := (0, 0, 0, 0, 0);

   type appendix_type is (none, a, b, c, d, e, f, g, h, i, j, k, l, m,
     n, o, p, q, r, s, t, u, v, w, x, y, z);
   package appendix_io is new Text_IO.enumeration_io (appendix_type);

   type appendix_section_type is    record
      appendix : appendix_type := none;
      section  : section_type  := no_section;
   end record;

   no_appendix_section : constant appendix_section_type :=
     (none, (0, 0, 0, 0, 0));

   --  procedure PUT (OUTPUT : TEXT_IO.FILE_TYPE; S : SECTION_TYPE);
   --  procedure PUT (S : SECTION_TYPE);
   --  procedure GET (FROM : in STRING;
   --                   S : out SECTION_TYPE; LAST : out POSITIVE);
   --  function "<"(A, B : SECTION_TYPE) return BOOLEAN;
   --
   --  procedure PUT (OUTPUT : TEXT_IO.FILE_TYPE; S : APPENDIX_SECTION_TYPE);
   --  procedure PUT (S : APPENDIX_SECTION_TYPE);
   --  procedure GET (FROM : in STRING;
   --                   S : out APPENDIX_SECTION_TYPE; LAST : out POSITIVE);
   --  function "<"(A, B : APPENDIX_SECTION_TYPE) return BOOLEAN;
   --

   procedure Put (output : Text_IO.File_Type; s : section_type) is
      level : Integer := 0;

      procedure put_level (output : Text_IO.File_Type; l : Integer) is
      begin
         if l > 9999  then
            Put (output, "****");
         elsif l > 999  then
            Put (output, l, 4);
         elsif l > 99  then
            Put (output, l, 3);
         elsif l > 9  then
            Put (output, l, 2);
         elsif l >= 0  then
            Put (output, l, 1);
         else
            Put (output, "**");
         end if;
      end put_level;

   begin
      if s.fifth_level <= 0  then
         if s.fourth_level <= 0  then
            if s.third_level <= 0  then
               if s.second_level <= 0  then
                  level := 1;
               else
                  level := 2;
               end if;
            else
               level := 3;
            end if;
         else
            level := 4;
         end if;
      else
         level := 5;
      end if;

      if s.first_level <= 9  then
         Put (output, ' ');
      end if;
      put_level (output, s.first_level);
      if level = 1  then
         Put (output, '.');
         Put (output, '0');           --  To match the ATLAS index convention
      end if;
      if level >= 2  then
         Put (output, '.');
         put_level (output, s.second_level);
      end if;
      if level >= 3  then
         Put (output, '.');
         put_level (output, s.third_level);
      end if;
      if level >= 4  then
         Put (output, '.');
         put_level (output, s.fourth_level);
      end if;
      if level >= 5  then
         Put (output, '.');
         put_level (output, s.fifth_level);
      end if;
   end put;

   procedure Put (s : section_type) is
      level : Integer := 0;

      procedure put_level (l : Integer) is
      begin
         if l > 9999  then
            Put ("****");
         elsif l > 999  then
            Put (l, 4);
         elsif l > 99  then
            Put (l, 3);
         elsif l > 9  then
            Put (l, 2);
         elsif l >= 0  then
            Put (l, 1);
         else
            Put ("**");
         end if;
      end put_level;

   begin
      if s.fifth_level = 0  then
         if s.fourth_level = 0  then
            if s.third_level = 0  then
               if s.second_level = 0  then
                  level := 1;
               else
                  level := 2;
               end if;
            else
               level := 3;
            end if;
         else
            level := 4;
         end if;
      else
         level := 5;
      end if;

      if s.first_level <= 9  then
         Put (' ');
      end if;
      put_level (s.first_level);
      Put ('.');
      if level = 1  then
         Put ('0');           --  To match the ATLAS index convention
      end if;
      if level >= 2  then
         put_level (s.second_level);
      end if;
      if level >= 3  then
         Put ('.');
         put_level (s.third_level);
      end if;
      if level >= 4  then
         Put ('.');
         put_level (s.fourth_level);
      end if;
      if level >= 5  then
         Put ('.');
         put_level (s.fifth_level);
      end if;
   end put;

   procedure Get (from : in String;
                  s : out section_type; last : out Integer) is
      l  : Integer := 0;
      ft : Integer := from'first;
      lt : Integer := from'last;
   begin
      s := no_section;
      if Trim (from)'last < from'first   then
         return;   --  Empty String, no data         --  Return default
      end if;

      Get (from, s.first_level, l);
      if l+1 >= lt  then
         last := l;
         return;
      end if;
      Get (from (l+2 .. lt), s.second_level, l);
      if l+1 >= lt  then
         last := l;
         return;
      end if;
      Get (from (l+2 .. lt), s.third_level, l);
      if l+1 >= lt  then
         last := l;
         return;
      end if;
      Get (from (l+2 .. lt), s.fourth_level, l);
      if l+1 >= lt  then
         last := l;
         return;
      end if;
      Get (from (l+2 .. lt), s.fifth_level, l);
      last := l;
      return;
   exception
      when Text_IO.end_error =>
         last := l;
         return;
      when Text_IO.data_error =>
         last := l;
         return;
      when others =>
         Put (" Unexpected exception in GET (FROM; SECTION_TYPE) with input =>");
         Put (from);
         New_Line;
         last := l;
         raise;
   end get;

   function "<"(a, b : section_type) return boolean is
   begin

      if a.first_level > b.first_level  then
         return false;
      elsif a.first_level < b.first_level  then
         return true;
      else
         if a.second_level > b.second_level  then
            return false;
         elsif a.second_level < b.second_level  then
            return true;
         else
            if a.third_level > b.third_level  then
               return false;
            elsif a.third_level < b.third_level  then
               return true;
            else
               if a.fourth_level > b.fourth_level  then
                  return false;
               elsif a.fourth_level < b.fourth_level  then
                  return true;
               else
                  if a.fifth_level > b.fifth_level  then
                     return false;
                  elsif a.fifth_level < b.fifth_level  then
                     return true;
                  else
                     return false;
                  end if;
               end if;
            end if;
         end if;
      end if;

      return false;

   end "<";

   procedure Put (output : Text_IO.File_Type; s : appendix_section_type) is
      use appendix_io;
   begin
      Put (output, s.appendix);
      Put (output, ' ');
      Put (output, s.section);
   end put;

   procedure Put (s : appendix_section_type) is
      use appendix_io;
   begin
      Put (s.appendix);
      Put (' ');
      Put (s.section);
   end put;

   procedure Get (from : in String;
                  s : out appendix_section_type; last : out Integer) is
      use appendix_io;
      l  : Integer := 0;
      ft : Integer := from'first;
      lt : Integer := from'last;
   begin

      s := no_appendix_section;
      if (ft = lt)  or else
        (Trim (from)'length = 0)  then   --  Empty/blank String, no data
         Put ("@");
         return;                      --  Return default
      end if;

      --PUT_LINE ("In GET =>" & FROM & '|');

      begin
         Get (from, s.appendix, l);
         --PUT ("A");
         if l+1 >= lt  then
            last := l;
            return;
         end if;
      exception
         when others  =>
            s.appendix := none;
            l := ft - 2;
      end;

      --    PUT ("B");
      --    GET (FROM (L+2 .. LT), S.SECTION.FIRST_LEVEL, L);
      --    if L+1 >= LT  then
      --      LAST := L;
      --      return;
      --    end if;
      --PUT ("C");
      --    GET (FROM (L+2 .. LT), S.SECTION.SECOND_LEVEL, L);
      --    if L+1 >= LT  then
      --      LAST := L;
      --      return;
      --    end if;
      --PUT ("D");
      --    GET (FROM (L+2 .. LT), S.SECTION.THIRD_LEVEL, L);
      --    if L+1 >= LT  then
      --      LAST := L;
      --      return;
      --    end if;
      --PUT ("E");
      --    GET (FROM (L+2 .. LT), S.SECTION.FOURTH_LEVEL, L);
      --    if L+1 >= LT  then
      --      LAST := L;
      --      return;
      --    end if;
      --PUT ("F");
      --    GET (FROM (L+2 .. LT), S.SECTION.FIFTH_LEVEL, L);
      --    LAST := L;
      --PUT ("G");

      Get (from (l+2 .. lt), s.section, l);
      --PUT ("F");
      return;
   exception
      when Text_IO.end_error =>
         last := l;
         return;
      when Text_IO.data_error =>
         last := l;
         return;
      when others =>
         put
           (" Unexpected exception in GET (FROM; APPENDIX_SECTION_TYPE) with input =>");
         Put (from);
         New_Line;
         last := l;
         return;
   end get;

   function "<"(a, b : appendix_section_type) return boolean is
   begin

      if a.appendix > b.appendix  then
         return false;
      elsif a.appendix < b.appendix  then
         return true;
      else
         if a.section.first_level > b.section.first_level  then
            return false;
         elsif a.section.first_level < b.section.first_level  then
            return true;
         else
            if a.section.second_level > b.section.second_level  then
               return false;
            elsif a.section.second_level < b.section.second_level  then
               return true;
            else
               if a.section.third_level > b.section.third_level  then
                  return false;
               elsif a.section.third_level < b.section.third_level  then
                  return true;
               else
                  if a.section.fourth_level > b.section.fourth_level  then
                     return false;
                  elsif a.section.fourth_level < b.section.fourth_level  then
                     return true;
                  else
                     if a.section.fifth_level > b.section.fifth_level  then
                        return false;
                     elsif a.section.fifth_level < b.section.fifth_level  then
                        return true;
                     else
                        return false;
                     end if;
                  end if;
               end if;
            end if;
         end if;
      end if;
   end "<";

   procedure prompt_for_entry (entry_number : String) is
   begin
      Put ("Give starting column and size of ");
      Put (entry_number);
      Put_Line (" significant sort field ");
      Put ("  with optional sort type and way  => ");
   end prompt_for_entry;

   procedure get_entry (mx, nx  : out natural;
                        sx  : out sort_type;
                        wx  : out way_type ) is
      m : natural := 1;
      n : natural := line_length;
      s : sort_type := a;
      w : way_type := i;
      z : natural := 0;

      procedure echo_entry is
      begin
         Put ("                    Sorting on LINE ("); Put (m,3);
         Put (" .. "); Put (n, 3); Put (")");
         Put ("  with S = "); Put (s); Put (" and W = "); Put (w);
         New_Line (2);
      end echo_entry;

   begin

      m := 0;
      n := line_length;
      s := a;
      w := i;

      Get_Line (enter_line, ls);
      if ls = 0  then
         raise entry_finished;
      end if;
      Integer_IO.Get (enter_line (1 .. ls), m, last);
      begin
         Integer_IO.Get (enter_line (last+1 .. ls), z, last);
         if  m = 0 or z = 0  then
            Put_Line ("Start or size of zero, you must be kidding, aborting");
            raise program_error;
         elsif m + z > line_length  then
            Put_Line ("Size too large, going to end of line");
            n := line_length;
         else
            n := m + z - 1;
         end if;
         sort_type_io.Get (enter_line (last+1 .. ls), s, last);
         way_type_io.Get (enter_line (last+1 .. ls), w, last);
         mx := m; nx := n;  sx := s; wx := w;
         echo_entry;
         return;
      exception
         when program_error  =>
            Put_Line ("PROGRAM_ERROR raised in GET_ENTRY");
            raise;
         when others =>
            mx := m; nx := n; sx := s; wx := w;
            echo_entry;
            return;
      end;
   end get_entry;

   function ignore_separators (s : String) return String is
      t : String (s'first .. s'last) := lower_case (s);
   begin
      for i in s'first+1 .. s'last-1  loop
         if (s (i-1) /= '-'  and then s (i-1) /= '_')  and then
           (s (i) = '-'  or else s (i) = '_')  and then
           (s (i+1) /= '-'  and then s (i+1) /= '_')  then
            t (i) := ' ';
         end if;
      end loop;
      return t;
   end ignore_separators;

   function ltu (c, d : character) return boolean is
   begin
      if (d = 'v')  then
         if (c < 'u')  then
            return true;
         else
            return false;
         end if;
      elsif (d = 'j')  then
         if (c < 'i')  then
            return true;
         else
            return false;
         end if;
      elsif (d = 'V')  then
         if (c < 'U')  then
            return true;
         else
            return false;
         end if;
      elsif (d = 'J')  then
         if (c < 'I')  then
            return true;
         else
            return false;
         end if;
      else
         return c < d;
      end if;
   end ltu;

   function equ (c, d : character) return boolean is
   begin
      if (d = 'u') or (d = 'v')  then
         if (c = 'u') or (c = 'v')  then
            return true;
         else
            return false;
         end if;
      elsif (d = 'i') or (d = 'j')  then
         if (c = 'i') or (c = 'j')  then
            return true;
         else
            return false;
         end if;
      elsif (d = 'U') or (d = 'V')  then
         if (c = 'U') or (c = 'V')  then
            return true;
         else
            return false;
         end if;
      elsif (d = 'I') or (d = 'J')  then
         if (c = 'I') or (c = 'J')  then
            return true;
         else
            return false;
         end if;
      else
         return c = d;
      end if;
   end equ;

   function gtu (c, d : character) return boolean is
   begin
      if d = 'u'  then
         if (c > 'v')  then
            return true;
         else
            return false;
         end if;
      elsif d = 'i'  then
         if (c > 'j')  then
            return true;
         else
            return false;
         end if;
      elsif d = 'U'  then
         if (c > 'V')  then
            return true;
         else
            return false;
         end if;
      elsif d = 'I'  then
         if (c > 'J')  then
            return true;
         else
            return false;
         end if;
      else
         return c > d;
      end if;
   end gtu;

   function ltu (s, t : String) return boolean is
   begin
      for i in 1 .. s'length  loop   --  Not TRIMed, so same length
         if equ (s (s'first+i-1), t (t'first+i-1))  then
            null;
         elsif gtu (s (s'first+i-1), t (t'first+i-1))  then
            return false;
         elsif ltu (s (s'first+i-1), t (t'first+i-1))  then
            return true;
         end if;
      end loop;
      return false;
   end ltu;

   function gtu (s, t : String) return boolean is
   begin
      for i in 1 .. s'length  loop
         if equ (s (s'first+i-1), t (t'first+i-1))  then
            null;
         elsif ltu (s (s'first+i-1), t (t'first+i-1))  then
            return false;
         elsif gtu (s (s'first+i-1), t (t'first+i-1))  then
            return true;
         end if;
      end loop;
      return false;
   end gtu;

   function equ (s, t : String) return boolean is
   begin
      if s'length /= t'length  then
         return false;
      end if;

      for i in 1 .. s'length  loop
         if not equ (s (s'first+i-1), t (t'first+i-1))  then
            return false;
         end if;
      end loop;

      return true;
   end equ;

   function slt (x, y : String;         --  Make LEFT and RIGHT
                 st : sort_type := a;
                 wt : way_type := i) return boolean is
      as : String (x'range) := x;
      bs : String (y'range) := y;
      mn, nn : Integer := 0;
      fn, gn : float := 0.0;
      --FS, GS : SECTION_TYPE := NO_SECTION;
      fs, gs : appendix_section_type := no_appendix_section;
      px, py : part_entry;       --  So I can X here
   begin
      if st = a  then
         as := lower_case (as);
         bs := lower_case (bs);
         if wt = i  then
            return as < bs;
         else
            return as > bs;
         end if;

      elsif st = c  then
         if wt = i  then
            return as < bs;
         else
            return as > bs;
         end if;

      elsif st = g  then
         as := ignore_separators (as);
         bs := ignore_separators (bs);
         if wt = i  then
            return as < bs;
         else
            return as > bs;
         end if;

      elsif st = u  then
         as := lower_case (as);
         bs := lower_case (bs);
         if wt = i  then
            return ltu (as, bs);
         else
            return gtu (as, bs);
         end if;

      elsif st = n  then
         Integer_IO.Get (as, mn, last);
         Integer_IO.Get (bs, nn, last);
         if wt = i  then
            return mn < nn;
         else
            return mn > nn;
         end if;

      elsif st = f  then
         float_io.Get (as, fn, last);
         float_io.Get (bs, gn, last);
         if wt = i  then
            return fn < gn;
         else
            return fn > gn;
         end if;

      elsif st = p  then
         Part_Entry_IO.Get (as, px, last);
         Part_Entry_IO.Get (bs, py, last);
         if wt = i  then
            return px < py;
         else
            return (not (px < py)) and (not (px = py));
         end if;

      elsif st = s  then
         --PUT_LINE ("AS =>" & AS & '|');
         Get (as, fs, last);
         --PUT_LINE ("BS =>" & BS & '|');
         Get (bs, gs, last);
         --PUT_LINE ("GOT AS & BS");
         if wt = i  then
            return fs < gs;
         else
            return (not (fs < gs)) and (not (fs = gs));
         end if;

      else
         return false;
      end if;

   exception
      when others  =>
         Text_IO.Put_Line ("exception in SLT    showing LEFT and RIGHT");
         Text_IO.Put_Line (x & "&");
         Text_IO.Put_Line (y & "|");
         raise;

   end slt;

   function sort_equal (x, y : String;
                        st : sort_type := a;
                        wt : way_type := i) return boolean is
      as : String (x'range) := x;
      bs : String (y'range) := y;
      mn, nn : Integer := 0;
      fn, gn : float := 0.0;
      fs, gs : appendix_section_type := no_appendix_section;
      px, py : part_entry;
   begin
      if st = a  then
         as := lower_case (as);
         bs := lower_case (bs);
         return as = bs;

      elsif st = c  then
         return as = bs;

      elsif st = g  then
         as := ignore_separators (as);
         bs := ignore_separators (bs);
         return as = bs;

      elsif st = u  then
         as := lower_case (as);
         bs := lower_case (bs);
         return equ (as,  bs);

      elsif st = n  then
         Integer_IO.Get (as, mn, last);
         Integer_IO.Get (bs, nn, last);
         return mn = nn;

      elsif st = f  then
         float_io.Get (as, fn, last);
         float_io.Get (bs, gn, last);
         return fn = gn;

      elsif st = p  then
         Part_Entry_IO.Get (as, px, last);
         Part_Entry_IO.Get (bs, py, last);
         return px = py;

      elsif st = s  then
         Get (as, fs, last);
         Get (bs, gs, last);
         return fs = gs;

      else
         return false;
      end if;

   exception
      when others  =>
         Text_IO.Put_Line ("exception in LT    showing LEFT and RIGHT");
         Text_IO.Put_Line (x & "|");
         Text_IO.Put_Line (y & "|");
         raise;

   end sort_equal;

   function lt  (left, right : text_type) return boolean is
   begin

      if slt (left (m1 .. n1),  right (m1 .. n1), s1, w1)  then
         return true;
      elsif sort_equal (left (m1 .. n1),  right (m1 .. n1), s1, w1) then
         if ((n2 > 0) and then
           slt (left (m2 .. n2),  right (m2 .. n2), s2, w2) ) then
            return true;
         elsif ((n2 > 0) and then
           sort_equal (left (m2 .. n2),  right (m2 .. n2), s2, w2)) then
            if ((n3 > 0) and then
              slt (left (m3 .. n3),  right (m3 .. n3), s3, w3 ))  then
               return true;
            elsif ((n3 > 0) and then
              sort_equal (left (m3 .. n3),  right (m3 .. n3), s3, w3))  then
               if ((n4 > 0) and then
                 slt (left (m4 .. n4),  right (m4 .. n4), s4, w4) )  then
                  return true;
               end if;
            end if;
         end if;
      end if;
      return false;
   exception
      when others =>
         Text_IO.Put_Line ("exception in LT    showing LEFT and RIGHT");
         Text_IO.Put_Line (left & "|");
         Text_IO.Put_Line (right & "|");
         raise;
   end lt;

   procedure open_file_for_inPut (input : in out Text_IO.File_Type;
                                  prompt : String := "File for input => ") is
      last : natural := 0;
   begin
  get_input_file:
      loop
     check_input:
         begin
            New_Line;

            Put (prompt);
            Get_Line (input_name, last);
            Open (input, In_File, input_name (1 .. last));
            exit;
         exception
            when others  =>
               Put_Line ("   !!!!!!!!!  Try Again  !!!!!!!!");
         end check_input;
      end loop get_input_file;

   end open_file_for_input;

   procedure create_file_for_output (output : in out Text_IO.File_Type;
                                     prompt : String := "File for output => ") is
      name : String (1 .. 80) := (others => ' ');
      last : natural := 0;
   begin

  get_output_file:
      loop
     check_output:
         begin
            New_Line;

            Put (prompt);
            Get_Line (name, last);
            if Trim (name (1 .. last))'length /= 0  then
               Create (output, Out_File, name (1 .. last));
            else
               Create (output, Out_File, Trim (input_name));
            end if;
            exit;
         exception
            when others  =>
               Put_Line ("   !!!!!!!!!  Try Again  !!!!!!!!");
         end check_output;
      end loop get_output_file;

   end create_file_for_output;

   function graphic (s : String) return String is
      t : String (1 .. s'length) := s;
   begin
      for i in s'range  loop
         if character'pos (s (i)) < 32  then
            t (i) := ' ';
         end if;
      end loop;
      return t;
   end graphic;

begin

   New_Line;
   Put_Line ("Sorts a text file of lines four times on subStrings M .. N");
   Put_Line (
     "A)lphabetic (all case) C)ase sensitive, iG)nore seperators, U)i_is_vj,");
   Put_Line ("    iN)teger, F)loating point, S)ection, or P)art entry");
   Put_Line ("         I)ncreasing or D)ecreasing");
   New_Line;

   open_file_for_inPut (input, "What file to sort from => ");
   New_Line;

   prompt_for_entry ("first");
   begin
      get_entry (m1, n1, s1, w1);
   exception
      when program_error  =>
         raise;
      when others =>
         null;
   end;

   begin
      prompt_for_entry ("second");
      get_entry (m2, n2, s2, w2);
      prompt_for_entry ("third");
      get_entry (m3, n3, s3, w3);
      prompt_for_entry ("fourth");
      get_entry (m4, n4, s4, w4);
   exception
      when program_error  =>
         raise;
      when entry_finished =>
         null;
      when Text_IO.data_error  | Text_IO.end_error  =>
         null;
   end;

   --PUT_LINE ("CREATING WORK FILE");
   New_Line;
   Create (work, inOut_File, "WORK.");
   Put_Line ("CREATED  WORK FILE");

   while not End_Of_File (input)  loop
      --begin
      Get_Line (input, line_text, current_length);
      --exception when others  =>
      --TEXT_IO.PUT_LINE ("INPUT GET exception");
      --TEXT_IO.PUT_LINE (LINE_TEXT (1 .. CURRENT_LENGTH) & "|");
      --end;
      --PUT_LINE (LINE_TEXT (1 .. CURRENT_LENGTH));
      --PUT_LINE ("=>" & HEAD (LINE_TEXT (1 .. CURRENT_LENGTH), LINE_LENGTH) & "|");
      if Trim (line_text (1 .. current_length)) /= ""  then
         --begin
         write (work, Head (line_text (1 .. current_length), line_length)  );
         --exception when others  =>
         --TEXT_IO.PUT_LINE ("WORK WRITE exception");
         --TEXT_IO.PUT_LINE (LINE_TEXT (1 .. CURRENT_LENGTH) & "|");
         --end;
      end if;
   end loop;
   Close (input);

   Put_Line ("Begin sorting");

line_heapsort:
    declare

       l    : line_io.positive_count := size (work) / 2 + 1;
       ir   : line_io.positive_count := size (work);
       i, j : line_io.positive_count;

    begin
       Text_IO.Put_Line ("SIZE OF WORK = " & Integer'image (Integer (size (work))));
   main:
       loop

          if l > 1  then
             l := l - 1;
             read (work, line_text, l);
             old_line := line_text;
          else
             read (work, line_text, ir);
             old_line := line_text;
             read (work, line_text, 1);
             write (work, line_text, ir);
             ir := ir - 1;
             if ir = 1 then
                write (work, old_line, 1);
                exit main;
             end if;
          end if;
          i := l;
          j := l + l;

          while j <= ir   loop
             if j < ir  then
                read (work, line_text, j);
                read (work, p_line, j+1);
                --if LT (LINE.TEXT, P_LINE.TEXT)  then
                if lt (line_text, p_line)  then
                   j := j + 1;
                end if;
             end if;
             read (work, line_text, j);
             --if OLD_LINE.TEXT < LINE.TEXT  then
             if lt (old_line , line_text)  then
                write (work, line_text, i);
                i := j;
                j := j + j;
             else
                j := ir + 1;
             end if;
          end loop;
          write (work, old_line, i);

       end loop main;

    exception
       when constraint_error => Put_Line ("HEAP CONSTRAINT_ERROR");
       when others           => Put_Line ("HEAP other_ERROR");
    end line_heapsort;

    Put_Line ("Finished sorting in WORK");

    create_file_for_output (output, "Where to put the output => ");

    --RESET (WORK);
    set_index (work, 1);
    while not End_Of_File (work)  loop
       read (work, line_text);
       if Trim (graphic (line_text))'length > 0  then
          --PUT_LINE (TRIM (LINE_TEXT, RIGHT));
          Put_Line (output, Trim (line_text, right));
       end if;
    end loop;

    Close (work);
    Close (output);
    Put_Line ("Done!");
    New_Line;

exception
   when program_error  =>
      Put_Line ("SORT terminated on a PROGRAM_ERROR");
      Close (output);
   when Text_IO.data_error =>     --Terminate on primary start or size = 0
      Put_Line ("SORT terminated on a DATA_ERROR");
      Put_Line (line_text);
      Close (output);
   when constraint_error =>       --Terminate on blank line for file name
      Put_Line ("SORT terminated on a CONSTRAINT_ERROR");
      Close (output);
   when Text_IO.device_error  =>     --Ran out of space to write output file
      Put_Line ("SORT terminated on a DEVICE_ERROR");
      delete (output);
      create_file_for_output (output, "Wherelse to put the output => ");
      reset (work);
      while not End_Of_File (work)  loop
         read (work, line_text);
         Put_Line (output, line_text);    --(1 .. LINE.CURRENT_LENGTH));
      end loop;
      Close (output);
end sorter;
