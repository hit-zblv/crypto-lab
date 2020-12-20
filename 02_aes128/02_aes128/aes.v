/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Cipher Top Level                                       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

`include "timescale.v"

module aes (
  input  wire         sys_clk,
  input  wire         sys_rst_n,
  input  wire         ld,
  input  wire [0:127] key,
  input  wire [0:127] text_in,
  output wire         done,
  output wire [0:127] text_out
);
  
  aes_core core (
    .clk      (sys_clk   ),
    .rst_n    (sys_rst_n ),
    .ld       (ld        ),
    .key      (key       ),
    .text_in  (text_in   ),
    .done     (done      ),
    .text_out (text_out  )
  );
  
endmodule

