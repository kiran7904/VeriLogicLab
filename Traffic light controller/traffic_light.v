module traffic_light(output logic [2:0]light,input logic clk,rst);
  int count;
  typedef enum logic [1:0]{RED=2'b00,GREEN=2'b01,YELLOW=2'b10}state;
  state ps,ns;
  localparam REDD=10;
  localparam GREENN=10;
  localparam YELLOWW=3;
  function automatic int check(state s);
    begin
    case(s)
      RED: return REDD-1;
      GREEN:return GREENN-1;
      YELLOW:return YELLOW-1;
      default: return REDD-1;
    endcase
   end
  endfunction
  always_ff@(posedge clk or posedge rst)begin
  if(rst) begin
    ps<=RED;
    count<=0;
  end
  else begin
    if(count==check(ps))begin
    ps<=ns;
    count<=0;
    end
    else begin
      count<=count+1;
      end
    end
  end
  always_comb begin
    case(ps)
      RED:ns=GREEN;
      GREEN:ns=YELLOW;
      YELLOW:ns=RED;
    endcase
  end
  always_comb begin
    case(ps)
      RED:light=3'b100;
      GREEN:light=3'b010;
      YELLOW:light=3'b001;
    endcase
  end
endmodule
                                                                                                     
  
    
