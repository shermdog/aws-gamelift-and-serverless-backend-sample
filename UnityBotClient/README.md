# Bot Client Implementation for testing the Unity deployment

This additional component is designed to help test the Unity deployment option by running headless client bots on AWS Fargate, a fully managed serverless platform for running containerized applications.

# Setup

You need to have the backend, GameLift resources and client all set up and deployed first.

1. Make sure you have [Docker](https://docs.docker.com/get-docker/) installed and running on your system
2. Make sure you have AWS CLI configured on your system
3. Set your AWS Account ID in `configuration.sh`
3. Open the GameLiftExampleUnityProject and configure bots by selecting *Gamelift -> SetAsBotClientBuild*. You can test run a bot locally.
4. Build the bot client by selecting *Gamelift -> BuildLinuxBotClient*. Select the folder *UnityBotCLient/Build* as the output folder
5. Run `./buildSetupAndRunBots.sh` to start the bots. Modify the script if you want to change the bot count. Each Fargate Task will run 4 bots, so the default configuration 10 will run 40 bots on a continuous fashion as a Fargate Service, until you terminate them. The script will
  * Create an ECR repository
  * Build the container from your prebuilt binary and push it to the repository
  * Deploy the stack `gamelift-example-bot-resources.yaml` that creates a VPC, ECS Cluster and an ECS Service that hots your bots. Each Task in the service runs 4 bots and you can configure the amount of Tasks in the script.
6. When you're done, run `./destroyBots.sh` to destroy the whole infrastructure for the bots

The bots will be deployed to your defined home region but you could easily modify the script to deploy the stack to multiple regions to better test latency-based matchmaking and multi-region fleets.
