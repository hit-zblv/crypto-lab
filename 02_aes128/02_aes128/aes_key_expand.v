/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Key Expand Block (for 128 bit keys)                    ////
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

module aes_key_expand (
  input  wire         clk,
  input  wire         rst_n,
  input  wire         kld,
  input  wire         enable,
  input  wire [0:127] key,
  output wire [31:0]  rkey0,
  output wire [31:0]  rkey1,
  output wire [31:0]  rkey2,
  output wire [31:0]  rkey3 
);

  //
  // Round Key Format is 
  // { w[0], w[1], w[2], w[3] }
  //
  reg  [31:0]    w[3:0];
  wire [31:0]    w_tmp;
  wire [31:0]    subword;
  wire [31:0]    rcon;

  assign rkey0 = w[0];
  assign rkey1 = w[1];
  assign rkey2 = w[2];
  assign rkey3 = w[3];

  aes_rconst rconst (
    .clk   ( clk    ), 
    .rst_n ( rst_n  ),
    .kld   ( kld    ), 
    .enable( enable ), 
    .rcon  ( rcon   )
  );

  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
      w[0] <= #1 32'h00000000;
    end
    else begin
      w[0] <= #1 kld ? key[000:031] : 
                 ( enable ? w[0]^subword^rcon : w[0] );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
      w[1] <= #1 32'h00000000;
    end
    else begin
      w[1] <= #1 kld ? key[032:063] : 
                 ( enable ? w[0]^w[1]^subword^rcon : w[1] );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
      w[2] <= #1 32'h00000000;
    end
    else begin
      w[2] <= #1 kld ? key[064:095] : 
                 ( enable ? w[0]^w[2]^w[1]^subword^rcon : w[2] );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
      w[3] <= #1 32'h00000000;
    end
    else begin
      w[3] <= #1 kld ? key[096:127] : 
                 ( enable ? w[0]^w[3]^w[2]^w[1]^subword^rcon : w[3] );
    end
  end

  assign w_tmp = w[3];

`ifdef COMPOSITE
  aes_sbox_comp sbox3 (   
    .a   ( w_tmp[23:16]   ), 
    .d   ( subword[31:24] )
  );
  aes_sbox_comp sbox2 (
    .a   ( w_tmp[15:08]   ),
    .d   ( subword[23:16] )
  );
  aes_sbox_comp sbox1 (
    .a   ( w_tmp[07:00]   ),
    .d   ( subword[15:08] )
  );
  aes_sbox_comp sbox0 (   
    .a   ( w_tmp[31:24]   ), 
    .d   ( subword[07:00] )
  );
`else
  aes_sbox_lut sbox3 (   
    .a   ( w_tmp[23:16]   ), 
    .d   ( subword[31:24] )
  );
  aes_sbox_lut sbox2 (
    .a   ( w_tmp[15:08]   ),
    .d   ( subword[23:16] )
  );
  aes_sbox_lut sbox1 (
    .a   ( w_tmp[07:00]   ),
    .d   ( subword[15:08] )
  );
  aes_sbox_lut sbox0 (   
    .a   ( w_tmp[31:24]   ), 
    .d   ( subword[07:00] )
  );
`endif

endmodule

