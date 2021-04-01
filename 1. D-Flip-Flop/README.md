# D Flip-Flop realization

This is the first project of FPGA course, written in Verilog language.

## How it works

First of all, `SR Latch` is considered to understand how it works.
In short, here is it:

<img src="https://steamuserimages-a.akamaihd.net/ugc/263836971403353556/F6AAAC5B777F2732937EB1D7FF96BCBA571C8486/" alt="drawing" width="600"/>

S is the set-signal, R is the reset signal. Q - the output signal. `SR Latch` is used to store the bit of information. As we can see, when two input signal are equal to 1, the metastability appears - the next state of Q signal can be both 1 and 0. 

So the new scheme `D Latch` was created: 

<img src="https://progi.pro/media/main/e0/89/d5/e089d5e9f10f9a271a412eb4a18cd62f.png" alt="drawing" width="600"/>

Now everything is cool. Metastable state is excluded. 
