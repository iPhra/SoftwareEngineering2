How to turn on the server and update it with new code:

1) Head to https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#Instances:sort=desc:statusChecks

2) Right click on the Instance, go on Instance State, and press Start

3) Wait until you get 2/2 check

4) Open terminal on Mac and insert:  
ssh -i "~/.ssh/d4h.pem" ubuntu@ec2-52-57-95-222.eu-central-1.compute.amazonaws.com

5) Type in the bash:  
cd LorenzoMolteniNegri && git pull && pm2 restart Data4Help