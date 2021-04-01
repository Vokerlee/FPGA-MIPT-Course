# D Flip-Flop realization

This is the first project of FPGA course, written in Verilog language.

## How it works

First of all, `SR Latch` is considered to understand how it works.
In short, here is it:

<img src="https://i.stack.imgur.com/HKd5r.jpg" alt="drawing" width="500"/>

S is the set-signal, R is the reset signal. Q - the output signal. `SR Latch` is used to store the bit of information. As we can see, when two input signal are equal to 1, the metastability appears - the next state of Q signal can be both 1 and 0. 

So the new scheme `D Latch` was created: 

<img src="https://community.cadence.com/cfs-file/__key/telligent-evolution-components-attachments/00-27-00-00-00-03-00-42/04181.png" alt="drawing" width="700"/>

Now everything is cool. Metastable state is excluded. 

But this scheme can get bit-information only by D signal 
