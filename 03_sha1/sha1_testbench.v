/////////////////////////////////////////////////////////////////
// sha1_testbench.v version 0.1
// 
// Generic verilog test bench that tests the SHA-1 implementation
//
// Paul Hartke, phartke@stanford.edu, Copyright(c)2002
//
// The information and description contained herein is the
// property of Paul Hartke.
//
// Permission is granted for any reuse of this information
// and description as long as this copyright notice is
// preserved.  Modifications may be made as long as this
// notice is preserved.
// This code is made available "as is".  There is no warranty,
// so use it at your own risk.
// Documentation? "Use the source, Luke!"
/////////////////////////////////////////////////////////////////

module test;

  reg           clk;
  reg           start;
  reg   [511:0] y;
  reg   [31:0]  data_in;
  reg           load_in;
  reg   [159:0] cv;
  reg           use_prev_cv;
  wire          busy;
  wire          out_valid;
  wire  [159:0] cv_next;
  reg           reset;

  sha1_exec dut (
    .clk        (clk), 
    .reset      (reset), 
    .load_in    (load_in),
    .data_in    (data_in), 
    .start      (start),
    .cv         (cv), 
    .use_prev_cv(use_prev_cv), 
    .busy       (busy), 
    .out_valid  (out_valid), 
    .cv_next    (cv_next)
  );

  integer       i;
  reg   [159:0] expected_result;
  
  initial begin
     $dumpfile("dump.vcd");
     $dumpvars();
  end

  task inputdata;
    input   [511:0] y;
    integer         i;
    begin
      for( i=0; i<=15; i=i+1 ) begin
        data_in <= (y >> 512-((i+1)*32));
        load_in <= 1'b1;
        // $display("%8x", data_in);
        @(posedge clk) ; 
      end
      load_in = 1'b0;
    end
  endtask

  task delayx;
    input   [31:0]  number;
  begin
    repeat( number ) @( posedge clk );
    #1;
  end
  endtask

  initial begin
    clk = 0;
  end
  always #5 clk = ~clk;

  initial begin
    i = 0;
    start = 0;
    y = 512'b0;
    cv = 160'h0;
    data_in = 32'b0;
    load_in = 1'b0;
    use_prev_cv = 1'b0;
    expected_result = 160'h0;
    reset = 1;
    delayx(3);
    reset = 0;
    delayx(2);

    ////////////////////////////////////////////////////////////////////
    //
    // Test 1: Simple Test
    //
    $display("");       
    $display("//");
    $display("// Test 1: Simple Test Begun ...");
    $display("//");
    @( posedge clk );
    y = {"abc", 8'h80, 416'd0, 64'd24};
    $display("input is \"abc\"");
    expected_result = 160'ha9993e36_4706816a_ba3e2571_7850c26c_9cd0d89d;
    inputdata(y);
    cv = 160'h67452301_EFCDAB89_98BADCFE_10325476_C3D2E1F0;
    start = 1;
    @( posedge clk );
    start = 0;
    wait( out_valid );
    @(posedge clk);
    $display("result is %8h %8h %8h %8h %8h", cv_next[159:128], 
              cv_next[127:96], cv_next[95:64], cv_next[63:32], 
              cv_next[31:0]);
    if ( cv_next == expected_result ) begin
      $display ("*** Test 1 Passed ...");
    end
    else begin
      $display ("*** Test 1 Failed ...");
    end
    $display("*** Test 1 Done ...");       
    $display("");       
    delayx(10);

    ////////////////////////////////////////////////////////////////////
    //
    // Test 2: More Complex Test
    //
    $display("//");
    $display("// Test 2: More Complex Test Begun ...");
    $display("//");
    y = {"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq", 8'h80, 56'd0};
    $display("input is \"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq\"");
    expected_result = 160'h84983e44_1c3bd26e_baae4aa1_f95129e5_e54670f1;
    inputdata(y);
    cv = 160'h67452301_EFCDAB89_98BADCFE_10325476_C3D2E1F0;
    start = 1;
    @( posedge clk );
    start = 0;
    wait( out_valid );
    @( posedge clk );
    $display( "intermediate result is %8h %8h %8h %8h %8h", cv_next[159:128], 
              cv_next[127:96], cv_next[95:64], cv_next[63:32], 
              cv_next[31:0] );
    //
    // Test 2: The Second Block
    //
    y = {448'h0, 61'd56, 3'd0};
    inputdata(y);
    start = 1;
    use_prev_cv = 1;
    @( posedge clk );
    start = 0;
    use_prev_cv = 0;
    wait( out_valid );
    @( posedge clk );
    $display( "result is %8h %8h %8h %8h %8h", cv_next[159:128], 
              cv_next[127:96], cv_next[95:64], cv_next[63:32], 
              cv_next[31:0] );
    if ( cv_next == expected_result ) begin
      $display ("*** Test 2 Passed ...");
    end
    else begin
      $display ("*** Test 2 Failed ...");
    end
    $display("*** Test 2 Done ...");       
    $display("");       
    delayx(10);
    $stop;

    ////////////////////////////////////////////////////////////////////
    //
    // Test 3: Most Complex Test
    // Warning!!!  The following test takes ~50 minutes on my machine!!
    //
    /*
    $display("//");
    $display("// Test 3: Most Complex Test Begun ...");
    $display("//");
    use_prev_cv = 1'b0;
    y = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"};
    $display("  input is one million \"a\"s");
    expected_result = 160'h34aa973c_d4c4daa4_f61eeb2b_dbad2731_6534016f;      
    inputdata(y);
    cv = 160'h67452301_EFCDAB89_98BADCFE_10325476_C3D2E1F0;
    start = 1;
    @( posedge clk );
    start = 0;
    wait( out_valid );
    @( posedge clk );
    $display( "result is %8h %8h %8h %8h %8h", cv_next[159:128], 
              cv_next[127:96], cv_next[95:64], cv_next[63:32], 
              cv_next[31:0] ); 
    for ( i=1; i<15625 ; i=i+1 ) begin
      inputdata(y);
      start = 1;
      use_prev_cv = 1;
      @(posedge clk);
      start = 0;
      use_prev_cv = 0;
      wait( out_valid );
      @( posedge clk );
      if (i%10 == 0) $display("%d of 15625 Iterations Completed!", i);
    end
    //
    // The last data block for Test 3
    //
    y = {8'h80, 440'd0, 61'd1000000, 3'd0};
    inputdata(y);
    start = 1;
    use_prev_cv = 1;
    @(posedge clk);
    start = 0;
    wait( out_valid );
    @( posedge clk );
    $display( "result is %8h %8h %8h %8h %8h", cv_next[159:128], 
              cv_next[127:96], cv_next[95:64], cv_next[63:32], 
              cv_next[31:0] );
    if ( cv_next == expected_result ) begin
      $display ("Test 3 Passed ...");
    end
    else begin
      $display ("Test 3 Failed ...");
    end
    $display("Test 3 Done ...");       
    $display("");       
    delayx(10);
    $stop;
    */
  end // end of initial

  ////////////////////////////////////////////////////////////////////
  //
  // Debugging printouts of all pertinent state...
  //
  /*
  always @( posedge clk ) begin
    if (sha1_exec.state == 2'b01) begin
      $display( "%8h %8h %8h %8h %8h -- %8h %8h %8h-- round: %d", 
        sha1_exec.sha1_round.a, sha1_exec.sha1_round.b, 
        sha1_exec.sha1_round.c, sha1_exec.sha1_round.d,
        sha1_exec.sha1_round.e, sha1_exec.sha1_round.w, 
        sha1_exec.sha1_round.f, sha1_exec.sha1_round.k, 
        sha1_exec.rnd_cnt_q );
    end
  end
  */

endmodule // test

