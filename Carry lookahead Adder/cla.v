module cla(output [3:0]s,output cy,input [3:0]a,b,input [3:0]cin);
  wire [3:0]p,g,c;
  assign p=a^b;
  assign g=a&b;
  assign s[0]=a[0]^b[0]^cin[0];
  assign c[0]=((a[0]^b[0])&cin[0])|(a[0]&b[0]);
  genvar i;
  generate 
    for(i=1;i<4;i++)begin
      assign s[i]=p[i]^c[i];
      assign c[i]=(p[i-1]&c[i-1])|(g[i-1]);
    end
  endgenerate
  assign cy=c[3];
endmodule
