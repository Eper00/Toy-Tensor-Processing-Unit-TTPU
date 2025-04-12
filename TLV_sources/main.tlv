\m4_TLV_version 1d -p verilog --bestsv --noline: tl-x.org
\m5
   use(m5-1.0) // M5 könyvtár



\SV
   // Makerchip környezet, FPGA támogatással
   m4_include_lib(['https://raw.githubusercontent.com/os-fpga/Virtual-FPGA-Lab/3760a43f58573fbcf7b7893f13c8fa01da6260fc/tlv_lib/fpga_includes.tlv'])
   m4_include_lib(['https://raw.githubusercontent.com/Eper00/Toy-Tensor-Processing-Unit-TTPU-/TLV_sources/floating_point_mau.tlv'])
   m4_lab()

\TLV
   /board
      // Full adder bemenetek a slideswitch-ekből
      m4_rand($in1, 15, 0)
      m4_rand($in2, 15, 0)
      
      m5+($out, $carry_out, $in1, $in2, $carry_in)

      // Kimenetek a ledekre írva
      *led[0] = $out;
      *led[1] = $carry_out;

   // Board példányosítása az FPGA-n
   m4+board(/board, /fpga, 3, ['*'])

\SV
   endmodule
