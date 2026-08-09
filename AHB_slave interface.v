module AHB_slave_interface(
    input Hclk,
    input Hresetn,
    input Hwrite,
    input Hreadyin,
    input [1:0] Htrans,
    input [31:0] Haddr,
    input [31:0] Hwdata,
    input [31:0] prdata,
    output [1:0] Hresp,
    output [31:0] Hrdata,
    output reg valid,
    output reg [31:0] Haddr1,
    output reg [31:0] Haddr2,
    output reg [31:0] Hwdata1,
    output reg [31:0] Hwdata2,
    output reg Hwritereg,
    output reg Hwritereg1,
    output reg [2:0] tempselx
    );
    //piplining logic for the address
    always@(posedge Hclk or posedge Hresetn)
      begin
       if(Hresetn)
         begin
           Haddr1 <= 32'b0;
           Haddr2 <= 32'b0;
         end      
       else
         begin
           Haddr1 <= Haddr;
           Haddr2 <= Haddr1;
         end 
      end
      
      //piplining logic for the data
        always@(posedge Hclk or posedge Hresetn)
      begin
       if(Hresetn)
         begin
           Hwdata1 <= 32'b0;
           Hwdata2 <= 32'b0;
         end      
       else
         begin
           Hwdata1 <= Hwdata;
           Hwdata2 <= Hwdata1;
         end 
      end
      //piplining logic for the writereg
        always@(posedge Hclk or posedge Hresetn)
      begin
       if(Hresetn)
         begin
           Hwritereg <= 1'b0;
           Hwritereg1 <= 1'b0;
         end      
       else
         begin
           Hwritereg <= Hwrite;
           Hwritereg1 <= Hwritereg;
         end 
      end
      
      //logic for the tempselx
      always@(*)
      begin
        if(Haddr >= 32'h8000_0000 && Haddr < 32'h8400_0000)
            tempselx = 3'b001;
        else if(Haddr >= 32'h8400_0000 && Haddr < 32'h8800_0000) 
          tempselx = 3'b010;
        else if(Haddr >= 32'h8800_0000 && Haddr < 32'h8c00_0000) 
          tempselx = 3'b100;
        else
          tempselx = 3'b0000;
      end
      
      //logic for the valid
      always@(*)
      begin
        if((Haddr >= 32'h8000_0000 && Haddr < 32'h8c00_0000) && (Hreadyin == 1'b1) && ((Htrans == 2'b10)||(Htrans == 2'b11)))
          valid =1'b1;
        else
          valid =1'b0;
      end
      
      assign Hrdata = prdata;
      assign Hresp = 2'd0;
endmodule
