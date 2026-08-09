module APB_CONTROLLER(
    input Hclk,
    input Hwrite,
    input Hresetn,
    input valid,
    input [31:0] Haddr1,
    input [31:0] Haddr2,
    input [31:0] Hwdata1,
    input [31:0] Hwdata2,
    input Hwritereg,
    input Hwritereg1,
    input  [31:0] prdata,
    input [2:0] tempselx,
    output reg Hreadyout,
    output reg Pwrite,
    output reg penable,
    output reg [3:0] pselx,
    output reg [31:0] pwdata,
    output reg [31:0] paddr
    );
    
    parameter st_idle  = 3'b000,
              st_wwait = 3'b001,
              st_writep = 3'b010,
              st_write = 3'b011,
              st_wenable = 3'b100,
              st_wenablep= 3'b101,
              st_read  = 3'b110,
              st_renable = 3'b111;
    reg [2:0] ps,ns;
     
always@(posedge Hclk or posedge Hresetn)
  begin
    if (Hresetn)
        ps <= st_idle;
    else
        ps <= ns;
  end
  
always@(*)
  begin
    case(ps)
      st_idle :begin 
               if(valid && Hwrite)
                    ns = st_wwait;
               else if (valid && !Hwrite)
                    ns = st_read;
               else 
                    ns = st_idle;
               end
      st_wwait : ns = (valid)? st_writep : st_write;
      st_writep: ns = st_wenablep;
      st_write : ns = (valid)? st_wenablep : st_wenable;
      st_wenable:begin
                   if(valid && Hwrite)
                        ns = st_wwait;
                   else if (valid && !Hwrite)
                        ns = st_read;
                   else 
                        ns = st_idle;
                 end
      st_wenablep : begin
                      if(!valid)
                        ns = st_write;
                      else if(valid)
                        ns = st_writep;
                      else
                        ns = st_read;
                    end 
      st_renable : begin
                     if(valid && Hwrite)
                        ns = st_wwait;
                     else if(valid && !Hwrite)
                        ns = st_read;
                     else
                        ns = st_idle;
                   end 
      default : begin 
               if(valid && Hwrite)
                    ns = st_wwait;
               else if (valid && !Hwrite)
                    ns = st_read;
               else 
                    ns = st_idle;
               end
    endcase
  end
  
always@(posedge Hclk or posedge Hresetn)
  begin
    if (Hresetn)
      begin
        Hreadyout <= 1'b1;
        Pwrite    <= 1'b0;
        penable   <= 1'b0;
        pselx     <= 3'b000;
        paddr     <= 32'b0;
        pwdata    <= 32'b0;
      end
    else
      begin
        // defaults (equivalent to st_idle)
        Hreadyout <= 1'b1;
        Pwrite    <= 1'b0;
        penable   <= 1'b0;
        pselx     <= 3'b000;
        paddr     <= 32'b0;
        pwdata    <= 32'b0;
 
        case(ps)
          st_idle     : begin
                          Hreadyout <= 1'b1;
                          penable   <= 1'b0;
                          pselx     <= 3'b000;
                        end
          st_wwait    : begin
                          Hreadyout <= 1'b0;
                          paddr     <= Haddr1;
                        end
          st_writep   : begin
                          Hreadyout <= 1'b0;
                          pselx     <= tempselx;
                          Pwrite    <= 1'b1;
                          paddr     <= Haddr2;
                          pwdata    <= Hwdata1;
                        end
          st_write    : begin
                          Hreadyout <= 1'b0;
                          pselx     <= tempselx;
                          Pwrite    <= 1'b1;
                          paddr     <= Haddr2;
                          pwdata    <= Hwdata1;
                        end
          st_wenable  : begin
                          Hreadyout <= 1'b1;
                          penable   <= 1'b1;
                          pselx     <= tempselx;
                          Pwrite    <= 1'b1;
                          paddr     <= Haddr2;
                          pwdata    <= Hwdata1;
                        end
          st_wenablep : begin
                          Hreadyout <= 1'b1;
                          penable   <= 1'b1;
                          pselx     <= tempselx;
                          Pwrite    <= 1'b1;
                          paddr     <= Haddr2;
                          pwdata    <= Hwdata1;
                        end
          st_read     : begin
                          Hreadyout <= 1'b0;
                          pselx     <= tempselx;
                          paddr     <= Haddr1;
                        end
          st_renable  : begin
                          Hreadyout <= 1'b1;
                          penable   <= 1'b1;
                          pselx     <= tempselx;
                          paddr     <= Haddr1;
                        end
        endcase
      end
  end

endmodule
