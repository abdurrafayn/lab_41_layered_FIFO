class driver;

    transaction trans;
    mailbox gen2driver;

    virtual busI virt_intf;

    function new(mailbox gen2driver, virtual busI virt_intf);
            this.trans = new();
            this.gen2driver = gen2driver;
            this.virt_intf = virt_intf;
            
    endfunction 

    task run();
        
        forever 
            begin
                trans = new();
                gen2driver.get(trans);
               $display("here_drv");
                @(negedge virt_intf.clk);

                virt_intf.wr_en <= trans.wr_en;
                virt_intf.rd_en <= trans.rd_en;
                virt_intf.data_in <= trans.data_in;

                virt_intf.rst_n <= trans.rst_n;
                
                $display("\n");
                $display("--------------------------------------");
                $display("Driver Data--");
                $display("--------------------------------------");
                $display("Wr_en: %0d | rd_en: %0d | Data_In: %0d | rst_n: %0d", trans.wr_en, trans.rd_en, trans.data_in, trans.rst_n);
                $display("\n");
            end
    endtask
endclass //driver