# TightVNC auto setup script

### What's this?

The main body is an autoit script. It import vnc register file to your Windows system. Then run TightVNC server, wait client connect in.

### How it works?

The 1st step. WinRAR self-extract package put some file to your temp folder and run autoit script.

The 2nd step. Autoit script run TightVNC server and config it to listening client connect.

In 2nd step. It

1. read client ip address form config.ini.
2. import vnc register file.
3. send growl notification if client is mac os x (Not Yet Implementation) 
4. connect to vnc viewer if client run vnc viewer as listening mode.

### Thanks

TightVNC - <http://www.tightvnc.com/>

AutoIt3 - <http://www.autoitscript.com/site/autoit/>
