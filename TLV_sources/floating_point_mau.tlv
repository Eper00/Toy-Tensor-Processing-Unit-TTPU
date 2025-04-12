\m5_TLV_version 1d: tl-x.org

\m5
   use(m5-1.0)
\SV
   m5_makerchip_module
\TLV mau($_result_sum, $_in1 ,$_in2)
   |mau
      ?$valid
         @0
            $in1_sign     = $in1[15];
            $in1_exponent[4:0] = $in1[14:10];
            $in1_fraction[10:0] = {1'b1 , $in1[9:0]};

            $in2_sign     = $in2[15];
            $in2_exponent[4:0] = $in2[14:10];
            $in2_fraction[10:0] = {1'b1 , $in2[9:0]};

            $result_sign0     = ($in1 == 0 || $in2 == 0) ? 1'b0 : $in1_sign ^ $in2_sign;
            $result_exponent0[4:0] = ($in1 == 0 || $in2 == 0) ? 5'b0 : $in1_exponent + $in2_exponent - 5'd15;
            $product_fraction[21:0] = ($in1 == 0 || $in2 == 0) ? 22'b0 : $in1_fraction * $in2_fraction;
         @1
            $result_fraction1[9:0] = ($product_fraction[21] == 1) ? $product_fraction[20:11] :
                                                                  $product_fraction[19:10];
            $result_exponent1[4:0] = ($product_fraction[21] == 1) ? $result_exponent0 + 1 :
                                                                  $result_exponent0;
            $result_acc[15:0] = {$result_sign0, $result_exponent1, $result_fraction1};
         @2
            
            $a_sign     = $result_acc[15];
            $a_exponent[4:0] = $result_acc[14:10];
            $a_fraction[9:0] =  $result_acc[9:0];

            $b_sign     = $accumlator[15];
            $b_exponent[4:0] = $accumlator[14:10];
            $b_fraction[9:0] = $accumlator[9:0];

            $result_exponent2[4:0] = ($a_exponent[4:0] >= $b_exponent[4:0]) ?  $a_exponent[4:0] : $b_exponent[4:0];
            $shift_amount[11:0] = ($a_exponent[4:0] >= $b_exponent[4:0]) ?  $a_exponent[4:0] - $b_exponent[4:0] : $b_exponent[4:0] - $a_exponent[4:0];
            $extended_a_fraction[10:0] = ($a_exponent[4:0] >= $b_exponent[4:0]) ? {1'b1, $a_fraction[9:0]} : {1'b1, $a_fraction[9:0]} >> $shift_amount[11:0];
            $extended_b_fraction[10:0] = ($a_exponent[4:0] >= $b_exponent[4:0]) ? {1'b1, $b_fraction[9:0]} >> $shift_amount[11:0] : {1'b1, $b_fraction[9:0]};
            $result_sign2 = ($a_sign == $b_sign) ? $a_sign : ($a[14:0] > $b[14:0] ) ? $a_sign : $b_sign;
         @3   
            $sum_fraction[11:0] = ($a_sign == $b_sign) ?  $extended_a_fraction[10:0] + $extended_b_fraction[10:0] : ( $extended_a_fraction[10:0] > $extended_b_fraction[10:0] ) ? ($extended_a_fraction[10:0] - $extended_b_fraction[10:0]) : ($extended_b_fraction[10:0] - $extended_a_fraction[10:0]);
         @4   
            $shift_amount_lod[3:0] = $sum_fraction[10] ? 0 : $sum_fraction[9] ? 1 : $sum_fraction[8] ? 2 : $sum_fraction[7] ? 3 : $sum_fraction[6] ? 4 : $sum_fraction[5] ? 5 : $sum_fraction[4] ? 6 : $sum_fraction[3] ? 7 : $sum_fraction[2] ? 8 : $sum_fraction[1] ? 9 : $sum_fraction[0] ? 10 : 11;
            $sum_fraction1[11:0] = $sum_fraction[11:0] << $shift_amount_lod[3:0];
            $result_fraction4[9:0] = $sum_fraction[11] == 1 ? $sum_fraction[10: 1] : $sum_fraction1[9:0] ;
            $result_exponent4[4:0] = $sum_fraction[11] == 1 ?  $result_exponent2 + 1 : $result_exponent2[4:0] - $shift_amount_lod[3:0];
            $result_sum[15:0] = (/top<<4$reset ) ? 0 : {$result_sign2, $result_exponent4, $result_fraction4};






\SV
   endmodule
