
`timescale 1ns/100ps 

module ks (
  decrypt,
  key,
  roundSel,
  roundKey
);

  input         decrypt;
  input  [1:64] key;
  input  [3:0]  roundSel;
  output [1:48] roundKey;
  
  wire   [1:56] KeyC0D0 ;
  wire   [1:56] KeyC1D1;
  wire   [1:56] KeyC2D2;
  wire   [1:56] KeyC3D3;
  wire   [1:56] KeyC4D4;
  wire   [1:56] KeyC5D5;
  wire   [1:56] KeyC6D6;
  wire   [1:56] KeyC7D7;
  wire   [1:56] KeyC8D8;
  wire   [1:56] KeyC9D9;
  wire   [1:56] KeyC10D10;
  wire   [1:56] KeyC11D11;
  wire   [1:56] KeyC12D12;
  wire   [1:56] KeyC13D13;
  wire   [1:56] KeyC14D14;
  wire   [1:56] KeyC15D15;
  wire   [1:56] KeyC16D16;
  wire   [3:0]  activeSel;
  reg    [1:56] activeKey;
  
  assign KeyC0D0 = {
    key[57], key[49], key[41], key[33], key[25], key[17], key[09],
    key[01], key[58], key[50], key[42], key[34], key[26], key[18],
    key[10], key[02], key[59], key[51], key[43], key[35], key[27],
    key[19], key[11], key[03], key[60], key[52], key[44], key[36],
    key[63], key[55], key[47], key[39], key[31], key[23], key[15],
    key[07], key[62], key[54], key[46], key[38], key[30], key[22],
    key[14], key[06], key[61], key[53], key[45], key[37], key[29],
    key[21], key[13], key[05], key[28], key[20] ,key[12], key[04]
  };

  assign KeyC1D1  = {KeyC0D0[2:28],  KeyC0D0[1],    KeyC0D0[30:56],  KeyC0D0[29]};
  assign KeyC2D2  = {KeyC1D1[2:28],  KeyC1D1[1],    KeyC1D1[30:56],  KeyC1D1[29]};
  assign KeyC3D3  = {KeyC2D2[3:28],  KeyC2D2[1:2],  KeyC2D2[31:56],  KeyC2D2[29:30]};
  assign KeyC4D4  = {KeyC3D3[3:28],  KeyC3D3[1:2],  KeyC3D3[31:56],  KeyC3D3[29:30]};
  assign KeyC5D5  = {KeyC4D4[3:28],  KeyC4D4[1:2],  KeyC4D4[31:56],  KeyC4D4[29:30]};
  assign KeyC6D6  = {KeyC5D5[3:28],  KeyC5D5[1:2],  KeyC5D5[31:56],  KeyC5D5[29:30]};
  assign KeyC7D7  = {KeyC6D6[3:28],  KeyC6D6[1:2],  KeyC6D6[31:56],  KeyC6D6[29:30]};
  assign KeyC8D8  = {KeyC7D7[3:28],  KeyC7D7[1:2],  KeyC7D7[31:56],  KeyC7D7[29:30]};
  assign KeyC9D9  = {KeyC8D8[2:28],  KeyC8D8[1],    KeyC8D8[30:56],  KeyC8D8[29]};
  assign KeyC10D10= {KeyC9D9[3:28],  KeyC9D9[1:2],  KeyC9D9[31:56],  KeyC9D9[29:30]};
  assign KeyC11D11= {KeyC10D10[3:28],KeyC10D10[1:2],KeyC10D10[31:56],KeyC10D10[29:30]};
  assign KeyC12D12= {KeyC11D11[3:28],KeyC11D11[1:2],KeyC11D11[31:56],KeyC11D11[29:30]};
  assign KeyC13D13= {KeyC12D12[3:28],KeyC12D12[1:2],KeyC12D12[31:56],KeyC12D12[29:30]};
  assign KeyC14D14= {KeyC13D13[3:28],KeyC13D13[1:2],KeyC13D13[31:56],KeyC13D13[29:30]};
  assign KeyC15D15= {KeyC14D14[3:28],KeyC14D14[1:2],KeyC14D14[31:56],KeyC14D14[29:30]};
  assign KeyC16D16= {KeyC15D15[2:28],KeyC15D15[1],  KeyC15D15[30:56],KeyC15D15[29]};
  
  assign roundKey = {
    activeKey[14],activeKey[17],activeKey[11],activeKey[24],activeKey[1], activeKey[5],
    activeKey[3] ,activeKey[28],activeKey[15],activeKey[6], activeKey[21],activeKey[10],
    activeKey[23],activeKey[19],activeKey[12],activeKey[4], activeKey[26],activeKey[8],
    activeKey[16],activeKey[7], activeKey[27],activeKey[20],activeKey[13],activeKey[2],
    activeKey[41],activeKey[52],activeKey[31],activeKey[37],activeKey[47],activeKey[55],
    activeKey[30],activeKey[40],activeKey[51],activeKey[45],activeKey[33],activeKey[48],
    activeKey[44],activeKey[49],activeKey[39],activeKey[56],activeKey[34],activeKey[53],
    activeKey[46],activeKey[42],activeKey[50],activeKey[36],activeKey[29],activeKey[32]
  };

  assign activeSel = decrypt ? ~roundSel : roundSel;
  always @(*) begin
    case( activeSel )
      0       : activeKey = KeyC1D1;
      1       : activeKey = KeyC2D2;
      2       : activeKey = KeyC3D3;
      3       : activeKey = KeyC4D4;
      4       : activeKey = KeyC5D5;
      5       : activeKey = KeyC6D6;
      6       : activeKey = KeyC7D7;
      7       : activeKey = KeyC8D8;
      8       : activeKey = KeyC9D9;
      9       : activeKey = KeyC10D10;
      10      : activeKey = KeyC11D11;
      11      : activeKey = KeyC12D12;
      12      : activeKey = KeyC13D13;
      13      : activeKey = KeyC14D14;
      14      : activeKey = KeyC15D15;
      15      : activeKey = KeyC16D16;
      default : activeKey = 0;
    endcase
  end

endmodule

