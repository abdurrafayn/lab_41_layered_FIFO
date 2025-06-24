// timeunit 1ns;
// timeprecision 1ns;

class environment;

//compoenents
    generator gen;
    driver driv;
    monitor mon;
    scoreboard scb;

    //Mailboxes
    mailbox gen2driver, gen2scb, mon2scb;

    //virtual interface
    virtual  busI vif;

    event gen_ended;
    int count;
    //constructor

    function new(virtual busI vif, int count);
    this.vif = vif;
    this.count = count;
    //creating instance of mailboxes
    gen2driver  = new();
    gen2scb     = new();
    mon2scb     = new();

    //creating object of generator, driver, monitor, scoreboard
    gen = new( gen2driver, gen2scb , count, gen_ended);
    driv = new(gen2driver, vif);
    mon = new(mon2scb, vif);
    scb = new(gen2scb, mon2scb);
    endfunction
    task test();
        vif.rst_n=0;
        @(posedge vif.clk);
        vif.rst_n=1;
        @(posedge vif.clk);

            fork
                gen.run();
                driv.run();
                mon.run();
                scb.run();
            join_none

    endtask

    task post_test();
        @(gen_ended);
        // wait(count == driv.drv_count);
        // wait(count == scb.scb_count);
        #25;
        // wait(driv.drv_count >= count);
        // wait(scb.scb_count >= count);

        $display("\n");
        $display("===========================================================================================");
        $display("TEST COMPLETED - RESULTS");
        $display("===========================================================================================");
        $display("Scoreboard Count: %0d | Scoreboard Errors: %0d", scb.count, scb.error_count);

        if(scb.error_count != 0) 
        $display("ERROR: please check your design");
        else
        $display("Task Completed");
    endtask

    task run();
        test();
        post_test();
    $finish;
    endtask

endclass //environment