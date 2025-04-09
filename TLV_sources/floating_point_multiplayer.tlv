\m5_TLV_version 1d: tl-x.org
\m5
   
   // ============================================
   // Welcome, new visitors! Try the "Learn" menu.
   // ============================================
   
   //use(m5-1.0)   /// uncomment to use M5 macro library.
\SV
  
   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV full_adder($_out, $_carry_out, $_in1, $_in2, $_carry_in)
   $_out = $_in1 ^ $_in2 ^ $_carry_in;
   $_carry_out = ($_in1 + $_in2 + $_carry_in) > 2'b1;

\SV
   endmodule
