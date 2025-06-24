class monitor;

    transaction trans;
    mailbox mon2score;
    virtual busI virt_intf;


    function new(mailbox mon2score, virtual busI virt_intf);
            this.mon2score = mon2score;
            this.virt_intf = virt_intf;
            this.trans = new();
            
    endfunction 

    task run();
        
        forever 
            begin
                // gen2driver.get(trans);
                @(negedge virt_intf.clk);

                trans.wr_en <= virt_intf.wr_en;
                trans.rd_en <= virt_intf.rd_en;
                trans.data_in <= virt_intf.data_in;
                trans.rst_n <= virt_intf.rst_n;
                
                @(negedge virt_intf.clk);

                trans.data_out <= virt_intf.data_out;
                trans.full <= virt_intf.full;
                trans.empty <= virt_intf.empty;

                mon2score.put(trans);
                
                $display("\n");
                $display("--------------------------------------");
                $display("Monitor Data --");
                $display("--------------------------------------");
                $display("Wr_en: %0d | rd_en: %0d | Data_In: %0d | rst_n: %0d | Data_Out: %0d | Full: %0d | Empty: %0d", 
                        trans.wr_en, trans.rd_en, trans.data_in, trans.rst_n, trans.data_out, trans.full, trans.empty);
                $display("\n");
            end
    endtask
endclass //driver