# Group-elk-submission

ELK STACK

We are creating an ELK stack that will run on a script. 
An ELK stack is a combination of Elasticsearch, logstash, and kibana 
essentially comunicating with eachother to operate on a higher level of showing what
data is being transported through the network.
____________________________________________________________________________________

#VIEW THIS README IN CODE, NOT PREVIEW

##Needed folders/files
- "elk_env" 

##Steps to start up ELK, run all commands seperately 

```

###DOWNLOAD pwgen
sudo dnf install pwgen

###1 First clone the repo through SSH
git clone git@github.com:Steelgatellc-ga/Group-elk-submission.git 

###2 CD into the repo
cd Group-elk-submission

###3 list out all of the files in the repo
ls -a 

###4 run the script
./group_elk.sh

###5 check to see if all containers are up and running  
podman ps

###6 check to see if logstash is up and CONNECTS to Elasticsearch successfully
podman logs logstash01

###7 Send a test log to verify working ELK stack
echo '{"message": "Hello from TCP test", "level": "info", "timestamp": "'$(date -Is)'"}' | nc localhost 50000

###8 Copy enrollment token from elk_env
cat elk_env

###9 GO to the browser and search in the address bar "http://localhost:5601/"

###10 Paste the token

###11 Copy bin/kibana-verification-code

###12 GO back to your terminal and command
podman exec -it kib01 bin/kibana-verification-code

###13 Copy the 6 digets and paste it back in the verification box

###14 Get the credentials elk_env for ELASTIC_USERNAME and ELASTIC_PASSWORD
cat elk_env 

###15 Click on the 3 bars on the top left, go to "Stack Management", Then to "Index Management"

###16 Here your log should appear

#HELP
### If you have any questions or issues with the repo please refer to our issue page. Thank You!
```
