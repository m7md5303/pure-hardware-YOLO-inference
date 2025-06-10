module yolo_post (clk, rst_n, s_axis_tready, s_axis_tvalid, s_axis_tdata, detect_valid,
row_det0, row_det1, row_det2, row_det3, row_det4, row_det5, row_det6, row_det7,
row_det8, row_det9, row_det10, row_det11, row_det12);
//declaring parameter
parameter NO_GRIDS = 4'd13;//number of grids per image row
parameter IMG_GRIDS = 8'd169;//number of grids per image
parameter NO_BYTES = 5'd18;//number of bytes per grid
parameter CONF_THRESHOLD = 367001;//Confidence Threshold
//defining ports
input  clk, rst_n, s_axis_tvalid;
input signed [7:0] s_axis_tdata ; 
output reg s_axis_tready;
reg read_ready;
output reg detect_valid;
output [NO_GRIDS-1:0] row_det0, row_det1, row_det2, row_det3, row_det4, row_det5, row_det6, row_det7,
row_det8, row_det9, row_det10, row_det11, row_det12;
//declaring flags and counters
reg [7:0] rec_grid_count; //to indicate which grid is being processed
reg [4:0] rec_byte_count; //to indicate which no. of bytes received per grid
reg max1, max2, max3; //storing results of comparison for the three bytes of the objectness score
reg [IMG_GRIDS-1:0] detections ; //temporary storage for detections
reg finished_detections;//flag for acknowldgmenting the end of this frame detections
reg signed [9:0] conf1, conf2, conf3;
//s_axis_tready logic
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        s_axis_tready<=0;
        read_ready<=0;
    end
    else begin
        s_axis_tready<=1;
        read_ready<=1;
    end
end
//received bytes per grid counter
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rec_byte_count<=0;
    end
    else begin
        if(s_axis_tvalid&&read_ready) begin
            if(rec_byte_count==(NO_BYTES-1)) begin
                rec_byte_count<=0;
            end
            else begin
                rec_byte_count<=rec_byte_count+1;
            end
        end
    end
end
//received grids counter
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rec_grid_count<=0;
    end
    else begin
        if(finished_detections) begin
            if(rec_grid_count==(IMG_GRIDS-1)) begin
                rec_grid_count<=0;
            end
            else begin
                rec_grid_count<=rec_grid_count+1;
            end
        end
    end
end
//the detections carrier outputs
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        detections<=0;
        max1<=0;
        max2<=0;
        max3<=0;
    end
    else begin
        if(rec_byte_count==5&&s_axis_tvalid&&read_ready) begin
            max1 <= compare_to_threshold(s_axis_tdata , conf1);
        end
        else if(rec_byte_count==11&&s_axis_tvalid&&read_ready) begin
            max2 <= compare_to_threshold(s_axis_tdata , conf2);
        end
        else if(rec_byte_count==17&&s_axis_tvalid&&read_ready) begin
            max3 <= compare_to_threshold(s_axis_tdata , conf3);
        end
        if(rec_byte_count==17&&s_axis_tvalid&&read_ready) begin
            finished_detections<=1;
        end
        if(finished_detections) begin
            detections[rec_grid_count] <= get_max(max1, max2, max3);
            finished_detections<=0;
        end
    end
end
//confidence score carrier registers (bytes no. 5, 11, 17) 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        conf1<=0;
        conf2<=0;
        conf3<=0;
    end
    else begin
        if(rec_byte_count==4&&s_axis_tvalid&&read_ready) begin
            conf1<=s_axis_tdata;
        end
        else if(rec_byte_count==10&&s_axis_tvalid&&read_ready) begin
            conf2<=s_axis_tdata;
        end
        else if(rec_byte_count==16&&s_axis_tvalid&&read_ready) begin
            conf3<=s_axis_tdata;
        end
    end
end
//getting the outputs
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        detect_valid<=0;
    end
    else begin
        if(finished_detections) begin
            detect_valid<=1;
        end
        else begin
            detect_valid<=0;
        end
    end
end
assign row_det0 = detections[12:0];
assign row_det1 = detections[25:13];
assign row_det2 = detections[38:26];
assign row_det3 = detections[51:39];
assign row_det4 = detections[64:52];
assign row_det5 = detections[77:65];
assign row_det6 = detections[90:78];
assign row_det7 = detections[103:91];
assign row_det8 = detections[116:104];
assign row_det9 = detections[129:117];
assign row_det10 = detections[142:130];
assign row_det11 = detections[155:143];
assign row_det12 = detections[168:156];
//function for comparing the input bytes with threshold of approximately 30% confidence
function compare_to_threshold;
    input signed [7:0] in_byte_clsscore;
    input signed [7:0] in_byte_conf;
    begin
        if((((in_byte_clsscore*4)+512)*((in_byte_conf*4)+512))>CONF_THRESHOLD) begin
            compare_to_threshold=1;
        end
        else begin
            compare_to_threshold=0;
        end
    end   
endfunction
//function for getting orring of 3
function get_max;
    input x1,x2,x3;
    begin
        get_max = x1 | x2 | x3;
    end
endfunction
endmodule //yolo_post
