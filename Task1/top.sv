module top;

timeunit 1ns;
timeprecision 1ns;


bit clk;

initial clk = 0;
always #5 clk = ~clk;

busI newBus(clk);

synchronous_fifo dut (
        .clk (newBus.clk), .rst_n (newBus.rst_n),
        .w_en (newBus.wr_en), .r_en (newBus.rd_en),
        .data_in (newBus.data_in), .data_out (newBus.data_out),
        .full (newBus.full), .empty (newBus.empty));


initial begin

        environment env;
        // int count = 20;  

        env = new(newBus, 20);
        env.run();
    end
// mem_test test (newBus);

// mem memory (newBus);

// always #5 clk = ~clk;
endmodule


