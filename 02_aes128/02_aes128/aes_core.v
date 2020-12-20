/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Core Top Level                                         ////
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

module aes_core (
  input  wire         clk,
  input  wire         rst_n,
  input  wire         ld,
  input  wire [0:127] key,
  input  wire [0:127] text_in,
  output wire         done,
  output wire [0:127] text_out
);
  
  //////////////////////////////////////////////////////////////////
  //
  // Local Wires
  //
  wire   [31:0]    rkey0;
  wire   [31:0]    rkey1;
  wire   [31:0]    rkey2;
  wire   [31:0]    rkey3;
  reg    [7:0]     sa00;
  reg    [7:0]     sa01;
  reg    [7:0]     sa02;
  reg    [7:0]     sa03;
  reg    [7:0]     sa10;
  reg    [7:0]     sa11;
  reg    [7:0]     sa12;
  reg    [7:0]     sa13;
  reg    [7:0]     sa20;
  reg    [7:0]     sa21;
  reg    [7:0]     sa22;
  reg    [7:0]     sa23;
  reg    [7:0]     sa30;
  reg    [7:0]     sa31;
  reg    [7:0]     sa32;
  reg    [7:0]     sa33;
  wire   [7:0]     sa00_next;
  wire   [7:0]     sa01_next;
  wire   [7:0]     sa02_next;
  wire   [7:0]     sa03_next;
  wire   [7:0]     sa10_next;
  wire   [7:0]     sa11_next;
  wire   [7:0]     sa12_next;
  wire   [7:0]     sa13_next;
  wire   [7:0]     sa20_next;
  wire   [7:0]     sa21_next;
  wire   [7:0]     sa22_next;
  wire   [7:0]     sa23_next;
  wire   [7:0]     sa30_next;
  wire   [7:0]     sa31_next;
  wire   [7:0]     sa32_next;
  wire   [7:0]     sa33_next;
  wire   [7:0]     sa00_sub;
  wire   [7:0]     sa01_sub;
  wire   [7:0]     sa02_sub;
  wire   [7:0]     sa03_sub;
  wire   [7:0]     sa10_sub;
  wire   [7:0]     sa11_sub;
  wire   [7:0]     sa12_sub;
  wire   [7:0]     sa13_sub;
  wire   [7:0]     sa20_sub;
  wire   [7:0]     sa21_sub;
  wire   [7:0]     sa22_sub;
  wire   [7:0]     sa23_sub;
  wire   [7:0]     sa30_sub;
  wire   [7:0]     sa31_sub;
  wire   [7:0]     sa32_sub;
  wire   [7:0]     sa33_sub;
  wire   [7:0]     sa00_sr;
  wire   [7:0]     sa01_sr;
  wire   [7:0]     sa02_sr;
  wire   [7:0]     sa03_sr;
  wire   [7:0]     sa10_sr;
  wire   [7:0]     sa11_sr;
  wire   [7:0]     sa12_sr;
  wire   [7:0]     sa13_sr;
  wire   [7:0]     sa20_sr;
  wire   [7:0]     sa21_sr;
  wire   [7:0]     sa22_sr;
  wire   [7:0]     sa23_sr;
  wire   [7:0]     sa30_sr;
  wire   [7:0]     sa31_sr;
  wire   [7:0]     sa32_sr;
  wire   [7:0]     sa33_sr;
  wire   [7:0]     sa00_mc;
  wire   [7:0]     sa01_mc;
  wire   [7:0]     sa02_mc;
  wire   [7:0]     sa03_mc;
  wire   [7:0]     sa10_mc;
  wire   [7:0]     sa11_mc;
  wire   [7:0]     sa12_mc;
  wire   [7:0]     sa13_mc;
  wire   [7:0]     sa20_mc;
  wire   [7:0]     sa21_mc;
  wire   [7:0]     sa22_mc;
  wire   [7:0]     sa23_mc;
  wire   [7:0]     sa30_mc;
  wire   [7:0]     sa31_mc;
  wire   [7:0]     sa32_mc;
  wire   [7:0]     sa33_mc;
  reg    [3:0]     dcnt;
  
  //////////////////////////////////////////////////////////////////
  //
  // Modules
  //
  aes_key_expand key_expand (
    .clk    (   clk   ),
    .rst_n  (   rst_n ),
    .kld    (   ld    ),
    .key    (   key   ),
    .rkey0  (   rkey0 ),
    .rkey1  (   rkey1 ),
    .rkey2  (   rkey2 ),
    .rkey3  (   rkey3 ),
    .enable (  |dcnt  )
  );

  //////////////////////////////////////////////////////////////////
  //
  // State Control Logic
  //
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      dcnt <= #1 4'h0;
    end
    else if ( ld ) begin
      dcnt <= #1 4'hb;
    end
    else if ( |dcnt ) begin
       dcnt <= #1 dcnt - 4'h1;
    end
    else begin 
      dcnt <= #1 dcnt;
    end
  end
  
  assign done = ~|dcnt ;

  //////////////////////////////////////////////////////////////////
  //
  // Every Round State Registers
  //
  // Include initial round & normal 9 rounds & last round
  //
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa33 <= #1 8'h00;
    end
    else begin
      sa33 <= #1 ld ? text_in[120:127] : ( dcnt == 4'hb ) ? sa33 ^ rkey3[07:00] : 
                 ( |dcnt ? sa33_next : sa33 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa23 <= #1 8'h00;
    end
    else begin
      sa23 <= #1 ld ? text_in[112:119] : ( dcnt == 4'hb ) ? sa23 ^ rkey3[15:08] : 
                 ( |dcnt ? sa23_next : sa23 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa13 <= #1 8'h00;
    end
    else begin
      sa13 <= #1 ld ? text_in[104:111] : ( dcnt == 4'hb ) ? sa13 ^ rkey3[23:16] : 
                 ( |dcnt ? sa13_next : sa13 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa03 <= #1 8'h00;
    end
    else begin
      sa03 <= #1 ld ? text_in[096:103] : ( dcnt == 4'hb ) ? sa03 ^ rkey3[31:24] : 
                 ( |dcnt ? sa03_next : sa03 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa32 <= #1 8'h00;
    end
    else begin
      sa32 <= #1 ld ? text_in[088:095] : ( dcnt == 4'hb ) ? sa32 ^ rkey2[07:00] : 
                 ( |dcnt ? sa32_next : sa32 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa22 <= #1 8'h00;
    end
    else begin
      sa22 <= #1 ld ? text_in[080:087] : ( dcnt == 4'hb ) ? sa22 ^ rkey2[15:08] : 
                 ( |dcnt ? sa22_next : sa22 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa12 <= #1 8'h00;
    end
    else begin
      sa12 <= #1 ld ? text_in[072:079] : ( dcnt == 4'hb ) ? sa12 ^ rkey2[23:16] : 
                 ( |dcnt ? sa12_next : sa12 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa02 <= #1 8'h00;
    end
    else begin
      sa02 <= #1 ld ? text_in[064:071] : ( dcnt == 4'hb ) ? sa02 ^ rkey2[31:24] : 
                 ( |dcnt ? sa02_next : sa02 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa31 <= #1 8'h00;
    end
    else begin
      sa31 <= #1 ld ? text_in[056:063] : ( dcnt == 4'hb ) ? sa31 ^ rkey1[07:00] : 
                 ( |dcnt ? sa31_next : sa31 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa21 <= #1 8'h00;
    end
    else begin
      sa21 <= #1 ld ? text_in[048:055] : ( dcnt == 4'hb ) ? sa21 ^ rkey1[15:08] : 
                 ( |dcnt ? sa21_next : sa21 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa11 <= #1 8'h00;
    end
    else begin
      sa11 <= #1 ld ? text_in[040:047] : ( dcnt == 4'hb ) ? sa11 ^ rkey1[23:16] : 
                 ( |dcnt ? sa11_next : sa11 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa01 <= #1 8'h00;
    end
    else begin
      sa01 <= #1 ld ? text_in[032:039] : ( dcnt == 4'hb ) ? sa01 ^ rkey1[31:24] : 
                 ( |dcnt ? sa01_next : sa01 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa30 <= #1 8'h00;
    end
    else begin
      sa30 <= #1 ld ? text_in[024:031] : ( dcnt == 4'hb ) ? sa30 ^ rkey0[07:00] : 
                 ( |dcnt ? sa30_next : sa30 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin   
      sa20 <= #1 8'h00;
    end
    else begin
      sa20 <= #1 ld ? text_in[016:023] : ( dcnt == 4'hb ) ? sa20 ^ rkey0[15:08] : 
                 ( |dcnt ? sa20_next : sa20 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
      sa10 <= #1 8'h00;
    end
    else begin
      sa10 <= #1 ld ? text_in[008:015] : ( dcnt == 4'hb ) ? sa10 ^ rkey0[23:16] : 
                 ( |dcnt ? sa10_next : sa10 );
    end
  end
  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
      sa00 <= #1 8'h00;
    end
    else begin
      sa00 <= #1 ld ? text_in[000:007] : ( dcnt == 4'hb ) ? sa00 ^ rkey0[31:24] : 
                 ( |dcnt ? sa00_next : sa00 );
    end
  end

  //////////////////////////////////////////////////////////////////
  //
  // Round Function
  //
  // (1) SubBytes
  //
  aes_sbox_lut us00 (   
    .a( sa00     ),
    .d( sa00_sub )
  );
  aes_sbox_lut us10 (   
    .a( sa10     ),
    .d( sa10_sub )
  );
  aes_sbox_lut us20 (
    .a( sa20     ),
    .d( sa20_sub )
  );
  aes_sbox_lut us30 (
    .a( sa30     ),
    .d( sa30_sub )
  );
  aes_sbox_lut us01 (
    .a( sa01     ),
    .d( sa01_sub )
  );
  aes_sbox_lut us11 (
    .a( sa11     ),
    .d( sa11_sub )
  );
  aes_sbox_lut us21 (
    .a( sa21     ),
    .d( sa21_sub )
  );
  aes_sbox_lut us31 (
    .a( sa31     ),
    .d( sa31_sub )
  );
  aes_sbox_lut us02 (
    .a( sa02     ),
    .d( sa02_sub )
  );
  aes_sbox_lut us12 (   
    .a( sa12     ),
    .d( sa12_sub )
  );
  aes_sbox_lut us22 (
    .a( sa22     ),
    .d( sa22_sub )
  );
  aes_sbox_lut us32 (
    .a( sa32     ),
    .d( sa32_sub )
  );
  aes_sbox_lut us03 (
    .a( sa03     ),
    .d( sa03_sub )
  );
  aes_sbox_lut us13 (
    .a( sa13     ),
    .d( sa13_sub )
  );
  aes_sbox_lut us23 (
    .a( sa23     ),
    .d( sa23_sub )
  );
  aes_sbox_lut us33 (
    .a( sa33     ),
    .d( sa33_sub )
  );
  //
  // (2) ShiftRows
  //
  assign sa00_sr = sa00_sub;
  assign sa01_sr = sa01_sub;
  assign sa02_sr = sa02_sub;
  assign sa03_sr = sa03_sub;
  assign sa10_sr = sa11_sub;
  assign sa11_sr = sa12_sub;
  assign sa12_sr = sa13_sub;
  assign sa13_sr = sa10_sub;
  assign sa20_sr = sa22_sub;
  assign sa21_sr = sa23_sub;
  assign sa22_sr = sa20_sub;
  assign sa23_sr = sa21_sub;
  assign sa30_sr = sa33_sub;
  assign sa31_sr = sa30_sub;
  assign sa32_sr = sa31_sub;
  assign sa33_sr = sa32_sub;
  //
  // (3) MixColumns
  //
  assign { sa00_mc, sa10_mc, sa20_mc, sa30_mc } = mix_col( sa00_sr, sa10_sr, sa20_sr, sa30_sr );
  assign { sa01_mc, sa11_mc, sa21_mc, sa31_mc } = mix_col( sa01_sr, sa11_sr, sa21_sr, sa31_sr );
  assign { sa02_mc, sa12_mc, sa22_mc, sa32_mc } = mix_col( sa02_sr, sa12_sr, sa22_sr, sa32_sr );
  assign { sa03_mc, sa13_mc, sa23_mc, sa33_mc } = mix_col( sa03_sr, sa13_sr, sa23_sr, sa33_sr );
  //
  // (4) NextStates
  //
  assign sa00_next = (~|dcnt[3:1] & dcnt[0]) ? sa00_sr ^ rkey0[31:24] : sa00_mc ^ rkey0[31:24];
  assign sa10_next = (~|dcnt[3:1] & dcnt[0]) ? sa10_sr ^ rkey0[23:16] : sa10_mc ^ rkey0[23:16];
  assign sa20_next = (~|dcnt[3:1] & dcnt[0]) ? sa20_sr ^ rkey0[15:08] : sa20_mc ^ rkey0[15:08];
  assign sa30_next = (~|dcnt[3:1] & dcnt[0]) ? sa30_sr ^ rkey0[07:00] : sa30_mc ^ rkey0[07:00];
  assign sa01_next = (~|dcnt[3:1] & dcnt[0]) ? sa01_sr ^ rkey1[31:24] : sa01_mc ^ rkey1[31:24];
  assign sa11_next = (~|dcnt[3:1] & dcnt[0]) ? sa11_sr ^ rkey1[23:16] : sa11_mc ^ rkey1[23:16];
  assign sa21_next = (~|dcnt[3:1] & dcnt[0]) ? sa21_sr ^ rkey1[15:08] : sa21_mc ^ rkey1[15:08];
  assign sa31_next = (~|dcnt[3:1] & dcnt[0]) ? sa31_sr ^ rkey1[07:00] : sa31_mc ^ rkey1[07:00];
  assign sa02_next = (~|dcnt[3:1] & dcnt[0]) ? sa02_sr ^ rkey2[31:24] : sa02_mc ^ rkey2[31:24];
  assign sa12_next = (~|dcnt[3:1] & dcnt[0]) ? sa12_sr ^ rkey2[23:16] : sa12_mc ^ rkey2[23:16];
  assign sa22_next = (~|dcnt[3:1] & dcnt[0]) ? sa22_sr ^ rkey2[15:08] : sa22_mc ^ rkey2[15:08];
  assign sa32_next = (~|dcnt[3:1] & dcnt[0]) ? sa32_sr ^ rkey2[07:00] : sa32_mc ^ rkey2[07:00];
  assign sa03_next = (~|dcnt[3:1] & dcnt[0]) ? sa03_sr ^ rkey3[31:24] : sa03_mc ^ rkey3[31:24];
  assign sa13_next = (~|dcnt[3:1] & dcnt[0]) ? sa13_sr ^ rkey3[23:16] : sa13_mc ^ rkey3[23:16];
  assign sa23_next = (~|dcnt[3:1] & dcnt[0]) ? sa23_sr ^ rkey3[15:08] : sa23_mc ^ rkey3[15:08];
  assign sa33_next = (~|dcnt[3:1] & dcnt[0]) ? sa33_sr ^ rkey3[07:00] : sa33_mc ^ rkey3[07:00];

  //////////////////////////////////////////////////////////////////
  //
  // Final text output
  //
  assign text_out = { sa00, sa10, sa20, sa30, 
                      sa01, sa11, sa21, sa31, 
                      sa02, sa12, sa22, sa32, 
                      sa03, sa13, sa23, sa33 };

  //////////////////////////////////////////////////////////////////
  //
  // Generic Functions
  //
  function [7:0] xtime;
    input [7:0] b; 
    begin
      xtime = { b[6:0],1'b0 } ^ ( 8'h1b & {8{b[7]}} );
    end
  endfunction

  function [31:0] mix_col;
    input   [7:0]   s0;
    input   [7:0]   s1;
    input   [7:0]   s2;
    input   [7:0]   s3;
    reg     [7:0]   s0_o;
    reg     [7:0]   s1_o;
    reg     [7:0]   s2_o;
    reg     [7:0]   s3_o;
    begin
      mix_col[31:24] = xtime(s0) ^ xtime(s1) ^ s1 ^ s2 ^ s3;
      mix_col[23:16] = s0 ^ xtime(s1) ^ xtime(s2) ^ s2 ^ s3;
      mix_col[15:08] = s0 ^ s1 ^ xtime(s2) ^ xtime(s3) ^ s3;
      mix_col[07:00] = xtime(s0) ^ s0 ^ s1 ^ s2 ^ xtime(s3);
    end
  endfunction

endmodule

