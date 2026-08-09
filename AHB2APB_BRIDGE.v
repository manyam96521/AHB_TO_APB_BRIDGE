module TOP_AHB2APB_BRIDGE(
    input         Hclk,
    input         Hresetn,
    input         Hwrite,
    input         Hreadyin,
    input  [1:0]  Htrans,
    input  [31:0] Haddr,
    input  [31:0] Hwdata,
    input  [31:0] prdata,     

    output [1:0]  Hresp,
    output [31:0] Hrdata,      
    output        Hreadyout,   
    output        Pwrite,
    output        penable,
    output [2:0]  pselx,
    output [31:0] pwdata,
    output [31:0] paddr
    );

    wire        valid;
    wire [31:0] Haddr1;
    wire [31:0] Haddr2;
    wire [31:0] Hwdata1;
    wire [31:0] Hwdata2;
    wire        Hwritereg;
    wire        Hwritereg1;
    wire [2:0]  tempselx;

    AHB_slave_interface U_AHB_SLAVE_IF (
        .Hclk       (Hclk),
        .Hresetn    (Hresetn),
        .Hwrite     (Hwrite),
        .Hreadyin   (Hreadyin),
        .Htrans     (Htrans),
        .Haddr      (Haddr),
        .Hwdata     (Hwdata),
        .prdata     (prdata),
        .Hresp      (Hresp),
        .Hrdata     (Hrdata),
        .valid      (valid),
        .Haddr1     (Haddr1),
        .Haddr2     (Haddr2),
        .Hwdata1    (Hwdata1),
        .Hwdata2    (Hwdata2),
        .Hwritereg  (Hwritereg),
        .Hwritereg1 (Hwritereg1),
        .tempselx   (tempselx)
    );

    APB_CONTROLLER U_APB_CONTROLLER (
        .Hclk       (Hclk),
        .Hwrite     (Hwrite),
        .Hresetn    (Hresetn),
        .valid      (valid),
        .Haddr1     (Haddr1),
        .Haddr2     (Haddr2),
        .Hwdata1    (Hwdata1),
        .Hwdata2    (Hwdata2),
        .Hwritereg  (Hwritereg),
        .Hwritereg1 (Hwritereg1),
        .prdata     (prdata),
        .tempselx   (tempselx),
        .Hreadyout  (Hreadyout),
        .Pwrite     (Pwrite),
        .penable    (penable),
        .pselx      (pselx),
        .pwdata     (pwdata),
        .paddr      (paddr)
    );

endmodule