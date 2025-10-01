module up_down(output reg [3:0]q=4'b0000,input clk,rst,input updown);
  always@(posedge clk)begin
    if(rst)
      if(updown)
        q<=4'b0000;
      else
        q<=4'b1111;
    else
      if(updown && q!==4'b1111)
        q<=q+1;
    else if(!updown && q!==4'b0000)
        q<=q-1;
  end
endmodule
