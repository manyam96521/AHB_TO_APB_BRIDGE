module TB_TOP_AHB2APB_BRIDGE();

reg         Hclk;
reg         Hresetn;
reg         Hwrite;
reg         Hreadyin;
reg  [1:0]  Htrans;
reg  [31:0] Haddr;
reg  [31:0] Hwdata;
reg  [31:0] prdata;

wire [1:0]  Hresp;
wire [31:0] Hrdata;
wire        Hreadyout;
wire        Pwrite;
wire        penable;
wire [2:0]  pselx;
wire [31:0] pwdata;
wire [31:0] paddr;

TOP_AHB2APB_BRIDGE DUT (
    .Hclk      (Hclk),
    .Hresetn   (Hresetn),
    .Hwrite    (Hwrite),
    .Hreadyin  (Hreadyin),
    .Htrans    (Htrans),
    .Haddr     (Haddr),
    .Hwdata    (Hwdata),
    .prdata    (prdata),
    .Hresp     (Hresp),
    .Hrdata    (Hrdata),
    .Hreadyout (Hreadyout),
    .Pwrite    (Pwrite),
    .penable   (penable),
    .pselx     (pselx),
    .pwdata    (pwdata),
    .paddr     (paddr)
);

parameter IDLE    = 2'b00,
          BUSY    = 2'b01,
          NON_SEQ = 2'b10,
          SEQ     = 2'b11;

//clock
initial
begin
    Hclk = 0;
    forever #5 Hclk = ~Hclk;
end

// Active-high reset (matches AHB_slave_interface and APB_CONTROLLER
// as provided: both use posedge Hresetn / if(Hresetn)).
task reset;
  begin
    Hresetn = 1;
    #30;
    Hresetn = 0;
  end
endtask

task Hwrite_reg(input j);
  begin
    @(posedge Hclk)
    Hwrite = (j == 1) ? 1'b1 : 1'b0;
  end
endtask

// Drives a single AHB write: address phase for 1 cycle, data phase
// for 1 cycle, then holds idle long enough for the address/data to
// clear the AHB_slave_interface pipeline (2 cycles) and the
// APB_CONTROLLER's setup+enable sequence (~3-4 cycles).
task ahb_write(input [31:0] addr, input [31:0] data);
    begin
        @(posedge Hclk);
        Htrans   = NON_SEQ;
        Haddr    = addr;
        Hwrite   = 1'b1;
        Hreadyin = 1'b1;
        @(posedge Hclk);
        Hwdata = data;
        Htrans = IDLE;
        repeat(8) @(posedge Hclk);
    end
endtask

// Drives a single AHB read, same timing reasoning as ahb_write.
task ahb_read(input [31:0] addr);
    begin
        @(posedge Hclk);
        Htrans   = NON_SEQ;
        Haddr    = addr;
        Hwrite   = 1'b0;
        Hreadyin = 1'b1;
        @(posedge Hclk);
        Htrans = IDLE;
        repeat(8) @(posedge Hclk);
    end
endtask

initial
begin
    Hresetn  = 0;
    Hwrite   = 0;
    Hreadyin = 1;
    Htrans   = IDLE;
    Haddr    = 32'h0000_0000;
    Hwdata   = 32'h0000_0000;
    prdata   = 32'h0000_0000;

    reset;

    // Test-1: single write
    ahb_write(32'h8001_1254, 32'h0989_2324);

    // Test-2: single read
    ahb_read(32'h8000_0000);

    // Test-3: back-to-back writes to different peripherals (tempselx changes)
    ahb_write(32'h8000_0004, 32'hAAAA_AAAA);
    ahb_write(32'h8400_0008, 32'hBBBB_BBBB);

    // Test-4: back-to-back reads
    ahb_read(32'h8000_0004);
    ahb_read(32'h8400_0008);

    // Test-5: reset in the middle of an operation
    @(posedge Hclk);
    Htrans   = NON_SEQ;
    Haddr    = 32'h8002_5893;
    Hwrite   = 1'b1;
    Hreadyin = 1'b1;
    @(posedge Hclk);
    Hwdata  = 32'h1111_2222;
    Hresetn = 1;
    #20;
    Hresetn = 0;
    Htrans  = IDLE;
    repeat(4) @(posedge Hclk);

    // Test-6: write right after reset
    ahb_write(32'h8002_5893, 32'h9893_7382);

    $display("All test cases completed");
    $finish;
end

endmodule