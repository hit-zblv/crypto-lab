
`timescale 1ns/100ps 

module des (
  clk,
  rst_n,
  desIn, 
  key, 
  decrypt, 
  start,
  desOut, 
  ready
);

  input            clk;
  input            rst_n;
  input  [1:64]    desIn;
  input  [1:64]    key;
  input            decrypt;
  input            start;
  output [1:64]    desOut;
  output           ready;
  
  reg    [3:0]     roundSel;
  wire   [1:64]    IP, FP;
  wire   [1:48]    roundKey;
  wire   [1:32]    Fout;
  wire   [1:32]    Rtmp, Rnxt;
  wire   [1:32]    Lnxt;
  reg    [1:32]    L, R;
  
  assign Lnxt  = ( ~|roundSel ) ? IP[33:64] : R;
  assign Rtmp  = ( ~|roundSel ) ? IP[01:32] : L;
  assign Rnxt  = Rtmp ^ Fout;
  assign ready = ( ~|roundSel );
  
  f f ( 
    .P         (Fout    ), 
    .R         (Lnxt    ), 
    .roundKey  (roundKey) 
  );
  
  always @( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
      L <= #1 32'h0000_0000;
    end
    else if ( ~|roundSel && ~start ) begin
      L <= #1 L;
    end
    else begin
      L <= #1 Lnxt;
    end
  end
  
  always @( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
      R <= #1 32'h0000_0000;
    end
    else if ( ~|roundSel && ~start ) begin
      R <= #1 R;
    end
    else begin
      R <= #1 Rnxt;
    end
  end
          
  always @( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
      roundSel <= #1 4'h0;
    end
    else if ( ~|roundSel && ~start ) begin
      roundSel <= #1 roundSel;
    end
    else begin
      roundSel <= #1 roundSel + 4'b0001;
    end
  end

  // Select a roundkey from key expansion.
  ks ks (
    .decrypt   ( decrypt  ),
    .key       ( key      ),
    .roundSel  ( roundSel ),
    .roundKey  ( roundKey ) 
  );
  
  // Perform initial permutation
  assign IP[1:64] = {    
    desIn[58], desIn[50], desIn[42], desIn[34], desIn[26], desIn[18], desIn[10], desIn[02], 
    desIn[60], desIn[52], desIn[44], desIn[36], desIn[28], desIn[20], desIn[12], desIn[04], 
    desIn[62], desIn[54], desIn[46], desIn[38], desIn[30], desIn[22], desIn[14], desIn[06], 
    desIn[64], desIn[56], desIn[48], desIn[40], desIn[32], desIn[24], desIn[16], desIn[08], 
    desIn[57], desIn[49], desIn[41], desIn[33], desIn[25], desIn[17], desIn[09], desIn[01], 
    desIn[59], desIn[51], desIn[43], desIn[35], desIn[27], desIn[19], desIn[11], desIn[03], 
    desIn[61], desIn[53], desIn[45], desIn[37], desIn[29], desIn[21], desIn[13], desIn[05], 
    desIn[63], desIn[55], desIn[47], desIn[39], desIn[31], desIn[23], desIn[15], desIn[07] 
  };
  
  // Perform final permutation
  assign FP   = { R, L };
  assign desOut = {    
    FP[40], FP[08], FP[48], FP[16], FP[56], FP[24], FP[64], FP[32], 
    FP[39], FP[07], FP[47], FP[15], FP[55], FP[23], FP[63], FP[31], 
    FP[38], FP[06], FP[46], FP[14], FP[54], FP[22], FP[62], FP[30], 
    FP[37], FP[05], FP[45], FP[13], FP[53], FP[21], FP[61], FP[29], 
    FP[36], FP[04], FP[44], FP[12], FP[52], FP[20], FP[60], FP[28], 
    FP[35], FP[03], FP[43], FP[11], FP[51], FP[19], FP[59], FP[27], 
    FP[34], FP[02], FP[42], FP[10], FP[50], FP[18], FP[58], FP[26], 
    FP[33], FP[01], FP[41], FP[09], FP[49], FP[17], FP[57], FP[25] 
  };

endmodule

