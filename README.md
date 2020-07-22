## WIP

#### About
Small ruby utility which gives you EC2 console view from your command line so you don't have to switch from your workstation to browser.
Extremely useful if you have a lot of servers.
Also saves from getting timed out and relogging in multiple time.

#### Setup
Use the credential.yml.example to create a credentials.yml and put your AWS key and id in there.

#### Run
You need to pass an environment and a tag name
* ruby runner.rb 'dev' 'logstash'
