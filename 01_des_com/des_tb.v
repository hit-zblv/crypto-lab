
`timescale 1ns/10ps 

module des_tb;

  reg         dut_clk;
  reg         dut_rst_n;
  reg  [1:64] dut_desIn;
  reg  [1:64] dut_key;
  reg         dut_decrypt;
  reg         dut_start;

  wire [1:64] dut_desOut;
  wire        dut_ready;

  des dut ( 
    .clk     ( dut_clk     ),
    .rst_n   ( dut_rst_n   ),
    .desIn   ( dut_desIn   ),
    .key     ( dut_key     ),
    .decrypt ( dut_decrypt ),
    .start   ( dut_start   ),
    .desOut  ( dut_desOut  ),
    .ready   ( dut_ready   ) 
  );

  task delay;
    input [31:0] num;
  begin
    repeat(num) @(posedge dut_clk);
    #1;
  end
  endtask

  initial begin
    dut_clk   = 1'b0;
    dut_rst_n = 1'b1;
    repeat(1) @(negedge dut_clk);
    dut_rst_n = 1'b0;
    repeat(1) @(posedge dut_clk);
    #1;
    dut_rst_n = 1'b1;
  end

  always #5 dut_clk = ~dut_clk; // 100MHz

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end

  integer   seed;
  reg[31:0] num1;
  reg[31:0] num2;
  reg[31:0] num3;

  initial begin
    if ( !$value$plusargs("seed+%d", seed) ) begin
      seed = 0;
    end
    @(posedge dut_clk);
    #1;
    num1 = $random(seed);
    num2 = $random(seed);
    num3 = $random(seed);
  end

  integer           PLOGFILE;
  integer           CLOGFILE;

  initial begin
    PLOGFILE=$fopen("plain.txt", "a"); 
    CLOGFILE=$fopen("cipher.txt", "a"); 
    $display("");
    $display("**************************************");
    $display("* DES Test started ...               *");
    $display("**************************************");
    $display("");
    dut_decrypt = 1'b0;
    dut_start   = 1'b0;
    dut_key     = 64'b0;
    dut_desIn   = 64'b0;
    @(posedge dut_rst_n);
    //
    // key        : 64'haabb_0918_2736_ccdd
    // plaintext  : 64'h1234_56ab_cd13_2536
    // ciphertext : 64'hc0b7_a8d0_5f3a_829c
    //
    // key        : 64'haabb_0918_2736_ccdd
    // plaintext  : 64'h2a13_d554_8657_bc0c
    // ciphertext : 64'hd845_4605_78c6_2a28
    //
    dut_key     = 64'haabb_0918_2736_ccdd;
    dut_desIn   = 64'h1234_56ab_cd13_2536;
    //dut_desIn   = {num2,num3};
    delay(3); // Dont change this delay.
    dut_start   = 1'b1;
    $fdisplay(PLOGFILE, "plaintext = %h", dut_desIn); 
    delay(1);
    dut_start   = 1'b0;
  end
    
  // 
  // Print the cipher text to cipher.txt
  //
  reg      dut_ready_dly;
  wire     dut_ready_pulse;

  initial begin 
    dut_ready_dly = 1;
  end

  always @(posedge dut_clk) begin
    dut_ready_dly <= #1 dut_ready;
  end

  assign dut_ready_pulse = ~dut_ready_dly & dut_ready;

  always @(posedge dut_clk) begin
    if ( dut_ready_pulse ) begin
      $fdisplay(CLOGFILE, "ciphertext = %h", dut_desOut); 
      @(posedge dut_clk);
      #1;
      $display("");
      $display("**************************************");
      $display("* DES Test done ...                  *");
      $display("**************************************");
      $display("");
      $fclose(PLOGFILE);
      $fclose(CLOGFILE);
      $finish;
    end
  end
    
endmodule

