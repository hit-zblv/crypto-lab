/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES RCON Block                                             ////
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

module aes_rconst (
  input  wire           clk,
  input  wire           rst_n,
  input  wire           kld,
  input  wire           enable,
  output wire  [31:0]   rcon 
);
  reg      [7:0]    rcon_r;
  reg      [3:0]    rcnt_next;
  reg      [3:0]    rcnt;

  assign rcon = { rcon_r, 24'h00_0000 };
  always @( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
      rcon_r <= #1 8'h01;
    end
    else if ( kld ) begin
      rcon_r <= #1 8'h01;
    end
    else begin     
      rcon_r <= #1 frcon(rcnt_next);
    end
  end

  always @( * ) begin
    rcnt_next = rcnt;
    if ( enable ) begin
      rcnt_next = rcnt + 4'h1;
    end
  end

  always @( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
      rcnt <= #1 4'h0;
    end
    else if ( kld ) begin 
      rcnt <= #1 4'h0;
    end
    else begin
      rcnt <= #1 rcnt_next;
    end
  end

  function [7:0] frcon;
    input  [3:0]  i;
    begin
      case ( i )   // synopsys parallel_case
        4'h0    : frcon = 8'h01;
        4'h1    : frcon = 8'h02;
        4'h2    : frcon = 8'h04;
        4'h3    : frcon = 8'h08;
        4'h4    : frcon = 8'h10;
        4'h5    : frcon = 8'h20;
        4'h6    : frcon = 8'h40;
        4'h7    : frcon = 8'h80;
        4'h8    : frcon = 8'h1b;
        4'h9    : frcon = 8'h36;
        default : frcon = 8'h01;
      endcase
    end
  endfunction

endmodule

