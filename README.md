# Pure-Hardware YOLO-Inference <span><a href= '#paper'>[1]</a></span>
#### If you find this repo useful don't forget to give a star.
#### Don't forget to cite <span><a href= '#paper'>the work</a></span> whenever you use it. 
## Introduction:
THis repository is for YOLO inference on FPGA without any interaction from software through utilizing FINN framework, Vivado and Verilog HDL. The target board used was ZCU102. However, Pynq-Z2 was also used for testing the algorithm.
## Project flow:
#### Any input to the system must be 416 x 416 RGB image
1- You have firstly to train your network and retrieve the .pt weights file<br/>
I have used dataset for cars detection in this project<br/>
2- export your pre-trained model using file 1<br/>
3- Generate your ip whether through file 2 or file 3 from the following notebooks<br/>
4- Verify the flow steps through file 4<br/>
5- Design your block diagram in Vivado as in file 6 after adding file 5 to your project sources<br/>
6- Simulate your system by Vivado simulator using file 7 (check the signals name are the same as you have in your project)<br/>
## Files Description:
<h3> <a href='https://github.com/m7md5303/pure-hardware-YOLO-inference/blob/main/export.ipynb'> 1-export.ipynb </a> </h3>
<p> The first step needed after the training process is exporting the model into QONNX format. You will need the best.pt file to instantiate a pre-trained model firstly before the export.</p>
<p>The used YOLO model in this repository can be found in this <span><a href='https://github.com/sefaburakokcu/finn-quantized-yolo.git'>repo</a></span></p>

<h3> <a href='https://github.com/m7md5303/pure-hardware-YOLO-inference/blob/main/EA_lpyolo.ipynb'> 2-EA_lpyolo.ipynb </a> </h3>
<p> This is the main notebook in the project. It is responsible for generating the streaming dataflow ip (NN Accelerator) using FINN. You can find explained details in the markdown cells. Note that the notebook will be static if you are viewing through GitHub. You will need firstly to install FINN to be able to run it. The folding values in this notebook were set as in this <span><a href='https://github.com/sefaburakokcu/finn-quantized-yolo.git'>repo</a></span>.</p>

<h3> <a href='https://github.com/m7md5303/pure-hardware-YOLO-inference/blob/main/EA_lpyolo-pynq.ipynb'> 3-EA_lpyolo-pynq.ipynb </a> </h3>
<p> This notebook is almost the same as the previous one. However, I reduced the paralleslism in the network (folding) in order to decrease the needed resources and to be able to deploy it on PYNQ-Z2. The goal from this is visualizing the final output through the PYNQ Jupyter Notebook.</p>

<h3> <a href='https://github.com/m7md5303/pure-hardware-YOLO-inference/blob/main/Y_Verification.ipynb'> 4-Y_Verification.ipynb </a> </h3>
<p> This notebook is for the verifying of the internally generated ONNX graphs during the flow before the hardware conversion. This is done through comparing the output values with the original model. The main function used was the built-in FINN function (execute_onnx)</p>

<h3> <a href='https://github.com/m7md5303/pure-hardware-YOLO-inference/blob/main/yolo_Post.v'> 5-Post-Processing Block</a> </h3>
<p> This Verilog module is the main core of the hardware inference. It post-processes the RAW output from the YOLO network without any interaction from the software. The used data was only related to the class score and objectness score where there was no care about the position of the object inside its grid since it was sufficient to know whether the 32 x 32 pixel-grid has an object or no.</p>

<h3> <a href='https://github.com/m7md5303/pure-hardware-YOLO-inference/blob/main/Sys%20bd.png'> 6-System Block Design </a> </h3>
<p> This how the system should look like for simulation. It is also possible if you want to integrate it in your project or use it only as a standalone system. Just take care of the IO mapping to generate your bitstream properly</p>

<h3> <a href='https://github.com/m7md5303/pure-hardware-YOLO-inference/blob/main/testbench.sv'> 7-TestBench </a> </h3>
<p> This is a simple testbench that simulates the system using the AXI-Stream protocol with giving two consequent images loaded from the two memory files. The image must be 416 x 416 pixels for correct results. THe pixel values must have be represented in hexadecimal format as well.</p>

<h2 id="paper">Reference:</h2>
<ul>
  <li>
    "Pure-Hardware YOLO-Inference via FPGAs," in Conf. ICECS'25, Marrakesh, Accepted manuscript-in press
  </li>
</ul>
