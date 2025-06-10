//the testbench module
module yolo_tb;
//declaring ports
  bit clk;
  logic [23:0]in_data;
  logic in_valid;
  logic in_ready;
  logic rst_n;
  logic [23:0]s_axis_0_0_tdata;
  logic s_axis_0_0_tready;
  logic s_axis_0_0_tvalid;
//declaring important simulation variables
    int err_count=0;
    int crrct_count=0;
    int detections=0;
    logic correct_transaction=0;//flag for correct transactions
//instantiating the wrapper
design_1_wrapper DUT (.*);
//generating the clock
initial begin
   forever begin
    #1; clk=~clk;
    end
end
//loading the memory with the image data
bit [23:0] img_mem [173055:0];
bit [23:0] img_mem1 [173055:0];
int i=0;
//generating stimulus
initial begin
    $readmemh("/tmp/finn_dev_drmervat/vivado_zynq_proj_tb_en_ze/finn_zynq_link.srcs/sim_1/new/pixels_hex.txt", img_mem);
    $readmemh("/tmp/finn_dev_drmervat/vivado_zynq_proj_tb_en_ze/finn_zynq_link.srcs/sim_1/new/pixels_hex1.txt", img_mem1);
    rst_n =0;
    repeat(10)begin
        check_reset;
    end
    rst_n=1;
    in_valid=0;
    //sending the car picture
    for(i=0;i<173056;) begin
        send_data(img_mem[i]);
        if(correct_transaction)
        i++;
    end
    for(i=0;i<173056;) begin
        send_data(img_mem1[i]);
        if(correct_transaction)
        i++;
    end
    wait(detections==338);
    rst_n=0;
    check_reset;
    #10;
    $stop;
end
//assign the placeholder signals with their corresponding ones from the main design
assign s_axis_0_0_tdata = in_data;
assign in_ready =  s_axis_0_0_tready;
assign s_axis_0_0_tvalid = in_valid;
//checking reset task
task check_reset;
    in_data=$random;
    in_valid=$random;
    @(negedge clk);
    if(DUT.design_1_i.yolo_post_0.detect_valid) begin
        $display("reset error at %t",$time);
        err_count++;
    end
    else begin
        crrct_count++;
    end
endtask
//sending data task
task send_data(logic [23:0] data);
    if(in_ready)begin
    correct_transaction=1;
    end
    else begin
    correct_transaction=0;
    end
    in_data= data;
    in_valid=1;
    @(negedge clk);

endtask
always@(posedge DUT.design_1_i.yolo_post_0.detect_valid) begin
    detections++;
end
endmodule
