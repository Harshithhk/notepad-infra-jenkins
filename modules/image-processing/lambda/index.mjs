import { ECSClient, RunTaskCommand } from "@aws-sdk/client-ecs";

const ecs = new ECSClient({});

/**
 * SQS event → one or more records
 * Each record.body should be a JSON string representing the job payload
 */
export const handler = async (event) => {
  console.log("Received event from SQS:", JSON.stringify(event));

  const clusterArn = process.env.CLUSTER_ARN;
  const taskDefArn = process.env.TASK_DEF_ARN;
  const subnets = process.env.SUBNETS.split(",");
  const securityGroup = process.env.SECURITY_GROUP;

  const promises = event.Records.map(async (record) => {
    const body = record.body;
    let payload;

    try {
      payload = JSON.parse(body);
    } catch (err) {
      console.error("Failed to parse SQS message body as JSON:", body, err);
      // You can decide to throw here to trigger redrive / DLQ
      return;
    }

    console.log("Launching ECS task with payload:", payload);

    const cmd = new RunTaskCommand({
      cluster: clusterArn,
      taskDefinition: taskDefArn,
      launchType: "FARGATE",
      networkConfiguration: {
        awsvpcConfiguration: {
          subnets,
          securityGroups: [process.env.WORKER_SECURITY_GROUP],
          assignPublicIp: "ENABLED",
        },
      },
      overrides: {
        containerOverrides: [
          {
            name: process.env.SERVICE_NAME || "image-processing",
            environment: [
              {
                name: "JOB_PAYLOAD",
                value: JSON.stringify(payload),
              },
            ],
          },
        ],
      },
    });

    const resp = await ecs.send(cmd);
    console.log("RunTask response:", JSON.stringify(resp));
  });

  await Promise.all(promises);

  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Tasks launched" }),
  };
};
