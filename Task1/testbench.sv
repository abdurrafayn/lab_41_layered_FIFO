timeunit 1ns;
timeprecision 1ns;

module testb_top;

bit clk;

initial clk = 0;
always #5 clk = ~clk;

mem_itf newBus1(clk);
environment env;


mem memory (.newBus(newBus1));

initial begin

    env = new(newBus1, 183);
    env.run();

end

endmodule